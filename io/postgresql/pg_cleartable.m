function pg_cleartable(conn, table, varargin)
%PG_CLEARTABLE  Deletes all contents from a table
%
%   Deletes all contents from a table and resets the primary key counter.
%
%   Syntax:
%   pg_cleartable(conn, table, varargin)
%
%   Input:
%   conn      = Database connection object
%   table     = Table to be cleared
%   varargin  = none
%
%   Output:
%   none
%
%   Example
%   conn = pg_connectdb('someDatabase');
%   pg_cleartable(conn, 'someTable');
%
%   See also pg_getpk, pg_gettables

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
% Created: 30 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% delete contents

pg_exec(conn, sprintf('DELETE FROM %s', table));

%% reset sequence

pg_exec(conn, sprintf('SELECT setval(''%s_%s_seq'', 1, FALSE)', table, pg_getpk(conn, table)));
