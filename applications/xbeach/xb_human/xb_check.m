function valid = xb_check(xb)
%XB_CHECK  Checks whether a variable is a valid XBeach structure
%
%   Checks whether a variable is a valid XBeach structure.
%
%   Syntax:
%   valid = xb_check(xb)
%
%   Input:
%   xb          = XBeach structure array
%
%   Output:
%   valid       = Boolean value for validity of structure
%
%   Example
%   valid = xb_check(xb)
%
%   See also xb_get, xb_set, xb_show

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

%% check structure

valid = true;

if ~isstruct(xb)
    valid = false;
elseif ~all(ismember({'date' 'type' 'function' 'data'}, fieldnames(xb)))
    valid = false;
elseif ~all(ismember({'name', 'value'}, fieldnames(xb.data)))
    valid = false;
end
