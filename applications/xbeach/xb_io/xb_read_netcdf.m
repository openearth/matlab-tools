function variables = xb_read_netcdf(fname, varargin)
%XB_READ_NETCDF  Reads NetCDF formatted output files from XBeach
%
%   Reads NetCDF formatted output file from XBeach in the form of an
%   XBeach structure.
%
%   Syntax:
%   variables = xb_read_netcdf(fname, varargin)
%
%   Input:
%   fname       = filename of the netcdf file
%   varargin    = none
%
%   Output:
%   variables   = XBeach structure array
%
%   Example
%   variables = xb_read_output('outputdir')
%   assert(ismember({variables.name},  'xw'})
%   variables = xb_read_output('outputdir', 'variables', {'yw','zs'},
%   timestepindex, 100}
%   assert(~ismember({variables.name},  'xw'})
%
%   See also xb_read_output, xb_read_dat

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


%%

if ~exist(fname, 'file')
    error(['File does not exist [' fname ']'])
end

variables = xb_empty();

info = nc_info(fname);
% Read all variables
for (i=1:length({info.Dataset.Name}))
    variables.data(i).name = info.Dataset(i).Name;
    variables.data(i).value = nc_varget(fname, info.Dataset(i).Name);
end

% set meta data
variables = xb_meta(variables, mfilename, 'output', fname);

