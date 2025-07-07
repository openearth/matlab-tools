%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20156 $
%$Date: 2025-05-19 14:16:30 +0200 (Mon, 19 May 2025) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 20156 2025-05-19 12:16:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
%
%

function [fpath_mat_tmp,var_id,layer,var_idx,sum_var_idx]=gdm_get_name_map_2DH(flg_loc,simdef,gridInfo,kvar,tag,time_dnum_kt)

var_str_original=flg_loc.var{kvar};
[varname_save_mat,var_id]=D3D_var_num2str_structure(var_str_original,simdef);

layer=gdm_layer(flg_loc,gridInfo.no_layers,varname_save_mat,kvar,var_str_original); %we use <layer> for flow and sediment layers
[var_idx,sum_var_idx]=gdm_var_idx(simdef,flg_loc,flg_loc.var_idx{kvar},flg_loc.sum_var_idx(kvar),var_str_original);

fdir_mat=simdef.file.mat.dir;
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_kt,'var',varname_save_mat,'var_idx',var_idx,'layer',layer);

end %function
