%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20156 $
%$Date: 2025-05-19 14:16:30 +0200 (Mon, 19 May 2025) $
%$Author: chavarri $
%$Id: gdm_create_mat_summerbed.m 20156 2025-05-19 12:16:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_create_mat_summerbed.m $
%
%

function [fpath_mat,fpath_mat_postprocess,varname_read_variable,layer,var_idx,sum_var_idx]=gdm_map_summerbed_mat_name_build(flg_loc,kvar,simdef,fdir_mat,tag,pol_name,time_dnum_kt,sb_pol,gridInfo)

var_str_original=flg_loc.var{kvar};
[varname_save_mat,varname_read_variable,varname_load_mat]=D3D_var_num2str_structure(var_str_original,simdef);

layer=gdm_layer(flg_loc,gridInfo.no_layers,varname_save_mat,kvar,var_str_original); %we use <layer> for flow and sediment layers
[var_idx,sum_var_idx]=gdm_var_idx(simdef,flg_loc,flg_loc.var_idx{kvar},flg_loc.sum_var_idx(kvar),var_str_original);

fpath_mat=gdm_map_summerbed_mat_name(varname_save_mat,fdir_mat,tag,pol_name,time_dnum_kt,sb_pol,var_idx,layer);

if flg_loc.do_val_B_mor(kvar)
    var_str_save_tmp=sprintf('%s_B_mor',varname_load_mat);
elseif flg_loc.do_val_B(kvar)
    var_str_save_tmp=sprintf('%s_B',varname_load_mat);
else
    var_str_save_tmp=varname_load_mat; %the variable to save is different than the raw variable name we read
end
fpath_mat_postprocess=gdm_map_summerbed_mat_name(var_str_save_tmp,fdir_mat,tag,pol_name,time_dnum_kt,sb_pol,var_idx,layer);

end %function