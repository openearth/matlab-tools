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

function create_mat_map_2DH_his_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

flg_loc=gdm_parse_his(fid_log,flg_loc,simdef);
flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

nobs=flg_loc.nobs;

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

idx_obs=gdm_get_idx_grd(gridInfo,flg_loc);

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
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',flg_loc.obs(kobs).name,'var',var_str_read,'layer',layer,'elevation',flg_loc.elev(kobs),'tim',time_dtime(1),'tim2',time_dtime(end),'depth_average',flg_loc.depth_average(kvar),'depth_average_limits',flg_loc.depth_average_limits(kvar,:));

            %% read data
            if ~(exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite)
                data_var=gdm_read_data_map_simdef(fdir_mat,simdef,var_id,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'var_idx',flg_loc.var_idx{kvar},'layer',layer,'tol',flg_loc.tol,'sum_var_idx',flg_loc.sum_var_idx(kvar),'sediment_transport',flg_loc.sediment_transport(kvar),'depth_average',flg_loc.depth_average(kvar),'elevation',flg_loc.elev(kobs),'depth_average_limits',flg_loc.depth_average_limits(kvar,:));
                [idx_time,dim]=D3D_search_index_in_dimension(data_var,'time');
                idx_face=D3D_search_index_in_dimension(data_var,'mesh2d_nFaces');
                data=submatrix(data_var.val,idx_time,1); %remove time
                data=submatrix(data,idx_face,idx_obs(kobs)); %take station we want
                data_his(kobs,kt,kvar)=squeeze(data); 
            end
        end %kobs

        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end %kvar
end %kt

%% SAVE

for kvar=1:nvar
    [var_str_read,var_id]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
    
    layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers

    for kobs=1:nobs
    
        %read
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',flg_loc.obs(kobs).name,'var',var_str_read,'layer',layer,'elevation',flg_loc.elev(kobs),'tim',time_dtime(1),'tim2',time_dtime(end),'depth_average',flg_loc.depth_average(kvar),'depth_average_limits',flg_loc.depth_average_limits(kvar,:));

        if ~(exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite)
            data=data_his(kobs,:,kvar); %#ok
            data=data'; %we save it in one column
            save_check(fpath_mat_tmp,'data'); 
        end
    end %kvar
end %kobs

end %function

%% 
%% FUNCTION
%%
