function result = MC(varargin)
%MC  perform Monte Carlo simulation
%
%   This routine executes a Monte Carlo simulation. By default, the crude
%   Monte Carlo method is chosen. The input is parsed by
%   propertyname-propertyvalue pairs. At least the 'stochast' and the
%   'x2zFunction' are required as input. The stochast structure should
%   contain the fields 'Name', 'Distr' and 'Params'. The x2zFunction should
%   have the input arguments 'P', 'samples' (structure) and optionally
%   'Resistance' followed by more optional arguments (varargin).
%   Apart from the crude Monte Carlo, also two "importance sampling"
%   methods are available. The simple importance sampling can create more
%   extreme situations by a multiplication factor W which is applied to one
%   specific stochastic variable. Please note that with this method the
%   applicability range of the simulation is moved to the area of smaller
%   probabilities, implying that the area of large probabilities is less
%   accurate. The advanced importance sampling method samples for one
%   stochastic variable uniformly over the x-space, resulting in relatively
%   many samples in the tails of the distribution. This results in a good
%   representation of the probabilities over the whole probability range
%   with a limited number of samples.
%
%   Syntax:
%   result = MC(stochast)
%   result = MC(..
%       'stochast', stochast,...
%       'NrSamples', 1000);
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   MC
%
%   See also exampleStochastVar

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
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

%%
%{
% example of MC
result = MC(exampleStochastVar,...
 'Resistance', 25:5:100);

% example of MC with simple importance sampling
result = MC(exampleStochastVar,...
 'Resistance', 25:5:100,...
 'ISvariable', 'WL_t',...
 'W', 100);

% example of MC with advanced importance sampling
result = MC(exampleStochastVar,...
 'Resistance', 25:5:100,...
 'ISvariable', 'WL_t',...
 'f1', 1,...
 'f2', 1e-6);
%}

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
    'x2zFunction', @x2z,...  % Function to transform x to z
    'method', 'matrix',...   % z-function method 'matrix' (default) or 'loop'
    'variables', {{}},...    % aditional variables to use in x2zFunction
    'NrSamples', 1e2,...     % number of samples
    'ISvariable', '',...     % "importance sampling" variable
    'W', 1,...               % "(simple) importance sampling" factor
    'f1', Inf,...            % "(advanced) importance sampling" upper frequency boundary
    'f2', 0,...              % "(advanced) importance sampling" lower frequency boundary
    'Resistance', 0,...      % NOT IN USE ANY MORE Resistance value(s) to be (optionally) used in z-function       
    'P2xFunction', @P2x,...  % Function to transform P to x
    'seed', NaN,...          % seed for random generator
    ...
    'result', struct() ...   % input existing result structure to re-calculate existing samples
    );
% overrule default settings by propertyName-propertyValue pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

% Resistance no longer used as separate propertyName-propertyValue pair
if ~isequal(OPT.Resistance, 0)
    error('MC:Resistance', 'Resistance no longer used as separate propertyName-propertyValue pair; include this in "variables" and modify z-function')
end

%% check whether result is parsed as input
result_as_input = ~isempty(fieldnames(OPT.result));
if result_as_input
    % put stochast structure into the input field of result
    OPT.stochast = OPT.result.Input;
    % overwrite fields of OPT with 
    for f = fieldnames(OPT.result.settings)'
        if ~ismember(f, {'stochast' 'result'})
            OPT.(f{1}) = OPT.result.settings.(f{1});
        end
    end
end

%%
stochast = OPT.stochast;

if ~isfield(stochast, 'propertyName')
    for istochast = 1:length(stochast)
        stochast(istochast).propertyName = false;
    end
end

Nstoch = length(stochast); % number of stochastic variables

% active
active = ~cellfun(@isempty, {stochast.Distr}) &...
    ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr},...
    'UniformOutput', false));


if result_as_input
    P = OPT.result.Output.P;
    p_correctie = OPT.result.Output.Pcor;
    Pexc = OPT.result.Output.Pexc;
    x = OPT.result.Output.x;
