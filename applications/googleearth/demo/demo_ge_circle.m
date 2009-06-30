


X = 4;
R = 5e5;

output = [];

for Y = 10:10:70
   
   latStr = ['Latitude = ',num2str(Y)];
   
   output = [output,ge_circle(X,Y,R,...
                         'divisions',5,...
                             'name',latStr,... 
                        'lineWidth',5.0,...
                        'lineColor','b8ff0b20',...
                        'polyColor','00000000')];
end


kmlFileName = 'demo_ge_circle.kml';
kmlTargetDir = [''];%..',filesep,'kml',filesep];

ge_output([kmlTargetDir,kmlFileName], [output],'name',kmlFileName)