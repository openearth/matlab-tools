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

function gdm_create_mat_M1D(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

is_straigth=0;
if isfield(flg_loc,'fpath_map_curved')
    is_straigth=1;
end

%% PATHS

fdir_mat=simdef.file.fdir_mat;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=gdm_fpathmap(simdef,0);

%take coordinates from curved domain (in case the domain is straightened)
fpath_map_grd=fpath_map; 
if is_straigth
    fpath_map_grd=flg_loc.fpath_map_curved;
end

%% DIMENSIONS

nvar=numel(flg_loc.var);
nbr=numel(flg_loc.branch);

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRIDS

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map_grd,'dim',1,'simdef',simdef);

%% LOAD TIME

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

kbr=0;
ktc=0;
kvar=0;
messageOut(fid_log,sprintf('Reading %s branch %4.2f time %4.2f %% variable %4.2f %%',tag,kbr/nbr*100,ktc/nt*100,kvar/nvar*100));

%% branches
for kbr=1:nbr %branches
    ktc=0;

    branch=flg_loc.branch{kbr};
    branch_name=flg_loc.branch_name{kbr};

    gridInfo_br=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat,gridInfo,branch,branch_name);
    
    %% time
    for kt=kt_v 
        ktc=ktc+1;

        %% variables
        for kvar=1:nvar 
            
            varname=flg_loc.var{kvar};
            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(varname,simdef);
            
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);

            do_read=1;
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
                do_read=0;
            end

            %% read data
            if do_read
                branch_idx=gdm_select_edgenode_1D_variable(var_id,gridInfo_br);
                data_var=gdm_read_data_map_simdef(fdir_mat,simdef,var_id,'tim',time_dnum(kt),'sim_idx',sim_idx(kt),'idx_branch',branch_idx,'branch',branch_name);    
                data=squeeze(data_var.val); %#ok
                save_check(fpath_mat_tmp,'data'); 
            end                
            
            %% disp
            messageOut(fid_log,sprintf('Reading %s branch %4.2f time %4.2f %% variable %4.2f %%',tag,kbr/nbr*100,ktc/nt*100,kvar/nvar*100));
            
        end %var
    end %kt
end %br

end %function

%% 
%% FUNCTION
%%
