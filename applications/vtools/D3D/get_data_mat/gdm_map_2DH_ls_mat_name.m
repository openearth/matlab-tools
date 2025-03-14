%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19763 $
%$Date: 2024-08-30 06:01:35 +0200 (Fri, 30 Aug 2024) $
%$Author: chavarri $
%$Id: gdm_check_type_of_result_2DH_ls.m 19763 2024-08-30 04:01:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_check_type_of_result_2DH_ls.m $
%
%

function fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum,var_str_read,pliname,layer,var_idx)

fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum,'var',var_str_read,'pli',pliname,'layer',layer,'var_idx',var_idx);

end %function