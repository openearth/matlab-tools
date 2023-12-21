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
%Flags to plot and default values.

function [vals2add,def_v]=gdm_flags_plot_and_default()

sediment_transport=gdm_struct_sediment_transport();
vals2add={'var_idx','sum_var_idx','do_val_B_mor','do_val_B','layer','unit','do_cum','do_area','sediment_transport','do_vector','tol' };
def_v   ={{[]},                 0,             0,         0,   {[]},  {[]},       0,        0,  sediment_transport,          0,1.5e-7};
% def_t   =[        2,            1,             1,         1,      2,     2,       1,        1,                   3]
end
