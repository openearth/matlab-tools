function [tables, owners]= jdb_gettables(conn, varargin)
%JDB_GETTABLES  List all tables in current database
%
%   List all tables in current database. Return a list with table names in
%   given database connection. Ignores system tables like pg_catalog and
%   information_schema.
%
%   Syntax:
%   tables = jdb_gettables(conn, varargin)
%
%   Input:
%   conn      = Database connection object
%   varargin  = none
%
%   Output:
%   tables    = Cell array with table names
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   tables = jdb_gettables(conn);
%
%   See also jdb_connectdb, jdb_getcolumns, jdb_table2struct

%% Copyright notice: see below


%% read options
OPT.all = true;

OPT = setproperty(OPT,varargin{:});

%% list tables
% dbtype = class(conn);
% C      = textscan(dbtype, '%s', 'delimiter','.');
% dbtype = C{:}{1};
C = textscan(class(conn), '%s', 'delimiter','.');
C = C{:};
if ismember('oracle',C)
    dbtype = 'oracle';
elseif ismember('postgresql',C)
    dbtype = 'postgresql';    
else
    dbtype = 'unknown';
end

switch dbtype
    case 'oracle'        
        sql = 'SELECT DISTINCT "OWNER", "OBJECT_NAME" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''TABLE''';
%         sql = 'SELECT DISTINCT "OBJECT_NAME" FROM ALL_OBJECTS WHERE OBJECT_TYPE = ''TABLE''';
    case 'postgresql'
        sql = 'SELECT tablename FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'',''information_schema'')';
    otherwise
        sql = '';
end

tables = jdb_fetch(conn, sql);

if size(tables,2)==2
    owners = tables(:,1);
    tables = tables(:,2);
else
    owners  = repmat({''},size(tables));
end

% Postproces tablenames
if ~OPT.all
    switch dbtype
        case 'oracle'        
    %         "CDW"."F_PIPEL_CSD"
            idx = ~ismember(owners(:,1),{'SYS' 'SYSTEM' 'MDSYS' 'XDB' 'OLAPSYS' 'APEX_030200' 'EXFSYS' 'CTXSYS'});

%             tmp =  strcat(jdb_quote(tables(idx,1)),repmat('.',size(tables(idx,1),1),1),jdb_quote(tables(idx,2)));
            tables = tables(idx,:);
            owners = owners(idx,:);
    end
end

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
