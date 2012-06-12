function result=ITHK_runUB(outputDir)
% Running Unibest Interactive Tool
% Leon de Jongste, Witteveen+Bos
% last edited: 15-03-2011

%% run Unibest-CL
% % method 1
% [status,result] = dos('COMPUTECLR.bat','-echo');
global S

% method 2
cd(S.settings.outputdir);
batchfileName='computeClrIT.bat';
[status,result] = system(batchfileName,'-echo');
cd(S.settings.basedir)