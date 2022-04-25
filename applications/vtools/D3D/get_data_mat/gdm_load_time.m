%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17946 $
%$Date: 2022-04-07 14:25:02 +0200 (Thu, 07 Apr 2022) $
%$Author: chavarri $
%$Id: simulation_paths.m 17946 2022-04-07 12:25:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/simulation_paths.m $
%

function [nt,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map)

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% CALC

load_tim=false;
if exist(fpath_mat_time,'file')==2 
    messageOut(fid_log,'Time-file already exists');
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting time-file.')
        load(fpath_mat_time,'tim');
        v2struct(tim);
    else 
        messageOut(fid_log,'Overwriting time-file.')
        load_tim=true;
    end
else
    messageOut(fid_log,'Time-file does not exist. Reading.');
    load_tim=true;
end
if load_tim
    [time_dnum,time_dtime]=D3D_time_dnum(fpath_map,flg_loc.tim);
    tim=v2struct(time_dnum,time_dtime); %#ok
    save_check(fpath_mat_time,'tim');
end
nt=numel(time_dnum);

end %function