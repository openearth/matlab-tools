%DELFT3D_IO_METEO_TEST   Test script for DELFT3D_IO_METEO
%
%   reads test files created by delft3d_io_meteo_write_test
%
%See also: DELFT3D_IO_METEO, DELFT3D_IO_METEO_WRITE, delft3d_io_meteo_write_test

%% Options

   OPT.cd        = [fileparts(mfilename('fullpath')),filesep];

%% Read files

   U = delft3d_io_meteo('read',[OPT.cd,'delft3d_io_meteo_write_test.amu']);
   V = delft3d_io_meteo('read',[OPT.cd,'delft3d_io_meteo_write_test.amv']);
   P = delft3d_io_meteo('read',[OPT.cd,'delft3d_io_meteo_write_test.amp']);

%% plot

   figure
   pcolorcorcen(P.data.cen.x,P.data.cen.y,P.data.cen.air_pressure)
   hold on
   quiver2     (U.data.cen.x,U.data.cen.y,U.data.cen.x_wind,V.data.cen.y_wind,1e2,'k')
   axis equal
   axis tight
   print2a4([OPT.cd,'delft3d_io_meteo_read_test.png'],'v','t')
