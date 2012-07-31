function columns = pg_getcolumns(conn, table, varargin)
%PG_GETCOLUMNS  List all columns in a given table
%
%   List all columns in a given table in the current database. Returns a
%   list with column names. Ignores system columns like cmin and cmax.
%
%   Syntax:
%   columns = pg_getcolumns(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table name
%   varargin  = none
%
%   Output:
%   columns   = Cell array with column names
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   tables = pg_gettables(conn);
%   columns = pg_getcolumns(conn, tables{1});
%
%   See also pg_connectdb, pg_gettables

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

%% read options

OPT = struct();

OPT = setproperty(OPT,varargin{:});

%% list tables

strSQL = sprintf('SELECT attname FROM pg_attribute, pg_type WHERE typname = ''%s'' AND attrelid = typrelid AND attname NOT IN (''tableoid'',''cmax'',''xmax'',''cmin'',''xmin'',''ctid'')', table);

columns = pg_fetch(conn, strSQL);