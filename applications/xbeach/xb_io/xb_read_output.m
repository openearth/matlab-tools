function variables = xb_read_output(fname, varargin)
%XB_READ_OUTPUT  Reads output files from XBeach
%
%   Reads output files from XBeach. The actual work is done by either the
%   xb_read_dat or xb_read_netcdf function. This function only determines
%   which one to use. Specific variables can be requested in the varargin
%   by means of an exact match, dos-like filtering or regular expressions
%   (see strfilter)
%
%   Syntax:
%   varargout = xb_read_output(fname, varargin)
%
%   Input:
%   fname       = Path to the directory containing the dat files, a dat
%                 file or the netcdf file to be read. This can also be a
%                 XBeach run structure, which is translated to a path.
%   varargin    = vars:         variable filters
%
%   Output:
%   varargout = XBeach structure array
%
%   Example
%   xb = xb_read_output('path_to_model/')
%   xb = xb_read_output('path_to_model/H.dat')
%   xb = xb_read_output('path_to_model/', 'vars', {'H', 'u*', '/_mean$'})
%   xb = xb_read_output('xboutput.nc')
%
%   See also xb_read_input, xb_write_input, xb_read_dat, xb_read_netcdf

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

%% read output

% user current directory, if no input is given
if ~exist('fname', 'var')
    fname = pwd;
end

% extract path, if xbeach structure is supplied
if xb_check(fname)
    fname = xb_get(fname, 'path');
end

if ~exist(fname, 'file')
    error(['File does not exist [' fname ']'])
end

% determine data type (dat/netcdf)
if isdir(fname) || strcmpi(fname(end-3:end), '.dat')
  variables = xb_read_dat(fname, varargin{:});
elseif strcmpi(fname(end-2:end), '.nc')
  variables = xb_read_netcdf(fname, varargin{:});
elseif isdir(fileparts(fname))
  variables = xb_read_dat(fileparts(fname), varargin{:});
else
    error(['Output type not recognised [' fname ']']);
end

% set meta data
variables = xb_meta(variables, mfilename, 'output', fname);

