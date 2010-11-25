function xbSettings = xb_set(xbSettings, varargin)
%XB_SET  Sets variables in XBeach settings structure
%
%   Sets one or more variables in name/value formatted XBeach
%   settings structure. If a variable doesn't exist yet, it is created.
%   Units can be added by providing a cell array containing the variable
%   itself and a string containing the units, thus {data, units}. Please
%   add a flag '-units' to the varagin, if done so to ensure proper
%   parsing.
%
%   Syntax:
%   xbSettings   = xb_set(xbSettings, varargin)
%
%   Input:
%   xbSettings  = XBeach settings struct (name/value)
%   varargin    = Name/value pairs of variables to be set
%
%   Output:
%   xbSettings  = Updated XBeach settings struct
%
%   Example
%   xbSettings  = xb_set(xbSettings, 'zb', zb, 'zs', zs)
%   xbSettings  = xb_set(xbSettings, '-units', 'zb', {zb 'm+NAP'}, 'zs', {zs 'm+NAP'})
%
%   See also xb_get, xb_show

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
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read request

if ~xb_check(xbSettings); xbSettings = xb_empty(); end;

% determin if units are provided
has_units = false;
idx = strcmpi('-units', varargin);
if any(idx)
    has_units = true;
    varargin = varargin(~idx);
end

if isempty(varargin)
    names = {};
    values = {};
else
    l = length(varargin)-mod(length(varargin),2);
    names = varargin(1:2:l-1);
    values = varargin(2:2:l);
end

%% read variables

for i = 1:length(names)
    idx = strcmpi(names{i}, {xbSettings.data.name});
    if ~any(idx)
        idx = length(xbSettings.data)+1;
        xbSettings.data(idx).name = names{i};
    end
    if iscell(values{i}) && length(values{i}) == 2 && has_units
        val = values{i};
        if ischar(val{2})
            xbSettings.data(idx).value = val{1};
            xbSettings.data(idx).units = val{2};
        else
            xbSettings.data(idx).value = values{i};
        end
    else
        xbSettings.data(idx).value = values{i};
    end
end

% set meta data
xbSettings = xb_meta(xbSettings, mfilename);
