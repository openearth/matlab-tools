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

function gdm_plot_STO(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

tag_do='do_p';
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

% flg_loc=gdm_parse_sto(fid_log,flg_loc,simdef);

%% PATHS

% fdir_mat=simdef(1).file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
% mkdir_check(fdir_fig);

%% SUMMERBED PLOT

if flg_loc.do_sb
    for ksim=1:numel(simdef)
        gdm_STO_plot_SMB(fid_log,flg_loc,simdef(ksim))
    end
end

%% ALL TOGETHER

gdm_plot_STO_all(fid_log,flg_loc,simdef);

end %function

%%
%% FUNCTIONS
%%

function gdm_plot_STO_all(fid_log,flg_loc,simdef)


tag='SMB';
in_plot.(tag)=flg_loc;
in_plot.(tag).tag=tag;

%%

nf=numel(gdm_read_dk(simdef)); %we cannot use the size of `qbk` because the loop may be skipped if files exist
nst=numel(flg_loc.sedtrans_name);

in_plot.(tag).var={};
in_plot.(tag).layer={};
in_plot.(tag).var_idx={};
in_plot.(tag).do_val_B_mor=[];
in_plot.(tag).var_2={};
in_plot.(tag).do_cum=[];
in_plot.(tag).do_area=[];

%% sum(Qbk): cumulative of product with width, cumulative, B_mor 

for kst=1:nst
    in_plot.(tag).var=cat(2,in_plot.(tag).var,flg_loc.sedtrans_name{kst}); 
    in_plot.(tag).layer=cat(2,in_plot.(tag).layer,{0});
    in_plot.(tag).var_idx=cat(2,in_plot.(tag).var_idx,{1:1:nf});
    in_plot.(tag).do_val_B_mor=cat(2,in_plot.(tag).do_val_B_mor,1);
    in_plot.(tag).var_2=cat(2,in_plot.(tag).var_2,{'stot'});
    in_plot.(tag).do_cum=cat(2,in_plot.(tag).do_cum,0); %we do not want to plot the cumulative
    in_plot.(tag).do_area=cat(2,in_plot.(tag).do_area,1);
end

%%

in_plot.(tag).do_p_single=0;

% flg_loc=isfield_default(flg_loc,'do_p',1);
% flg_loc=isfield_default(flg_loc,'do_p_single',1);
% flg_loc=isfield_default(flg_loc,'do_diff_t',0);
% flg_loc=isfield_default(flg_loc,'do_diff_s',0);
% flg_loc=isfield_default(flg_loc,'do_diff_s_t',0);
% flg_loc=isfield_default(flg_loc,'do_diff_s_perc',0);
% flg_loc=isfield_default(flg_loc,'do_all_s',1);
% flg_loc=isfield_default(flg_loc,'do_all_s_diff_t',0);
% flg_loc=isfield_default(flg_loc,'do_xvt',0);
% flg_loc=isfield_default(flg_loc,'do_xvt_single',1);
% flg_loc=isfield_default(flg_loc,'do_xvt_diff_t',1);
% flg_loc=isfield_default(flg_loc,'do_xvt_diff_s',1);
% flg_loc=isfield_default(flg_loc,'do_xvt_cel',1);
% flg_loc=isfield_default(flg_loc,'do_plot_structures',0);
% flg_loc=isfield_default(flg_loc,'do_rkm',1); %the default is to convert to rkm. This is not very general maybe, but it applies to our projects. 
% flg_loc=isfield_default(flg_loc,'do_diff_t_first_time',1); 
% flg_loc=isfield_default(flg_loc,'do_diff_s_ref_sim',1); 

% in_plot.(tag).do_output_xvt=1;

%%

[data_xvt_all,data_xvt0_all,tim_dtime_plot]=gdm_plot_SMB(fid_log,in_plot.(tag),simdef);


statis='val_mean_weighted';

val_cum=cell(nst,1);
for kst=1:nst
    val_cum{kst}=gdm_compute_cumulative(data_xvt,statis,tim_dtime_plot);
end

% data_xvt_all
% flg_loc.


% fig_1D_01(flg_loc)
    %call gdm_plot_STO-> get data_xvt as output

%loop on time
%loop on sediment transport relations
    %get cumulative sediment transport for each relation
%plot cumulative for all relations


end