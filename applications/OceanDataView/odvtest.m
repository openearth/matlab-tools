%ODVTEST   script to test ODVRREAD, ODVDISP, ODVPLOT_CAST, ODVPLOT_OVERVIEW
%
% plots all CTDCAST files in a directory one by one, in Matlab and in Google Earth.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL
% $Keywords:

% TO DO  only one kml colorbar L

OPT.pause = 0;
OPT.plot  = 1;
OPT.kml   = 1;

SET(1).vc = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(2).vc = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';

SET(1).vc = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc';
SET(2).vc = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc';

SET(1).directory = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-270409_result\'];
SET(1).mask      = 'result_CTDCAST*.txt';

SET(2).directory = [fileparts(mfilename('fullpath')),filesep,'userkc30e50-data_centre632-090210_result\'];
SET(2).mask      = 'world*.txt';

SET(1).variable  = 'P011::PSALPR02';
SET(2).variable  = 'P011::PSSTTS01';

SET(1).clim      = [5 25];
SET(2).clim      = [5 25];

for i=1:length(SET)

   files     = dir([SET(i).directory,filesep,SET(i).mask]);

   % Coastline of world
   
   L.lon = nc_varget(SET(i).vc,'lon');
   L.lat = nc_varget(SET(i).vc,'lat');
   
   clear D
   
   for ifile=1:length(files);
   
      fname = files(ifile).name;
       
      set(gcf,'name',[num2str(ifile),': ',fname])
       
      jfile    = ifile;% = 1;
      D(jfile) = odvread([SET(i).directory,filesep,fname]);
       
      %odvdisp(D)
      
      disp(['plotting # ',num2str(ifile,'%0.3d'),', press key to continue'])
      clf

      if OPT.plot
      if D(jfile).cast==1
      odvplot_cast    (D(jfile),'lon',L.lon,'lat',L.lat,'variable',SET(i).variable)
      else
      odvplot_overview(D(jfile),'lon',L.lon,'lat',L.lat,'variable',SET(i).variable);
      end
      end
      
      if OPT.kml
      fnames{ifile} = [D(jfile).LOCAL_CDI_ID,'.kml'];
      odvplot_overview_kml(D(jfile),...
         'fileName',fnames{ifile},...
         'colorbar',0,...
         'variable',SET(i).variable,...
             'clim',SET(i).clim,...
         'colorMap',jet(24));
      end
      
   
      if OPT.pause
         pausedisp
      end

   end % ifile 
   
   if OPT.kml
   fnames{end+1} = [last_subdir(SET(i).directory),'_colorbar.kml'];
   KMLcolorbar('CBcolorTitle',['water temperature [°C] (',SET(i).variable,')'],...
                 'CBfileName',fnames{end},...
                     'CBclim',SET(i).clim,...
                 'CBcolorMap',jet(24));
   
   KMLmerge_files('sourceFiles',fnames,'fileName',[last_subdir(SET(i).directory),'.kml']);
   end
   
end   

