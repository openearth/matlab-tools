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

function data_plot=fcn_data_plot_all(input_m,timeloop)

data_plot.x=[input_m.D3D__nodes].*[input_m.D3D__tasks_per_node];
data_plot.nodes=[input_m.D3D__nodes];
data_plot.y=timeloop;

end %function