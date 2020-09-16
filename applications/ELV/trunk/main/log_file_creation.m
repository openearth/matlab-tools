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
%log_file_creation is a function that creates the log file
%
%fid_log=log_file_creation(path_file_input)
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

function fid_log=log_file_creation(path_file_input)

%%

[path_folder_main,~,~]=fileparts(path_file_input); %get path to main folder
path_file_log=fullfile(path_folder_main,'log.txt');

%if exist(path_file_log,'file')
    %error('It already exists a log file, it seems you are going to overwrite results...')
%else
    [~,name_computer]=system('hostname'); %get computer name
    name_user=getenv('username'); %get username
    
    fid_log=fopen(path_file_log,'w'); %file identifier of log
    fprintf(fid_log,'%s\n%s\n%s\n','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%','%%                                    ELV                                    %%','%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of simulation');
    fprintf(fid_log,'computer: %s',name_computer);
    fprintf(fid_log,'user: %s\n',name_user);
    fprintf(fid_log,'matlab version: %s\n',version);
    
end