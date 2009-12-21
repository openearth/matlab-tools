function knmi_all
%KNMI_ALL    download potwind + etmgeg from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_POTWIND_GET_URL,         KNMI_ETMGEG_GET_URL
%          KNMI_POTWIND2NC,              KNMI_ETMGEG2NC
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

% urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
% urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
  urlbase = 'http://opendap.deltares.nl:8080'; % production server
  locbase = 'P:\mcdata';
  locbase = 'F:\checkouts\';

%% POTWIND: Wind

  %OPT.directory_nc                           = [locbase,'\opendap\knmi\potwind\'];
   OPT.directory_nc                           = [locbase,'\OpenEarthRawData\KNMI\potwind\processed\'];
   KNMI_potwind_get_url                        ([locbase,'\OpenEarthRawData\KNMI\potwind'])
   knmi_potwind2nc             ('directory_raw',[locbase,'\OpenEarthRawData\KNMI\potwind\raw\'],...
                                'directory_nc', OPT.directory_nc)
   nc_cf_stationtimeseries2meta('directory_nc', OPT.directory_nc,...
                                'standard_names',{'wind_speed','wind_from_direction'},...
                                      'basename','potwind');
   nc_cf_directory2catalog                     (OPT.directory_nc)
   
%% ETMGEG: Daily meteo statistics

  %OPT.directory_nc                            = [locbase,'\opendap\knmi\etmgeg\'];
   OPT.directory_nc                            = [locbase,'\OpenEarthRawData\knmi\etmgeg\processed\'];
   KNMI_etmgeg_get_url                          ([locbase,'\OpenEarthRawData\KNMI\etmgeg'])
   knmi_etmgeg2nc              ('directory_raw' ,[locbase,'\OpenEarthRawData\knmi\etmgeg\raw\'],...
                                'directory_nc'  ,OPT.directory_nc);
   nc_cf_stationtimeseries2meta('directory_nc'  ,OPT.directory_nc,...
                                      'basename','etmgeg');
   nc_cf_directory2catalog                      (OPT.directory_nc)
   
%% Make KML
%  TO DO: do it also for etmgeg, without parameters

   subdirs        = {'potwind',...
                     'etmgeg'};
   standard_names = {'wind_speed',
                     ''};
   
   for ii=1:length(subdirs)
   
   disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': ',subdirs{ii}])
   
       directory           = [locbase,'\OpenEarthRawData\knmi\',subdirs{ii},'\processed\'];
   OPT2.fileName           = [directory,filesep,subdirs{ii},'.kml'];
   OPT2.kmlName            =  subdirs{ii};
   OPT2.THREDDSbase        = [urlbase,'/thredds/dodsC/opendap/knmi/',     subdirs{ii},'/'];
   OPT2.HYRAXbase          = [urlbase,'/opendap/knmi/',                   subdirs{ii},'/'];
   OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/knmi/',subdirs{ii},'/'];
   OPT2.standard_name      = standard_names{ii};
   OPT2.description        = {['parameter: ',OPT2.standard_name],...
                              'source: <a href="http://www.knmi.nl">KNMI</a>'};
   
   
   OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
   OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
   
   nc_cf_stationtimeseries2kmloverview([directory,filesep,subdirs{ii},'.xls'],OPT2);
   
   end
   