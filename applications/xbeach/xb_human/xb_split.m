function varargout = xb_split(xb, varargin)
%XB_SPLIT  Splits a XBeach structure in multiple XBeach structures
%
%   Splits a XBeach structure in multiple XBeach structures by moving
%   several fields to one XBeach structure and others to another. User '*'
%   to select all non-matched fields.
%
%   Syntax:
%   varargout = xb_split(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = List of fields to be stored in one XBeach structure. To
%               store multiple fields in a XBeach structure, use a cell
%               array of field names as item in the list.
%
%   Output:
%   varargout = List of XBeach structure arrays.
%
%   Example
%   [xb1 xb2 xb3] = xb_split(xb, {'nx' 'ny'}, 'bcfile', {'xfile', 'yfile'})
%
%   See also xb_join, xb_empty, xb_set, xb_get

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

%% split structures

varargout = {};

ri = nan;
r  = false(size(xb.data));

for i = 1:length(varargin)
    f = varargin{i};
    
    if ~iscell(f)
        f = {f};
    end
    
    if ~ismember('*', f)
        idx = ismember({xb.data.name}, f);

        r(idx) = true;

        varargout{i} = xb;
        varargout{i}.data = xb.data(idx);
    else
        ri = i;
    end
end

if ~isnan(ri)
    varargout{ri} = xb;
	varargout{ri}.data = xb.data(~r);
end
