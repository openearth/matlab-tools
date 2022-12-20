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

% fdir_mat=simdef.file.mat.dir;
% fpath_map=gdm_fpathmap(simdef,0);
% fpath_mat_time='';
fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% LOAD TIME

flg_loc.tim=NaN;
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef,'results_type','map'); %force his reading. Needed for SMT.

% [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_time_dnum(fpath_map,flg_loc.tim,'fdir_mat',fdir_mat);

% nt=numel(time_dnum);
for kt=1:nt
    if ~isnat(time_mor_dtime(kt))
        fprintf('%04d %6.2f %% hydro: %s morpho: %s \n',kt,kt/nt*100,datestr(time_dtime(kt),'yyyy-mm-dd HH:MM:SS'),datestr(time_mor_dtime(kt),'yyyy-mm-dd HH:MM:SS'));
    else
        fprintf('%04d %6.2f %% hydro: %s \n',kt,kt/nt*100,datestr(time_dtime(kt),'yyyy-mm-dd HH:MM:SS'));
    end
end

end %function