function rs = pg_exec(conn, sql, varargin)
%PG_EXEC  Executes a SQL query and returns a cursor object
%
%   Executes a SQL query and checks the result for errors. 
%   Returns the result set.
%
%   Syntax:
%   rs = pg_exec(conn, sql, varargin)
%
%   Input:
%   conn      = Database connection object
%   sql       = SQL query string
%   varargin  = none
%
%   Output:
%   rs        = Result set from SQL query
%
%   Example
%   pg_exec(conn, 'DELETE FROM someTable WHERE someColumn = 1');
%
%   See also pg_fetch, pg_select_struct, pg_insert_struct, pg_update_struct, exec

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

%% execute sql query

prefs = getpref('postgresql');

if ~isstruct(prefs) || ~isfield(prefs, 'passive') || ~prefs.passive
    
    rs = exec(conn, sql);

    pg_error(rs);
    
else
    
    if ~isfield(prefs, 'file') || isempty(prefs.file)
    
        disp(sql);
        
    else
        
        fid = fopen(prefs.file, 'a');
        fprintf(fid, '%s\n', sql);
        fclose(fid);
        
    end
    
end
