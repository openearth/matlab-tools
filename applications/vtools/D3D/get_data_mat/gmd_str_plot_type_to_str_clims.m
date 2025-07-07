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

function [clims_str_var,clims_str]=gmd_str_plot_type_to_str_clims(str_plot_types,kpt,str_clims)

tag_ref=str_plot_types{kpt}; %'diff_t'
clims_str=gdm_str_cmap_clim(tag_ref,str_clims); %clims_diff_t
clims_str_var=sprintf('%s_var',clims_str); %clims_diff_t_var

end %function