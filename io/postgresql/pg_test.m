function OK = pg_test(varargin)
%PG_TEST test postgresql toolbox with simple 2-column datamodel:
%
% For the simple test datamodel see "pg_test_template.sql".
%
%See also: postgresql

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.db     = 'postgres';
OPT.schema = 'public';
OPT.user   = '';
OPT.pass   = '';
OPT.table  = 'AaB7';

OPT = setproperty(OPT,varargin);

%% connect
if ~pg_settings('check',1)
   pg_settings
end
if isempty(OPT.user)
[OPT.user,OPT.pass] = pg_credentials();
end
conn=pg_connectdb(OPT.db,'user',OPT.user,'pass',OPT.pass,'schema',OPT.schema);

%% show contents
tables = pg_gettables(conn);
if any(strmatch(OPT.table,tables))
   for itab=1:length(tables)
      table = tables{itab};
      columns = pg_getcolumns(conn,table);
      for icol=1:length(columns)
          column = columns{icol};
          disp([conn.Instance,':',table,':',column])
      end
   end
   error(['request table for pg_test is already in database:',OPT.table])
end
%% add datemodel for testing
% http://archives.postgresql.org/pgsql-performance/2004-11/msg00350.php
% http://dba.stackexchange.com/questions/322/what-are-the-drawbacks-with-using-uuid-or-guid-as-a-primary-key
sql   = loadstr('pg_test_template.sql');
for i=1:length(sql)
    sqlstr = strrep(sql{i},'?',OPT.table);
    pg_exec(conn,sqlstr);
end

%% do test
OK = [];
   pg_cleartable(conn,OPT.table) % reset values and serial
pg_insert_struct(conn,OPT.table,struct('Value','3.1416'));        % 1
pg_insert_struct(conn,OPT.table,struct('Value',[3.1416 3.1416])); % 2 3
pg_insert_struct(conn,OPT.table,struct('Value','2'));             % 4
pg_insert_struct(conn,OPT.table,struct('Value',[2 2]));           % 4 5

D = pg_select_struct(conn,OPT.table,struct('Value','2'));
OK(end+1) = isequal(cell2mat({D{:,1}}),[4 5 6]);

D = pg_select_struct(conn,OPT.table,struct('Value',2));
OK(end+1) = isequal(cell2mat({D{:,1}}),[4 5 6]);

D = pg_select_struct(conn,OPT.table,struct('Value','3.1416'));
OK(end+1) = isequal(cell2mat({D{:,1}}),[1 2 3]);

% for reals, the selection does not work if numeric data 
% are supplied, perhaps due to machine precision issues
D = pg_select_struct(conn,OPT.table,struct('Value',3.1416));
%isequal(cell2mat({D{:,1}}),[1 2 3])
