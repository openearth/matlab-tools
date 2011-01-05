function xb = xb_rename(xb, varargin)
%XB_RENAME  Renames one or more fields in XBeach structure
%
%   Renames one or more fields in XBeach structure and returns the
%   resulting structure.
%
%   Syntax:
%   xb = xb_rename(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = List of pairs of old and new fieldnames (e.g.
%               'old1','new1','old2','new2',...)
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_rename(xb, 'globalx', 'x', 'globaly', 'y')
%
%   See also xb_empty, xb_get, xb_set, xb_del

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
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% rename fields

if ~xb_check(xb); error('Invalid XBeach structure'); end;

if ~isempty([varargin{:}])
    if length(varargin) == 1
        old = varargin;
        new = {input([varargin{1} ': '], 's')};
    else
        old = varargin(1:2:end);
        new = varargin(2:2:end);
    end
    
    for i = 1:length(new)
        idx = strcmpi(old{i}, {xb.data.name});
        xb.data(idx).name = new{i};
    end
end
