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
var_str=D3D_var_num2str_structure(varname,simdef);
layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'pli',pliname,'layer',layer);
data=load(fpath_mat_tmp,'data');
if size(data.data.val,3)>1 %% 2DV
    what_is=1;
else
    what_is=2;
end
end %function