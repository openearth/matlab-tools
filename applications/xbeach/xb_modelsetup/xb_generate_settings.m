function xb = xb_generate_settings(varargin)
%XB_GENERATE_SETTINGS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_generate_settings(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_generate_settings
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'thetamin', -37.5, ...
    'thetamax', 37.5, ...
    'dtheta', 15, ...
    'tstop', 3600 ...
);

OPT = setproperty(OPT, varargin{:});

%% generate settings

xb = xb_empty();

f = fieldnames(OPT);
for i = 1:length(f)
    xb = xb_set(xb, f{i}, OPT.(f{i}));
end

xb = xb_meta(xb, mfilename, 'input');