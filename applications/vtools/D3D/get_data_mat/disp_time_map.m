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

function disp_time_map(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_map=gdm_fpathmap(simdef,0);

%% LOAD TIME

flg_loc.tim=NaN;
[time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_time_dnum(fpath_map,flg_loc.tim,'fdir_mat',fdir_mat);

nt=numel(time_dnum);
for kt=1:nt
    fprintf('%04d %5.2f %% %s %s \n',kt,kt/nt*100,datestr(time_dtime(kt),'yyyy-mm-dd HH:MM:SS'),datestr(time_mor_dtime(kt),'yyyy-mm-dd HH:MM:SS'));
end

end %function