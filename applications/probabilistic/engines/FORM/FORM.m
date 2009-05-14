function result = FORM(stochast, varargin)
%FORM  routine for First Order Reliability Method (FORM)
%
% Routine to perform the probabilistic First Order Reliability Method
%   
% syntax:
% result = FORM(stochast, varargin)
%
% input:
% stochast = structure with stochastic variables
% varargin = series of keyword-value pairs to set properties
%
% output:
% result = structure with settings, input and output
%
% See also setProperty exampleStochastVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% settings
% defaults
OPT = struct(...
    'maxiter', 50,...        % maximum number of iterations
    'DerivativeSides', 1,... % 1 or 2 sided derivatives
    'startU', 0,...          % start value for elements of u-vector
    'du', .3,...             % step size for dz/du / Perturbation Value
    'Resistance', 0,...      % Resistance value(s) to be (optionally) used in z-function
    'epsZ', .01,...          % stop criteria for change in z-value
    'epsBeta', .01,...       % stop criteria for change in Beta-value
    'Relaxation', .25,...    % Relaxation value
    'P2xFunction', @P2x,...  % Function to transform P to x
    'x2zFunction', @x2z,...  % Function to transform x to z
    'variables', {{}} ...    % aditional variables to use in x2zFunction
    );
% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

getdefaults('stochast', exampleStochastVar, 0);

%% series of FORM calculations
% in case of multiple Resistance-values
if ~isscalar(OPT.Resistance)
    % a series of z-criteria
    if issorted(OPT.Resistance)
        startU = OPT.startU; % startU for the first FORM run
        for iFORM = 1:length(OPT.Resistance)
            result(iFORM) = FORM(stochast, varargin{:},...
                'Resistance', OPT.Resistance(iFORM),...
                'startU', startU); %#ok<AGROW>
            % base startU for the next FORM run on the latest one
            startU = result(iFORM).Output.u(end,:);
        end
        return
    else
        error('FORM:criteriaZnotsorted', 'The series of z-criteria should be sorted')
    end
end

%%
% input
Nstoch = length(stochast); % number of stochastic variables
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));

% define du
[id_low id_upp] = deal(NaN(1,Nstoch));
if OPT.DerivativeSides == 1
    % one sided derivatives
    du = [eye(Nstoch)*OPT.du; zeros(1,Nstoch)];
    du([~active false],:) = [];
    id_low(active) = deal(size(du,1));
    id_upp(active) = 1:sum(active);
elseif OPT.DerivativeSides == 2
    % two sided derivatives
    du = [eye(Nstoch)*-OPT.du/2; eye(Nstoch)*OPT.du/2; zeros(1,Nstoch)];
    du([~active ~active false],:) = [];
    id_low(active) = 1:sum(active);
    id_upp(active) = sum(active)+(1:sum(active));
else
    error('OPT.DerivativeSides should be either 1 or 2')
end
rel_ids = {id_low id_upp};

% predefine series of u-combinations
if length(OPT.startU) == Nstoch
    startU = OPT.startU;
elseif isscalar(OPT.startU)
    startU = ones(1,Nstoch)*OPT.startU;
else
    error('FORM:startU', 'The parameter "startU" should be either a scalar or a vector with the length of the # stochasts')
end
[u id_low id_upp] = prescribeU(startU, [], du, OPT.Relaxation, rel_ids);

%% initialise FORM-procedure
NextIter = true;            % condition to go to next iteration
Converged = false;          % logical to indicate whether convergence criteria have been reached
maxIterReached = false;     % logical to indicate whether maximum number of iteration has been reached
Calc = 0;                   % number of calculations so far
Iter = 0;                   % number of iterations so far
maxiter = OPT.maxiter;      % maximum number of iterations
beta = NaN(OPT.maxiter,1);  % preallocate beta

