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

switch simdef.D3D.structure
    case {2,4}
        model_type_str='dfm';
    case 3
        model_type_str='sobek3';
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef.file.his;
fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

%2DO make this inside actually reading the grid and ouput <no_layers>=1. Repeat in <plot>
if simdef.D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end
% [nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his,fdir_mat);
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef,'results_type','his'); %force his reading. Needed for SMT.

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% CONSTANT IN TIME

%% LOOP

stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef.D3D.structure);

ns=numel(stations);

ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
for ks=ks_v
    ksc=ksc+1;
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        [var_str,var_id]=D3D_var_num2str_structure(varname,simdef,'res_type','his');
        
        layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks},var_str);
        
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var',var_str,'layer',layer);
        
        do_read=1;
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
            do_read=0;
        end
        
        if do_read

            %% read data
            %<gdm_read_data_his_simdef>

            %2DO:
            %   -make a function that reworks the data if necessary
            %   -load the times as specified in the input! now it is inconsistent. ?? I don;t know what I meant to say anymore.

                %% raw data
                data_raw=gdm_read_data_his(fdir_mat,fpath_his,var_id,'station',stations{ks},'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx);

            %% processed data

            data=squeeze(data_raw.val); %#ok

            %% save and disp
            save_check(fpath_mat_tmp,'data');
            messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));

            %% BEGIN DEBUG

            %END DEBUG
            
        end %do_read
        
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
