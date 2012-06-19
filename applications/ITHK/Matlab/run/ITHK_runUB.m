function result=ITHK_runUB(outputDir)
% Running Unibest Interactive Tool
% Leon de Jongste, Witteveen+Bos
% last edited: 15-03-2011

global S

%% run Unibest-CL
curdir=cd;
cd(S.settings.outputdir);
batchfileName='computeClrIT.bat';
[status,result] = system(batchfileName,'-echo');
cd(curdir);