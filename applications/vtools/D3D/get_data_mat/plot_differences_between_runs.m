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
%Plot differences between runs

function plot_differences_between_runs(fid_log,in_plot,simdef_ref,simdef)
        
%% map_sal_01
if isfield(in_plot,'fig_map_sal_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <sal>')
%             in_plot_loc=in_plot_loc.fig_map_sal_01;
%             in_plot_loc.tag_fig=sprintf('%s_diff',in_plot_loc.tag);
%             plot_map_sal_diff_01(fid_log,in_plot_loc,simdef_ref,simdef)
end

%% sal mass  
if isfield(in_plot,'fig_map_sal_mass_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%             plot_map_sal_diff_01(fid_log,in_plot.fig_map_sal_mass_01,simdef_ref,simdef)
end

%% his sal 01
if isfield(in_plot,'fig_his_sal_01')==1
    warning('deprecate and call <his_01>')
%             in_plot.fig_his_sal_01.tag_fig=sprintf('%s_diff',in_plot.fig_his_sal_01.tag);
%             plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
end

%% his sal 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
%     plot_his_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 2DH
% tag_check='fig_map_2DH_01';
% if isfield(in_plot,tag_check)==1
%     in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
%     plot_map_2DH_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
% end

%% map 2DH ls
%Done when passing `simdef_all`
% tag_check='fig_map_2DH_ls_01';
% if isfield(in_plot,tag_check)==1
%     in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
%     plot_map_2DH_ls_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
% end

%% map 1D
%Done when passing `simdef_all`
% tag_check='fig_map_1D_01';
% if isfield(in_plot,tag_check)==1
%     in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
%     plot_map_1D_xv_diff_01(fid_log,in_plot_fig,simdef_ref,simdef);
% end

%% map_summerbed
%better is to just call it one, but we have to pass simdef_ref to the regular call
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
    plot_1D_01(fid_log,in_plot_fig,simdef,'simdef_ref',simdef_ref);
end

end %function