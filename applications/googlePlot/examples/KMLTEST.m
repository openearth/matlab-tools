%% test1
load('D:\work\KML\waddenzeeinkleur.mat');
x = D.x;
y = D.y;
z = min(1,D.z);
EPSG = load('D:\repositories\OpenEarth\matlab\applications\SuperTrans2.0\data\EPSG');
[lon,lat] = convertCoordinatesNew(x,y,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
  KMLsurf(lat ,lon ,-z*1000+1000,'fileName',  'Waddenzee_surf.kmz','polyOutline',1,'polyFill',1,'reversePoly',true);
  KMLpcolor(lat ,lon ,z          ,'fileName''polyOutline',1,'polyFill',1,'fillAlpha',0.7,'colorSteps',50,'reversePoly',true);
  KMLline(lat ,lon ,'fileName','Waddenzee_linesA.kmz','lineColor',hot(length(lat(1,:))));
  KMLline(lat',lon','fileName','Waddenzee_linesB.kmz','lineColor',hsv(length(lat(:,1))));

 KMLline3(lat',lon',-z'*1000+1000,'fileName','Waddenzee_linesB.kmz','lineColor',hsv(length(lat(:,1))));

  
  KMLupload('Waddenzee_pcolor.kmz')
%% test2 griddata

url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids/jarkusKB128_1312.nc';
x   = nc_varget(url,   'x',[     1],[     -1]);
y   = nc_varget(url,   'y',[   1  ],[  -1   ]);
z   = nc_varget(url,   'z',[1 1 1],[1 -1 -1]);
z = (z+30)*4;
[x,y] = meshgrid(x,y);
EPSG = load('D:\repositories\OpenEarth\matlab\applications\SuperTrans2.0\data\EPSG');
[lon,lat] = convertCoordinatesNew(x,y,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
[OPT] =  KMLsurf(lat,lon,z,'fileName','jarkusKB128_1312a1.kmz','polyOutline',0,'colorSteps',50,'fillAlpha',0.7,'reversePoly',false);


%% test3 JARKUS

url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect_new.nc';
       time = [  43  1];
 alongshore = [1  -1];
cross_shore = [   1 -1];
lat = nc_varget(url,     'lat',[        alongshore(1),cross_shore(1)],[        alongshore(2),cross_shore(2)]);
lon = nc_varget(url,     'lon',[        alongshore(1),cross_shore(1)],[        alongshore(2),cross_shore(2)]);
z   = nc_varget(url,'altitude',[time(1),alongshore(1),cross_shore(1)],[time(2),alongshore(2),cross_shore(2)]);

KMLline(lat,lon,'fileName','JARKUS2.kmz');