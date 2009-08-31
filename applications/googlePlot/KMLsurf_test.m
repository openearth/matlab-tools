[lat,lon] = meshgrid(54:.1:57,2:.1:5);
z = peaks(31);
z = abs(z);

KMLsurf(lat   ,lon-5,z,'fileName',fullfile(tempdir,'KMLsurf_1.kml'),'zScaleFun',@(z) (z+1).*2000,'extrude',true,'polyOutline',true,'polyFill',false);
KMLsurf(lat+5 ,lon-5,z,'fileName',fullfile(tempdir,'KMLsurf_2.kml'),'colorMap',@(m) gray(m),'zScaleFun',@(z) (z.^2)*1000);
KMLsurf(lat+10,lon-5,z,'fileName',fullfile(tempdir,'KMLsurf_3.kml'),'zScaleFun',@(z) -log(z/100)*1000,'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'extrude',true,'polyOutline',true);
KMLsurf(lat+5,lon*10,z,'fileName',fullfile(tempdir,'KMLsurf_4.kml'),'zScaleFun',@(z) (z.^2)*1000,'cLim',[200 300]);