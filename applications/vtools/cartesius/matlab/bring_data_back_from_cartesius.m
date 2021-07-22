%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16663 $
%$Date: 2020-10-21 10:32:44 +0200 (Wed, 21 Oct 2020) $
%$Author: chavarri $
%$Id: main_bring_data_back.m 16663 2020-10-21 08:32:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/cartesius/matlab/main_bring_data_back.m $
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

function bring_data_back_from_Cartesius(surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,varargin)

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

path_h6=fullfile(path_commands,'commands_2.sh');
fid_h6=fopen(path_h6,'w');
path_ca=fullfile(path_commands,'commands_1.sh');
fid_ca=fopen(path_ca,'w');

%% CALC

switch flg.opt
    %% 1,2
    case {1,2}
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

        %% transport

        compressed_path_h6=strrep(compressed_path_cartesius,cartesius_project_folder_lin,'/p/');
        cmd_transport=sprintf('rsync -av --bwlimit=5000 %s@cartesius.surfsara.nl:%s %s',surf_userid,compressed_path_cartesius,compressed_path_h6);

        %% uncompress

        output_folder_h6=linuxify(folder2work_win);
        cmd_cd_C_sim=sprintf('cd %s',output_folder_h6); 
        cmd_uncomp=sprintf('tar -zxvf %s',compressed_path_h6);
        cmd_del_tar=sprintf('rm -rf %s',compressed_path_h6); %delete tar

        %% display

%         fprintf('In Cartesius: \n\n')
%         fprintf('Start if necessary: \n')
        fprintf(fid_ca,'ssh %s@cartesius.surfsara.nl \n\n',surf_userid);
        fprintf(fid_ca,'%s \n',cmd_go_cartesius_folder);
        fprintf(fid_ca,'%s \n',cmd_comp);
%         fprintf('\n')
        
%         fprintf('In H6: \n\n')
        fprintf(fid_h6,'%s \n',cmd_transport);
        fprintf(fid_h6,'%s \n',cmd_cd_C_sim);
        fprintf(fid_h6,'%s \n',cmd_uncomp);
        fprintf(fid_h6,'%s \n',cmd_del_tar);
%         fprintf('\n')

        case 3
            nf=numel(path_bring_back);
            cmd_transport=cell(nf,1);
            for kf=1:nf
                cmd_transport{kf,1}=sprintf('rsync -av --bwlimit=5000 %s@cartesius.surfsara.nl:%s %s',surf_userid,cartesify(cartesius_project_folder_lin,path_bring_back{kf}),linuxify(path_bring_back{kf}));
            end %kf
            
            %% display
%             fprintf('In H6: \n\n')
            for kf=1:nf
                fprintf(fid_h6,'%s \n',cmd_transport{kf,1});
            end %kf
%             fprintf('\n')

    otherwise
        error ('this option does not exist')
end %flg.opt

%% close 

fclose(fid_h6);
fclose(fid_ca);

%% disp

fprintf('Run file for compressing data in Cartesius: %s \n',path_ca);
fprintf('Run file for bringing data back to H6: %s \n',path_h6);

end %function
