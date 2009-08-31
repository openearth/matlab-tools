
lat = linspace(-90,90,1000)'; lon = linspace(0,5*360,1000)';
KMLline(lat,lon,'fileName',fullfile(tempdir,'line1.kml'));

[lat,lon] = meshgrid(10:.1:20,50:.1:60);
z = 30*(sin(lat)+cos(lon));
KMLline(lat ,lon ,z ,'fileName',fullfile(tempdir,'line2.kml'),'fillColor',  [1 0 0],'zScaleFun',@(z) (z+30)*100);
KMLline(lat',lon',z','fileName',fullfile(tempdir,'line3.kml'),'zScaleFun',@(z) (z+30)*120);