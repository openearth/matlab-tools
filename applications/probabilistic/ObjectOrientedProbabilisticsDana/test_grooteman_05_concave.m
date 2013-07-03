%function result = test_grooteman_05_concave(varargin)
% PROB_QUADRATIC_RS_CONCAVE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 31 Aug 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;

%% Read Settings
varargin = {};
OPT = struct(...
    'seed', 5, ...                                                        % seed used in ADIS (default = random)
    'animate', true, ...                                                   % boolean indicating animation of ADIS routine
    'NrSamplesCMC', 1e4);                                                   % number of samples used for crude Monte Carlo

OPT = setproperty(OPT, varargin{:});

%% define stochastic variables
addpath(genpath(pwd),'-end')

stochast = prob_grooteman_05_concave_stochast_test();

result = struct('Exact',{struct('Beta', norm_inv(1-1.05e-1, 0, 1),'P_f', 1.05e-1)});

%% run FORM
result.FORM = FORM(...
    'stochast', stochast,...
    'x2zFunction', @prob_grooteman_05_concave_x2z_test);

%% run Monte Carlo
result.CMC = MC(...
    'stochast', stochast,...
    'x2zFunction', @prob_grooteman_05_concave_x2z_test,...
    'NrSamples', OPT.NrSamplesCMC);

% %% run Directional Sampling
% result.ADIS = DS(...
%     'seed', OPT.seed, ...
%     'animate', OPT.animate, ...
%     'stochast', stochast,...
%     'x2zFunction', @prob_grooteman_05_concave_x2z_test);

%% run Directional Sampling Object-Oriented

StochVars(2,1) = RandomVariable;

for i=1:2
    StochVars(i,1).Name                     = ['U' num2str(i)];
    StochVars(i,1).Distribution             = @norm_inv;
    StochVars(i,1).DistributionParameters   = {0 1};
end

LSF                     = LimitState;
LSF.Name                = 'Z';
LSF.LimitStateFunction  = @prob_grooteman_05_concave_x2z_test;
LSF.RandomVariables     = StochVars;
LSF.ResponseSurface     = AdaptiveResponseSurface;

LineSearcher            = LineSearch;

% here i only call the class and i am only calling the object
% i am not calling the methods inside the object, i am only calling the
% constructor method, which is the method with the exact name as the object

DS_gr_05                = AdaptiveDirectionalImportanceSampling(LSF,LineSearcher,0.95,0.2,OPT.seed); % 
% DS_gr_05.StartUpMethods = StartUpMethod;


DS_gr_05.CalculatePf;

result.OO_ADIS.DS_object    = DS_gr_05;
result.OO_ADIS.Output.P_f   = DS_gr_05.Pf;
result.OO_ADIS.Output.Beta  = norm_inv(1-DS_gr_05.Pf, 0, 1);
result.OO_ADIS.Output.Calc  = DS_gr_05.LimitState.NumberExactEvaluations;

result.OO_ADIS.DS_object.plot

%% print result
prob_print_test(result);