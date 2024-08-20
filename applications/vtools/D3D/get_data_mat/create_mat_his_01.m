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

function create_mat_his_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

% switch simdef.D3D.structure
%     case {2,4}
%         model_type_str='dfm';
%     case 3
%         model_type_str='sobek3';
% end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef.file.his;
% fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

gridInfo=EHY_getGridInfo(fpath_his,'no_layers');
% gridInfo=gdm_load_grid_simdef(fid_log,simdef);

% [nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his,fdir_mat);
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef,'results_type','his'); %force his reading. Needed for SMT.

%% PARSE

flg_loc=gdm_parse_his(fid_log,flg_loc,simdef);

nvar=flg_loc.nvar;
ns=flg_loc.ns;
stations=flg_loc.stations;

%% LOOP

ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
for ks=ks_v
    ksc=ksc+1;
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        elevation=flg_loc.elevation(ks);
        
        [var_str,var_id]=D3D_var_num2str_structure(varname,simdef,'res_type','his');
        
        %2DO: if depth_average, it takes all layers and elevation data is ommited. 
        layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks},var_str,elevation);
        
        %2DO: add `depth_average` to the name and move to a function to be called also in plot and plot_diff
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var',var_str,'layer',layer,'elevation',elevation,'tim',time_dtime(1),'tim2',time_dtime(end));
        
        do_read=1;
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
            do_read=0;
        end
        
        if do_read

            %% read data
            data=gdm_read_data_his_simdef(fdir_mat,simdef,var_id,'tim',time_dnum,'layer',layer,'sim_idx',sim_idx,'station',stations{ks},'elevation',elevation);

            %% processed data
            data=squeeze(data.val); %#ok

            %% save and disp
            save_check(fpath_mat_tmp,'data');
            messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));

            %% BEGIN DEBUG

            %END DEBUG
            
        end %do_read
        
        %% export
        gdm_export_his_01(fid_log,flg_loc,fpath_mat_tmp,time_dtime)
        
    end %kvar
end    

%% JOIN

% %% first time for allocating
% 
% kt=1;
% fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
% tmp=load(fpath_mat_tmp,'data');
% 
% %constant
% 
% %time varying
% nF=size(tmp.data,2);
% 
% data=NaN(nt,nF);
% 
% %% loop 
% 
% for kt=1:nt
%     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%     tmp=load(fpath_mat_tmp,'data');
% 
%     data(kt,:)=tmp.data;
% 
% end
% 
% save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
