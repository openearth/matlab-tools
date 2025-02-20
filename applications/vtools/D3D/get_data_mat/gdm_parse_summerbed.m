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
flg_loc=isfield_default(flg_loc,'do_plot_structures',0);
flg_loc=isfield_default(flg_loc,'do_rkm',1); %the default is to convert to rkm. This is not very general maybe, but it applies to our projects. 

flg_loc=isfield_default(flg_loc,'do_legend_adhoc',0);
if isfield(flg_loc,'legend_file')
    flg_loc.legend_adhoc=readcell(flg_loc.legend_file,'delimiter','|||'); %I assume nobody will use ||| in the legend. 
    flg_loc.do_legend_adhoc=1;
end

flg_loc=isfield_default(flg_loc,'tol_time_measurements',1);

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

%add B_mor variables to plot
flg_loc=check_B(fid_log,flg_loc,simdef,'B_mor');
flg_loc=check_B(fid_log,flg_loc,simdef,'B');

end

%%
%% FUNCTIONS
%%

function flg_loc=check_B(fid_log,flg_loc,simdef,str_in)

flg_loc.var=reshape(flg_loc.var,1,numel(flg_loc.var));
flg_loc.do_cum=reshape(flg_loc.do_cum,1,numel(flg_loc.do_cum));
flg_loc.unit=reshape(flg_loc.unit,1,numel(flg_loc.unit));

str_do=sprintf('do_val_%s',str_in);
if isfield(flg_loc,str_do)==0
    flg_loc.(str_do)=zeros(size(flg_loc.var));
end
nvar_tmp=numel(flg_loc.var);
for kvar=1:nvar_tmp
    if flg_loc.(str_do)(kvar)
        [~,~,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
        flg_loc.var=cat(2,flg_loc.var,sprintf('%s_%s',var_str_save,str_in));
        flg_loc.ylims_var=cat(1,flg_loc.ylims_var,flg_loc.ylims_var{kvar,1});
        flg_loc.ylims_diff_s_var=cat(1,flg_loc.ylims_diff_s_var,flg_loc.ylims_diff_s_var{kvar,1});
        flg_loc.ylims_diff_t_var=cat(1,flg_loc.ylims_diff_t_var,flg_loc.ylims_diff_t_var{kvar,1});

        %add one more entry with default values
        flg_loc=gdm_add_flags_plot(flg_loc);

        %modify last entry
        flg_loc.unit{end}=sprintf('%s_%s',flg_loc.unit{kvar},str_in);
        flg_loc.var_idx{end}=flg_loc.var_idx{kvar};
        flg_loc.do_area(end)=flg_loc.do_area(kvar);
        flg_loc.do_cum(end)=flg_loc.do_cum(kvar);
    end
end

end %function