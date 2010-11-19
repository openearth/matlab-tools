function XBdims = xb_read_dims(filename)
%XB_READ_DIMS  read dimensions from xbeach output
%
%   Routine to read the dimension from either netcdf of .dat xbeach output.
%   The input argument "filename" can be the directory of the xbeach
%   output, the "dims.dat" file or the "xboutput.nc" file. In case
%   "filename" is a directory, it is assumed that the dimensions should be
%   read from the "dims.dat" file inside the given directory.
%
%   Syntax:
%   XBdims   = xb_read_dims(varargin)
%
%   Input:
%   filename = file name. This can either be a output folder, a dims.dat file
%              or a xboutput.nc file.
%
%   Output:
%   XBdims   = structure containing the dimensions of xbeach output
%              variables
%
%   Example
%   xb_read_dims
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if nargin == 0
    % the current working directory is taken by default
    filename = cd;
end

if isdir(filename)
    % assume the filename to be the dims.dat file in the given directory
    filename = fullfile(filename, 'dims.dat');
    
    if ~exist(filename, 'file')
        error(['"' filename '" is not found.'])
    end
end

% derive extension
[fpath fname extension] = fileparts(filename);

if strcmpi(extension, '.nc')
    % obtain info from netcdf file
    info = nc_info(url);
    
    % pre-allocate XBdims
    XBdims = struct();
    
    % put dimensions in structure
    for ivar = 1:length(info.Dimension)
        XBdims.(info.Dimension(ivar).Name) = info.Dimension(ivar).Length;
    end
    
elseif strcmpi(extension, '.dat')
    % read dimensions from dims.dat file
    fid = fopen(filename, 'r');
    XBdims.nt = fread(fid, 1, 'double');
    XBdims.nx = fread(fid, 1, 'double');
    XBdims.ny = fread(fid, 1, 'double');
    XBdims.ntheta = fread(fid, 1, 'double');
    XBdims.kmax = fread(fid, 1, 'double');
    XBdims.ngd = fread(fid, 1, 'double');
    XBdims.nd = fread(fid, 1, 'double');
    XBdims.ntp = fread(fid, 1, 'double');
    XBdims.ntc = fread(fid, 1, 'double');
    XBdims.ntm = fread(fid, 1, 'double');
    XBdims.tsglobal = fread(fid, [XBdims.nt], 'double');
    XBdims.tspoints = fread(fid, [XBdims.ntp], 'double');
    XBdims.tscross = fread(fid, [XBdims.ntc], 'double');
    XBdims.tsmean = fread(fid, [XBdims.ntm], 'double');
    fclose(fid);
    
    % read dimensions from xy.dat file
    xyfile = fullfile(fpath,'xy.dat');
    fidxy = fopen(xyfile ,'r');
    XBdims.x = fread(fidxy, [XBdims.nx XBdims.ny] + 1, 'double');
    XBdims.y = fread(fidxy, [XBdims.nx XBdims.ny] + 1, 'double');
    XBdims.xc = fread(fidxy, [XBdims.nx XBdims.ny] + 1, 'double');
    XBdims.yc = fread(fidxy, [XBdims.nx XBdims.ny] + 1, 'double');
    fclose(fidxy);
else
    error(['extension "' extension '" not valid'])
end