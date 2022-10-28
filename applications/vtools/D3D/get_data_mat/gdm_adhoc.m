%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18488 $
%$Date: 2022-10-27 14:13:26 +0200 (Thu, 27 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18488 2022-10-27 12:13:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%variables: open D3D_list_of_variables

function gdm_adhoc(fid_log,in_plot,simdef)

%% PARSE

if isfield(in_plot,'adhoc')==0
    in_plot.adhoc=0;
end

if in_plot.adhoc==0; return; end

%% CALC

switch in_plot.adhoc
    case 1
        tag_check='fig_his_01';
        in_plot_fig=gmd_tag(in_plot,tag_check);
        gdm_adhoc_export_for_groundwater(fid_log,in_plot_fig,simdef);
    otherwise
        messageOut(fid_log,sprintf('Adhoc function %d does not exist.',in_plot.adhoc));
end

end %function