else
    if OPT.f1 < Inf && OPT.f2 > 0 || OPT.W ~= 1
        % in case of importance sampling, check whether specified variable is
        % available
        idIS = strcmp({stochast.Name}, OPT.ISvariable);
        if all(~idIS)
            error([OPT.ISvariable ' not found'])
        end
        if any(idIS & ~active)
            error('Importance Sampling variable should be active')
        end
    end
    
    % get random samples of P
    if ~isnan(OPT.seed)
        rand('seed', OPT.seed)
    end
    
    P = rand(OPT.NrSamples, Nstoch);
    
    % f2 should be smaller than f2
    if OPT.f1 < OPT.f2
        [OPT.f1 OPT.f2] = deal(OPT.f2, OPT.f1);
    end
    
    if OPT.f1 < Inf && OPT.f2 > 0
        
        Iplus = 1;
        NaNsinP = true;
        
        while NaNsinP
            Iplus = Iplus + 1;
            maxpgrid = -log10(OPT.f2) + Iplus;
            pgrid = (0.01:0.01:maxpgrid)';
            Ponder = unique([flipud(0.5*(10.^-pgrid)); (0.489:0.001:0.511)';  (1-0.5*10.^-pgrid)]);
            
            % derive probability distribution and probability density of H as
            % table
            % this distribution is needed to derive the correction coefficient
            % which essential for Importance Sampling
            cdf = feval(stochast(idIS).Distr, Ponder, stochast(idIS).Params{:});
            
            [xcentr dPdx] = cdf2pdf(Ponder, cdf(:,end));
            
            % find boundaries for sampling of the Importance Sampling variable
            Pgrens = exp(-[OPT.f1 OPT.f2]); % probability of non-exceedance boundaries
            Hgrens = feval(stochast(idIS).Distr, Pgrens', stochast(idIS).Params{:});% boundaries from CDF
            Hgrens = [0.9; 1.1].*Hgrens(:,end); % make boundaries a bit wider, because of possibly correlated other variables
            
            % sample Importance Sampling variable
            H = Hgrens(1) + P(:,idIS)*(Hgrens(2)-Hgrens(1));
            
            P(:,idIS) = interp1(cdf(:,end), Ponder, H);
            
            if all(~any(isnan(P)))
                NaNsinP = false;
            end
        end
        % correction coefficient for bias in Importance Sampling variable
        p_correctie = interp1(xcentr, dPdx, H);   % PDF Importance Sampling variable
        p_correctie = repmat((Hgrens(2)-Hgrens(1))*p_correctie, 1, length(OPT.Resistance));
    else
        p_correctie = 1;
    end
    
    % set the P-values in the columns of the non-active variables to .5
    P(:,~active) = .5;
    
    if OPT.W ~= 1
        % change P values of the IS variable to W times as extreme
        P(:,idIS) = 1-(1-P(:,idIS))/OPT.W;
    end
    
    % transform P to x
    x = feval(OPT.P2xFunction, stochast, P);
    
    % derive the probability of exceedance for each realisation
    %TODO: check how to do this for importance sampling
    Pexc = prod(1-P(:,active),2);
end

% derive z based on x
[z OPT] = prob_zfunctioncall(OPT, stochast, x);

idFail = z < 0;

P_f = sum(idFail.* p_correctie)/(OPT.NrSamples*OPT.W);
P_f(P_f == 0) = deal(NaN);

% remove fields from OPT structure
OPT = rmfield(OPT, {'stochast' 'result'});

% prepare result structure
result = struct(...
    'settings', OPT,...
    'Input', stochast,...
    'Output', struct(...
        'P_f', P_f,...
        'Pexc', Pexc,...
        'Pcor', p_correctie, ...
        'Calc', size(z,1),...
        'idFail', idFail,...
        'u', norm_inv(P, 0, 1),...
        'P', P,...
        'x', x,...
        'z', z ...
    ));