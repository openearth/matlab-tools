function knmi_all
%KNMI_ALL    download potwind + etmgeg from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_POTWIND_GET_URL,         KNMI_ETMGEG_GET_URL
%          KNMI_POTWIND2NC,              KNMI_ETMGEG2NC
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

   clear all
   close all

% TO DO: merge kmls for al substances

%% Initialize

   OPT.download       = 0; % get fresh downloads from rws and remove exisitng to sub dir old
   OPT.make_nc        = 1;
   OPT.make_catalog   = 1; % otherwise lod existing one
   OPT.make_kml       = 1;


   rawbase = 'F:\checkouts\OpenEarthRawData';                % @ local
    ncbase = 'F:\opendap.deltares.nl\thredds\dodsC\opendap'; % @ local
   urlbase = 'http://opendap.deltares.nl:8080';              % production server (links)
   kmlbase = 'F:\kml.deltares.nl\';                          % @ local, no links to other kml or images any more

   subdirs     = {'potwind','etmgeg'}; % take 9 and 14 mins respectively
   varnames    = {'wind_speed','air_temperature_mean'};
   resolveUrls = {'http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/',...
                  'http://www.knmi.nl/klimatologie/daggegevens/download.html'};
   
   multiWaitbar(mfilename,0,'label','Looping substances.','color',[0.3 0.8 0.3])

%% Parameter loop

n = 0;
for ii=1:length(subdirs)
n = n+1;
   
   subdir                = subdirs{ii};

   disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': '   ,subdirs{ii}])
      
   OPT.directory_nc      = [ ncbase,'\knmi\',filesep,subdir,filesep];
   OPT.directory_kml     = [kmlbase,'\knmi\',filesep,subdir,filesep];
   OPT.directory_raw     = [rawbase,'\knmi\',filesep,subdir,filesep,'raw',filesep];

   multiWaitbar(mfilename,n/length(subdirs),'label',['Processing substance: ',num2str(ii)])

%% Download from waterbase.nl and make netCDF

   if strcmpi(subdir,'potwind')
   
   KNMI_potwind_get_url        ('download'       , OPT.download,...
                                'directory_raw'  , OPT.directory_raw,...
                                'directory_nc'   , OPT.directory_nc,...
                                'nc'             , OPT.make_nc)
   elseif strcmpi(subdir,'etmgeg')
   
   KNMI_etmgeg_get_url         ('download'       , OPT.download,...
                                'directory_raw'  , OPT.directory_raw,...
                                'directory_nc'   , OPT.directory_nc,...
                                'nc'             , OPT.make_nc)
   end 

%% Make catalog.nc (and write human readable subset to catalog.xls)
%  make sure urlPath alreayd links to place where we are going to put them.
%  so we can copy catalog.nc together with the other nc files.
%  For making kml below we use local still files !
%  Idea: make a special *_local_machine catalog?

   if OPT.make_catalog
   CATALOG = nc_cf_opendap2catalog('base',[OPT.directory_nc],... % dir where to READ netcdf
                  'catalog_dir',[OPT.directory_nc],... % dir where to SAVE catalog
                         'save',1,...
                   'urlPathFcn',@(s) path2os(strrep(s,ncbase,['http://opendap.deltares.nl/thredds/dodsC/opendap/']),'h'),... % dir where to LINK to for netCDF
                      'varname','');
   else
   CATALOG = nc2struct([OPT.directory_nc,'catalog.nc']);
   end
      
%% Make KML overview with links to netCDFs on http://opendap.deltares.nl THREDDS

%  TO DO loop over varnames

   if OPT.make_kml

      OPT2.fileName           = [OPT.directory_kml,filesep,subdir,'.kml'];
      OPT2.kmlName            = ['KNMI/' subdir];
      OPT2.text               = {['<B>',subdir,'</B>']};

     %OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
     %OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';

      OPT2.description        = ['parameter: ',subdir,'source: <a href="http://www.knmi.nl">KNMI</a>'];
      OPT2.name               = subdir;
      
      OPT2.lon                = 1;
      OPT2.lat                = 54;
      OPT2.z                  = 100e4;
      OPT2.varname            = varnames{ii};
      
      OPT2.logokmlName        = 'Rijkswaterstaat logo';
      OPT2.overlayXY          = [.5 1];
      OPT2.screenXY           = [.5 1];
      OPT2.imName             = 'overheid.png';
      OPT2.logoName           = 'overheid4GE.png';
      OPT2.varPathFcn         = @(s) path2os(strrep(s,['http://opendap.deltares.nl/thredds/dodsC/opendap/'],ncbase),filesep); % use local netCDF files for preview/statistics when CATALOG refers already to server
      OPT2.resolveUrl         = cellfun(@(x) resolveUrls{ii},cellstr(CATALOG.station_name),'un',0);
      OPT2.resolveName        = 'www.knmi.nl';

      nc_cf_stationtimeseries2kmloverview(CATALOG,OPT2); % inside urlPath is used to read netCDF data

   end   
end
   