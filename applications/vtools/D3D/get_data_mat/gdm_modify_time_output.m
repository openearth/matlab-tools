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

function gdm_modify_time_output(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% PARSE

if isfield(flg_loc,'smt_last_time')==0
    flg_loc.smt_last_time=0;
end

%% CALC

if ~flg_loc.smt_last_time 
    return
elseif simdef.D3D.structure~=4
    return
else
    messageOut(fid_log,'Modifying time of SMT output according to input time.')
    datetime_obj=flg_loc.tim;

    %% check if it has been modified
    fdir_mat=simdef.file.mat.dir;
    fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
    fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
    fpath_mat_tim=fullfile(fdir_mat,'tim.mat');

    %The file with all times `tim.mat` is never changed once it exists. This
    %is problematic if the analysis time changes, as we modify the actual simulation
    %time. I think that the best we can do is to erase this file and create it
    %every time. I will think about it.     
    if isfile(fpath_mat_tim)
        delete(fpath_mat_tim)
    end

    do_load=1;
    if isfile(fpath_mat_time)
        tim_data=load(fpath_mat_time);
        tim_data.tim.time_dtime;
        if tim_data.tim.time_dtime==flg_loc.tim'
            do_load=0;
        end
    end
%     [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx,do_load]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

    if do_load==0; return; end

    %% modify time of SMT

    fdir_output=fileparts(simdef.file.mdf);
    fdir_output=fullfile(fdir_output,'../');
%     fdir_output=fullfile(fdir_sim,'output');
    dire=dir(fdir_output);
    nd=numel(dire)-2;
    if nd~=numel(datetime_obj)
        error('Number of results time %d in output folder %s does not match number of objective times %d from input',nd,fdir_output,numel(datetime_obj))
    end
    
    for kd=1:nd
        numdir=kd-1; %starts at 0
        fdir_sim_loc=fullfile(fdir_output,sprintf('%d',numdir));
        simdef=D3D_simpath(fdir_sim_loc);
        for kpart=1:simdef.file.partitions
            fpath_map_loc=fullfile(simdef.file.output,sprintf('%s_%04d_map.nc',simdef.file.mdfid,kpart-1));    
            tim_loc=ncread(fpath_map_loc,'time');
            [time_r,time_mor_r,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime]=D3D_results_time(fpath_map_loc,0,[1,Inf]);
            
            [t0_dtime,units,tzone,tzone_num]=NC_read_time_0(fpath_map_loc);

            %We are modifying the time vector in the NetCDF file. The time
            %is written in seconds starting from a reference time in a
            %certain time zone. We are not changing the reference time, so
            %the time we aim for, the objective time, must be in that
            %timzone. 

            %Actually I think it does not matter because when subtracting
            %it already does account for timezones.
            % datetime_obj.TimeZone=tzone;
    
            %time moved to 0 
            datetime_1=datetime(0,0,0,0,0,0,'timezone','+00:00');
            time_r_mod=seconds(datetime_1+seconds(time_r)-t0_dtime);
    
            time_r_mod(end)=seconds(datetime_obj(kd)-t0_dtime);
            
            ncwrite_class(fpath_map_loc,'time',tim_loc,time_r_mod)
        end
    
    end

end
end %function