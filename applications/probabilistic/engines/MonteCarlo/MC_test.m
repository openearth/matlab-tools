function testresult = MC_test()
% MC_TEST  Test routine for Monte Carlo function
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 06 Aug 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

%% define stochastic variables
% stochast in the new style, including "propertyName" field
stochast_new = struct(...
    'Name', {
    'R'...
    'S'...
    },...
    'Distr', {
    @norm_inv...
    @norm_inv...
    },...
    'Params', {
    {9 2}...
    {6 3}...
    },...
    'propertyName', {
    true...
    true...
    } ...
    );

% stochast old style
stochast = struct(...
    'Name', {
    'R'...
    'S'...
    },...
    'Distr', {
    @norm_inv...
    @norm_inv...
    },...
    'Params', {
    {9 2}...
    {6 3}...
    } ...
    );

testresult = [];

%% test 1
resultCMC = MC(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1,...
    'seed', 0);

% Probability of failure should be always the same for a fixed seed
testresult(end+1) = resultCMC.Output.P_f == 0.19;

%% test 2
resultSISMC = MC(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1,...
    'ISvariable', 'S',...
    'W', 10,...
    'seed', 0);
% Probability of failure should be always the same for a fixed seed
testresult(end+1) = resultSISMC.Output.P_f == 0.083;

%% test 3
resultAISMC = MC(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1,...
    'ISvariable', 'S',...
    'f1', 1,...
    'f2', 1e-6,...
    'seed', 0);
% Probability of failure should be always the same for a fixed seed
testresult(end+1) = roundoff(resultAISMC.Output.P_f, 4) == 0.2089;

%% test 4
resultCMC_resistance = MC(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1,...
    'variables', {'Resistance' (0:4)},...
    'seed', 0);

% Probability of failure for a vector with resistances
testresult(end+1) = all(resultCMC_resistance.Output.P_f == [0.19 0.15 0.12 0.05 0.03]);

%% test 5
resultCMC_resistance = MC(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction2,...
    'variables', {'Resistance' (0:4)},...
    'seed', 0);

% Probability of failure for a vector with resistances
testresult(end+1) = all(resultCMC_resistance.Output.P_f == [0.19 0.15 0.12 0.05 0.03]);

%% test 6
% example of new style, where propertyName-propertyValue pairs are used to
% specify the input of the z-function
resultCMC_resistance = MC(...
    'stochast', stochast_new,...
    'x2zFunction', @x2z_testfunction3,...
    'variables', {'Resistance' (0:4)},...
    'seed', 0);

% Probability of failure for a vector with resistances
testresult(end+1) = all(resultCMC_resistance.Output.P_f == [0.19 0.15 0.12 0.05 0.03]);

%% combine all testresults in one boolean
testresult = all(testresult);

function z = x2z_testfunction1(samples, Resistance, varargin)

OPT = struct(...
    'Resistance', 0);

OPT = setproperty(OPT, varargin{:});
Resistance = OPT.Resistance;

variables = fieldnames(samples);
nsamples = length(samples.(variables{1}));
nResistance = length(Resistance);
z = repmat(Resistance, nsamples, 1) + repmat(samples.R - samples.S, 1, nResistance);

function z = x2z_testfunction2(R, S, varargin)

OPT = struct(...
    'Resistance', 0);

OPT = setproperty(OPT, varargin{:});

nsamples = length(R);
nResistance = length(OPT.Resistance);

z = repmat(OPT.Resistance, nsamples, 1) + repmat(R - S, 1, nResistance);

function z = x2z_testfunction3(varargin)

OPT = struct(...
    'Resistance', 0,...
    'R', [],...
    'S', []);

OPT = setproperty(OPT, varargin{:});

nsamples = length(OPT.R);
nResistance = length(OPT.Resistance);

z = repmat(OPT.Resistance, nsamples, 1) + repmat(OPT.R - OPT.S, 1, nResistance);
