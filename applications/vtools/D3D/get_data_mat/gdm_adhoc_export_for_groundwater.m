%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18488 $
%$Date: 2022-10-27 14:13:26 +0200 (Thu, 27 Oct 2022) $
%$Author: chavarri $
%$Id: create_mat_his_01.m 18488 2022-10-27 12:13:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_01.m $
%
%

function gdm_adhoc_export_for_groundwater(fid_log,flg_loc,simdef)

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

obs=D3D_observation_stations(fpath_his);

fpath_csv=fullfile(fdir_mat,'groundwater.csv');

fid=fopen(fpath_csv,'w');

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
klw=0;
for ks=ks_v
    ksc=ksc+1;
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        [var_str,var_id]=D3D_var_num2str_structure(varname,simdef,'res_type','his');
        
        layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks},var_str);
        
        %sal
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var','sal','layer',layer);
        load(fpath_mat_tmp,'data');
        data_s=mean(data,1,'omitnan'); %time is in first dimension
        
        %cell centre
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var','Zcen_cen','layer',layer);
        load(fpath_mat_tmp,'data');
        data_z=mean(data,1,'omitnan'); %time is in first dimension
        
        %cords
        idx_obs=find_str_in_cell(obs.name,stations(ks));
        idx_obs=idx_obs(1);
        
        if any(size(data_z)-size(data_s)); error('ups...'); end
        
        %write
        nl=size(data_z,2);
        
        for kl=1:nl
            if isnan(data_s(kl)); continue; end
            klw=klw+1;
%             if klw==33238
%                 a=1;
%             end
            fprintf(fid,'%0.10E, %0.10E, %0.10E, %0.10E \r\n',obs.x(idx_obs),obs.y(idx_obs),data_z(kl),data_s(kl));
        end %kl
       
        fprintf('%5.2f \n',ksc/ns*100);
%         figure;surf(data)

    end %kvar
end    

fclose(fid);

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
