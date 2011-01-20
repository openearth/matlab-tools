function n = xb_exist(xb, varargin)
%XB_EXIST  Checks if certain fields exist in XBeach structure
%
%   Returns the number of fields from the provided list of field names that
%   actually exist in the provided XBeach structure.
%
%   Syntax:
%   n = xb_exist(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = List of fieldnames
%
%   Output:
%   n         = Integer indicating the number of fields that exist in the
%               XBeach structure
%
%   Example
%   n = xb_exist(xb, 'nx', 'ny')
%
%   See also xb_empty, xb_set, xb_get, xb_check

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

%% check existance

if ~xb_check(xb); error('Invalid XBeach structure'); end;

n = 0;
for i = 1:length(varargin)
    idx = strcmpi(varargin{i}, {xb.data.name});
    if any(idx)
        n = n+1;
    else
        re = regexp(varargin{i},'^(?<sub>.+?)\.(?<field>.+)$','names');
        if ~isempty(re)
            sub = xb_get(xb, re.sub);
            if xb_check(sub)
                idx = strcmpi(re.field, {sub.data.name});
                if any(idx)
                    n = n+1;
                end
            end
        end
    end
end
