function rs = pg_select_struct(conn, table, data, varargin)
%PG_SELECT_STRUCT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = pg_select_struct(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   pg_select_struct
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read input

strSQLSelect            = '*';

if ~isempty(varargin)
    
    if iscell(varargin{1})
        strSQLSelect    = concat(varargin{1}, ',');
    else
        strSQLSelect    = concat(varargin, ',');
    end
    
end

%% built sql statement

f           = fieldnames(data);
v           = struct2cell(data);

[v{:}]      = pg_value2sql(v{:});

w           = cell(1,2*length(f));
w(1:2:end)  = f;
w(2:2:end)  = v;

strSQLWhere = regexprep(concat(w,','),'([^,]*),([^,]*)(,?)','$1=$2$3');

strSQL = sprintf('SELECT %s FROM %s WHERE %s', strSQLSelect, table, strSQLWhere);

rs = pg_fetch(conn, strSQL);