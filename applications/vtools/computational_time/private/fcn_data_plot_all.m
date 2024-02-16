%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19434 $
%$Date: 2024-02-16 15:11:01 +0100 (Fri, 16 Feb 2024) $
%$Author: chavarri $
%$Id: fcn_data_plot_multi_node.m 19434 2024-02-16 14:11:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/computational_time/private/fcn_data_plot_multi_node.m $
%

function data_plot=fcn_data_plot_all(input_m,timeloop)

data_plot.x=[input_m.D3D__nodes].*[input_m.D3D__tasks_per_node];
data_plot.nodes=[input_m.D3D__nodes];
data_plot.y=timeloop;

end %function