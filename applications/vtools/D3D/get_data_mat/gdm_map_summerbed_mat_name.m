%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18381 $
%$Date: 2022-09-23 10:08:29 +0200 (Fri, 23 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_var_num2str.m 18381 2022-09-23 08:08:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_var_num2str.m $
%

function fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_read,fdir_mat,tag,pol_name,time_dnum_loc,sb_pol)

switch var_str_read
    case 'ba' %variables without time dependency
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
    otherwise
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_loc,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
end

end %function