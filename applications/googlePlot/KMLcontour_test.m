[lat,lon] = meshgrid(54:.1:57,2:.1:5);
z = peaks(31);
z = abs(z);

KMLcontour(lat   ,lon,z,'fileName',fullfile(tempdir,'contour1.kml'),'zScaleFun',@(z) (z+1)*2000,'writeLabels',true);
KMLcontour(lat+5 ,lon,z,'fileName',fullfile(tempdir,'contour2.kml'),'writeLabels',false,'colorMap',@(m) gray(m));
KMLcontour(lat+10,lon,z,'fileName',fullfile(tempdir,'contour3.kml'),'is3D',false,'writeLabels',false,'cLim',[-10 10],'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m));
KMLcontour(lat+10,lon*10,z,'fileName',fullfile(tempdir,'contour4.kml'),'zScaleFun',@(z) (z.^2)*10000,'writeLabels',true,'cLim',[200 300],'labelDecimals',4);