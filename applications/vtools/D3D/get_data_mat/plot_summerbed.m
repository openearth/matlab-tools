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

function plot_summerbed(fid_log,flg_loc,simdef)

%% TAG

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% PARSE

flg_loc=gdm_parse_summerbed(flg_loc,simdef(1));

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% LOAD REFERENCE DATA

%time is based on reference simulation. 
kref=flg_loc.sim_ref;
[gridInfo_ref,time_dnum_ref,time_dnum_plot,~,tim_dtime_plot]=gdm_load_time_grid(fid_log,flg_loc,simdef(kref),tag);

%% DIMENSION

nt=size(time_dnum_plot,1);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);
nsim=numel(simdef);

%% FIGURE

in_p=flg_loc;

%% COMMON

in_p.all_struct=gdm_read_structures(simdef,flg_loc);

%% LOOP ON SUMMERBED POLYGONS
for ksb=1:nsb %summerbed polygons

    %Read summerbed polygon. 
    %ATTENTION: The polygon of the reference simulation is
    %used for all simulations. It is supposed that when running with
    %several simulations they are all the same. 

    fdir_mat=simdef(kref).file.mat.dir;
    fpath_map=simdef(kref).file.map;
    fdir_fig=fullfile(simdef(kref).file.fig.dir,tag_fig,tag_serie);

    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);
    sb_def=gdm_read_summerbed(flg_loc,fid_log,fdir_mat,fpath_sb_pol,fpath_map);

    %% LOOP ON RKM POLYGONS
    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;

        kt_v=gdm_kt_v(flg_loc,nt); %time index vector

        fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,'inpol');
        plot_summerbed_inpolygon(flg_loc,fdir_fig_loc,rkmv,sb_def,gridInfo_ref);

        %% LOOP ON VARIABLES
        for kvar=1:nvar %variable
            
            var_idx=flg_loc.var_idx{kvar};

            in_p.frac=var_idx;
            in_p.do_area=flg_loc.do_area(kvar);

            [var_str_read,~,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
                       
            %time 0 of all simulations (their time 0, it can be different
            %than the time 0 of the reference simulation).
            data_0=load_data_0(flg_loc,simdef,var_str_read,var_str_save,tag,pol_name,sb_pol,kvar,nsim);
                                          
            %allocate for saving all data if necessary
            fn_data=fieldnames(data_0(1));
            nfn=numel(fn_data);
            [nx,nD]=size(data_0(1).(fn_data{1}));
            if flg_loc.do_xvt 
                for kfn=1:nfn
                    statis=fn_data{kfn};
                    
                    data_xvt.(statis)=NaN(nx,nsim,nt,nD);
                    data_xvt0.(statis)=NaN(nx,nsim,nt,nD);
                end
            end

            %ylims
            lims=flg_loc.ylims_var{kvar,1};
            lims_diff_t=flg_loc.ylims_diff_t_var{kvar,1};
            lims_diff_s=flg_loc.ylims_diff_s_var{kvar,1};

            %% LOOP ON REFERENCE TIME
            ktc=0;
            for kt=kt_v %time
                ktc=ktc+1;
                
                %local time of reference simulation.
                time_plot_loc=time_dnum_plot(kt); 
                in_p.tim=time_plot_loc; %pass to plot

                %load all simulations at local time
                for ksim=1:nsim
                    [gridInfo,time_dnum_loc,time_dnum_plot_loc]=gdm_load_time_grid(fid_log,flg_loc,simdef(ksim),tag);
                    %We search in the vector-time of a simulation (`ksim`)
                    %in plot units (`plot`) (can either be flow or morpho) in dnum format = `time_dnum_plot_loc`
                    %
                    %We search for a time in the reference-simulation time-vector in plot
                    %units in dnum format = `time_plot_loc`
                    %
                    %If we find it, we will take the flow time of the
                    %simulation. I.e., an index in `time_dnum_loc`
                    data_sim(ksim)=load_data_match_time(flg_loc,simdef(ksim),time_dnum_plot_loc,time_plot_loc,time_dnum_loc,data_0(1),gridInfo,var_str_read,var_str_save,tag,pol_name,sb_pol,kvar);
                end
                
                %ad-hoc legend with string as a function of time
                if flg_loc.do_legend_adhoc
                    in_p.leg_str=flg_loc.legend_adhoc{kt,1};
                    in_p.do_leg=1;
                end

                %% LOOP ON FIELDNAMES
                for kfn=1:nfn
                    statis=fn_data{kfn};
                    
                    %skip statistics not in list    
                    if isfield(flg_loc,'statis_plot')
                        if ismember(statis,flg_loc.statis_plot)==0
                            continue
                        end
                    end
                    
                    [in_p.lab_str,in_p.is_std]=adjust_label(flg_loc,kvar,var_str_save,statis);
                    
                    %measurements          
                    [plot_mea,data_mea]=gdm_load_measurements_match_time(flg_loc,time_plot_loc,var_str_save,ksb,statis);
                    %measurements at time 0. We need the `statis`, so it better be here than outside the loop.                         
                    [~,data_mea_0]=gdm_load_measurements_match_time(flg_loc,time_dnum_plot(1),var_str_save,ksb,statis);

                    %% regular plot
                    if flg_loc.do_p_single
                        for ksim=1:nsim 
                            bol_ks=false(nsim,1);
                            bol_ks(ksim)=true;

                            tag_ref='val';
                            lims_loc=lims;

                            in_p.is_diff=0;
                            in_p.is_background=0;
                            in_p.is_percentage=0;
                            in_p.val=[data_sim(bol_ks).(statis)];
                            in_p.leg_str=flg_loc.leg_str(ksim);

                            in_p.plot_mea=plot_mea;
                            in_p.s_mea=data_mea.x;
                            in_p.val_mea=data_mea.y;

                            runid=simdef(bol_ks).file.runid;

                            fcn_plot(flg_loc,in_p,fid_log,simdef(bol_ks),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                        end %ks
                    end

                    %% difference with initial time
                    if flg_loc.do_diff_t
                        for ksim=1:nsim 
                            bol_ks=false(nsim,1);
                            bol_ks(ksim)=true;

                            tag_ref='diff_t';
                            lims_loc=lims_diff_t;

                            in_p.is_diff=1;
                            in_p.is_background=0;
                            in_p.is_percentage=0;
                            in_p.val=[data_sim(bol_ks).(statis)]-[data_0(bol_ks).(statis)];
                            in_p.leg_str=flg_loc.leg_str(ksim);

                            in_p.plot_mea=plot_mea;
                            if plot_mea
                                in_p.s_mea=data_mea.x;
                                in_p.val_mea=data_mea.y-data_mea_0.y;
                            end

                            runid=simdef(bol_ks).file.runid;

                            fcn_plot(flg_loc,in_p,fid_log,simdef(bol_ks),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                        end %ks
                    end

                    %% difference with reference
                    if flg_loc.do_diff_s && ksim~=kref
                        for ksim=1:nsim 
                            bol_ks=false(nsim,1);
                            bol_ks(ksim)=true;

                            tag_ref='diff_s';
                            lims_loc=lims_diff_s;

                            in_p.is_diff=1;
                            in_p.is_background=0;
                            in_p.is_percentage=0;
                            in_p.val=[data_sim(bol_ks).(statis)]-[data_sim(kref).(statis)];
                            in_p.leg_str=flg_loc.leg_str(ksim);

                            in_p.plot_mea=0; %nothing to plot when doing difference between simulations. 

                            runid=sprintf('%s-%s',simdef(bol_ks).file.runid,simdef(kref).file.runid);

                            fcn_plot(flg_loc,in_p,fid_log,simdef(bol_ks),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                        end %ks
                    end

                    %% difference with reference and initial time
                    if flg_loc.do_diff_s_t && ksim~=kref
                        for ksim=1:nsim 
                            bol_ks=false(nsim,1);
                            bol_ks(ksim)=true;

                            tag_ref='diff_s_t';
                            lims_loc=lims_diff_t;

                            in_p.is_diff=1;
                            in_p.is_background=0;
                            in_p.is_percentage=0;
                            in_p.val=([data_sim(bol_ks).(statis)]-[data_0(kref).(statis)])-([data_sim(kref).(statis)]-[data_0(kref).(statis)]);
                            in_p.leg_str=flg_loc.leg_str(ksim);

                            in_p.plot_mea=0; %nothing to plot when doing difference between simulations. 

                            runid=sprintf('%s-%s',simdef(bol_ks).file.runid,simdef(kref).file.runid);

                            fcn_plot(flg_loc,in_p,fid_log,simdef(bol_ks),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                        end %ks
                    end

                    %% difference with reference in percentage terms
                    if flg_loc.do_diff_s_perc && ksim~=kref
                        for ksim=1:nsim 
                            bol_ks=false(nsim,1);
                            bol_ks(ksim)=true;

                            tag_ref='diff_s_perc';
                            lims_loc=[-100,100]; %adjust

                            in_p.is_diff=1;
                            in_p.is_background=0;
                            in_p.is_percentage=1;

                            val_ref_tt_tmp=[data_sim(kref).(statis)];
                            bol_0=val_ref_tt_tmp==0;
                            val_ref_tt_tmp(bol_0)=NaN;

                            in_p.val=([data_sim(bol_ks).(statis)]-val_ref_tt_tmp)./val_ref_tt_tmp*100;
                            in_p.leg_str=flg_loc.leg_str(ksim);

                            in_p.plot_mea=0; %nothing to plot when doing difference between simulations. 

                            runid=sprintf('%s-%s',simdef(bol_ks).file.runid,simdef(kref).file.runid);

                            fcn_plot(flg_loc,in_p,fid_log,simdef(bol_ks),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                        end %ks
                    end

                    %% all simulations together
                    if flg_loc.do_all_s && nsim>1
                        bol_ks=true(nsim,1);

                        tag_ref='all_s';
                        lims_loc=lims;

                        in_p.is_diff=0;
                        in_p.is_background=0;
                        in_p.is_percentage=0;

                        in_p.val=[data_sim(bol_ks).(statis)];
                        in_p.leg_str=flg_loc.leg_str;

                        in_p.plot_mea=plot_mea;
                        if plot_mea
                            in_p.s_mea=data_mea.x;
                            in_p.val_mea=data_mea.y;
                        end

                        runid='';

                        fcn_plot(flg_loc,in_p,fid_log,simdef(kref),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                    end

                    %% all simulations together difference in time
                    if flg_loc.do_all_s_diff_t && nsim>1
                        bol_ks=true(nsim,1);

                        tag_ref='all_s_diff_t';
                        lims_loc=lims_diff_t;

                        in_p.is_diff=1;
                        in_p.is_background=0;
                        in_p.is_percentage=0;

                        in_p.val=[data_sim(bol_ks).(statis)]-[data_0(bol_ks).(statis)];
                        in_p.leg_str=flg_loc.leg_str;

                        in_p.plot_mea=plot_mea;
                        if plot_mea
                            in_p.s_mea=data_mea.x;
                            in_p.val_mea=data_mea.y-data_mea_0.y;
                        end

                        runid='';

                        fcn_plot(flg_loc,in_p,fid_log,simdef(kref),tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,lims_loc);
                    end
                    
                    %% SAVE FOR XVT
                    if flg_loc.do_xvt
                        %<data_sim> has simulation in the structure.
                        %<data_xvt> has simulation in the second column. 
                        data_xvt.(statis)(:,:,kt,:)=[data_sim.(statis)];
                        data_xvt0.(statis)(:,:,kt,:)=[data_0.(statis)];
                    end

                    %% DISP
                    messageOut(fid_log,sprintf('Done plotting figure %s rkm poly %4.2f %% time %4.2f %% variable %4.2f %% statistic %4.2f %%',tag,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100,kfn/nfn*100));

                end %kfn

                %BEGIN DEBUG

                %END DEBUG

                %% movie

%                 if isfield(flg_loc,'do_movie')==0
%                     flg_loc.do_movie=1;
%                 end

            end %kt
            
            %% xvt
            multi_dim=check_multi_dimensional(data_0(kref));

            if flg_loc.do_xvt && ~multi_dim %skip if multidimentional
               plot_xvt(fid_log,flg_loc,rkmv.rkm_cen,tim_dtime_plot,kvar,data_xvt,data_xvt0,simdef,sb_pol,pol_name,var_str_save,tag,in_p.all_struct,tag_fig,tag_serie,var_idx,lims)
            end
            
            %% cumulative
            if flg_loc.do_cum(kvar)
                plot_cum(simdef,time_dnum_plot,nx,nsim,nD,flg_loc.lab_str,data_xvt,sb_pol,pol_name,var_str_save,var_idx,kt_v,tag_fig,tag_serie,lims);
            end
            
        end %kvar    
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,fn,sb_pol,var_idx,kylim)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
nvi=numel(var_idx);
svi=repmat('%02d',1,nvi);
var_idx_s=sprintf(svi,var_idx);

if isempty(runid)
    fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_ylim_%02d',tag,datestr(time_dnum,'yyyymmddHHMM'),var_str,var_idx_s,fn,sb_pol,kylim));
else
    fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%s_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,var_idx_s,fn,sb_pol,kylim));
end

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function

%%

function fpath_fig=fig_name_xvt(fdir_fig,tag,runid,var_str,fn,sb_pol,kref,kclim,var_idx)

nvi=numel(var_idx);
svi=repmat('%02d',1,nvi);
var_idx_s=sprintf(svi,var_idx);

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_allt_%s_%s_%s_%s_%02d_clim_%02d',tag,runid,var_str,var_idx_s,fn,sb_pol,kref,kclim));

end %function

%%

function plot_xvt(fid_log,flg_loc,s,tim_dtime_p,kvar,data_xvt,data_xvt0,simdef,sb_pol,pol_name,var_str_save,tag,all_struct,tag_fig,tag_serie,var_idx,ylims)

%% PARSE

if ~flg_loc.do_xvt
    messageOut(fid_log,'Not doing xvt plot.')
    return
end

if numel(tim_dtime_p)<=1
    messageOut(fid_log,'Insufficient times for xvt plot')
    return
end

%% CALC

fn_data=fieldnames(data_xvt);
nfn=numel(fn_data);
ndiff=gdm_ndiff(flg_loc);
nclim=size(ylims,1);
nS=numel(simdef);

[x_m,y_m]=meshgrid(s,tim_dtime_p);

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.fig_size=[0,0,14.5,12];

in_p.all_struct=all_struct;
in_p.x_m=x_m;
in_p.y_m=y_m;
in_p.ml=2.5;

in_p.ylab_str='';
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;
in_p.frac=var_idx;
%                 in_p.tit_str=branch_name;

for kS=1:nS

    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie); 
    runid=simdef(kS).file.runid;

    for kfn=1:nfn
        statis=fn_data{kfn};

        %skip statistics not in list    
        if isfield(flg_loc,'statis_plot')
            if ismember(statis,flg_loc.statis_plot)==0
                continue
            end
        end

        val_1=squeeze(data_xvt.(statis)(:,kS,:))';
        val_0=squeeze(data_xvt0.(statis)(:,kS,:))';

        [in_p.lab_str,in_p.is_std]=adjust_label(flg_loc,kvar,var_str_save,statis);
        in_p.clab_str=lab_str;

        for kdiff=1:ndiff
            for kclim=1:nclim

                [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,val_1,val_0,'ylims','ylims_diff',var_str_save);
                in_p.clims=in_p.ylims; %the output from `gdm_data_diff` is saved in the variable we call first (`ylims`) and we want it here for `clims`.
                in_p.ylims=NaN;
                fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,tag_ref);
                mkdir_check(fdir_fig_loc,NaN,1,0);
                fname_noext=fig_name_xvt(fdir_fig_loc,tag,runid,var_str_save,statis,sb_pol,kdiff,kclim,var_idx);

                in_p.fname=fname_noext;
                fig_surf(in_p)
            end %kclim
        end %kdiff
    end %kfn
end %kS

end %function

%%

function plot_summerbed_inpolygon(flg_loc,fdir_fig_loc,rkmv,sb_def,gridInfo)

%% PARSE

flg_loc=isfield_default(flg_loc,'do_plot_inpolygon',1);
if flg_loc.do_plot_inpolygon==0
    return
end

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.gridInfo=gridInfo;
% in_p.gridInfo_v=gridInfo_v;
in_p=gdm_read_plot_along_rkm(in_p,flg_loc);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%fxw
if isfield(flg_loc,'do_fxw')==0
    flg_loc.do_fxw=0;
end
switch flg_loc.do_fxw
    case 1
        in_p.fxw=gdm_load_fxw(fid_log,fdir_mat,'fpath_fxw',simdef.file.fxw); %non-snapped
    case 2
        in_p.fxw=gdm_load_snapped(fid_log,fdir_mat,simdef,'fxw');
end
if isfield(in_p,'fxw') && ~isstruct(in_p.fxw) && isnan(in_p.fxw)
    in_p=rmfield(in_p,'fxw');
end

[xlims_all,ylims_all]=D3D_gridInfo_lims(gridInfo);

%% data

data=NaN(size(gridInfo.Xcen));
npol=numel(rkmv.rkm_cen);
for kpol=1:npol
    bol_get=rkmv.bol_pol_loc{kpol} & sb_def.bol_sb;
    data(bol_get)=rkmv.rkm_cen(kpol);
end %kpol
in_p.val=data;
in_p.unit='rkm';
in_p.clims=NaN;
in_p.do_title=0;

%% PLOT ALL

mkdir_check(fdir_fig_loc,NaN,1,0);
in_p.fname=fullfile(fdir_fig_loc,'inpoly');
in_p.xlims=xlims_all;
in_p.ylims=ylims_all;

fig_map_sal_01(in_p);

%% PLOT RKM

if flg_loc.do_plot_along_rkm==1
    for krkm=flg_loc.krkm_v
        
        in_p.xlims=in_p.rkm{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
        in_p.ylims=in_p.rkm{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];

        in_p.fname=fullfile(fdir_fig_loc,sprintf('inpoly_%02d',krkm));

        fig_map_sal_01(in_p);
    end %krkm
end %do

end %function

%%

%For a certain time, it searches the results that match this time and makes 
%the difference. The reference data is passed.
%
function data=load_data_match_time(flg_loc,simdef,time_dnum_plot,time_dnum_plot_kt,time_dnum,data_ref,gridInfo,var_str_read,var_str_save,tag,pol_name,sb_pol,kvar)

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

%% CALC

%we do not need dtime, only dnum.
% [time_loc_v]=gdm_time_flow_mor(flg_loc,simdef,time_dnum,NaT,time_mor_dnum,NaT); %[nt_loc,1]

[kt_loc,~,flg_found]=absmintol(time_dnum_plot,time_dnum_plot_kt,'tol',tol_tim,'do_break',0,'do_disp_list',2,'dnum',1);
if ~flg_found
    %fill with nans
    fn_data=fieldnames(data_ref(1));
    nfn=numel(fn_data);
    for kfn=1:nfn
        data.(fn_data{kfn})=NaN(size(data_0_loc(1).(fn_data{kfn})));
    end
else
    data=load_data(flg_loc,gridInfo,simdef,time_dnum(kt_loc),var_str_read,var_str_save,tag,pol_name,sb_pol,kvar);
end    

end %function

%%

function data=load_data(flg_loc,gridInfo,simdef,time_dnum_kt,var_str_read,var_str_save,tag,pol_name,sb_pol,kvar)

layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); 
fdir_mat=simdef.file.mat.dir;
fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_save,fdir_mat,tag,pol_name,time_dnum_kt,sb_pol,flg_loc.var_idx{kvar},layer); %flow time for filename
load(fpath_mat_tmp,'data');            

end %function

%%

function multi_dim=check_multi_dimensional(data)

fn_data=fieldnames(data);
sval=size(data.(fn_data{1}));
multi_dim=false;
if sval(2)>1 || numel(sval(2:end))>1
    multi_dim=true;
end

end %function

%%

function data_0=load_data_0(flg_loc,simdef,var_str_read,var_str_save,tag,pol_name,sb_pol,kvar,nsim)

fid_log=NaN;

for ksim=1:nsim
    [gridInfo,time_dnum,~]=gdm_load_time_grid(fid_log,flg_loc,simdef(ksim),tag);
    data_0(ksim)=load_data(flg_loc,gridInfo,simdef(ksim),time_dnum(1),var_str_read,var_str_save,tag,pol_name,sb_pol,kvar);
end

end

%%

function [lab_str,is_std]=adjust_label(flg_loc,kvar,var_str_save,statis)

%units (cannot be outside <fn> loop because it can be overwritten)
if isfield(flg_loc,'unit') && ~isempty(flg_loc.unit{kvar})
    lab_str=flg_loc.unit{kvar};
else
    lab_str=var_str_save;
end

%adjust depending on statistic
switch statis
    case 'val_sum_length'
        lab_str=sprintf('%s/B',lab_str);
end

%standard deviation
is_std=false;
switch statis
    case 'val_std'
        is_std=true;
end

end %function

%%

function fcn_plot(flg_loc,in_p,fid_log,simdef,tag_serie,sb_pol,pol_name,var_str_save,statis,tag,tag_ref,time_plot_loc,var_idx,runid,ylims)

tag_fig=flg_loc.tag;
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie); 
fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,tag_ref);
tag_fig_loc=sprintf('%s_%s',tag,tag_ref);

