%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19744 $
%$Date: 2024-08-21 16:45:01 +0200 (Wed, 21 Aug 2024) $
%$Author: chavarri $
%$Id: plot_map_2DH_ls_diff_01.m 19744 2024-08-21 14:45:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_ls_diff_01.m $
%
%

function what_is=gdm_check_type_of_result_2DH_ls(flg_loc,simdef,fdir_mat,time_dnum,tag)
kt=1;
kpli=1;
kvar=1;
fpath_pli=flg_loc.pli{kpli,1};
pliname=gdm_pli_name(fpath_pli);
varname=flg_loc.var{kvar};
var_str=D3D_var_num2str_structure(varname,simdef);
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'pli',pliname);
data=load(fpath_mat_tmp,'data');
if size(data.data.val,3)>1 %% 2DV
    what_is=1;
else
    what_is=2;
end
end %function