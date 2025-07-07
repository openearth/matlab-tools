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
%Parse all flags. Called in create mat and plot. 

function flg_loc=gdm_parse_summerbed(flg_loc,simdef)

fid_log=NaN;

flg_loc=isfield_default(flg_loc,'sim_ref',1);
flg_loc=isfield_default(flg_loc,'do_p',1);
flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_perc',0);
flg_loc=isfield_default(flg_loc,'do_all_s',1);
flg_loc=isfield_default(flg_loc,'do_all_s_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_xvt',0);
flg_loc=isfield_default(flg_loc,'do_xvt_single',1);
flg_loc=isfield_default(flg_loc,'do_xvt_diff_t',1);
flg_loc=isfield_default(flg_loc,'do_xvt_diff_s',1);
flg_loc=isfield_default(flg_loc,'do_xvt_cel',1);
flg_loc=isfield_default(flg_loc,'do_plot_structures',0);
flg_loc=isfield_default(flg_loc,'do_rkm',1); %the default is to convert to rkm. This is not very general maybe, but it applies to our projects. 
flg_loc=isfield_default(flg_loc,'tol_time_measurements',1);
flg_loc=isfield_default(flg_loc,'is_pol_diff',zeros(1,numel(flg_loc.sb_pol)));

flg_loc=isfield_default(flg_loc,'do_diff_pol',0);
if isfield(flg_loc,'sb_pol_diff')
    flg_loc.do_diff_pol=1;
end

flg_loc=isfield_default(flg_loc,'do_legend_adhoc',0);
if isfield(flg_loc,'legend_file')
    flg_loc.legend_adhoc=readcell(flg_loc.legend_file,'delimiter','|||'); %I assume nobody will use ||| in the legend. 
    flg_loc.do_legend_adhoc=1;
end

flg_loc=isfield_default(flg_loc,'do_tv',0);
if flg_loc.do_tv==1 
    if ~isfield(flg_loc,'rkm_plot_tv')
        messageOut(fid_log,'You want to plot `tv` but there is no `rkm_plot_tv`.')
        flg_loc.do_tv=0;
    elseif ~iscell(flg_loc.rkm_plot_tv)
        messageOut(fid_log,'`rkm_plot_tv` must be cell array.')
        flg_loc.do_tv=0;
    end
end


% flg_loc=isfield_default(flg_loc,'do_sb_pol_together',0);
% if isfield(flg_loc,'sb_pol_together')
%     flg_loc.do_sb_pol_together=1;
% end

%%

flg_loc=gdm_default_flags(flg_loc);

flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

flg_loc=gdm_parse_stot(flg_loc,simdef);

flg_loc=gdm_parse_val_B_mor(flg_loc,simdef);

flg_loc=gdm_parse_val_B(flg_loc,simdef);

%% Plotting flags

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_s_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_t_var'); 

end

%%
%% FUNCTIONS
%%

