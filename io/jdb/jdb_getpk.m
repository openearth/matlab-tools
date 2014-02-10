function varargout = jdb_getpk(conn, table, varargin)
%PG_GETPK  Retrieve name of primary key for given table
%
%   Retrieve name of primary key for given table in current database and
%   returns its name.
%
%   Syntax:
%   pk_name = jdb_getpk(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Name of table for which primary key is requested
%   varargin  = none
%
%   Output:
%   pk_name   = Name of primary key
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   pk = jdb_getpk(conn, 'someTable');
%
%   See also jdb_getid, jdb_gettables, jdb_getcolumns, jdb_connectdb

%% Copyright notice: see below

%% read options
% OPT = struct();
% 
% OPT = setproperty(OPT,varargin{:});

%% list tables
dbtype = class(conn);
C      = textscan(dbtype, '%s', 'delimiter','.');
dbtype = C{:}{1};

switch dbtype
    case 'oracle' 
        % http://bytes.com/topic/oracle/answers/644008-query-find-primary-foreign-keys
        table = upper(table);
%       strSQL =  ['SELECT * FROM ALL_CONS_COLUMNS A JOIN ALL_CONSTRAINTS C  ON A.CONSTRAINT_NAME = C.CONSTRAINT_NAME WHERE C.TABLE_NAME = ''MEASURE_UNITS'' AND C.CONSTRAINT_TYPE = ''P''']
        strSQL =  ['SELECT "COLUMN_NAME" FROM ALL_CONS_COLUMNS A JOIN ALL_CONSTRAINTS C  ON A.CONSTRAINT_NAME = C.CONSTRAINT_NAME WHERE C.TABLE_NAME = ''',table,''' AND C.CONSTRAINT_TYPE = ''P'''];

    case 'postgresql'
        %  http://wiki.postgresql.org/wiki/Retrieve_primary_key_columns
        %  http://postgresql.1045698.n5.nabble.com/how-to-find-primary-key-field-name-td4893701.html
        strSQL = sprintf('SELECT pg_attribute.attname FROM pg_index, pg_class, pg_attribute WHERE pg_class.oid = ''%s''::regclass AND indrelid = pg_class.oid AND pg_attribute.attrelid = pg_class.oid AND pg_attribute.attnum = any(pg_index.indkey) AND indisprimary', jdb_quote(table));
    otherwise
        strSQL = '' ;
end

rs = jdb_fetch(conn, strSQL);

varargout = {rs};


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       bas.hoonhout@deltares.nl
%       ronald.vanderhout@vanoord.com
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