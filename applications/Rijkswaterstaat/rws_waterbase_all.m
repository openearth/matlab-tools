%function rws_waterbase_all
%RWS_WATERBASE_ALL    download waterbase.nl parameters from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_ALL,                   , RWS_WATERBASE_*
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

%% Initialize

   OPT.download       = 1; % get fresh downloads from rws and remove exisitng to sub dir old
   OPT.make_nc        = 1;
   OPT.make_kml       = 1;
   OPT.baseurl        = 'http://live.waterbase.nl';

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

   OPT.donar_wnsnum = [22 23 24]; % wave stuff: H, T, dir (SCHOUWBK,SANDTE,HARVMD disappeared with data from 1980's)
   OPT.donar_wnsnum = [24]; % wave stuff: H, T, dir (SCHOUWBK,SANDTE,HARVMD disappeared with data from 1980's)

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
      OPT.directory_nc   = [ ncbase,'\rijkswaterstaat\waterbase\'      ,filesep,subdir,filesep];
      OPT.directory_raw  = [rawbase,'\rijkswaterstaat\waterbase\cache\',filesep,subdir,filesep];
      
   %% Download from waterbase.nl
   
   if OPT.download
      rws_waterbase_get_url_loop('donar_wnsnum' ,OPT.code,...
                    'directory_raw',OPT.directory_raw,...
                'directory_raw_old',[OPT.directory_raw filesep 'old'],...
                          'cleanup',1); % remove date from file name> version control on cached download too ?
                                 
   end
   
   %% Read raw, cache as *.mat and make netCDF
   
   if OPT.make_nc
   
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
                                'load',1,...% skip cached mat file, always load zipped txt file
                               'debug',0,...% check unit conversion and more
                                'mask',['id' num2str(OPT.code) '*.zip']);  % as more ids are in same dir
   end

   %% Make catalog.nc (and write human readable subset to catalog.xls)

      CATALOG = nc_cf_opendap2catalog('base',[OPT.directory_nc],... % dir where to READ netcdf
                     'catalog_dir',[OPT.directory_nc],... % dir where to SAVE catalog
                            'save',1,...
                      ... % 'urlPathFcn',@(s) path2os(strrep(s,ncbase,['http://opendap.deltares.nl/thredds/dodsC/opendap/']),'h'),... % dir where to LINK to for netCDF
                         'varname','');

   %% Make KML overview with links to netCDF on opendap.deltares.nl
      
   if OPT.make_kml

      OPT2.fileName           = [OPT.directory_nc,filesep,subdir,'.kml'];
      OPT2.kmlName            = [                                    'rijkswaterstaat/waterbase/' subdir];
      OPT2.HYRAXbase          = [urlbase,                   '/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.THREDDSbase        = [urlbase,     '/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.text               = {['<B>',OPT.name,'</B>',...
                                  ' / DONAR number: '     ,num2str(OPT.donar_wnsnum     ),...
                                  ' / DONAR code: '       ,       (OPT.donar_parcode    ),... % '%O2 does not work
                                  ' / DONAR description: ',num2str(OPT.donar_wns_oms    ),...
                                  ' / CF standard name: ' ,       (OPT.standard_name    ) ,...
                                  ' / BODC/SeaDataNet: '  ,       (OPT.sdn_standard_name),...
                                  ' / Aquolex: '          ,       (OPT.aquo_lex_code    )]};

     %OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
     %OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';

      OPT2.description        = {['data: Rijkswaterstaat (',OPT.baseurl,'), presentation: www.OpenEarth.eu']};
      OPT2.name               = OPT.name;
      
      OPT2.lon                = 1;
      OPT2.lat                = 54;
      OPT2.z                  = 100e4;
      OPT2.varname            = subdir;
      
      OPT2.logokmlName        = 'Rijkswaterstaat logo';
      OPT2.overlayXY          = [.5 1];
      OPT2.screenXY           = [.5 1];
      OPT2.imName             = 'overheid.png';
      OPT2.logoName           = 'overheid4GE.png';
      
      nc_cf_stationtimeseries2kmloverview(CATALOG,OPT2); % inside urlPath is used to read netCDF data
      
      close all
      
   end  
      
end
   