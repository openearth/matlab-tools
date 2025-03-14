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

function what_is=gdm_check_type_of_result_2DH_ls(flg_loc,simdef,fdir_mat,time_dnum,tag,gridInfo)
kt=1;
kpli=1;
kvar=1;
fpath_pli=flg_loc.pli{kpli,1};
pliname=gdm_pli_name(fpath_pli);
varname=flg_loc.var{kvar};
[~,~,var_str]=D3D_var_num2str_structure(varname,simdef);
layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
var_idx=flg_loc.var_idx{1}; %The same applies to all variables. If one is 2DV, all are 2DV. 
fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum(kt),var_str,pliname,layer,var_idx);
data=load(fpath_mat_tmp,'data');
if size(data.data.val,3)>1 %% 2DV
    what_is=1;
else
    what_is=2;
end
end %function