[lat,lon] = meshgrid([51:54],[3:7]);

kmlline(lat ,lon ,'fileName','KMLline_testh.kml','lineColor',jet(2),'kmlName','horizontal','text',{'1','2','3','4'});
kmlline(lat',lon','fileName','KMLline_testv.kml','lineWidth',[1 3 3],'kmlName','vertical'  ,'text',{'a','b','c','d','e'});
