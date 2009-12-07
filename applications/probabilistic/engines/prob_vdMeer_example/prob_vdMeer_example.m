function [resultMC resultFORM] = prob_vdMeer_example(varargin)
%PROB_VDMEER_EXAMPLE  example of probabilistic calculation with van der Meer formula
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_vdMeer_example(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_vdMeer_example
%
%   See also 

%% Copyright notice
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Dec 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% define the stochasts
% create a structure with fields 'Name', 'Distr' and 'Params'
stochast = struct(...
    'Name', {
    'RhoS'...       % [kg/m3] RhoS density sediment
    'RhoW'...       % [kg/m3] RhoW density water
    'TanAlfa'...    % [-] TanAlfa  slope of structure
    'Steep'...      % [-] Steep    wave steepness
    'P'...          % [-] P        notional permeability
    'S'...          % [-] S        damage number
    'N'...          % [-] N        number of waves
    'H'...          % [m] H        significant wave height
    'D'...          % [m] D        stone size
    'Cpl'		    % [-] Cpl      constant in vdMeer formula
    },...
    'Distr', {
    @norm_inv...       % [kg/m3] RhoS density sediment
    @norm_inv...       % [kg/m3] RhoW density water
    @norm_inv...       % [-] TanAlfa  slope of structure
    @norm_inv...       % [-] Steep    wave steepness
    @logn_inv...       % [-] P        notional permeability
    @deterministic...  % [-] S        damage number
    @deterministic...  % [-] N        number of waves
    @exp_inv...        % [m] H        significant wave height
    @norm_inv...       % [m] D        stone size
    @norm_inv...	   % [-] Cpl      constant in vdMeer formula
    },...
    'Params', {
    {2650 100}...   % [kg/m3] RhoS density sediment
    {1030 5}...     % [kg/m3] RhoW density water
    {0.25 0.0125}...% [-] TanAlfa  slope of structure
    {0.05 0.01}...  % [-] Steep    wave steepness
    {{@logn_moments2lambda 0.1  0.05} {@logn_moments2zeta 0.1  0.05}}...  % [-] P        notional permeability
    {2  }...        % [-] S        damage number
    {7000}...       % [-] N        number of waves
    {3.83 1}...     % [m] H        significant wave height
    {0.6 0.05}...   % [m] D        stone size
    {6.2 0.43}...	% [-] Cpl      constant in vdMeer formula
    } ...
    );

%% main matter: running the calculation
% run the calculation using Monte Carlo
resultMC = MC(stochast,...
    'NrSamples', 3e4,...
    'x2zFunction', @prob_vdMeer_example_x2z);

% run the calculation using FORM
resultFORM = FORM(stochast,...
    'x2zFunction', @prob_vdMeer_example_x2z);

%% Z-function
function z = prob_vdMeer_example_x2z(x, varnames, Resistance, varargin)

%% retrieve calculation values
for i = 1:size(x,2)
    samples.(varnames{i}) = x(:,i);
end

%%
g = 9.81;                               %[m/s2]
for i = 1:size(x,1)
    Delta = (samples.RhoS(i) - samples.RhoW(i)) / samples.RhoW(i);    % [-] relative density
    Ksi = samples.TanAlfa(i)/sqrt(samples.Steep(i));      % [-] Iribarren number
    z(i,:) = samples.Cpl(i)*samples.P(i)^0.18*(samples.S(i)/sqrt(samples.N(i)))^0.2*Ksi^(-0.5)-samples.H(i)/Delta/samples.D(i); %[-] vdMeer
end