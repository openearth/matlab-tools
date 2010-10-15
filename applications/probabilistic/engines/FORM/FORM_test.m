function testresult = FORM_test()
% FORM_TEST  One line description goes here
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
% Created: 30 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTest.category('UnCategorized');

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
resultFORM = FORM(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1);

% Probability of failure should be always the same for a fixed seed
testresult(end+1) = roundoff(resultFORM.Output.P_f, 4) == 0.2027;

%% test 2
resultFORM_resistance = FORM(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction1,...
    'variables', {'Resistance', 0:4});

% Probability of failure for a vector with resistances
partres = zeros(size(resultFORM_resistance));
for ires = 1:length(resultFORM_resistance)
    partres(ires) = resultFORM_resistance(ires).Output.P_f;
end
testresult(end+1) = all(roundoff(partres, 4) == [0.2027 0.1336 0.0828 0.0480 0.0261]);

%% test 3
resultFORM_resistance = FORM(...
    'stochast', stochast,...
    'x2zFunction', @x2z_testfunction2,...
    'variables', {'Resistance', 0:4});

% Probability of failure for a vector with resistances
partres = zeros(size(resultFORM_resistance));
for ires = 1:length(resultFORM_resistance)
    partres(ires) = resultFORM_resistance(ires).Output.P_f;
end
testresult(end+1) = all(roundoff(partres, 4) == [0.2027 0.1336 0.0828 0.0480 0.0261]);

%% test 4
resultFORM_2sided = FORM(...
    'stochast', stochast,...
    'DerivativeSides', 2,...
    'x2zFunction', @x2z_testfunction2,...
    'variables', {'Resistance', 0:4});

% Probability of failure for a vector with resistances
partres = zeros(size(resultFORM_2sided));
for ires = 1:length(resultFORM_2sided)
    partres(ires) = resultFORM_2sided(ires).Output.P_f;
end
testresult(end+1) = all(roundoff(partres, 4) == [0.2027 0.1336 0.0828 0.0480 0.0261]);

%% test 5
stochast_deter = stochast;
stochast_deter(1).Distr = @deterministic;
stochast_deter(1).Params = stochast(1).Params(1);
resultFORM_deterministic = FORM(...
    'stochast', stochast_deter,...
    'x2zFunction', @x2z_testfunction2);

% Probability of failure with only one stochastic variable
testresult(end+1) = roundoff(resultFORM_deterministic.Output.P_f, 4) == 0.1587;

%% test 6
resultFORM_dudistfactor = FORM(...
    'stochast', stochast,...
    'dudistfactor', 0.25,...
    'x2zFunction', @x2z_testfunction2);

% Probability of failure with different du per variable
testresult(end+1) = roundoff(resultFORM_dudistfactor.Output.P_f, 3) == 0.203;

%% test 7
% example of new style, where propertyName-propertyValue pairs are used to
% specify the input of the z-function
resultFORM = FORM(...
    'stochast', stochast_new,...
    'x2zFunction', @x2z_testfunction3);

% Probability of failure should be always the same for a fixed seed
testresult(end+1) = roundoff(resultFORM.Output.P_f, 4) == 0.2027;

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