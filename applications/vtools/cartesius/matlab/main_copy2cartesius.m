%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: absolute_limits.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%Create paths for running an FM simulation in Cartesius

%% PREAMBLE

clear
clc

%% INPUT

surf_userid='pr1n0147';
folder2send_win='p:\11205258-016-kpp2020rmm-3d\C_Work\01_RMM_simulations\computations\a_032';
temporary_folder_win='p:\11205258-016-kpp2020rmm-3d\C_Work\00_temporal\';
cartesius_project_folder_lin='/projects/0/hisigem/';
runscript='run.sh'; %must be in run folder

%% CALC

%% compress and place in output folder of p

if strcmp(folder2send_win(end),'\')
    folder2send_win(end)='';
end
pathsplit=regexp(folder2send_win,'\','split');
comp_name=sprintf('%s.tar.gz',pathsplit{1,end});
comp_path_win=fullfile(temporary_folder_win,comp_name);

comp_path_lin=linuxify(comp_path_win);
temporary_folder_lin=linuxify(folder2send_win);

npath=numel(pathsplit);
folder2sendup_win='p:\';
for kpath=2:npath-1
    folder2sendup_win=strcat(folder2sendup_win,pathsplit{1,kpath},'\');
end
folder2sendup_lin=linuxify(folder2sendup_win);

folder_run=pathsplit{end};
cmd_cd=sprintf('cd %s',folder2sendup_lin);
cmd_comp=sprintf('tar -zcvf %s %s',comp_path_lin,folder_run);

%% send file

path_dest_cart='';
for kpath=2:npath-1
    path_dest_cart=strcat(path_dest_cart,pathsplit{1,kpath},'/');
end
path_dest_cart=strcat(cartesius_project_folder_lin,path_dest_cart);
cmd_send=sprintf('rsync -av --bwlimit=5000 %s %s@cartesius.surfsara.nl:%s',comp_path_lin,surf_userid,path_dest_cart);

%% uncompress file

cmd_cd_C_sim=sprintf('cd %s',path_dest_cart); 
path_file_cartesius=strcat(path_dest_cart,comp_name);
cmd_uncomp=sprintf('tar -zxvf %s',path_file_cartesius);
cmd_del_tar=sprintf('rm %s',comp_name); %delete tar

%% run simulation

path_dest_cart_run=strcat(path_dest_cart,folder_run);
cmd_cd_cart_run=sprintf('cd %s',path_dest_cart_run);
cmd_dos2unix=sprintf('dos2unix %s',runscript);
cmd_submit=sprintf('sbatch %s',runscript);

%% DISPLAY

clc
fprintf('In H6: \n\n')
fprintf('%s \n',cmd_cd)
fprintf('%s \n',cmd_comp)
fprintf('%s \n',cmd_send)
fprintf('\n-----------\n\n')
fprintf('In Cartesius: \n\n')
fprintf('Start if necessary: \n')
fprintf('ssh %s@cartesius.surfsara.nl \n\n',surf_userid)
fprintf('%s \n',cmd_cd_C_sim)
fprintf('%s \n',cmd_uncomp)
fprintf('%s \n',cmd_del_tar)
fprintf('%s \n',cmd_cd_cart_run)
fprintf('%s \n',cmd_dos2unix)
fprintf('%s \n',cmd_submit)
fprintf('\n')


