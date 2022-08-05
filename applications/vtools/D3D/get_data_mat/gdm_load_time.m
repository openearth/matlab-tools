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

function [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map,fdir_mat)

%% PARSE

if isfield(flg_loc,'overwrite_tim')==1
    messageOut(fid_log,'<overwrite_tim> flag is outdated. Time will be overwritten if the one present is different than the requested one')
%     flg_loc.overwrite_tim=0;
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(flg_loc,'tim_tol')==0
    flg_loc.tim_tol=10;
end



%% CALC

load_tim=false;
if exist(fpath_mat_time,'file')==2 
    messageOut(fid_log,sprintf('Time-file already exists: %s',fpath_mat_time));
    load(fpath_mat_time,'tim');
    v2struct(tim);
    
    %compare datenum
    if isdatetime(flg_loc.tim)
        tim_obj=datenum_tzone(flg_loc.tim);
    else
        tim_obj=flg_loc.tim;
    end
    
    if isduration(flg_loc.tim_tol)
        tim_tol_d=days(flg_loc.tim_tol);
    else
        tim_tol_d=flg_loc.tim_tol;
    end
    
    %flow or morpho time
    switch flg_loc.tim_type
        case 1
            tim_cmp=time_dnum;
        case 2
            tim_cmp=time_mor_dnum;
    end
    
    nt1=numel(tim_cmp);
    nt2=numel(tim_obj);
    ntT=NC_nt(fpath_map); 
    if isnan(tim_obj(1)) && ntT==nt1
        messageOut(fid_log,'Requested time is the same as existing one. Loading.')
    elseif nt1~=nt2 || any(abs(reshape(tim_cmp,1,[])-reshape(tim_obj,1,[]))>tim_tol_d) 
        messageOut(fid_log,'Requested time is different than available time. Overwritting.')
        load_tim=true;
    else
        messageOut(fid_log,'Requested time is the same as existing one. Loading.')
    end
else
    messageOut(fid_log,'Time-file does not exist. Reading.');
    load_tim=true;
end
if load_tim
    [time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=D3D_time_dnum(fpath_map,flg_loc.tim,'tim_type',flg_loc.tim_type,'tol',flg_loc.tim_tol,'fdir_mat',fdir_mat);
    tim=v2struct(time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx); %#ok
    
    save_check(fpath_mat_time,'tim');
end
nt=numel(time_dnum);

end %function