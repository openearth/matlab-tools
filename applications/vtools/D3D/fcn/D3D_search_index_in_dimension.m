%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18516 $
%$Date: 2022-11-04 16:20:34 +0100 (Fri, 04 Nov 2022) $
%$Author: chavarri $
%$Id: gdm_order_dimensions.m 18516 2022-11-04 15:20:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_order_dimensions.m $
%
%

function idx_f=D3D_search_index_in_dimension(data,varname)

str_sim_c=strrep(data.dimensions,'[','');
str_sim_c=strrep(str_sim_c,']','');
tok=regexp(str_sim_c,',','split');
idx_f=find_str_in_cell(tok,{varname});

end %function