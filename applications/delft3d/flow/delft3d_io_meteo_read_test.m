function delft3d_io_meteo_read_test()
%DELFT3D_IO_METEO_READ_TEST   Test script for delft3d_io_meteo
%
%   reads test files created by delft3d_io_meteo_write_test
%
%See also: delft3d_io_meteo, delft3d_io_meteo_write, delft3d_io_meteo_write_test

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

Category(TestCategory.DataAccess);

%% Check wlsettings
if ~exist('wl_grid','file') || ...
        ~exist('vs_use','file') ||...
        ~exist('vs_let','file') ||...
        ~exist('vs_get','file')
    try
        wlsettings;
    catch
        if TeamCity.running
            TeamCity.ignore('This test needs wlsettings (wl_grid, vs_use etc.)');
            return;
        end
        error('This test needs wlsettings to run');
    end
end

%% Options

   OPT.cd        = [fileparts(mfilename('fullpath')),filesep];

%% Read files

   U = delft3d_io_meteo('read',which('delft3d_io_meteo_write_test.amu'));
   V = delft3d_io_meteo('read',which('delft3d_io_meteo_write_test.amv'));
   P = delft3d_io_meteo('read',which('delft3d_io_meteo_write_test.amp'));

%% plot

   figure
   pcolorcorcen(P.data.cen.x,P.data.cen.y,P.data.cen.air_pressure)
   hold on
   quiver2     (U.data.cen.x,U.data.cen.y,U.data.cen.x_wind,V.data.cen.y_wind,1e2,'k')
   axis equal
   axis tight
   print2a4([OPT.cd,'delft3d_io_meteo_read_test.png'],'v','t',200,'o');
   
   assert(exist([OPT.cd,'delft3d_io_meteo_read_test.png'],'file')==2,'Image was not created.');
   delete([OPT.cd,'delft3d_io_meteo_read_test.png']);
