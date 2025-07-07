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

function fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum,var_str_read,pliname,layer,var_idx)

fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum,'var',var_str_read,'pli',pliname,'layer',layer,'var_idx',var_idx);

end %function