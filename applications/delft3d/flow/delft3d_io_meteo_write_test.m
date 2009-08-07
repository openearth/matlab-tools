%DELFT3D_IO_METEO_WRITE_TEST   test for DELFT3D_IO_METEO_WRITE
%
%   creates a field of (p,u,v), writes it to curvi-linear delft3d meteo 
%   files, with files for a delft3d simulation that can swallow them, for 
%   subsequent use by delft3d_io_meteo_read_test.
%
%See also: DELFT3D_IO_METEO, DELFT3D_IO_METEO_WRITE, DELFT3D_IO_METEO_READ_TEST

%% Options

   OPT.tstart    = floor(now);
   OPT.dt        = 1;
   OPT.tstop     = floor(now)+OPT.dt;
   OPT.refdate   = datenum(1970,1,1);
   OPT.cd        = [fileparts(mfilename('fullpath')),filesep];
   OPT.grid_file = [OPT.cd,mfilename,'.grd'];

%% Create a grid file

  [P.x,P.y] = ndgrid(-2:.1:2,-3:.1:3);
   P.p      = 10.*peaks(P.x,P.y)+1e5;
  [P.dpdx,...
   P.dpdy]  = gradient(P.p);
   P.u      = + P.dpdx;
   P.v      = - P.dpdy;
   P.x      = P.x.*1e4;
   P.y      = P.y.*1e4;
   P.header = 'wind based on peaks() as streamfunction';

   fid(1)   = delft3d_io_meteo_write([OPT.cd,mfilename,'.amu'],OPT.tstart,P.u,P.x,P.y,'CoordinateSystem','Cartesian','quantity','x_wind'      ,'unit','m s-1','grid_file',OPT.grid_file,'header',P.header);
   fid(2)   = delft3d_io_meteo_write([OPT.cd,mfilename,'.amv'],OPT.tstart,P.v,P.x,P.y,'CoordinateSystem','Cartesian','quantity','y_wind'      ,'unit','m s-1','grid_file',OPT.grid_file,'header',P.header);
   fid(3)   = delft3d_io_meteo_write([OPT.cd,mfilename,'.amp'],OPT.tstart,P.p,P.x,P.y,'CoordinateSystem','Cartesian','quantity','air_pressure','unit','mbar' ,'grid_file',OPT.grid_file,'header',P.header);
   
              delft3d_io_meteo_write(fid(1)                   ,OPT.tstop ,P.u,'CoordinateSystem','Cartesian','quantity','x_wind'      ,'unit','m s-1');
              delft3d_io_meteo_write(fid(2)                   ,OPT.tstop ,P.v,'CoordinateSystem','Cartesian','quantity','y_wind'      ,'unit','m s-1');
              delft3d_io_meteo_write(fid(3)                   ,OPT.tstop ,P.p,'CoordinateSystem','Cartesian','quantity','air_pressure','unit','mbar' );

%% Create a test simulation
%  create flow grid where centers are at the corners of the meteo grid

   P.cor.x = center2corner(P.x);
   P.cor.y = center2corner(P.y);   
   
   wlgrid('write','filename',[OPT.cd,'delft3d_io_meteo.grd'],'X',P.cor.x,'Y',P.cor.y,'CoordinateSystem','Cartesian','Format','NewRGF');

   MDF = delft3d_io_mdf('read',[OPT.cd,'delft3d_io_meteo.mdf']);
   
   MDF.keywords.mnkmax  = [size(P.cor.x,1)+1 size(P.cor.x,2)+1 1];
   MDF.keywords.depuni  = 1e3;
   MDF.keywords.tstart  = (OPT.tstart - OPT.refdate).*24*60;
   MDF.keywords.tstop   = (OPT.tstop  - OPT.refdate).*24*60;
   MDF.keywords.dt      = (OPT.dt                  ).*24*60;
   MDF.keywords.itdate  = datestr(OPT.refdate,'yyyy-mm-dd');
   MDF.keywords.filcco  = [OPT.cd,'delft3d_io_meteo.grd'];
   MDF.keywords.fwndgu  = [mfilename,'.amu'];
   MDF.keywords.fwndgv  = [mfilename,'.amv'];
   MDF.keywords.fwndgp  = [mfilename,'.amp'];
   MDF.keywords.flmap   = [(OPT.tstart - OPT.refdate) OPT.dt (OPT.tstop  - OPT.refdate)].*24*60;
   MDF.keywords.flhis   = [(OPT.tstart - OPT.refdate)      0 (OPT.tstop  - OPT.refdate)].*24*60;

   
   MDF = delft3d_io_mdf('write',[OPT.cd,'delft3d_io_meteo_test.mdf'],MDF.keywords);

%% plot

   figure
   pcolorcorcen(P.x,P.y,P.p)
   hold on
   quiver2(P.x,P.y,P.u,P.v,1e2,'k')
   axis equal
   axis tight
   print2a4([OPT.cd,'delft3d_io_meteo_write_test.png'],'v','t')
   
%% run simulation   

%% run DELFT3D_IO_METEO_TEST

   h = vs_use([OPT.cd,'trim-delft3d_io_meteo_test'])
   
   M        = vs_meshgrid2dcorcen(h);
   M.p      = vs_let_scalar      (h,'map-series',{1}, 'PATM');
   M.u      = vs_let_scalar      (h,'map-series',{1}, 'WINDU');
   M.v      = vs_let_scalar      (h,'map-series',{1}, 'WINDV');
   
   figure
   pcolorcorcen(M.cen.x,M.cen.y,M.p)
   hold on
   quiver2(M.cen.x,M.cen.y,M.u,M.v,1e2,'k')
   axis equal
   axis tight
   print2a4([OPT.cd,'delft3d_io_meteo_delft3d_test.png'],'v','t')
   
   