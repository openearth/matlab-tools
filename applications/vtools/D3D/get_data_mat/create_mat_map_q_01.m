%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17958 $
%$Date: 2022-04-20 09:27:05 +0200 (Wed, 20 Apr 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 17958 2022-04-20 07:27:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function create_mat_map_q_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting mat-file.')
        return
    end
    messageOut(fid_log,'Overwriting mat-file.')
else
    messageOut(fid_log,'Mat-file does not exist. Reading.')
end

%% LOAD TIME

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

%% CONSTANT IN TIME

%load grid for number of layers
% load(simdef.file.mat.grd,'gridInfo')

% raw_ba=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_ba','mergePartitions',1,'disp',0);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,0/nt*100));
for kt=kt_v
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    %% read data
    
    fpath_uv=mat_tmp_name(fdir_mat,'uv','tim',time_dnum(kt));
    if exist(fpath_uv,'file')==2
        load(fpath_uv,'data_uv')
    else
        data_uv=EHY_getMapModelData(fpath_map,'varName','uv','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0);
        save_check(fpath_uv,'data_uv');
    end
    
    fpath_zw=mat_tmp_name(fdir_mat,'zw','tim',time_dnum(kt));
    if exist(fpath_zw,'file')==2
        load(fpath_zw,'data_zw')
    else
        data_zw=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_zw','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0);
        save_check(fpath_zw,'data_zw');
    end
    
    %% calc
    
    %squeeze to take out the first (time) dimension. Then layers are in dimension 2.
    vel_mag=squeeze(data_uv.vel_mag); %m/s
    thk=diff(squeeze(data_zw.val),1,2); %m
    q=sum(vel_mag.*thk,2,'omitnan')'; %m^2/s
    
    %data
%     data=v2struct(data_u,data_h,q,Q,idx_cs,Q_cs,Q_cs_frac); %#ok
    data=q; %#ok

    %% save and disp
    save_check(fpath_mat_tmp,'data');
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,kt/nt*100));
    
    %% BEGIN DEBUG
%     figure
%     hold on
%     plot(thk)
%     plot(q)
% plot(raw_ba.val)
% plot(mass,'-*')
    %END DEBUG
end    

%% JOIN

%if creating files in parallel, another instance may have already created it.
%
%Not a good idea because of the overwriting flag. Maybe best to join it several times.
%
% if exist(fpath_mat,'file')==2
%     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
%     return
% end

% data=struct();

%% first time for allocating

kt=1;
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
tmp=load(fpath_mat_tmp,'data');

%constant

%time varying
nF=size(tmp.data,2);

data=NaN(nt,nF);

%% loop 

for kt=1:nt
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
    tmp=load(fpath_mat_tmp,'data');

    data(kt,:)=tmp.data;

end

save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
