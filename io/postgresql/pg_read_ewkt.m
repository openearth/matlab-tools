function S = pg_read_ewkt(s)
%PG_READ_EWKT  Read WKT (Well Known Text) string into WKT struct
%
%   Read a WKT (Well Known Text) string into struct
%
%   Syntax:
%   S = pg_read_ewkt(s)
%
%   Input: 
%   s         = WKT string
%
%   Output:
%   S         = WKT struct
%
%   Example
%   S = pg_read_ewkt(s)
%   s = pg_write_ewkt(S)
%
%   See also pg_write_ewkt, pg_read_ewkb, pg_write_ewkb

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
% Created: 18 Jan 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% parse text

S = regexp(s, '(?<srid>\s*SRID\s*=\s*\d+\s*;)?\s*(?<type>\w+)\s*\((?<coords>.*)\)\s*$', 'names');

if isempty(S)
    error('Cannot parse WKT string');
end

%% parse srid

if isfield(S, 'srid') && ~isempty(S.srid)
    S.srid = str2num(regexprep(S.srid, '\s*SRID\s*=\s*(\d+)\s*;', '$1'));
else
    S.srid = 0;
end

%% parse coords

coords = regexp(S.coords, '\((.*?)\)', 'tokens');

if isempty(coords)
    coords = {{S.coords}};
end

S.coords = {};
for i = 1:length(coords)
    coords2 = regexp(coords{i}{1}, '\s*,\s*', 'split');
    for j = 1:length(coords2)
        S.coords{i}(j,:) = cellfun(@str2num, regexp(coords2{j}, '\s+', 'split'));
    end
end

if length(S.coords) == 1
    S.coords = S.coords{i};
end

%% parse dims

S.dims = {'x' 'y'};