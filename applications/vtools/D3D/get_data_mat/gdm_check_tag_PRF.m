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

function in_plot_fig=gdm_check_tag_PRF(in_plot)

%% depending on tag

tag_check='PRF';
tag_old='fig_map_2DH_ls_01';

%% common

in_plot_fig=gdm_check_tag(in_plot,tag_old,tag_check);

end %function