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

function analysis_computational_time(path_folder_sims,path_input_folder,path_input_folder_refmdf)

%% input matrix

fcn_adapt=@(X)input_variation(X);
input_m=D3D_input_variation(path_folder_sims,path_input_folder,path_input_folder_refmdf,fcn_adapt);

%% computational time

timeloop=fcn_get_computational_time(input_m);

%% scaling on each node

data_plot=fcn_data_plot_single_node(input_m,timeloop);

%% PLOT

in_p=struct();
in_p.data_plot=data_plot;

in_p.do_log=0;
in_p.fname='h7_1node';

fig_computational_time(in_p);

in_p.do_log=1;
in_p.fname='h7_1node_log';

fig_computational_time(in_p);

%% multinode

data_plot=fcn_data_plot_multi_node(input_m,timeloop);

%% PLOT

in_p=struct();
in_p.data_plot=data_plot;

in_p.fname='h7_mnode';
in_p.do_log=0;
in_p.do_rel=0;
fig_computational_time_multi_node(in_p);

in_p.fname='h7_mnode_log';
in_p.do_log=1;
in_p.do_rel=0;
fig_computational_time_multi_node(in_p);

in_p.fname='h7_mnode_rel';
in_p.do_log=0;
in_p.do_rel=1;
fig_computational_time_multi_node(in_p);

end %function