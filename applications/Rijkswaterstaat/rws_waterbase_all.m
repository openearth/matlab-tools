function rws_waterbase_all
%RWS_WATERBASE_ALL    download waterbase.nl parameters from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_ALL,                   , RWS_WATERBASE_*
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

%% Initialize

  %urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
  %urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
   urlbase = 'http://opendap.deltares.nl:8080'; % production server

  %rawbase = 'P:\mcdata';                       % @ deltares internally
  % ncbase = 'P:\mcdata';                       % @ deltares internally
   rawbase = 'f:\checkouts\OpenEarthRawData';   % @ local
    ncbase = 'f:\opendap\thredds\';             % @ local
   
   OPT.donar_wnsnum = [209 332 346 347 360 363 364 380 491 492 493 541 560 1083]; % 0=all or select number from 'donar_wnsnum' column in rws_waterbase_name2standard_name.xls
   OPT.donar_wnsnum = [209 332]; % 0=all or select number from 'donar_wnsnum' column in rws_waterbase_name2standard_name.xls

%% Parameter choice

   DONAR = xls2struct([fileparts(mfilename('fullpath')) filesep 'rws_waterbase_name2standard_name.xls']);

   if  OPT.donar_wnsnum==0
       OPT.donar_wnsnum = DONAR.donar_wnsnum;
   end

   %% Parameter loop

   for ivar=[OPT.donar_wnsnum]

   disp(['Processing donar_wnsnum: ',num2str(ivar)])
      
   index = find(DONAR.donar_wnsnum==ivar);

      OPT.code           = DONAR.donar_wnsnum(index);
      OPT.standard_name  = DONAR.cf_standard_name{index};
      OPT.name           = DONAR.name{index};

      subdir             = OPT.name;
      OPT.directory_nc   = [ ncbase,'\rijkswaterstaat\waterbase\'      ,filesep,subdir];
      OPT.directory_raw  = [rawbase,'\rijkswaterstaat\waterbase\cache\',filesep,subdir];
      
   %% Download from waterbase.nl
%     rws_waterbase_get_url_loop('donar_wnsnum' ,OPT.code,...
%                                'directory_raw',OPT.directory_raw);
   
   %% Make netCDF
   
      rws_waterbase2nc('donar_wnsnum' ,OPT.code,...
                       'directory_nc' ,OPT.directory_nc,...
                       'directory_raw',OPT.directory_raw,...
                              'method','fgetl',... % 'fgetl' for water levels or discharges
                            'att_name',{'aquo_lex_code'           ,'donar_wnsnum'           ,'sdn_standard_name'},...
                             'att_val',{DONAR.aquo_lex_code(index),DONAR.donar_wnsnum(index),DONAR.sdn_standard_name(index) }); 
   %% Make overview png and xls
          
      nc_cf_stationtimeseries2meta('directory_nc'  ,[OPT.directory_nc],...
                                   'parameters'    ,{OPT.name});
   
   %% Make catalog.nc
   
      nc_cf_directory2catalog([OPT.directory_nc])
   
   %% Make KML overview with links to netCDF on opendap.deltares.nl
      
      OPT2.fileName           = [OPT.directory_nc,'.kml'];
      OPT2.kmlName            = [                                    'rijkswaterstaat/waterbase/' subdir];
      OPT2.HYRAXbase          = [urlbase,                   '/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.THREDDSbase        = [urlbase,     '/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdir,'/'];
      OPT2.description        = {['parameter: ',OPT.name],...
                                 'source: <a href="http://www.waterbase.nl">Rijkswaterstaat</a>'};
      OPT2.name               = OPT.name;
      OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
      OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
      
      % camera

      OPT2.lon = 1;
      OPT2.lat = 54;
      OPT2.z   = 100e4;

      nc_cf_stationtimeseries2kmloverview([OPT.directory_nc,'.xls'],OPT2);
      
end
   