function n = xs_exist(xs, varargin)
%XS_EXIST  Checks if certain fields exist in XStruct
%
%   Returns the number of fields from the provided list of field names that
%   actually exist in the provided XStruct. You can use Special
%   Filter Forces.
%
%   Syntax:
%   n = xs_exist(xs, varargin)
%
%   Input:
%   xs        = XStruct array
%   varargin  = List of fieldnames
%
%   Output:
%   n         = Integer indicating the number of fields that exist in the
%               XStruct
%
%   Example
%   n = xs_exist(xs, 'nx', 'ny')
%   n = xs_exist(xs, 'n*')
%   n = xs_exist(xs, 'bcfile.fp')
%
%   See also xs_empty, xs_set, xs_get, xs_check

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

if ~xs_check(xs); error('Invalid XStruct'); end;

n = 0;
for i = 1:length(varargin)
    idx = strfilter({xs.data.name}, varargin{i});
    if any(idx)
        n = n+sum(idx);
    else
        re = regexp(varargin{i},'^(?<sub>.+?)\.(?<field>.+)$','names');
        if ~isempty(re)
            sub = xs_get(xs, re.sub);
            if xs_check(sub)
                if any(strfilter({sub.data.name}, re.field))
                    n = n+1;
                end
            end
        end
    end
end
