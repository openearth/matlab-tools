%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 15:24:14 +0200 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_simpath_mdf.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_mdf.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -
%

% function copy_script_submit_cluster(path_script,line_num,new_line)

%% DEBUG
path_script="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210503_vow21\03_schematized_1d\main_plot.m";
line_num=27;
sim_num=20:1:32;
ns=numel(sim_num);
for ks=1:ns
    new_line{ks,1}=sprintf('sim_num_v=%d',sim_num(ks));
end

%% 

[path_dir,path_nam,path_ext]=fileparts(path_script);

%sh general script
path_sh_g=fullfile(path_dir,'sumbit_all.sh');
fid_g=fopen(path_sh_g,'w');

scri=file_in_cell_io('read',path_script);

ns=numel(new_line);
for ks=1:ns
    %m script
    path_nam_loc=sprintf('%s_%02d',path_nam,ks);
    path_nam_ext_loc=sprintf('%s%s',path_nam_loc,path_ext);
    path_scri=fullfile(path_dir,path_nam_ext_loc);
    scri{line_num,1}=new_line{ks,1};
    file_in_cell_io('write',path_scri,scri,'check_existing',false);
    
    %sh script
    path_sh_nam_loc=sprintf('%s.sh',path_nam_loc);
    path_sh_loc=fullfile(path_dir,path_sh_nam_loc);
    fid=fopen(path_sh_loc,'w');
    
    fprintf(fid,'#!/bin/bash                         \n');
    fprintf(fid,'#$ -cwd                             \n');
    fprintf(fid,'#$ -m bea                           \n');
    fprintf(fid,'#$ -q normal-e3-c7                  \n');
    fprintf(fid,'                                    \n');
    fprintf(fid,'# NOTES:                            \n');
    fprintf(fid,'#	-do a dos2unix                   \n');
    fprintf(fid,'# 	-call as qsub ./run_matlab_in_p  \n');
    fprintf(fid,'                                    \n');
    fprintf(fid,'module load matlab/2019a            \n');
    fprintf(fid,'matlab -r %s                        \n',path_nam_loc);
    
    fclose(fid);
    
    %sh script general
    fprintf(fid_g,'dos2unix %s \n',path_sh_nam_loc);
    fprintf(fid_g,'qsub ./%s \n',path_sh_nam_loc);

end %ks

fclose(fid_g);