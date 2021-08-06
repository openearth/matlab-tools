%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Get paths for bringing data from Cartesius to the p-drive
%
%E.G.
%
% surf_userid='pr1n0147';
% output_folder_win='p:\11206813-007-kpp2021_rmm-3d\C_Work\01_RMM_simulations\computations\r006\DFM_OUTPUT_RMM_dflowfm\';
% cartesius_project_folder_lin='/projects/0/hisigem/';
% path_commands='p:\11206813-007-kpp2021_rmm-3d\C_Work\00_temporal\';
%
%OPTION 1
%partition files in the folder
% fname_move='RMM_dflowfm_0000_fou.nc';
% npartitions=120;
% 
% bring_data_back_from_Cartesius(surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,fname_move,npartitions)
% 
%OPTION 2
%all files in the folder
%
% bring_data_back_from_Cartesius(surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands)
%
%OPTION 3
%list of single files
% path_bring_back={... %path in Windows where to place the same file in Cartesius
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_020/figures/crossection/cs_vert_a_020_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_020/figures/crossection/a_020_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_021/figures/crossection/cs_vert_a_021_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_021/figures/crossection/a_021_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/figures/crossection/cs_vert_a_026_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/figures/crossection/a_026_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_029/figures/crossection/cs_vert_a_029_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_029/figures/crossection/a_029_crosssection_error.txt'...
% };
%
% bring_data_back_from_Cartesius(surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,path_bring_back)

function bring_data_back_from_cartesius(surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,varargin)

%% PARSE

flg.opt=0;
if isempty(varargin)
    flg.opt=2; %bring all data from folder
elseif numel(varargin)==1
    if iscell(varargin{1})
        flg.opt=3;
        path_bring_back=varargin{1}; %path in Windows where to place the same file in Cartesius
    else
        error('not sure what is going on here')
    end
elseif numel(varargin)==2
    flg.opt=1;
    fname_move=varargin{1};
    npartitions=varargin{2};
end

% parin=inputParser;
% 
% addOptional(parin,'path_commands','');
% 
% parse(parin,varargin{:});

if strcmp(output_folder_win(end),'\')
    output_folder_win(end)='';
end

%% FILES

path_h6=fullfile(path_commands,'bring_data_back.sh');
fid_h6=fopen(path_h6,'w');
path_ca=fullfile(path_commands,'tmp_bring_data_back.sh');
fid_ca=fopen(path_ca,'w');

%% CALC

switch flg.opt
    %% 1,2
    case {1,2}
        %% send file with commands to cartesius

    cmd_send_commands_ca=sprintf('scp %s %s@cartesius.surfsara.nl:%s \n',linuxify(path_ca),surf_userid,cartesify(cartesius_project_folder_lin,path_ca));

        %% compress

%         fname_compressed='move_data';

%         output_folder_cartesius=cartesify(cartesius_project_folder_lin,output_folder_win);

        switch flg.opt
            case 1
                fname_compress='';
                for kpartitions=1:npartitions
                    fname_compress=[fname_compress,' ',strrep(fname_move,'0000',sprintf('%04d',kpartitions-1))];
                end
                folder2work_win=output_folder_win;
            case 2
                [folder2work_win,folder_last]=folderUp(output_folder_win);
                fname_compress=folder_last;
        end

        folder2work_cartesius=cartesify(cartesius_project_folder_lin,folder2work_win);
        compressed_path_win=fullfile(folder2work_win,strcat(fname_compress,'.tar.gz'));
        compressed_path_cartesius=cartesify(cartesius_project_folder_lin,compressed_path_win);

        cmd_go_cartesius_folder=sprintf('cd %s',folder2work_cartesius);
        cmd_comp=sprintf('tar -zcvf %s %s',compressed_path_cartesius,fname_compress);
        
        %% mkdir
        
        compressed_path_h6=strrep(compressed_path_cartesius,cartesius_project_folder_lin,'/p/');
        [path_dir,~,~]=fileparts(compressed_path_h6);
        cmd_mkdir=sprintf('mkdir %s',linuxify(path_dir));
        
        %% transport

        cmd_transport=sprintf('rsync -av --bwlimit=5000 %s@cartesius.surfsara.nl:%s %s',surf_userid,compressed_path_cartesius,compressed_path_h6);

        %% uncompress

        output_folder_h6=linuxify(folder2work_win);
        cmd_cd_C_sim=sprintf('cd %s',output_folder_h6); 
        cmd_uncomp=sprintf('tar -zxvf %s',compressed_path_h6);
        cmd_del_tar=sprintf('rm -rf %s',compressed_path_h6); %delete tar
        
        %% display

        %cartesius commands
        fprintf(fid_ca,'%s \n',cmd_go_cartesius_folder);
        fprintf(fid_ca,'%s \n',cmd_comp);
        
        %h6
        fprintf(fid_h6,'%s \n',cmd_send_commands_ca);
        fprintf(fid_h6,'ssh %s@cartesius.surfsara.nl ''%s'' \n',surf_userid,cartesify(cartesius_project_folder_lin,path_ca));
        fprintf(fid_h6,'%s \n',cmd_mkdir);
        fprintf(fid_h6,'%s \n',cmd_transport);
        fprintf(fid_h6,'%s \n',cmd_cd_C_sim);
        fprintf(fid_h6,'%s \n',cmd_uncomp);
        fprintf(fid_h6,'%s \n',cmd_del_tar);

        case 3
            %% transport
            nf=numel(path_bring_back);
            cmd_mkdir=cell(nf,1);
            cmd_transport=cell(nf,1);
            kf=1;
            [path_dir,~,~]=fileparts(path_bring_back{kf});
            cmd_mkdir{kf}=sprintf('mkdir %s',linuxify(path_dir));
            cmd_cd=sprintf('cd %s',linuxify(path_dir));
            for kf=1:nf
                [path_dir,~,~]=fileparts(path_bring_back{kf});
                cmd_mkdir{kf}=sprintf('mkdir %s',linuxify(path_dir));
                cmd_transport{kf,1}=sprintf('rsync -av --bwlimit=5000 %s@cartesius.surfsara.nl:%s %s &>log.txt',surf_userid,cartesify(cartesius_project_folder_lin,path_bring_back{kf}),linuxify(path_bring_back{kf}));
            end %kf
            
            %% display
            fprintf(fid_h6,'#!/bin/bash \n');
            fprintf(fid_h6,'%s \n',cmd_mkdir{1,1});
            fprintf(fid_h6,'%s \n',cmd_cd);
            for kf=1:nf
                fprintf(fid_h6,'%s \n',cmd_mkdir{kf,1});
                fprintf(fid_h6,'%s \n',cmd_transport{kf,1});
            end %kf

    otherwise
        error ('this option does not exist')
end %flg.opt

%% close 

fclose(fid_h6);
fclose(fid_ca);

%% disp

% fprintf('Run file for compressing data in Cartesius: %s \n',path_ca);
% fprintf('Run file for bringing data back to H6: %s \n',path_h6);
fprintf('For an unknown reason, sometimes it crashes because \n rsync is not found. Simply submit again. \n')
fprintf('qsub %s \n',linuxify(path_h6))

end %function
