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

function create_mat_map_sal_mass_01(fid_log,flg_loc,simdef)

% tag='map_sal_mass_01';
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
if isfield(flg_loc,'order_anl')==0
    flg_loc.order_anl=1;
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

switch flg_loc.order_anl
    case 1
        kt_v=1:1:nt;
    case 2
        kt_v=randi(nt,1,nt);
end

messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,0/nt*100));
for kt=kt_v
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt);
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    %% read data
    raw_sal=EHY_getMapModelData(fpath_map,'varName','sal','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0);
    raw_zint=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_zw','t0',time_dnum(kt),'tend',time_dnum(kt),'mergePartitions',1,'disp',0);
    
    %% calc
    
    %squeeze to take out the first (time) dimension. Then layers are in dimension 2.
    cl=sal2cl(1,squeeze(raw_sal.val)); %mgCl/l
    thk=diff(squeeze(raw_zint.val),1,2); %m
    mass=sum(cl/1000.*thk,2,'omitnan')'; %mgCl/m^2; cl*1000/1000/1000 [kgCl/m^3]
    
    %data
%     data=v2struct(data_u,data_h,q,Q,idx_cs,Q_cs,Q_cs_frac); %#ok
    data=mass; %#ok

    %% save and disp
    save_check(fpath_mat_tmp,'data');
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,kt/nt*100));
    
    %% BEGIN DEBUG
%     figure
%     hold on
%     plot(thk)
%     plot(vol)
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
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt);
tmp=load(fpath_mat_tmp,'data');

%constant

%time varying
nF=size(tmp.data,2);

data=NaN(nt,nF);

%% loop 

for kt=1:nt
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt);
    tmp=load(fpath_mat_tmp,'data');

    data(kt,:)=tmp.data;

end

% save_check(fpath_mat,'data','-v7.3');
save(fpath_mat,'data','-v7.3');

end %function

%% 
%% FUNCTION
%%

function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,kt)

fpath_mat_tmp=fullfile(fdir_mat,sprintf('%s_tmp_kt_%04d.mat',tag,kt));

end %function