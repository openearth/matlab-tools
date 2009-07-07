[lat,lon] = meshgrid([51:54],[3:7]);

kmlline(lat ,lon ,'fileName','KMLline_testh.kml','lineColor',[0 1 1],'kmlName','horizontal','text',{'a','b','c','d'});
kmlline(lat',lon','fileName','KMLline_testv.kml','lineColor',[1 0 0],'kmlName','vertical'  ,'text',{'a','b','c','d','e'});
