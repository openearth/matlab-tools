function demo_ge_output()%% Demo ge_output
 error('%s has been deprecated',mfilename)

kmlTargetDir = [''];%..',filesep,'kml',filesep];
kmlFileName01 = 'demo_ge_output1.kml';
kmlFileName02 = 'demo_ge_output2.kmz';

kmlStr01 = ge_point(5,5,5);
kmlStr02 = ge_point(6,6,6);

ge_output([kmlTargetDir,kmlFileName01],kmlStr01,...
                                         'name',kmlFileName01);

ge_output([kmlTargetDir,kmlFileName02],kmlStr02,...
                                         'name',kmlFileName02);

