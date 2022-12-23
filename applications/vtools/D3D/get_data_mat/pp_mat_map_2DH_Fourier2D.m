%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 06:18:42 +0200 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: pp_mat_map_2DH_cum_01.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/pp_mat_map_2DH_cum_01.m $
%
%

function pp_mat_map_2DH_Fourier2D(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_Fourier2D')==0
    flg_loc.do_Fourier2D=zeros(size(flg_loc.var));
end

if isfield(flg_loc,'var_idx')==0
    flg_loc.var_idx=cell(1,numel(flg_loc.var));
end
var_idx=flg_loc.var_idx;

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

fpath_map=simdef.file.map;

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% OVERWRITE

% ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

flg_loc.tim_just_load=1;
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% DIMENSIONS

nvar=numel(flg_loc.var);
kt_v=gdm_kt_v(flg_loc,nt); %time index vector

%% LOOP VAR
for kvar=1:nvar
    if ~flg_loc.do_Fourier2D(kvar)
        continue
    end
    
    varname=flg_loc.var{kvar};
    var_str_read=D3D_var_num2str_structure(varname,simdef);
    layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
    
    ktc=0;
    L=NaN(nt,1);
    int=L;
    amp=L;
    len=L;
    for kt=kt_v

        ktc=ktc+1;
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'var_idx',var_idx{kvar},'layer',layer);
        load(fpath_mat_tmp,'data')
        
        [L(kt,1),int(kt,1),amp(kt,1),len(kt,1)]=gdm_fourier2D(gridInfo,data);
%         [L(kt,1),int(kt,1)]=zero_crossing_properties(gridInfo.Xcen(:,1)',data(:,1)');
    
        %disp
        messageOut(fid_log,sprintf('Fourier2D %4.2f %%',ktc/nt*100));
    end %kt
    
    clear data
    
    fpath_mat_loc=mat_tmp_name(fdir_mat,sprintf('%s_Fourier2D_1',tag),'var',var_str_read,'var_idx',var_idx{kvar},'layer',layer);
    data.val=L;
    data.unit='fourier_max_length_x';
    save_check(fpath_mat_loc,'data')
    
    fpath_mat_loc=mat_tmp_name(fdir_mat,sprintf('%s_Fourier2D_2',tag),'var',var_str_read,'var_idx',var_idx{kvar},'layer',layer);
    data.val=int;
    data.unit='fourier_spectral_power';
    save_check(fpath_mat_loc,'data')
    
    fpath_mat_loc=mat_tmp_name(fdir_mat,sprintf('%s_Fourier2D_3',tag),'var',var_str_read,'var_idx',var_idx{kvar},'layer',layer);
    data.val=amp;
    data.unit='amplitude_L';
    save_check(fpath_mat_loc,'data')
    
    fpath_mat_loc=mat_tmp_name(fdir_mat,sprintf('%s_Fourier2D_4',tag),'var',var_str_read,'var_idx',var_idx{kvar},'layer',layer);
    data.val=len;
    data.unit='length';
    save_check(fpath_mat_loc,'data')
end %kvar

%% SAVE

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%
