basepath = fileparts(mfilename('fullpath'));
pth=[basepath filesep];

addpath(genpath([pth 'general']));
addpath(genpath([pth 'misc']));
addpath(genpath([pth 'ModelManager']));
addpath(genpath([pth 'OMSRunner']));
addpath(genpath([pth 'utils']));

clear pth
% cd /Users/fedorbaart/Documents/checkouts/baart_f/programs/matlab/operationalmodel/code

oetsettings;
wlsettings;
