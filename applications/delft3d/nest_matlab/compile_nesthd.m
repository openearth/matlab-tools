addpath(genpath('..\..\..\..\matlab'));
addpath(genpath('nest_ui'));
addpath(genpath('nesthd1'));
addpath(genpath('nesthd2'));
addpath(genpath('general'));
addpath(genpath('reawri'));

mcc -e -v nesthd

delete ('mccExcludedFiles.log'        ,'readme.txt' );
