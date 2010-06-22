function knmi_all
%KNMI_ALL    download potwind + etmgeg from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_POTWIND_GET_URL,         KNMI_ETMGEG_GET_URL
%          KNMI_POTWIND2NC,              KNMI_ETMGEG2NC
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

% urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
% urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
  urlbase = 'http://opendap.deltares.nl:8080'; % production server

%% POTWIND: Wind

   OPT.directory_nc                            = ['F:\opendap\thredds\knmi\potwind\'];
%  KNMI_potwind_get_url        ('directory_cache','F:\checkouts\OpenEarthRawData\KNMI\potwind\cache\'',...
%                               'directory_raw'  ,'F:\checkouts\OpenEarthRawData\KNMI\potwind\raw\',...
%                               'directory_nc'   , OPT.directory_nc)
%  nc_cf_stationtimeseries2meta('directory_nc'   , OPT.directory_nc,...
%                                'standard_names',{'wind_speed','wind_from_direction'},...
%                                      'basename','potwind');
%  nc_cf_directory2catalog                      (OPT.directory_nc)
   
%% ETMGEG: Daily meteo statistics

   OPT.directory_nc                            = ['F:\opendap\thredds\knmi\etmgeg\'];
%  KNMI_etmgeg_get_url         ('directory_cache','F:\checkouts\OpenEarthRawData\KNMI\etmgeg\cache\'',...
%                               'directory_raw'  ,'F:\checkouts\OpenEarthRawData\KNMI\etmgeg\raw\',...
%                               'directory_nc'   , OPT.directory_nc);
%  nc_cf_stationtimeseries2meta('directory_nc'   , OPT.directory_nc,...
%                                      'basename','etmgeg');
%  nc_cf_directory2catalog                       (OPT.directory_nc)
   
%% Make KML
%  TO DO: do it also for etmgeg, without parameters

   opendap_base   = 'F:\opendap\thredds\knmi\';
   subdirs        = {'potwind',...
                     'etmgeg'};
   names = {'wind_speed',''};
   
   for ii=1:length(subdirs)
   
   disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': '   ,subdirs{ii}])
   
   OPT2.fileName           = [opendap_base,filesep,subdirs{ii},'.kml'];
   OPT2.kmlName            =  subdirs{ii};
   OPT2.THREDDSbase        = [urlbase,'/thredds/dodsC/opendap/knmi/',     subdirs{ii},'/'];
   OPT2.HYRAXbase          = [urlbase,'/opendap/knmi/',                   subdirs{ii},'/'];
   OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/knmi/',subdirs{ii},'/'];
   OPT2.name               = names{ii};
   OPT2.description        = ['parameter: ',OPT2.name,'source: <a href="http://www.knmi.nl">KNMI</a>'];
   
   
   OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
   OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
   OPT2
   nc_cf_stationtimeseries2kmloverview([opendap_base,filesep,subdirs{ii},filesep,subdirs{ii},'.xls'],OPT2);
   
   end
   