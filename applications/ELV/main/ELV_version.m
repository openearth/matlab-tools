%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: ELV_version.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/ELV_version.m $
%
%ELV_version is a function that writes the version of each function in the log file
%
%ELV_version(fid_log)
%
%INPUT:
%   -fid_log = file identifier
%
%OUTPUT:
%   -
%
%HISTORY:

function ELV_version(fid_log)


fprintf(fid_log,'----------------------- \n'); 
fprintf(fid_log,'---ELV files version--- \n'); 

%% PATHS

paths_ELV=fullfile(pwd,'..\');
paths_main=fullfile(pwd,'..\main');

%% CALC

%ONLY MAIN
path_f1=dir(paths_main);
n_f1=size(path_f1,1);
for kf=3:n_f1
    [~,~,ext]=fileparts(path_f1(kf).name);
    if strcmp(ext,'.m')
        %% FUNCTION TO FILE
        path_file_in=fullfile(paths_main,path_f1(kf).name);
        fid_m=fopen(path_file_in,'r'); %file identifier of the file               
        for k=1:13 %at line 13 we have what we want
            id_line=fgets(fid_m);
        end
        fclose(fid_m);
        fprintf(fid_log,'%s',id_line); 
    end
end

%FULL TREE
% %directory tree
% [path_f1,path_f2,path_f3]=dirwalk(paths_ELV);
% n_f1=size(path_f1,1);
% 
% %walk directory
% for kf1=1:n_f1 
%     n_f3=size(path_f3{kf1,1},1);
%     if n_f3~=0
%         for kf3=1:n_f3
%             [~,~,ext]=fileparts(path_f3{kf1,1}{kf3,1});
%             if strcmp(ext,'.m')
%                 %% FUNCTION TO FILE
%                 path_file_in=fullfile(path_f1{kf1,1},path_f3{kf1,1}{kf3,1});
%                 fid_m=fopen(path_file_in,'r'); %file identifier of the file               
%                 for k=1:13 %at line 13 we have what we want
%                     id_line=fgets(fid_m);
%                 end
%                 fclose(fid_m);
%                 fprintf(fid_log,'%s',id_line); 
%             end
%         end
%     end
% end

fprintf(fid_log,'----------------------- \n'); 

