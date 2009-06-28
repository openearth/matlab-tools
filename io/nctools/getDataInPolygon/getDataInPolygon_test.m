function getDataInPolygon_test

%% NB1: onderstaande testcases zijn met voorgedefinieerde polygonen. Als je de polygonen niet opgeeft mag je ze zelf selecteren met de crosshair (rechter muisknop om te sluiten)
%% NB2: de routines zijn nog niet 100% robuust. Ook is de data op de OpenDAP server nog niet helemaal goed. Met name dit laatste moet zsm verholpen worden!
%% NB3: enkele onderdelen van dit script zijn nog vrij sloom: bepalen welke grids er zijn en het ophalen van alle kaartbladomtrekken. Hopelijk is dit te fixen middels de Catalog.xml op de OPeNDAP server

%% Test 1: work on JARUS grids
if 0
getDataInPolygon(...
    'datatype', 'jarkus', ...
    'starttime', datenum([1997 01 01]), ...
    'searchwindow', -2*365, ...
    'polygon', [70796.8 438560
                78910.8 438779
	            78618.4 461001
	            70869.9 461001
	            70796.8 438560], ...
    'datathinning', 1); %#ok<*UNRCH>
end

%% Test 2: work on VAKLODINGEN grids
if 0
getDataInPolygon(...
    'datatype', 'vaklodingen', ...
    'starttime', datenum([1997 01 01]), ...
    'searchwindow', -5*365, ...
    'polygon', [50214.6 425346
	            50318.5 441438
	            60440.5 441386
	            60129 425398
	            50214.6 425346], ...
    'datathinning', 1);
end

%% Test 1: work on VAKLODINGEN grids
if 1
getDataInPolygon(...
    'datatype', 'vaklodingen', ...
    'starttime', datenum([2009 01 01]), ...
    'searchwindow', -5*365, ...
    'datathinning', 1);
end

% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB109_4746.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB112_5150.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB119_4342.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB136_0504.nc
% 
% url='ttp://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB138_1514'
% nc_dump(url)
% nc_varget(url,'time')
% 
% ans =
% 
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
%        -9999
       
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_1110.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_1110.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB135_1312.nc
% http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB134_1312.nc