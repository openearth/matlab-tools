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

function create_mat_map_2DH_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

flg_loc=isfield_default(flg_loc,'do_create_mat',1);
if ~flg_loc.do_create_mat
    messageOut(fid_log,'Skipped mat-file creation.')
    return
end

%% DEFAULTS

[flg_loc,simdef]=gdm_parse_map_2DH(fid_log,flg_loc,simdef);
flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%% SHP

if flg_loc.write_shp
    fpath_poly=fullfile(fdir_mat,'grd_polygons.mat');
    if exist(fpath_poly,'file')==2
        load(fpath_poly,'polygons')
    else        
        polygons=D3D_grid_polygons(fpath_map);
        save_check(fpath_poly,'polygons');
    end
end

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    for kvar=1:nvar %variable
        
        [fpath_mat_tmp,var_id,layer,var_idx,sum_var_idx]=gdm_get_name_map_2DH(flg_loc,simdef,gridInfo,kvar,tag,time_dnum(kt));

        fpath_shp_tmp=strrep(fpath_mat_tmp,'.mat','.shp');

        do_read=1;
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
            do_read=0;
        end
        do_shp=0;
        if flg_loc.write_shp && (exist(fpath_shp_tmp,'file')~=2 || do_read==1)
            do_shp=1;
        end

        %% read data
        if do_read
            data_var=gdm_read_data_map_simdef(fdir_mat,simdef,var_id,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'var_idx',var_idx,'layer',layer,'tol',flg_loc.tol,'sum_var_idx',sum_var_idx,'sediment_transport',flg_loc.sediment_transport(kvar));      
            data=squeeze(data_var.val); 
            save_check(fpath_mat_tmp,'data'); 
        end

        %% shp
        if do_shp
            if ~do_read
                load(fpath_mat_tmp,'data')
            end
            messageOut(fid_log,sprintf('Starting to write shp: %s',fpath_shp_tmp));
            shapewrite(fpath_shp_tmp,'polygon',polygons,reshape(data,[],1));
%             messageOut(fid_log,sprintf('Finished to write shp: %s',fpath_shp_tmp)); %next message is sufficient
        end
        
        %% velocity
        if flg_loc.do_vector(kvar)
            gdm_read_data_map_simdef(fdir_mat,simdef,'uv','tim',time_dnum(kt),'sim_idx',sim_idx(kt),'var_idx',var_idx,'do_load',0);            
        end
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end %kvar
end %kt

end %function

%% 
%% FUNCTION
%%
