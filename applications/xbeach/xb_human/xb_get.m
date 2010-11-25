function varargout = xb_get(xbSettings, varargin)
%XB_GET  Retrieves variables from XBeach structure
%
%   Retrieves one or more variables from XBeach structure.
%
%   Syntax:
%   varargout   = xb_get(xbSettings, varargin)
%
%   Input:
%   xbSettings  = XBeach structure array
%   varargin    = Names of variables to be retrieved. If omitted, all
%                 variables are returned
%
%   Output:
%   varargout   = Values of requested variables.
%
%   Example
%   [zb zs] = xb_get(xbSettings, 'zb', 'zs')
%
%   See also xb_set, xb_show

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

if ~xb_check(xbSettings); error('Invalid XBeach structure'); end;

if isempty(varargin)
    vars = {xbSettings.data.name};
else
    vars = varargin;
end

%% read variables

varargout = num2cell(nan(size(vars)));

for i = 1:length(vars)
    idx = strcmpi(vars{i}, {xbSettings.data.name});
    if any(idx)
        varargout{i} = xbSettings.data(idx).value;
    end
end
