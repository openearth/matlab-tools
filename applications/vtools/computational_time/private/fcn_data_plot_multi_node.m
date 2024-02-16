%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18952 $
%$Date: 2023-05-22 16:55:45 +0200 (Mon, 22 May 2023) $
%$Author: chavarri $
%$Id: figure_layout.m 18952 2023-05-22 14:55:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function data_plot=fcn_data_plot_multi_node(input_m,timeloop)

tasks_total=[input_m.D3D__nodes].*[input_m.D3D__tasks_per_node];
num_nodes=[input_m.D3D__nodes];

tt_u=unique(tasks_total);
ntt=numel(tt_u);

data_plot=struct();
for ktt=1:ntt
    bol_get=tasks_total==tt_u(ktt);
    num_nodes_loc=[input_m(bol_get).D3D__nodes];
    num_nodes_u=unique(num_nodes_loc);
    nnu=numel(num_nodes_u);

    data_plot(ktt).leg=sprintf('tasks = %d',tt_u(ktt));
    for knu=1:nnu
        bol_uu=num_nodes==num_nodes_u(knu);
        bol_g2=bol_get & bol_uu;
       
        %save to plot
        data_plot(ktt).x(knu)=num_nodes_u(knu);
        data_plot(ktt).val_mean(knu)=mean(timeloop(bol_g2));
        data_plot(ktt).val_std(knu)=std(timeloop(bol_g2));
    end %knu
end %ktt

end %function