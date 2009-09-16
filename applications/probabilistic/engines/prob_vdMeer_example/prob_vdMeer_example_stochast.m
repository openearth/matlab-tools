function stochast = prob_vdMeer_example_stochast(varargin)
%PROB_VDMEER_EXAMPLE_STOCHAST  create stochast variable.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_vdMeer_example_stochast(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_vdMeer_example_stochast
%
%   See also

%% Copyright notice
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
% Created: 03 Sep 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
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
    'Cpl'		% [-] Cpl      constant in vdMeer formula
    },...
    'Distr', {
    @norm_inv...       % [kg/m3] RhoS density sediment
    @norm_inv...       % [kg/m3] RhoW density water
    @norm_inv...       % [-] TanAlfa  slope of structure
    @norm_inv...       % [-] Steep    wave steepness
    @logn_inv...        % [-] P        notional permeability
    @deterministic...  % [-] S        damage number
    @deterministic...  % [-] N        number of waves
    @exp_inv...            % [m] H        significant wave height
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
    {1 3.83}...     % [m] H        significant wave height
    {0.6 0.05}...   % [m] D        stone size
    {6.2 0.43}...	% [-] Cpl      constant in vdMeer formula
    } ...
    );

%%
OPT = struct(...
    'active', true(size(stochast)));

OPT = setProperty(OPT, varargin{:});

for i = find(~OPT.active)
    stochast(i).Distr = @deterministic;
end