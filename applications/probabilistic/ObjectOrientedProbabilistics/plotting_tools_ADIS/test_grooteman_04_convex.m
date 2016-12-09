function result = test_grooteman_04_convex(varargin)
% PROB_QUADRATIC_RS_CONVEX_TEST  One line description goes here
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

OPT = struct(...
    'MinAppr', 0, ...
    'NoCrossTerms', false, ...
    'Weightening', 'none', ...
    'StartUp', '', ...
    'Method', 'ADIS', ...
    'seed', NaN);                                                   % number of samples used for crude Monte Carlo

OPT = setproperty(OPT, varargin{:});

%% define stochastic variables
addpath(genpath(pwd),'-end')

result = struct('Exact',{struct('Beta', norm_inv(1-4.16e-3, 0, 1),'P_f', 4.16e-3)});

%% run Object-Oriented Directional Sampling

% construct stochastic variables
StochVars(2,1) = RandomVariable;

for i=1:2
    StochVars(i,1).Name                     = ['U' num2str(i)];
    StochVars(i,1).Distribution             = @norm_inv;
    StochVars(i,1).DistributionParameters   = {0 1};
end

% construct limit state
LSF                                 = LimitState;
LSF.Name                            = 'Z';
LSF.LimitStateFunction              = @prob_grooteman_04_convex_x2z_test;
LSF.RandomVariables                 = StochVars;
LSF.ResponseSurface                 = AdaptiveResponseSurface;
LSF.ResponseSurface.NoCrossTerms    = OPT.NoCrossTerms;

% check for weightening
switch OPT.Weightening
    case 'none'
        % nothing to be done, defaults are fine
    case 'selection'
        LSF.ResponseSurface.DefaultFit  = false;
    case 'weighted'
        LSF.ResponseSurface.DefaultFit  = false;
        LSF.ResponseSurface.WeightedARS = true;
        LSF.ResponseSurface.FitFunction = @wpolyfitn;
end

% construct line searcher 
LineSearcher            = LineSearch;

switch OPT.Method
    case 'ADIS'
        % construct ADIS object
        DS_gr_04        = AdaptiveDirectionalImportanceSampling(LSF,LineSearcher,0.95,0.2,OPT.seed);
        DS_gr_04.MinNrApproximatedPoints = OPT.MinAppr;
    case 'DS'
        DS_gr_04        = DirectionalSampling(LSF,LineSearcher,0.95,0.2,OPT.seed);
    case 'DS_all'
        DS_gr_04        = DirectionalSamplingAllPoints(LSF,LineSearcher,0.95,0.2,OPT.seed);
end

if strcmp(OPT.Method,'ADIS')
    if strcmp(OPT.StartUp,'AxialSearch')
        DS_gr_04.StartUpMethods = StartUpAxialSearch;
    elseif strcmp(OPT.StartUp,'AxialPoints')
        DS_gr_04.StartUpMethods = StartUpAxialPoints;
    elseif strcmp(OPT.StartUp,'FastARS')
        DS_gr_04.StartUpMethods = StartUpFastARS;
    end
end

% calculate Pf
DS_gr_04.CalculatePf;

% save results
result.OO_ADIS.DS_object     = DS_gr_04;
result.OO_ADIS.Output.P_f    = DS_gr_04.Pf;
result.OO_ADIS.Output.Beta   = norm_inv(1-DS_gr_04.Pf, 0, 1);
result.OO_ADIS.Output.Calc   = DS_gr_04.LimitState.NumberExactEvaluations;

%% print result
prob_print_test(result); 