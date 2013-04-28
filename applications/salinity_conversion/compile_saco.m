oetsettings ('quiet','searchdb',false);
addpath(genpath('saco_ui'));
addpath(genpath('general'));

mcc -e -v saco

delete ('mccExcludedFiles.log','readme.txt');
