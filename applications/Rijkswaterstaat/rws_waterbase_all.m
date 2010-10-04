function rws_waterbase_all
%RWS_WATERBASE_ALL    download waterbase.nl parameters from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_ALL,                   , RWS_WATERBASE_*
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

%% Initialize

   OPT.overwrite = 1;  % xls, png
   OPT.baseurl   = 'http://live.waterbase.nl';

  %urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
  %urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
   urlbase = 'http://opendap.deltares.nl:8080'; % production server

  %rawbase = 'P:\mcdata';                       % @ deltares internally
  % ncbase = 'P:\mcdata';                       % @ deltares internally
   rawbase = 'F:\checkouts\OpenEarthRawData';   % @ local
    ncbase = 'F:\opendap\thredds\';             % @ local
   
%% Parameter choice
   OPT.donar_wnsnum = [541];                 % empty location name/epsg id541-AALDK-164810240000-201006130000.txt epsg code missing
   OPT.donar_wnsnum = [410];                 % id410-BRESKBSD-179805240000-200907100000.txt issue to netCDF: vat: '' to 'emmer'
   OPT.donar_wnsnum = [1];                   % takes VEERY LONG

   OPT.donar_wnsnum = [ 22   23   24  559   44  ... %
                       282   29   54  410  209  ... %   
                       332  346  347  360  363  ... % 
                       364  380  491  492  493  ... % 
                       541  560 1083    1      ];   % 0=all or select number from 'donar_wnsnum' column in rws_waterbase_name2standard_name.xls

   DONAR = xls2struct([fileparts(mfilename('fullpath')) filesep 'rws_waterbase_name2standard_name.xls']);

   if  OPT.donar_wnsnum==0
       OPT.donar_wnsnum = DONAR.donar_wnsnum;
   end

   %% Parameter loop

   for ivar=[OPT.donar_wnsnum]

   disp(['Processing donar_wnsnum: ',num2str(ivar)])
      
   index = find(DONAR.donar_wnsnum==ivar);

      OPT.code              = DONAR.donar_wnsnum(index);
      OPT.donar_wnsnum      = DONAR.donar_wnsnum(index);
      OPT.donar_wns_oms     = DONAR.donar_wns_oms{index};
      OPT.donar_parcode     = DONAR.donar_parcode{index};
      OPT.standard_name     = DONAR.cf_standard_name{index};
      OPT.name              = DONAR.name{index};
      OPT.aquo_lex_code     = DONAR.aquo_lex_code{index};
      OPT.sdn_standard_name = DONAR.sdn_standard_name{index};

      subdir             = OPT.name;
      OPT.directory_nc   = [ ncbase,'\rijkswaterstaat\waterbase\'      ,filesep,subdir];
      OPT.directory_raw  = [rawbase,'\rijkswaterstaat\waterbase\cache\',filesep,subdir];
      
   %% Download from waterbase.nl
   
%     rws_waterbase_get_url_loop('donar_wnsnum' ,OPT.code,...
%                                'directory_raw',OPT.directory_raw,...
%                            'directory_raw_old',[OPT.directory_raw filesep 'old'],...
%                                      'cleanup',1); % remove date from file name> version control on cached download too ?
                                 
   %% Make netCDF
   
     if any(OPT.code==[1 54 29 22 23 24]) % long time series: waterlevels(1 54), Q(29) or waves(22 23 24)
        OPT.method='fgetl';
     else
        OPT.method='textread';
     end
   
     rws_waterbase2nc('donar_wnsnum' ,OPT.code,...
                      'directory_nc' ,OPT.directory_nc,...
                      'directory_raw',OPT.directory_raw,...
                             'method',OPT.method,... % 'fgetl' for water levels or discharges
                           'att_name',{'aquo_lex_code'           ,'donar_wnsnum'           ,'sdn_standard_name'},...
                            'att_val',{DONAR.aquo_lex_code(index),DONAR.donar_wnsnum(index),DONAR.sdn_standard_name(index) },...
                               'load',1,...% skip mat file, always load zipped txt file
                              'debug',0,...% check unit conversion
                               'mask',['id' num2str(OPT.code) '*.zip']);  % as more ids are in same dir

   %% Make overview png and xls of one parameter
   
     nc_cf_stationtimeseries2meta('directory_nc'  ,[OPT.directory_nc],...
                                  'parameters'    ,{OPT.name},...
                                  'overwrite'     ,OPT.overwrite);

% TO DO: option to overwrite xls and png, just as catalog.nc
% TO DO: merge nc_cf_stationtimeseries2meta and nc_cf_directory2catalog                             
   
   %% Make catalog.nc

      nc_cf_opendap2catalog([OPT.directory_nc],...
                            'save',1,...
                      'urlPathFcn',@(s) strrep(s,OPT.directory_nc,[OPT.linm_nc,'dodsC/opendap/',OPT.path]))

   %% Make KML overview with links to netCDF on opendap.deltares.nl
      
      OPT2.fileName           = [OPT.directory_nc,'.kml'];
      OPT2.kmlName            = [                                    'rijkswaterstaat/waterbase/' subdir];
      OPT2.HYRAXbase          = [urlbase,                   '/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.THREDDSbase        = [urlbase,     '/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.text               = {['parameter: '             ,       (OPT.name             ),...
                                  '<br> DONAR number: '     ,num2str(OPT.donar_wnsnum     ),...
                                  '<br> DONAR code: '       ,       (OPT.donar_parcode    ),... % '%O2 does not work
                                  '<br> DONAR description: ',num2str(OPT.donar_wns_oms    ),...
                                  '<br> CF standard name: ' ,       (OPT.standard_name    ) ,...
                                  '<br> BODC/SeaDataNet: '  ,       (OPT.sdn_standard_name),...
                                  '<br> Aquolex: '          ,       (OPT.aquo_lex_code    ),...
                                  '<br> source: <a href="',OPT.baseurl,'">Rijkswaterstaat</a>']};
     %OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
     %OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
     % add RWS logo
      OPT2.description        = {['source: Rijkswaterstaat (',OPT.baseurl,')']};
      OPT2.name               = OPT.name;
      
% TO DO: add units      
      
      % camera

      OPT2.lon         = 1;
      OPT2.lat         = 54;
      OPT2.z           = 100e4;

      nc_cf_stationtimeseries2kmloverview([OPT.directory_nc,'.xls'],OPT2);
      
      close all
      
end
   