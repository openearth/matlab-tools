function variables = xb_read_netcdf(fname, varargin)
%XB_READ_NETCDF  Reads NetCDF formatted output files from XBeach
%
%   Reads NetCDF formatted output file from XBeach in the form of an
%   XBeach structure. Specific variables can be requested in the varargin
%   by means of an exact match, dos-like filtering or regular expressions
%   (see xb_filter)
%
%   Syntax:
%   variables = xb_read_netcdf(fname, varargin)
%
%   Input:
%   fname       = filename of the netcdf file
%   varargin    = vars:     variable filters
%
%   Output:
%   variables   = XBeach structure array
%
%   Example
%   xb = xb_read_netcdf('xboutput.nc')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', 'H')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', 'H*')
%   xb = xb_read_netcdf('xboutput.nc', 'vars', '/_mean$')
%   xb = xb_read_netcdf('path_to_model/xboutput.nc', 'vars', {'H', 'u*', '/_min$'})
%
%   See also xb_read_output, xb_read_dat, xb_filter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Fedor Baart
%
%       fedor.baart@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'vars', {{}}, ...
    'start', [], ...
    'length', [], ...
    'stride', [] ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.vars); OPT.vars = {OPT.vars}; end;

%% read netcdf file

if ~exist(fname, 'file')
    error(['File does not exist [' fname ']'])
end

variables = xb_empty();

info = nc_info(fname);

XBdims = xb_read_dims(fname);

% store dims in xbeach struct
xb = xb_empty();
f = fieldnames(XBdims);
for i = 1:length(f)
    xb = xb_set(xb, f{i}, XBdims.(f{i}));
end
xb = xb_meta(xb, mfilename, 'dimensions', fname);
variables = xb_set(variables, 'DIMS', xb);

% read all variables that match filters
c = 2;
for i = 1:length({info.Dataset.Name})
    if ~isempty(OPT.vars) && ~any(xb_filter(info.Dataset(i).Name, OPT.vars)); continue; end;
    
    [start len stride] = xb_index(info.Dataset(i).Size, OPT.start, OPT.length, OPT.stride);
    
    variables.data(c).name = info.Dataset(i).Name;
    variables.data(c).value = nc_varget(fname, info.Dataset(i).Name, ...
        start, len, stride);
    
    c = c+1;
end

% set meta data
variables = xb_meta(variables, mfilename, 'output', fname);

