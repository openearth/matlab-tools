%DELFT3D_IO_METEO_CURV_TEST   Test script for DELFT3D_IO_METEO_CURV

% wlsettings
% cd P:\mctools\mc_toolbox\
% mcsettings

OPT.export = 0;
OPT.pause  = 1;
OPT.case   = '1';


switch OPT.case

case '1'

   OPT.file   = '.\new_meteo_format_example\arc_info.amu';

   L = load('D:\HOME\MATLAB\TOOLBOXES\ldb\worldcoast.mat');
   
   D = delft3d_io_meteo_curv('read',OPT.file,'timestep',Inf);
   
   for timestep = 1:size(D.data.cen.x_wind,3)
   
      figure(1)
      pcolorcorcen(D.data.cen.lonSticks,...
                   D.data.cen.latSticks,...
                   D.data.cen.x_wind(:,:,timestep)');
                   
      colorbarwithtitle([D.data.keywords.quantity1,'[',D.data.keywords.unit1,']'])
      hold on
      plot(L.long,L.lat,'k')
      title([datestr(D.data.datenum(timestep)),' ',D.data.timezone{timestep}])
      
      figure(2)
      pcolorcorcen(D.data.cen.lon,...
                   D.data.cen.lat,...
                   D.data.cen.x_wind(:,:,timestep)');
                   
      colorbarwithtitle([D.data.keywords.quantity1,'[',D.data.keywords.unit1,']'])
      hold on
      plot(L.long,L.lat,'k')
      title([datestr(D.data.datenum(timestep)),' ',D.data.timezone{timestep}])
      
      if OPT.pause
         disp('pause')
         pause
      end
      
      if OPT.export
         print2screensize([OPT.file,'.',datestr(D.data.datenum(timestep),30),'.png'])
      end
   
   end
   
case '2'

   OPT.file   = '.\new_meteo_format_example\curvi.wnd';

   L = load('D:\HOME\MATLAB\TOOLBOXES\ldb\worldcoast.mat');
   
   D = delft3d_io_meteo_curv('read',OPT.file,'timestep',Inf);
   
   for timestep = 1:size(D.data.cen.x_wind,3)
   
      figure(1)
      pcolorcorcen(D.data.cen.lonSticks,...
                   D.data.cen.latSticks,...
                   D.data.cen.x_wind(:,:,timestep)');
                   
      colorbarwithtitle([D.data.keywords.quantity1,'[',D.data.keywords.unit1,']'])
      hold on
      plot(L.long,L.lat,'k')
      title([datestr(D.data.datenum(timestep)),' ',D.data.timezone{timestep}])
      
      figure(2)
      pcolorcorcen(D.data.cen.lon,...
                   D.data.cen.lat,...
                   D.data.cen.x_wind(:,:,timestep)');
                   
      colorbarwithtitle([D.data.keywords.quantity1,'[',D.data.keywords.unit1,']'])
      hold on
      plot(L.long,L.lat,'k')
      title([datestr(D.data.datenum(timestep)),' ',D.data.timezone{timestep}])
      
      if OPT.pause
         disp('pause')
         pause
      end
      
      if OPT.export
         print2screensize([OPT.file,'.',datestr(D.data.datenum(timestep),30),'.png'])
      end
   
   end

end % case   

%% EOF