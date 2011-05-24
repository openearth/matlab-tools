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
%
%   Syntax:
%   result = MC(stochast)
%   result = MC(..
%       'stochast', stochast,...
%       'NrSamples', 1000);
%
%   Input:
%   varargin  = series of propertyName-propertyValue pairs
%
%   Output:
%   result = structure with 'settings', 'Input' and 'Output'. 'Input'
%            contains all stochastic variable information. Other defaults
%            and input is stored in the 'settings' field. The 'Output'
%            field contains the following information:
%               P_f : probability of failure
%               Pexc : probability of exceedance for each individual
%               realisation
%               Pcor : correction factor (only plays a role in importance
%               sampling applications)
%               Calc : number of calculations (equal to 'NrSamples' in
%               settings-field)
%               idFail : boolean indicating which calculations failed
%               u : values in the normally distributed spaces (for each
%               sample and each variable)
%               P : probabilities of non-exceedance for each of the
%               individual variable-sample combinations
%               x : actual variable values (each row corresponds to one
%               realisation)
%               z : result of z-function for each realisation (negative
%               z-values are considered as failure, corresponding to idFail)
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

%% settings

varargin = prob_checkinput(varargin{:});

% defaults
OPT = struct(...
    'stochast',     struct(),   ...     % stochast structure
    'x2zFunction',  @x2z,       ...     % Function to transform x to z
    'variables',    {{}},       ...     % aditional variables to use in x2zFunction
    'method',       'matrix',   ...     % z-function method 'matrix' (default) or 'loop'
    'NrSamples',    1e2,        ...     % number of samples
    'IS',           struct(),   ...     % sampling structure
    'P2xFunction',  @P2x,       ...     % function to transform P to x
    'seed',         NaN,        ...     % seed for random generator
    'result',       struct(),   ...     % input existing result structure to re-calculate existing samples
    ...
    ... deprecated importance sampling parameters
    ...
    'ISvariable',   '',         ...     % "importance sampling" variable
    'W',            1,          ...     % "(simple) importance sampling" factor
    'f1',           Inf,        ...     % "(advanced) importance sampling" upper frequency boundary
    'f2',           0           ...     % "(advanced) importance sampling" lower frequency boundary
);

OPT = setproperty(OPT, varargin{:});

% convert old to new IS input format
OPT = prob_is_convert(OPT);

%% parse result as input

result_as_input = ~isempty(fieldnames(OPT.result));

if result_as_input
    newOPT          = OPT.result.Settings;
    newOPT.stochast = OPT.result.Input;
    newOPT.result   = struct();
    
    OPT = newOPT;
end

%% start monte carlo routine

stochast    = OPT.stochast;
IS          = OPT.IS;

% determine active stochasts
active      = ~cellfun(@isempty, {stochast.Distr}) &     ...
              ~strcmp('deterministic', cellfun(@func2str, {stochast.Distr}, 'UniformOutput', false));

if result_as_input
    P       = OPT.result.Output.P;
    P_corr  = OPT.result.Output.P_corr;
    P_exc   = OPT.result.Output.P_exc;
    x       = OPT.result.Output.x;
else
    if ~isnan(OPT.seed)
        rand('seed', OPT.seed)
    end
    
    % draw random numbers
    P(:, active)    = rand(OPT.NrSamples, sum(active));
    P(:,~active)    = .5;
    
    % perform importance sampling
    [P P_corr]      = prob_is(stochast, IS, P);
    
    % determine probability of exceedance
	P_exc           = prod(1-P(:,active),2);
    
    % transform P to x
    x               = feval(OPT.P2xFunction, stochast, P);
end

% determine failures
z           = prob_zfunctioncall(OPT, stochast, x);
idFail      = z < 0;

% determine probability of failure
P_f         = sum(idFail.*P_corr)/OPT.NrSamples;
P_f(P_f==0) = NaN;

%% create result structure

result = struct(...
    'settings',     rmfield(OPT, {'stochast' 'result'}),    ...
    'Input',        stochast,                               ...
    'Output',       struct(                                 ...
                        'P_f',      P_f,                    ...
                        'P_exc',    P_exc,                  ...
                        'P_corr',   P_corr,                 ...
                        'Calc',     size(z,1),              ...
                        'idFail',   idFail,                 ...
                        'u',        norm_inv(P, 0, 1),      ...
                        'P',        P,                      ...
                        'x',        x,                      ...
                        'z',        z                       ...
                    )                                       ...
);