function xb = xb_read_ship(filename)
%XB_READ_SHIP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_read_ship(varargin)
%
%   Input: For <keyword,value> pairs call xb_read_ship() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_read_ship
%
%   See also

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

%% read ship file structure

if ~exist(filename, 'file')
    error('File not found: %s', filename);
end

fdir = fileparts(filename);
xb   = xs_empty();
fid  = fopen(filename, 'r');
n    = 1;

while ~feof(fid)
    xb(n) = xb_read_input(fullfile(fdir, fgetl(fid)));
    n     = n + 1;
end

fclose(fid);