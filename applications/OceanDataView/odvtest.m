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

OPT.pause        = 1;
OPT.plot         = 1;
OPT.kml          = 1;
OPT.basedir      = 'F:\checkouts\OpenEarthRawData\SeaDataNet\';

%% cast: CTD NIOZ
SET(1).vc                = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(1).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre630-270409_result\'];
SET(1).sdn_standard_name = 'P011::PSALPR02';
SET(1).clim              = [5 25];
SET(1).z                 = [];

%% samples: VOS: surface samples only
SET(2).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(2).directory         = [OPT.basedir,filesep,'userkc30e50-data_centre632-090210_result\'];
SET(2).sdn_standard_name = 'SDN:P011::PSSTTS01'; % Temperature of the water body by in-situ thermometer
SET(2).clim              = [5 25];
SET(2).z                 = [];

%% cast: CTD NIOZ
SET(3).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(3).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre630-2011-02-23_result\'];
SET(3).sdn_standard_name = 'SDN:P011::PSSTTS01'; % Temperature of the water body by in-situ thermometer
SET(3).clim              = [5 25];
SET(3).z                 = 'SDN:P011::PRESPS01';

%% samples: imares: surface samples only
SET(4).vc                = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc'
SET(4).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre633-230211_result\'];
SET(4).sdn_standard_name = 'SDN:P011::ODSDM021';% Salinity of the water body
SET(4).clim              = [5 25];
SET(4).z                 = [];

%% cast + samples (cast with 1 datapoint): TNO lithogaphy
SET(5).vc                = 'F:\opendap\thredds\deltares\landboundaries\northsea.nc'; % 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
SET(5).directory         = [OPT.basedir,filesep,'usergd30d98-data_centre635-210311_result\'];
SET(5).sdn_standard_name = 'SDN:P011::SEGMLENG';
SET(5).clim              = [5 25];
SET(5).z                 = 'SDN:P011::COREDIST';

for i=1 %1:length(SET)

   L = odv_metadata(SET(i).directory);

% Coastline of world
   
   L.lon = nc_varget(SET(i).vc,'lon');
   L.lat = nc_varget(SET(i).vc,'lat');
   
   clear D
   
% Cycle CDi

   for ifile=1:length(L.name);
       
      disp([num2str(ifile)])
   
      fname = L.name{ifile};
       
      set(gcf,'name',[num2str(ifile),': ',fname])
       
      jfile    = ifile;% = 1;
      
      D(jfile) = odvread([SET(i).directory,filesep,fname]);
       
      %odvdisp(D)
      
      %%
      clf
      if OPT.plot
       if D(jfile).cast==1
        odvplot_cast    (D(jfile),'lon',L.lon,'lat',L.lat,'sdn_standard_name',SET(i).sdn_standard_name,'z',SET(i).z);
       else
        odvplot_overview(D(jfile),'lon',L.lon,'lat',L.lat,'sdn_standard_name',SET(i).sdn_standard_name);
       end
      end
      
      % if OPT.kml
      %  if ~(D(jfile).cast==1)
      %   fnames{ifile} = [D(jfile).LOCAL_CDI_ID,'.kml'];
      %   odvplot_overview_kml(D(jfile),...
      %            'fileName',fnames{ifile},...
      %            'colorbar',0,...
      %   'sdn_standard_name',SET(i).sdn_standard_name,...
      %                'clim',SET(i).clim,...
      %           'colorMap',jet(24));
      %  end
      % end
      
      if OPT.pause
         disp(['processed # ',num2str([ifile,length(L.name);],'%0.3d/%0.3d'),', press key to continue'])
         pausedisp
      end

   end % ifile 

%% merge kml files

   % if OPT.kml
   %  if ~(D(jfile).cast==1)   
   %   fnames{end+1} = [last_subdir(SET(i).directory),'_colorbar.kml'];
   %   [~,pngname]=KMLcolorbar('CBcolorTitle',['water temperature [°C] (',SET(i).sdn_standard_name,')'],...
   %                             'CBfileName',fnames{end},...
   %                                 'CBclim',SET(i).clim,...
   %                             'CBcolorMap',jet(24));
   %   overallkml = [last_subdir(SET(i).directory),'.kml'];
   %   KMLmerge_files('sourceFiles',fnames,'fileName',overallkml);
   %   KML2kmz(overallkml,pngname)
   %   deletefile(fnames)
   %  end
   % end
   
%%   
   
   M = odv_merge(D,'sdn_standard_name',SET(i).sdn_standard_name)
   
%% kml with all data from downloaded set, encopassing multiple odv files
   
   KMLscatter(cell2mat(M.latitude),cell2mat(M.longitude),cell2mat(M.data),...
            ...% 'name',M.LOCAL_CDI_ID,... %      'description',['LOCAL_CDI_ID = ',M.LOCAL_CDI_ID,', cruise = ',M.cruise,', EDMO_code = ',num2str(M.EDMO_code)],...
            ...% 'html',M.LOCAL_CDI_ID,... %      'description',['LOCAL_CDI_ID = ',M.LOCAL_CDI_ID,', cruise = ',M.cruise,', EDMO_code = ',num2str(M.EDMO_code)],...
        'fileName',[last_subdir(SET(i).directory),'.kml'],...
          'timeIn',cell2mat(M.datenum)-1,...
         'timeOut',cell2mat(M.datenum)+1,...
         'kmlName',[last_subdir(SET(i).directory),'.kml'],...
'scalenormalState',2,'scalehighlightState',2,...
        'colorbar',1,...
            'cLim',[5 25],...
    'CBcolorTitle',[M.local_name,' (',M.local_units,')'])
   
   
end   

