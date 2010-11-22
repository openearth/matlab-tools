function XBdims = xb_getdimensions(modeldir)
%XB_GETDIMENSIONS  Collect XBeach simulation metadata
%
%   This function reads the dims.dat and xy.dat files and returns a
%   structure containing all metadata available in these files
%
%   Syntax:
%   XBdims = xb_getdimensions(modeldir)
%
%   Input:
%   modeldir   = path of the XBeach simulation. If left empty it will read
%                the current directory
%
%   Output:
%   % Output structure XBdims
%    XBdims.nt       = number of regular spatial output timesteps
%    XBdims.nx       = number of grid cells in x-direcion
%    XBdims.ny       = number of grid cells in y-direcion
%    XBdims.ntheta   = number of theta bins in wave module
%    XBdims.kmax     = number of sigma layers in Quasi-3D model
%    XBdims.ngd      = number of sediment classes
%    XBdims.nd       = number of sediment class layers
%    XBdims.ntp      = number of point output timesteps
%    XBdims.ntc      = number of transect output timesteps
%    XBdims.ntm      = number of time-average output timesteps
%    XBdims.tsglobal = times at which regular output is given
%    XBdims.tspoints = times at which point output is given
%    XBdims.tsmean   = times at which time-averaged output is given
%    XBdims.x        = world x-coordinates grid
%    XBdims.y        = world y-coordinates grid
%    XBdims.xc       = x-coordinates calculation grid
%    XBdims.yc       = y-coordinates calculation grid
%
%   Example
%   xb_getdimensions
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Robert McCall
%
%       robert.mccall@deltares.nl
%
%       Rotterdamseweg 185
%       Delft
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
% Created: 22 Nov 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

if ~exist('modeldir','var')
    modeldir = pwd;
end
if isempty(modeldir)
    modeldir = pwd;
end

fid=fopen([modeldir filesep 'dims.dat'],'r');

XBdims.nt=fread(fid,[1],'double');
XBdims.nx=fread(fid,[1],'double');
XBdims.ny=fread(fid,[1],'double');
XBdims.ntheta=fread(fid,[1],'double');
XBdims.kmax=fread(fid,[1],'double');
XBdims.ngd=fread(fid,[1],'double');
XBdims.nd=fread(fid,[1],'double');
XBdims.ntp=fread(fid,[1],'double');
XBdims.ntc=fread(fid,[1],'double');
XBdims.ntm=fread(fid,[1],'double');
%     XBdims.version=-1*fread(fid,[1],'double');
XBdims.tsglobal=fread(fid,[XBdims.nt],'double');
XBdims.tspoints=fread(fid,[XBdims.ntp],'double');
XBdims.tscross=fread(fid,[XBdims.ntc],'double');
XBdims.tsmean=fread(fid,[XBdims.ntm],'double');
fclose(fid);
% end

fidxy=fopen([modeldir filesep 'xy.dat'],'r');
XBdims.x=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');
XBdims.y=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');
XBdims.xc=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');
XBdims.yc=fread(fidxy,[XBdims.nx+1,XBdims.ny+1],'double');
fclose(fidxy);