%% start FORM iteration procedure
while NextIter
    Iter = Iter + 1;
    Calc = Calc(end)+1:size(u,1); % identifier of series of calculations to perform at once
    
    % transform u to P
    P(Calc,:) = norm_cdf(u(Calc,:), 0, 1); %#ok<AGROW>
    
    % transform P to x
    x(Calc,:) = feval(OPT.P2xFunction, stochast, P(Calc,:)); %#ok<AGROW>
    
    if any(any(~isfinite(x(Calc,:))))
        error('FORM:xBecameNonFinite', 'One or more x-values became Inf or NaN')
    end
    
    % derive z based on x
    z(Calc,1) = feval(OPT.x2zFunction, x(Calc,:), {stochast.Name}, OPT.Resistance,...
        OPT.variables{:});  %#ok<AGROW> % bepaal z(u) uit x(u)

    if Converged || maxIterReached
        % exit while loop
        break
    else
        % bepaal de afgeleide van z naar de u-waarden
        dzdu = zeros(1,Nstoch);
        sts = 1:Nstoch;
        for st = sts(active)
            % bepaal dz/du for the active variables
            dzdu(st) = (z(id_upp(st)) - z(id_low(st)))/(OPT.du);
        end

        % lineariseer de z-functie in u:
        % z(u) = B + A(1)*u(1) + ... + A(n)*u(n)
        % neem coefficienten A(i) gelijk aan -dz/du(i)
        A = dzdu;
        B = z(Calc(end)) - A*u(Calc(end),:)';

        % normaliseer bovenstaande z-functie door te delen door de wortel uit
        % de som van de kwadraten van A(i).  De genormaliseerde z-functie is
        % dan als volgt: z_norm(u) = beta + alpha(1)*u(1) + ... + alpha(n)*u(n)
        A_abs = sqrt(A*A');
        alpha = A/A_abs;
        beta(Iter) = B/A_abs; %#ok<AGROW>

        % Toetsen op convergentie: is z dicht genoeg bij 0?
        criteriumZ = abs(z(Calc(end))/A_abs) < OPT.epsZ;
        criteriumBeta = OPT.epsBeta == Inf ||...
            Iter>1 && abs(diff(beta(Iter-1:Iter)));
        if criteriumZ && criteriumBeta
            % convergence criteria have been met
            Converged = true;
        elseif Iter >= maxiter
            % maximum number of iteration has been reached
            maxIterReached = true;
        end
        if Converged || maxIterReached
            break
%             % carry out one more calculation using a relaxation value of 1
%             % ?? is this useful? (this is what Prob2B does)
%             tempu = prescribeU(-alpha.*beta(end), u, active, du, 1);
%             u = [u; tempu(end,:)]; %#ok<AGROW>
        else
            % derive a new series of u-values for the next iteration
            [u id_low id_upp] = prescribeU(-alpha.*beta(Iter), u, du, OPT.Relaxation, rel_ids);
        end
    end
end

%% write results to structure
result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
        'Converged', Converged,...
        'alpha', alpha,...
        'Beta', beta(find(~isnan(beta), 1, 'last')),...
        'P_f', 1-norm_cdf(beta(Iter), 0, 1),... % probability of failure
        'Iter', Iter,...
        'Calc', size(u,1),...
        'u', u,...
        'P', P,...
        'x', x,...
        'z', z,...
        'designpoint', [] ...
    ));

designpoint = cell(1, 2*size(x,2));
designpoint(1:2:length(designpoint)) = {stochast.Name};
designpoint(2:2:length(designpoint)) = mat2cell(x(end,:), 1, ones(1,size(x,2)));
result.Output.designpoint = struct(designpoint{:});

%% subfunction to predefine a series of u-values
function [u id_low id_upp] = prescribeU(currentU, u, du, Relaxation, rel_ids)
Calc = size(u,1);
if ~isempty(u)
    currentU = diff([u(end,:); currentU])*Relaxation + u(end,:);
end
u = [u; repmat(currentU, size(du,1), 1) + du];

if any(any(isnan(u)))
    error('FORM:ubecameNaN', 'One or more u-values became NaN')
end

id_low = Calc + rel_ids{1};
id_upp = Calc + rel_ids{2};
