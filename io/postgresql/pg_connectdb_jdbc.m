function conn = pg_connectdb_jdbc(db, varargin)
%PG_CONNECTDB_JDBC  Creates a JDBC connection to a PostgreSQL database with database toolbox
%
%   Creates a JDBC connection to a PostgreSQL database with the database toolbox.
%   A JDBC driver should be loaded first, see PG_SETTINGS and README.txt.
%   If a schema is given, this schema is set to the default for the current
%   session.
%
%   Syntax:
%   conn = pg_connectdb_jdbc(db, <keyword,value>)
%
%   Input:
%   db        = Name of database to connect to
%   keywords  = host    - Hostname of database server    (default: localhost)
%               port    - Port number of database server (default: 5432)
%               user    - Username for database server
%               pass    - Password for database server
%               schema  - Default schema for current session
%
%   Output:
%   conn      = Database connection object
%
%   Example:
%
%    conn = pg_connectdb_jdbc('someDatabase')
%    conn = pg_connectdb_jdbc('anotherDatabase','host','posgresql.deltares.nl')
%    conn = pg_connectdb_jdbc('anotherDatabase','schema','someSchema')
%
%   Example:connecting to the empty database of a virgin local Win32 PostgreSQL 9.1
%
%    conn = pg_connectdb_jdbc('postgres','user','postgres','pass','MyPassword')
%    conn = pg_connectdb_jdbc('postgres','user','postgres','pass','MyPassword','schema','public')
%
%   See also pg_exec_jdbc

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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

%% read options

   OPT = struct( ...
    'host',     'localhost', ...
    'port',     5432, ...
    'user',     '', ...
    'pass',     '', ...
    'schema',   '');

   if nargin==0;conn = OPT;return;end

   OPT = setproperty(OPT,varargin{:});

%% connect to database

   props = java.util.Properties;
   props.setProperty('user'    , OPT.user);
   props.setProperty('password', OPT.pass);

   driver = org.postgresql.Driver;
   url    = ['jdbc:postgresql://' OPT.host ':' num2str(OPT.port) '/' db];
   conn   = driver.connect(url, props);

%% display message on error

   if isempty(conn)
       if pg_settings('check',1)<0
       disp('run PG_Settings first')
       end
   else
       
       % set default schema, if given
       if ~isempty(OPT.schema)
           error(['schema not implemented in ',mfilename])
          %pg_exec_jdbc(conn, sprintf('SET search_path TO %s', OPT.schema));
       end
       
   end
