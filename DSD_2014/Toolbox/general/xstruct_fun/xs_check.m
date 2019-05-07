function valid = xs_check(xs)
%XS_CHECK  Checks whether a variable is a valid XStruct
%
%   Checks whether a variable is a valid XStruct.
%
%   Syntax:
%   valid = xs_check(xs)
%
%   Input:
%   xs          = XStruct array
%
%   Output:
%   valid       = Boolean value for validity of structure
%
%   Example
%   valid = xs_check(xs)
%
%   See also xs_get, xs_set, xs_show

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

% $Id: xs_check.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/xstruct_fun/xs_check.m $
% $Keywords: $

%% check structure

valid = true;

if ~isstruct(xs)
    valid = false;
elseif ~all(ismember({'date' 'type' 'function' 'data'}, fieldnames(xs)))
    valid = false;
else
    for i = 1:length(xs)
        if ~all(ismember({'name', 'value'}, fieldnames(xs(i).data)))
            valid = false;
        end
    end
end
