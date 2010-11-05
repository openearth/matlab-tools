function [x y data OPT] = surfer_read(filename)
%SURFER_READ  Reads surfers *.grd files
%
%   Syntax:
%   [x y data OPT] = surfer_read(filename)
%
%   Input:
%   filename = a surfer *.grd file
%
%   Output:
%   x        = vector with x coordinates
%   y        = vector with y coordinates
%   data     = the data in the grid (single precison)
%   OPT      = the metadata from the grid file
%
%   Example
%   [x y data OPT] = surfer_read(filename.grd)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com	
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% open grid file
fid         = fopen(filename);

%% read the limited meta data in the surfer grid file
OPT.id      = char(fread(fid,4,'char')');
OPT.size_x  =      fread(fid,1,'uint16');
OPT.size_y  =      fread(fid,1,'uint16');
OPT.min_x   =      fread(fid,1,'double');
OPT.max_x   =      fread(fid,1,'double');
OPT.min_y   =      fread(fid,1,'double');
OPT.max_y   =      fread(fid,1,'double');
OPT.min_val =      fread(fid,1,'double');
OPT.max_val =      fread(fid,1,'double');

%% read the contents of the file 
data        = nan(OPT.size_x,OPT.size_y);
data(1:end) = fread(fid,numel(data),'single');
data        = data';

%% close the file
fclose(fid);

%% set highest values to nan
data(data > 1e+037) = nan;

%% calculate x and y
x = linspace(OPT.min_x,OPT.max_x,OPT.size_x);
y = linspace(OPT.min_y,OPT.max_y,OPT.size_y);
