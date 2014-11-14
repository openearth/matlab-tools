function data = jdb_fetch(conn, sql, varargin)
% Executes a SQL query and imports database data into matlab
%
%   Executes a SQL query with the (i) licensed Mathworks database
%   toolbox or otherwise with (ii) the JDBC driver directly
%   fetches the result and checks the result for
%   errors. Returns the resulting data in a cell array or matrix.
%
%   Syntax:
%   rs = jdb_fetch(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Fetched data from result set from SQL query
%
%   Example
%   conn = jdb_connectdb('someDatabase');
%   jdb_fetch(conn, 'SELECT * FROM someTable');
%
%   See also jdb_exec, jdb_select_struct, jdb_insert_struct, jdb_update_struct, fetch

%% Copyright notice: see below

%% execute sql query
% inspect conn object to find out whether is was created with
% the licensed database toolbox or the JDCB driver directly.
OPT.database_toolbox = 0;
try %#ok<TRYNC>
    if any(strfind(char(conn.Constructor),'mathworks'))
        OPT.database_toolbox = 1;
    end
end

if OPT.database_toolbox
    data = fetch(conn, sql);
else
    % http://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html
    
    pstat = conn.prepareStatement(sql);
    rs = pstat.executeQuery();
    
    rsMetaData = rs.getMetaData();
    numberOfColumns = rsMetaData.getColumnCount();
    
    % a large fetch size greatly improves performance of large queries
    rs.setFetchSize(10000)
    
    row = 0;
    data = {};
    while 1
        try
            if ~rs.next()
                break
            end
            row=row+1;
            for col = 1:numberOfColumns
                jtype = char(rsMetaData.getColumnClassName(col));
                switch jtype
                    case 'java.lang.String'
                        data{row,col} = char(rs.getString(col));  %#ok<*AGROW>
                    case {'java.lang.Double','java.math.BigDecimal'}
                        data{row,col} = rs.getDouble(col);
                    case 'java.lang.Int'
                        data{row,col} = rs.getInt(col);
                    case 'java.sql.Timestamp'                       %'oracle.sql.TIMESTAMP'
                        data{row,col} = datenum(1970,0,0) + rs.getTimestamp(col).getTime()/1000/3600/24;
                    otherwise
                        warning('JDB:DATA_FETCH_ERROR:TYPE_NOT_IMPLEMENTED:datatype %s implemented',jtype)
                end
            end
        catch ME
            warning('JDB:DATA_FETCH_ERROR',ME.getReport())
            break
        end
    end
    
    pstat.close();
    rs.close();
    
end

jdb_error(data);

prefs = getpref('postgresql');
if isstruct(prefs) && isfield(prefs, 'verbose') && prefs.verbose
    disp(sql);
end

if isstruct(prefs) && isfield(prefs, 'file') && ~isempty(prefs.file)
    fid = fopen(prefs.file, 'a');
    fprintf(fid, '%s\n', sql);
    fclose(fid);
end


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Bas Hoonhout
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       bas.hoonhout@deltares.nl
%       ronald.vanderhout@vanoord.com
%
%   JDBC: Copyright (C) 2012 Deltares for Building with Nature
%       Gerben J. de Boer
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
