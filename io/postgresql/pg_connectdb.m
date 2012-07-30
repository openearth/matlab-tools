function conn = pg_connectdb(db, varargin)
%PG_CONNECTDB  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = pg_connectdb(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   pg_connectdb
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

%% read options

OPT = struct( ...
    'host',     'localhost', ...
    'port',     5432, ...
    'user',     '', ...
    'pass',     '', ...
    'schema',   '');

OPT = setproperty(OPT,varargin{:});

%% connect to database

conn = database( ...
    db, ...
    OPT.user, ...
    OPT.pass, ...
    'org.postgresql.Driver', ...
    ['jdbc:postgresql://' OPT.host ':' num2str(OPT.port) '/' db]);

% display message on error
if ~isempty(conn.message)
    error(conn.message)
else
    
    % set default schema, if given
    if ~isempty(OPT.schema)
        exec(conn, sprintf('SET search_path TO %s', OPT.schema));
    end
    
end
