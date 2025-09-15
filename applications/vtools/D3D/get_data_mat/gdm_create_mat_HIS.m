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

function gdm_create_mat_HIS(fid_log,flg_loc,simdef)

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
if ~isfield(simdef.file,'his')
    error('There is no his file in this simulation: %s',simdef.D3D.dire_sim)
end
fpath_his=simdef.file.his;
% fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

gridInfo=EHY_getGridInfo(fpath_his,'no_layers');

%% PARSE

flg_loc=gdm_parse_his(fid_log,flg_loc,simdef);

nvar=flg_loc.nvar;
nobs=flg_loc.nobs;
stations=flg_loc.stations;
ntimint=flg_loc.ntimint;
%Problem 1: `obs_all` must output either observation stations or cross-
%sections depending on the variable.
% obs_all=D3D_observation_stations(fpath_his,'simdef',simdef(1));

%% LOOP ON TIME INTERVAL

for ktimint=1:ntimint

    %2DO: Inside `gdm_load_time_simdef` make possible that, when reading his-file, the first and last time identify the times we want to read.
flg_loc.tim=flg_loc.tim_int{ktimint};
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef,'results_type','his'); %force his reading. Needed for SMT.

%% LOOP

kobs_v=gdm_kt_v(flg_loc,nobs);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/nobs*100));
for kobs=kobs_v
    ksc=ksc+1;

    %check if observation station exists
    %See Problem 1
%     idx_find=find_str_in_cell(obs_all.name,stations(kobs));
%     if isnan(idx_find)
%         error('station not found: %s',stations{kobs})
%     end

    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        elev=flg_loc.elev(kobs);
        
        [var_str,var_id]=D3D_var_num2str_structure(varname,simdef,'res_type','his');
        
        %2DO: if depth_average, it takes all layers and elevation data is ommited. 
        [layer,elev]=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{kobs},var_str,elev);
        
        %2DO: add `depth_average` to the name and move to a function to be called also in plot and plot_diff
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{kobs},'var',var_str,'layer',layer,'elevation',elev,'tim',time_dtime(1),'tim2',time_dtime(end));
        
        do_read=1;
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
            do_read=0;
        end
        
        if do_read

            %% read data
            data=gdm_read_data_his_simdef(fdir_mat,simdef,var_id,'tim',time_dnum,'layer',layer,'sim_idx',sim_idx,'station',stations{kobs},'elevation',elev,'angle',flg_loc.projection_angle(kvar));

            %% processed data
            data=squeeze(data.val); %#ok

            %% save
            save_check(fpath_mat_tmp,'data');
           
            %% BEGIN DEBUG

            %END DEBUG
            
        end %do_read
        
        %% disp
        messageOut(fid_log,sprintf('Reading %s: station %4.2f %% variable %4.2f %%',tag,ksc/nobs*100,kvar/nvar*100));

        %% export
        gdm_export_his_01(fid_log,flg_loc,fpath_mat_tmp,time_dtime)
        
    end %kvar
end %kobs    

end %ktimint

end %function

%% 
%% FUNCTION
%%
