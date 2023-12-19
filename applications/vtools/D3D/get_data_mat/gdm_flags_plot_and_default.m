%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19010 $
%$Date: 2023-06-20 17:14:57 +0200 (Tue, 20 Jun 2023) $
%$Author: kosters $
%$Id: gdm_parse_sediment_transport.m 19010 2023-06-20 15:14:57Z kosters $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_sediment_transport.m $
%
%Flags to plot and default values.

function [vals2add,def_v]=gdm_flags_plot_and_default()

sediment_transport=gdm_struct_sediment_transport();
vals2add={'var_idx','sum_var_idx','do_val_B_mor','do_val_B','layer','unit','do_cum','do_area','sediment_transport','do_vector','tol' };
def_v   ={{[]},                 0,             0,         0,   {[]},  {[]},       0,        0,  sediment_transport,          0,1.5e-7};
% def_t   =[        2,            1,             1,         1,      2,     2,       1,        1,                   3]
end
