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
    case 2
        tag_check='fig_map_2DH_01';
        in_plot_fig=gmd_tag(in_plot,tag_check);
        gdm_adhoc_cummulative_energy_loss(fid_log,in_plot_fig,simdef);
    case 3 
        tag_check='fig_map_2DH_ls_01';
        in_plot_fig=gmd_tag(in_plot,tag_check);
        gdm_adhoc_infinitesimal_perturbation_propagation(fid_log,in_plot_fig,simdef);
    otherwise
        messageOut(fid_log,sprintf('Adhoc function %d does not exist.',in_plot.adhoc));
end

end %function