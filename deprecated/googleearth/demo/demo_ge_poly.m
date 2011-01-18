function demo_ge_poly()%% Demo ge_poly 
 error('%s has been deprecated',mfilename)

load([pwd,filesep,'data',filesep,'conus.mat']);

world_coasts = ge_poly(uslon,uslat,...
                       'polyColor','9933ffff',...
                        'altitude',150000,...
                    'altitudeMode','relativeToGround',...
                         'extrude',1,...
                      'tessellate',true);
                  
kmlFileName = 'demo_ge_poly.kml';
kmlTargetDir = [''];%..',filesep,'kml',filesep];
ge_output([kmlTargetDir,kmlFileName],world_coasts,...
                              'name',kmlFileName);




