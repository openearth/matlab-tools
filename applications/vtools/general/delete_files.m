
%% PREAMBLE

clear
clc

%% INPUT

deletefiles=0; %if 0; it will display which ones it will delete

path_main_folder='p:\11204511-tenryuu-5b-2019\B3_Large-scale-modelling\2_simulations-2019\tenryuu\';
tag2erase={'_map.nc';'_his.nc';'_rst.nc'}; %erase files based on the last part of the file name
% folder2erase={'r_065','r_066'}; %folders to erase

folder2erase={};
% for kfol=1:20
%     folder2erase=cat(2,folder2erase,{sprintf('%03d',kfol)});
% end
for kfol=21:44
    folder2erase=cat(2,folder2erase,{sprintf('r_%03d',kfol)});
end

%% CALC

ntag=numel(tag2erase);
nfe=numel(folder2erase);

[pathNames,dirNames,fileNames]=dirwalk(path_main_folder);

np=numel(fileNames);

for kp=1:np
    nf=numel(fileNames{kp,1});
    for kf=1:nf
        file_path=fullfile(pathNames{kp,1},fileNames{kp,1}{kf,1});
        if contains(file_path,folder2erase) && contains(file_path,tag2erase)
            disp(file_path)
            if deletefiles==1
                delete(file_path)                
            end
        end
    end %kf
end %kp

fprintf('done \n')