function rs = pg_exec_jdbc(conn, sql, varargin)
%PG_EXEC_JDBC  Executes a SQL query and returns a cursor object
%
%   Executes a SQL query with JDBC jar file directly (licensed
%   Mathworks database toolbox not needed) 
%   and checks the result for errors. Returns the result set.
%
%   Syntax:
%   rs = pg_exec_jdbc(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object created with PG_CONNECTDB_JDBC
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Result set from SQL query
%
%   Example:
%   conn = pg_connectdb_jdbc('someDatabase');
%   pg_exec_jdbc(conn, 'DELETE FROM someTable WHERE someColumn = 1');
%
%   See also PG_CONNECTDB_JDBC, pg_fetch, pg_select_struct, pg_insert_struct, pg_update_struct, exec

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

%% execute sql query

prefs = getpref('postgresql');


if ~isstruct(prefs) || ~isfield(prefs, 'passive') || ~prefs.passive

   %% A test query

   pstat = conn.prepareStatement(sql);
   rsraw = pstat.executeQuery();

   %% Parse the results into a cell array with the highest possible
   %  data type for each column.

   count=0;
   rs = {};
   while rsraw.next()
       count=count+1;
       icol = 0;
       while 1
           icol = icol + 1;
           try
              rs{count,icol}=rsraw.getDouble(icol);
           catch
              try
                 rs{count,icol}=rsraw.getInt(icol);
              catch
                 try
                    rs{count,icol}=char(rsraw.getString(icol));
                 catch
                    break
                 end
              end
           end
       end
   end

   pstat.close();
   rsraw.close();
   pg_error(rs);
   
end

if isstruct(prefs) && isfield(prefs, 'verbose') && prefs.verbose
	disp(sql);
end
        
if isstruct(prefs) && isfield(prefs, 'file') && ~isempty(prefs.file)
    fid = fopen(prefs.file, 'a');
    fprintf(fid, '%s\n', sql);
    fclose(fid);
end
