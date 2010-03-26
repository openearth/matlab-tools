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

OPT(1).vc = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
OPT(2).vc = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';

%OPT(1).vc = 'F:\checkouts\OpenEarthRawData\deltares\landboundaries\processed\northsea.nc';
%OPT(2).vc = 'F:\checkouts\OpenEarthRawData\noaa\gshhs\processed\gshhs_i.nc';

OPT(1).directory = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-270409_result\'];
OPT(1).mask      = 'result_CTDCAST*.txt';

OPT(2).directory = [fileparts(mfilename('fullpath')),filesep,'userkc30e50-data_centre632-090210_result\'];
OPT(2).mask      = 'world*.txt';

OPT(1).variable  = 'P011::PSSTTS01';
OPT(2).variable  = 'P011::PSSTTS01';

OPT(1).clim      = [5 25];
OPT(2).clim      = [5 25];

OPT(1).kml       = 1;
OPT(2).kml       = 1;

for i=2%1:length(OPT)

   files     = dir([OPT(i).directory,filesep,OPT(i).mask]);

   % Coastline of world
   
      L.lon = nc_varget(OPT(i).vc,'lon');
      L.lat = nc_varget(OPT(i).vc,'lat');
   
   for ifile=1:length(files);
   
       fname = files(ifile).name;
       
       set(gcf,'name',[num2str(ifile),': ',fname])
   
       D = odvread([OPT(i).directory,filesep,fname]);
       
      %odvdisp(D)
      
       if D.cast==1
       odvplot_cast    (D,L.lon,L.lat)
       else
       odvplot_overview(D,'lon',L.lon,'lat',L.lat);
       
       if OPT(i).kml
       fnames{ifile} = [D.LOCAL_CDI_ID,'.kml'];
       odvplot_overview_kml(D,...
          'fileName',fnames{ifile},...
          'colorbar',0,...
          'variable',OPT(i).variable,...
              'clim',OPT(i).clim,...
          'colorMap',jet(24));
       end
       end
       
       disp(['plotting # ',num2str(ifile,'%0.3d'),', press key to continue'])
       clf
          
   end % ifile 
   
   if OPT(i).kml
   fnames{end+1} = [last_subdir(OPT(i).directory),'_colorbar.kml'];
   KMLcolorbar('colorTitle',['water temperature [°C] (',OPT(i).variable,')'],...
      'fileName',fnames{end},...
          'clim',OPT(i).clim,...
      'colorMap',jet(24));
   
   KMLmerge_files('sourceFiles',fnames,'fileName',[last_subdir(OPT(i).directory),'.kml']);
   end

end   

