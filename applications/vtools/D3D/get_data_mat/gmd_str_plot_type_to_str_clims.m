%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19787 $
%$Date: 2024-09-19 17:02:24 +0200 (Thu, 19 Sep 2024) $
%$Author: chavarri $
%$Id: gdm_parse_ylims.m 19787 2024-09-19 15:02:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_ylims.m $
%
%

function [clims_str_var,clims_str]=gmd_str_plot_type_to_str_clims(str_plot_types,kpt,str_clims)

tag_ref=str_plot_types{kpt}; %'diff_t'
clims_str=gdm_str_cmap_clim(tag_ref,str_clims); %clims_diff_t
clims_str_var=sprintf('%s_var',clims_str); %clims_diff_t_var

end %function