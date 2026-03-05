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

tag='STO'; %It needs to be this tag because we read variables created with this tag.
tag_fig=tag;

in_plot.(tag)=flg_loc;
in_plot.(tag).tag=tag;

in_plot.(tag).do_p_single=0;

%% allocate

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


%% PATHS

kref=flg_loc.sim_ref;

fdir_mat=simdef(kref).file.mat.dir;
fpath_map=simdef(kref).file.map;
fdir_fig=fullfile(simdef(kref).file.fig.dir,tag_fig,tag_serie);
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% TIME

%create time vector
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%take the one for plotting
%
%Rather than calling the function, we know it is morpho. 
% [gridInfo_ref,time_dnum_ref,time_dnum_plot,~,tim_dtime_plot]=gdm_load_time_grid(fid_log,flg_loc,simdef(kref),tag);
tim_dtime_plot=time_mor_dtime;
time_dnum_plot=time_mor_dnum;

%% DATA

[data_xvt_all,data_xvt0_all]=gdm_plot_SMB(fid_log,in_plot.(tag),simdef);

%% CUMULATIVE

statis='val_mean_weighted';

%We could loop over the following variables. For now we keep it simple. 
kt=nt;
krkmv=1;
ksb=1;

val_cum=cell(nst,1);
runid=simdef(kref).file.runid;
for kst=1:nst
    val_cum{kst}=gdm_compute_cumulative(data_xvt_all{1,1,kst},statis,tim_dtime_plot);
    val_cum_sum{kst}=sum(val_cum{kst},4);
    val_cum_sum_kt{kst}=squeeze(val_cum_sum{kst}(:,:,kt));
end

%% PLOT

%x-vector
pol_name=flg_loc.rkm_name{krkmv};
rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

%names for filenames
[sb_pol,sb_def,str_save_sb_pol,npol]=gdm_read_summerbed_polygon_all(fid_log,flg_loc,fdir_mat,fpath_map,ksb);    

fdir_fig_loc=fullfile(fdir_fig,str_save_sb_pol,pol_name,'cumulative_all');
mkdir_check(fdir_fig_loc);

fname_noext=fullfile(fdir_fig_loc,sprintf('%s_all_%s_%s_%s_%s',tag,runid,datestr(time_dnum_plot(kt),'yyyymmdd_HHMMSS'),statis,sb_pol{ksb}));

%plot

in_p=flg_loc;
in_p.val=cell2mat(val_cum_sum_kt);
in_p.tim=time_dnum_plot(kt);
in_p.variable='stot';
in_p.fname=fname_noext;
in_p.s=rkmv.rkm_cen;
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;

fig_1D_01(in_p);

end %function