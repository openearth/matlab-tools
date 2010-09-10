function result = FORM(varargin)
%FORM  routine for First Order Reliability Method (FORM)
%
% Routine to perform the probabilistic First Order Reliability Method
%   
% syntax:
% result = FORM(varargin)
%
% input:
% varargin = series of keyword-value pairs to set properties
%
% output:
% result = structure with settings, input and output
%
% See also setproperty exampleStochastVar

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

% the following few lines are meant for backward compatibility with the
% situation where the first input argument was always the stochast
% structure
first_input_is_stochast = nargin > 0 && isstruct(varargin{1});
if first_input_is_stochast
    varargin = [{'stochast'} varargin];
end

% defaults
OPT = struct(...
    'stochast', struct(),... % stochast structure
    'maxiter', 50,...        % maximum number of iterations
    'method', 'matrix',...   % z-function method 'matrix' (default) or 'loop'
    'DerivativeSides', 1,... % 1 or 2 sided derivatives
    'startU', 0,...          % start value for elements of u-vector
    'du', .3,...             % step size for dz/du / Perturbation Value
...    'Resistance', 0,...      % NOT IN USE ANY MORE Resistance value(s) to be (optionally) used in z-function
    'epsZ', .01,...          % stop criteria for change in z-value
    'maxdZ', 0.1,...         % second stop criterion for change in z-value
    'epsBeta', .01,...       % stop criteria for change in Beta-value
    'Relaxation', .25,...    % Relaxation value
    'x2zFunction', @x2z,...  % Function to transform x to z
    'variables', {{}} ...    % aditional variables to use in x2zFunction
    );

% Resistance no longer used as separate propertyName-propertyValue pair
if any(strcmp(varargin(1:2:end), 'Resistance'))
    error('FORM:Resistance', 'Resistance no longer used as separate propertyName-propertyValue pair; include this in "variables" and modify z-function')
end

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if ~ismember(OPT.DerivativeSides, 1:2)
    error('"DerivativeSides" should be either 1 or 2')
end

%% series of FORM calculations
Resistance = [];
if any(cellfun(@ischar, OPT.variables))
    char_id = find(cellfun(@ischar, OPT.variables));
    Resistance_id = char_id(ismember(OPT.variables(char_id), 'Resistance')) + 1;
    if ~isempty(Resistance_id)
        Resistance = OPT.variables{Resistance_id};
    end
end

% in case of multiple Resistance-values
if ~isempty(Resistance) && ~isscalar(Resistance)
    variables_id = find(ismember(varargin(1:2:end), 'variables'))*2;
    % a series of z-criteria
    if issorted(Resistance)
        startU = OPT.startU; % startU for the first FORM run
        modified_varargin = varargin;
        for iFORM = 1:length(Resistance)
            modified_varargin{variables_id}{Resistance_id} = Resistance(iFORM);
            result(iFORM) = FORM(modified_varargin{:},...
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
stochast = OPT.stochast;

if ~isfield(stochast, 'propertyName')
    for istochast = 1:length(stochast)
        stochast(istochast).propertyName = false;
    end
end

% input
Nstoch = length(stochast); % number of stochastic variables
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));

% define du
[id_low id_upp] = deal(NaN(1,Nstoch));
du = zeros(sum(active)*OPT.DerivativeSides+1, Nstoch);
if OPT.DerivativeSides == 1
    % one sided derivatives
    du(1:sum(active), active) = eye(sum(active)) * OPT.du;
    id_low(active) = deal(size(du,1));
    id_upp(active) = 1:sum(active);
elseif OPT.DerivativeSides == 2
    % two sided derivatives
    du(1:sum(active)*OPT.DerivativeSides, active) = [eye(sum(active)) * -OPT.du/2; eye(sum(active)) * OPT.du/2];
    id_low(active) = 1:sum(active);
    id_upp(active) = sum(active)+(1:sum(active));
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
Calc = 0;                   % number of calculations so far
Iter = 0;                   % number of iterations so far
[z, beta, criteriumZ, criteriumZ2, criteriumBeta] = deal(NaN(OPT.maxiter,1));  % preallocate 
[P x] = deal(NaN(OPT.DerivativeSides*sum(active)*OPT.maxiter+1,Nstoch));

%% start FORM iteration procedure
while NextIter
    Iter = Iter + 1;
    % check whether current iteration is the first one
    FirstIter = Iter == 1;
    % check whether current iteration exceeds the maximum number of
    % iterations
    maxIterReached = Iter >= OPT.maxiter;
    % define identifier of series of calculations to perform at once
    Calc = Calc(end)+1 : size(u,1);
    
    % transform u to P
    P(Calc,:) = norm_cdf(u(Calc,:), 0, 1);
    
    % transform P to x
    x(Calc,:) = P2x(stochast, P(Calc,:));
    
    if any(any(~isfinite(x(Calc,:))))
        error('FORM:xBecameNonFinite', 'One or more x-values became Inf or NaN')
    end
    
    % derive z based on x
    [z(Calc,1) OPT] = prob_zfunctioncall(OPT, stochast, x(Calc,:));
    
    if Converged
        % extra check for convergence
        Converged = abs(z(Calc(end))) < OPT.maxdZ / OPT.Relaxation;
        
        % exit while loop
        break
    end
    
    % derive dz/du for each of the active u-values
    dzdu = zeros(1,Nstoch);
    sts = 1:Nstoch;
    for st = sts(active)
        % derive dz/du for the active variables
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
    beta(Iter) = B/A_abs;
    
    % check for convergence
    criteriumZ(Iter) = abs(z(Calc(end)) / A_abs / OPT.epsZ);
    criteriumZ2(Iter) = abs(z(Calc(end)) / OPT.maxdZ);
    if ~FirstIter
        criteriumBeta(Iter) = abs(diff(beta(Iter-1:Iter)) / OPT.epsBeta);
    end
    
    % check whether convergence criteria have been met
    Converged = ~FirstIter &&...
        all([criteriumZ(Iter-1:Iter); criteriumBeta(Iter-1:Iter); criteriumZ2(Iter-1:Iter)] < 1);
    
    if maxIterReached && ~Converged
        break
    end
    
    if Converged
        % carry out one more calculation using a relaxation value of 1
        % to make u = -alpha*beta, otherwise the final u solution is
        % not consistent with alpha and beta
        du = zeros(size(stochast));
    end
    
    % derive a new series of u-values for the next iteration
    [u id_low id_upp] = prescribeU(-alpha.*beta(Iter), u, du, OPT.Relaxation, rel_ids);
end

%% write results to structure
indend = find(~isnan(beta), 1, 'last');
betas = beta(1:indend);
beta = beta(indend);
P_f = 1-norm_cdf(beta, 0, 1); % probability of failure
result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
        'Converged', Converged,...
        'alpha', alpha,...
        'Beta', beta,...
        'P_f', P_f,...
        'Iter', Iter,...
        'Calc', size(u,1),...
        'u', u,...
        'P', P(1:max(Calc),:),...
        'x', x(1:max(Calc),:),...
        'z', z(1:max(Calc),:),...
        'Betas', betas, ...
        'designpoint', [] ...
    ));

designpoint = cell(1, 2*size(x,2));
designpoint(1:2:length(designpoint)) = {stochast.Name};
designpoint(2:2:length(designpoint)) = mat2cell(x(end,:), 1, ones(1,size(x,2)));
result.Output.designpoint = struct(designpoint{:},...
    'finalP', result.Output.P(end,:),...
    'finalU', result.Output.u(end,:));

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