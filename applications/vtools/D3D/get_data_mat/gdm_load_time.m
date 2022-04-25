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