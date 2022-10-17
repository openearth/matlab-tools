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

function fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_read,fdir_mat,tag,pol_name,time_dnum_loc,sb_pol)

switch var_str_read
    case 'ba' %variables without time dependency
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
    otherwise
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_loc,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
end

end %function