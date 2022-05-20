%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18023 $
%$Date: 2022-05-05 10:40:39 +0200 (Thu, 05 May 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal3D_01.m 18023 2022-05-05 08:40:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal3D_01.m $
%
%

function create_mat_map_2DH_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME
if simdef.D3D.structure==4
    fpath_pass=simdef.D3D.dire_sim;
else
    fpath_pass=fpath_map;
end
[nt,time_dnum,~,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_pass);
   
%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    for kvar=1:nvar %variable
        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef);
        
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str);
        if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end

        %% read data
        if simdef.D3D.structure==4
            %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
            fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx(kt)),filesep]); 
        else
            fpath_map_loc=fpath_map;
        end
        data_var=gdm_read_data_map(fdir_mat,fpath_map_loc,var_str,'tim',time_dnum(kt)); 
            
        data=squeeze(data_var.val); %#ok
        save_check(fpath_mat_tmp,'data'); 
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));
    end

end %kt

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
