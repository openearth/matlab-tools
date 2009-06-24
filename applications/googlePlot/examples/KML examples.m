%% test1 griddata

url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB128_1312.nc';
x   = nc_varget(url,   'x',[     1],[     -1]);
y   = nc_varget(url,   'y',[   1  ],[  -1   ]);
z   = nc_varget(url,   'z',[1 1 1],[1 -1 -1]);
z = (z+30)*4;
[x,y] = meshgrid(x,y);
EPSG = load('D:\repositories\OpenEarth\matlab\applications\SuperTrans2.0\data\EPSG');
[lat,lon] = convertCoordinatesNew(x,y,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
[OPT] =  KMLsurf(lat,lon,z,'fileName','jarkusKB128_1312a1.kmz','polyOutline',0,'colorSteps',50,'fillAlpha',0.7,'reversePoly',false);


%% test2 JARKUS

url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect_new.nc';
       time = [  43  1];
 alongshore = [1  -1];
cross_shore = [   1 -1];
lat = nc_varget(url,     'lat',[        alongshore(1),cross_shore(1)],[        alongshore(2),cross_shore(2)]);
lon = nc_varget(url,     'lon',[        alongshore(1),cross_shore(1)],[        alongshore(2),cross_shore(2)]);
z   = nc_varget(url,'altitude',[time(1),alongshore(1),cross_shore(1)],[time(2),alongshore(2),cross_shore(2)]);

KMLline(lat,lon,'fileName','JARKUS2.kmz');


%% example 3 outline of vaklodingen
clear all
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen';
contents = opendap_folder_contents(url);
EPSG = load('EPSGnew');
for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x   = nc_varget(contents{ii},   'x');
    y   = nc_varget(contents{ii},   'y');
    x2 = [x(1) x(end) x(end) x(1) x(1)];
    y2 = [y(1) y(1) y(end) y(end) y(1)];
    [lat(:,ii),lon(:,ii)] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    text{ii} = fname;
end
KMLline(lat,lon,'fileName','vaklodingenOutlineDisco.kml','text',text,'lineColor',jet(length(lat2(1,:))))
KMLline(lat,lon,'fileName','vaklodingenOutline.kml'     ,'text',text,'lineColor',[0 0 0])

