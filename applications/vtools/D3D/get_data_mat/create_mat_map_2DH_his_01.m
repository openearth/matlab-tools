%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18959 $
%$Date: 2023-05-25 09:20:50 +0200 (Thu, 25 May 2023) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 18959 2023-05-25 07:20:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
%
%

function create_mat_map_2DH_his_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'write_shp')==0
    flg_loc.write_shp=0;
end
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

%add velocity vector to variables if needed
% if isfield(flg_loc,'do_vector')==0
%     flg_loc.do_vector=zeros(1,numel(flg_loc.var));
% end

if isfield(flg_loc,'var_idx')==0
    flg_loc.var_idx=cell(1,numel(flg_loc.var));
end

if isfield(flg_loc,'tol')==0
    flg_loc.tol=1.5e-7;
end
tol=flg_loc.tol;

if isfield(flg_loc,'sum_var_idx')==0
    flg_loc.sum_var_idx=zeros(size(flg_loc.var));
end

flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% INDEX OBS

[idx_obs,nobs]=gdm_get_idx_grd(gridInfo,flg_loc);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
data_his=NaN(nobs,nt,nvar);
for kt=kt_v
    ktc=ktc+1;
    for kvar=1:nvar %variable
        [var_str_read,var_id]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
        
        layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers

        %looping on kobs outside of the time loop would seem more logical, but we would load data kvar*kobs more times. 
        for kobs=1:nobs 
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'var',var_str_read,'var_idx',flg_loc.var_idx{kvar},'layer',layer,'station',flg_loc.obs(kobs).name);

            %% read data
            if ~(exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite)
                data_var=gdm_read_data_map_simdef(fdir_mat,simdef,var_id,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'var_idx',flg_loc.var_idx{kvar},'layer',layer,'tol',tol,'sum_var_idx',flg_loc.sum_var_idx(kvar),'sediment_transport',flg_loc.sediment_transport(kvar));      
                data=squeeze(data_var.val); %#ok
                data_his(kobs,kt,kvar)=data(:,idx_obs(kobs),:,:); %how do we make sure we get all dimensions?
            end
        end %kobs

        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end %kvar
end %kt

%% SAVE

for kvar=1:nvar
    for kobs=1:nobs
    
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'var',var_str_read,'var_idx',flg_loc.var_idx{kvar},'layer',layer,'station',flg_loc.obs(kobs).name);

    if ~(exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite)
        data=data_his(kobs,:,kvar); %#ok
        data=data'; %we save it in one column
        save_check(fpath_mat_tmp,'data'); 
    end
    end %kvar
end %kobs

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

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

%         kt=1;
%         fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%         tmp=load(fpath_mat_tmp,'data');
% 
%         %constant
% 
%         %time varying
%         nF=size(tmp.data.q_mag,2);
% 
%         q_mag=NaN(nt,nF);
%         q_x=NaN(nt,nF);
%         q_y=NaN(nt,nF);
% 
%         %% loop 
% 
%         for kt=1:nt
%             fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%             tmp=load(fpath_mat_tmp,'data');
% 
%             q_mag(kt,:)=tmp.data.q_mag;
%             q_x(kt,:)=tmp.data.q_x;
%             q_y(kt,:)=tmp.data.q_y;
% 
%         end
% 
%         data=v2struct(q_mag,q_x,q_y); %#ok
%         save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
