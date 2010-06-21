function OK = opendap_catalog_test
%OPENDAP_CATALOG_TEST  regression test for OPENDAP_CATALOG
%
%See also: OPENDAP_CATALOG, OPENDAP_CATALOG_DATASET

OK = true;
if TeamCity.running
    TeamCity.ignore('Test takes too long');
    return;
end

%% Define tests
OPT.run      = [0 0  1 0  0 0  0 0 0    0 0]; % which tests to run
OPT.run      = [1 1  0 1  1 1  1 1 1    0 0]; % which tests to run
success      = [1 1  1 1  1 1  1 1 1    1 1]; % by default all tests get 1, they can only fail when active
OPT.log      = fopen('opendap_catalog_test.log','w+');

OPT.url      = {'http://opendap.deltares.nl/thredds/catalog/opendap/catalog.xml',...                                         
                'http://opendap.deltares.nl/opendap/catalog.xml',...                                                         
                'http://coast-enviro.er.usgs.gov/thredds/catalog.xml',...                                                    
                'http://data.nodc.noaa.gov/opendap/catalog.xml',...                                                          
                'http://coast-enviro.er.usgs.gov/thredds/ioos_catalog_top.xml',...                                           
                'http://data.nodc.noaa.gov/opendap/jason2/lost+found/catalog.xml',...                                        
                'http://opendap.deltares.nl/opendap/rijkswaterstaat/jarkus/grids/KMLpreview/jarkusKB112_4544/catalog.xml',... 
                'http://data.nodc.noaa.gov/opendap/NESDIS_DataCenters/metadata/Geomag_Stations/catalog.xml',...              
                'http://data.nodc.noaa.gov/opendap/woa/ANOMALY/catalog.xml',...                                              
                'http://coast-enviro.er.usgs.gov/thredds/roms_catalog.xml',...                                               
                'http://rocky.umeoce.maine.edu:8080/thredds/catalog.xml',...                                                 
                ''}; % dummy
  
OPT.file     = {'deltares_thredds',... %  66 sec DONE THREDDS
                'deltares_hyrax',...   %  75 sec DONE HYRAX
                'usgs',...             %  31 sec DONE THREDDS: at 2009 01 01 USGS was working on a THREDDS update, so this test temporarily fails
                'noaa',...             % 773 sec DONE HYRAX, up to 4 (5 takes waaaay to long, due to argo)
                'ioos_catalog_top',... %         DONE nested catalogs
                'Forbidden',...        %         DONE HYRAX Forbidden (403)
                'end1',...             %         DONE HYRAX end level catalog with self-reference
                'end2',...             %         DONE HYRAX end level catalog with self-reference
                'end3',...             %         DONE HYRAX end level catalog with self-reference
                'roms_catalog_top',... %         TO DO nested services
                'rocky',...            %         TO DO illogical catalog reference
                ''}; % dummy
 
OPT.toplevel = {'',...
                '',...
                '',...
                'http://data.nodc.noaa.gov/opendap/',...
                '',...
                'http://data.nodc.noaa.gov/opendap/',...
                'http://opendap.deltares.nl/opendap/',...
                'http://data.nodc.noaa.gov/opendap/',...
                'http://data.nodc.noaa.gov/opendap/',...
                '',...
                '',...
                ''}; % dummy

OPT.maxlevel = [Inf Inf Inf 4 Inf Inf Inf Inf Inf      Inf Inf nan];  % nan = dummy

%% Run tests

   for i=1:length(OPT.run)
   
   if OPT.run(i)
   
   
      disp(['opendap_catalog_test: loading ',OPT.url{i}])

      files = opendap_catalog(OPT.url{i},'maxlevel',OPT.maxlevel(i),...
                                         'toplevel',OPT.toplevel{i},...
                                         'log',OPT.log);
      savestr([OPT.file{i},'_',num2str(OPT.maxlevel(i)),'_',datestr(now,'yyyymmdd'),'.txt'],files);
      
      dir = fileparts(mfilename('fullpath'));
      fname = [dir,filesep,'opendap_regression_tests',filesep,OPT.file{i},'_',num2str(OPT.maxlevel(i)),'.txt'];
      files_regression = textread(fname,'%s');
      
      if ~(isempty(files) & isempty(files_regression))
         if ~isequal(files,files_regression)
            success(i) = 0;
            disp(['opendap_catalog_test: failed: ',OPT.url{i}])
         else
            disp(['opendap_catalog_test: OK    : ',OPT.url{i}])
         end
      else
            disp(['opendap_catalog_test: empty:  ',OPT.url{i}])
      end
      
   end
   
   end
   
   OK = all(success);

            disp(['all requested tests ran succesfully'])
