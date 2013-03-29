function s = pg_write_ewkb(S)
%PG_WRITE_EWKB  Write WKT struct to WKB (Well Known Binary) string
%
%   Read a WKT (Well Known Text) struct to a hexadecimal WKB (Well Known
%   Binary) string
%
%   Syntax:
%   s = pg_write_ewkb(S)
%
%   Input: 
%   S         = WKT struct
%
%   Output:
%   s         = WKB string
%
%   Example
%   WKB = pg_write_ewkb(S)
%   S   = pg_read_ewkb(WKB)
%
%   See also pg_read_ewkb, pg_write_ewkt, pg_read_ewkt

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

%% return hex string

chars = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'];
idx   = round(rand(1,100) * 15)+1;

s = chars(idx);

% ...
