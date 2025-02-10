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
%

function [gridInfo,time_dnum,time_dnum_plot,time_mor_dnum,tim_dtime_plot]=gdm_load_time_grid(fid_log,flg_loc,simdef,tag)

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); 
fpath_map=simdef.file.map;

tim=load(fpath_mat_time,'tim');
time_dnum=tim.tim.time_dnum; %used to load the data (always flow time)
time_mor_dnum=tim.tim.time_mor_dnum; %used to match data (can be morpho time)

[time_dnum_plot,tim_dtime_plot]=gdm_time_flow_mor(flg_loc,simdef,tim.tim.time_dnum,tim.tim.time_dtime,tim.tim.time_mor_dnum,tim.tim.time_mor_dtime); %[nt_ref,1] 

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map,'disp',0,'dim',2);

end %function