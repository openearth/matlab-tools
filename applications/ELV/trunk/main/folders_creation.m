%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%folders_creation is a function that created the folder where output may be stored.
%
%folders_creation(path_file_input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function folders_creation(path_file_input,fid_log)
% version='1';
% fprintf(fid_log,'folders_creation version: %s\n',version);

%%

[path_folder_main,~,~]=fileparts(path_file_input); %get path to main folder

%% folder figures
path_folder_figures=fullfile(path_folder_main,'figures'); %create path to figures folder

if exist(path_folder_figures,'dir')
    error('It already exists a figures folder, it seems you are going to overwrite results...')
else
    mkdir(path_folder_figures)
end

%% folder temporal output

path_folder_output=fullfile(path_folder_main,'TMP_output'); %create path to output folder

%folder output
if exist(path_folder_output,'dir')
    error('It already exists an output folder, it seems you are going to overwrite results...')
else
    mkdir(path_folder_output)
end