mkdir_check(fdir_fig_loc,fid_log,1,0);

nylim=size(ylims,1);

for kylim=1:nylim
    fname_noext=fig_name(fdir_fig_loc,tag_fig_loc,runid,time_plot_loc,var_str_save,statis,sb_pol,var_idx,kylim);

    in_p.fname=fname_noext;
    in_p.ylims=ylims(kylim,:);

    fig_1D_01(in_p);
end
end %function

%%

function plot_cum(simdef,time_dnum_plot,nx,nsim,nD,lab_str,data_xvt,sb_pol,pol_name,var_str_save,var_idx,kt_v,tag_fig,tag_serie,lims)

for ksim=1:nsim

    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
    
    statis='val_mean';
    diff_tim=seconds(diff(time_dnum_plot));
    val_tim=data_xvt.(statis)(:,:,1:end-1,:).*repmat(reshape(diff_tim,1,1,[]),nx,nsim,1,nD); %we do not use the last value. Block approach with variables 1:end-1 with time 1:end
    val_cum=cumsum(cat(3,zeros(nx,nsim,1,nD),val_tim),3);
    
    in_p.lab_str=sprintf('%s_t',lab_str); %add time
    
    nylim=size(lims,1);
    for kt=kt_v
        in_p.tim=time_dnum_plot(kt);
        in_p.val=squeeze(val_cum(:,:,kt,:));
    
        fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,'cum');
        mkdir_check(fdir_fig_loc,fid_log,1,0);
    
        for kylim=1:nylim
            fname_noext=fig_name(fdir_fig_loc,sprintf('%s_cum',tag),runid,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,var_idx,kylim);
    
            in_p.fname=fname_noext;
            in_p.ylim=lims(kylim,:);
    
            fig_1D_01(in_p);
        end
    end
end %ksim

end