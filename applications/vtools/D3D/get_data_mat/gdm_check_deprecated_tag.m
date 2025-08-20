%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20194 $
%$Date: 2025-06-13 09:30:18 +0200 (Fri, 13 Jun 2025) $
%$Author: chavarri $
%$Id: plot_all_runs_one_figure.m 20194 2025-06-13 07:30:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_all_runs_one_figure.m $
%
%

function in_plot=gdm_check_deprecated_tag(in_plot,tag_check,tag_new)

if isfield(in_plot,tag_check)==1
    warning('Tag %s is deprecated. Use %s',tag_check,tag_new)
    in_plot.(tag_new)=in_plot.(tag_check);
end

end %function