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

function plot_map_2DH_ls_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

flg_loc=isfield_default(flg_loc,'do_p',1);
ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% PARSE

flg_loc=gdm_parse_map_2DH_ls(flg_loc);

%% PATHS

nsim=numel(simdef);
fdir_mat=simdef(flg_loc.sim_ref).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% TIME

%time of reference simulation
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,'');

%% DIMENSIONS

nt=numel(time_dnum);
nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);
nplot=6;

flg_loc.what_is=gdm_check_type_of_result_2DH_ls(flg_loc,simdef(1),fdir_mat,time_dnum,tag,gridInfo);
flg_loc.plot_type=flg_loc.what_is;
[nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);

%% figure
in_p=flg_loc; %attention with unexpected input
in_p.fig_visible=0;

flg_loc.fext=ext_of_fig(in_p.fig_print);

%% LOOP 

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0; kvar=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));

for kpli=1:npli %variable
    fpath_pli=flg_loc.pli{kpli,1};
    pliname=gdm_pli_name(fpath_pli);
    for kvar=1:nvar %variable

        varname=flg_loc.var{kvar};
        [var_str_read,~,var_str_save]=D3D_var_num2str_structure(varname,simdef(1));
        
        layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
        var_idx=flg_loc.var_idx{kvar};

        %Time 1 of simulation 1 for reference
        %It is up to you to be sure that it is the same for all simulations!
        %It is only necessary when plotting lines, not patches. For
        %patches, there is no option to add `val0` and it cannot be
        %transposed.
        if flg_loc.what_is==2 && flg_loc.plot_val0
            fdir_mat=simdef(1).file.mat.dir; %1 used for reference for all. Should be the same. 
            fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum(1),var_str_read,pliname,layer,var_idx);
            data_ref=load(fpath_mat_tmp,'data');   
            val0=data_ref.data.(flg_loc.str_val)';
        else
            val0=NaN;
        end

        %Preallocate for plotting all times/simulation together.
        %We could consider to only allocate if we actually want to plot it in this way. Otherwise, 
        %data is saved always in the same index. 
        data_all=cell(nsim,1); %inside -> data_all=NaN(nt,numel(data_ref.data.(str_val)),nS);
        
        fpath_file=cell(nplot,nt,nsim,nlims);

        %time 0
        kt=1;
        [in_p.tim,~]=gdm_time_flow_mor(flg_loc,simdef(1),time_dnum(kt),time_dtime(kt),time_mor_dnum(kt),time_mor_dtime(kt)); %output: time_dnum_plot

        %measurements at time 0                        
        [plot_mea,data_mea_0]=gdm_load_measurements_match_time(flg_loc,in_p.tim,var_str_save,kpli,'val_mean');

        ktc=0; 
        for kt=kt_v %time
            ktc=ktc+1;

            %time kt
            [in_p.tim,~]=gdm_time_flow_mor(flg_loc,simdef(1),time_dnum(kt),time_dtime(kt),time_mor_dnum(kt),time_mor_dtime(kt)); %output: time_dnum_plot
   
            %all data
            [data_all,gridInfo_ls,s,xlab_str,xlab_un]=load_all_data(data_all,flg_loc,simdef,kt,var_str_read,pliname,layer,flg_loc.str_val,tag,time_dnum,var_idx);

            %measurements                        
            [plot_mea,data_mea]=gdm_load_measurements_match_time(flg_loc,in_p.tim,var_str_save,kpli,'val_mean');

            %save to plot structure
            in_p.s_mea=data_mea.x;          
            in_p.xlab_str=xlab_str;
            in_p.xlab_un=xlab_un;
            
            %% plot single simulation and single time
            if flg_loc.do_p_single
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=1;
                for ksim=1:nsim
                    data_loc=data_all{ksim}(kt,:,:);
                    if flg_loc.what_is==2
                        data_loc=reshape(data_loc,[],1);
                    end
                    tag_fig=tag;
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(ksim).file.runid;

                    in_p.val_mea=data_mea.y;
                    in_p.is_diff=0;
                    in_p.plot_mea=plot_mea;
               
                    in_p.data_ls.grid=gridInfo_ls{ksim};
                    in_p.s=s{ksim};
                    in_p.val0=val0;

                    fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);     
                end %kS
            end

            %% plot all simulations and single time (if line plot)
            if flg_loc.do_all_s && flg_loc.what_is==2
                flg_loc.plot_type=2;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=2;

%                 data_loc=reshape(squeeze(data_all(kt,:,:)),[],1);
                data_loc=cell(nsim,1);
                for ksim=1:nsim
                    data_loc{ksim}=reshape(data_all{ksim}(kt,:),[],1);
                end

                ksim=1;                                
                tag_fig=sprintf('%s_all_s',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;

                in_p.val_mea=data_mea.y;
                in_p.is_diff=0;
                in_p.plot_mea=plot_mea;
    
                in_p.s=s;
                in_p.val0=val0;

                fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);       
            end

            %% plot difference in time
            if flg_loc.do_diff_t
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=3;
                for ksim=1:nsim
                    data_loc=data_all{ksim}(kt,:,:)-data_all{ksim}(1,:,:);
                    if flg_loc.what_is==2
                        data_loc=reshape(squeeze(data_loc),[],1);
                    end
                    tag_fig=sprintf('%s_diff_t',tag);
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(ksim).file.runid;

                    in_p.val_mea=data_mea.y-data_mea_0.y;
                    in_p.is_diff=1;
                    in_p.plot_mea=plot_mea;

                    in_p.data_ls.grid=gridInfo_ls{ksim};
                    in_p.s=s{ksim};
                    in_p.val0=0;

                    fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);           
                end %kS
            end

            %% plot difference with reference simulation
            if flg_loc.do_diff_s
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=4;
                for ksim=1:nsim
                    %We cannot skip because then we fail when creating
                    %movies. I have to think this more carefully. 
                    % if kS==flg_loc.sim_ref
                    %     continue
                    % end
                    if flg_loc.plot_type==1
                        error('Patch plot. I have to change the gridded interpolant by a scatter interpolant if the grid is not the same.')
                    end
                    F=griddedInterpolant(s{ksim},reshape(data_all{ksim}(kt,:,:),[],1));
                    data_loc_on_ref=F(s{flg_loc.sim_ref});
                    data_loc=reshape(data_loc_on_ref,[],1)-reshape(data_all{flg_loc.sim_ref}(kt,:,:),[],1);
                    tag_fig=sprintf('%s_diff_s',tag);
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(ksim).file.runid;

                    in_p.val_mea=data_mea.y-data_mea_0.y;
                    in_p.is_diff=1;
                    in_p.plot_mea=0;

                    in_p.data_ls.grid=gridInfo_ls{flg_loc.sim_ref};
                    in_p.s=s{flg_loc.sim_ref};

                    if flg_loc.plot_val0
                        %This could be moved at the beginning?
                        warning('change location')
                        F=griddedInterpolant(s{ksim},reshape(data_all{ksim}(1,:,:),[],1));
                        data_loc_on_ref=F(s{flg_loc.sim_ref});
                        in_p.val0=data_loc_on_ref-val0;
                    end

                    fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_s);               
                end %kS
            end
    
            %% plot all simulations together, difference in time
            if flg_loc.do_all_s_diff_t && flg_loc.what_is==2
                flg_loc.plot_type=2;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=5;

                data_loc=cell(nsim,1);
                for ksim=1:nsim
                    data_loc{ksim}=reshape(data_all{ksim}(kt,:)-data_all{ksim}(1,:),[],1);
                end

                ksim=1;

%                 data_loc=squeeze(data_all(kt,:,:)-data_all(1,:,:));
                tag_fig=sprintf('%s_all_s_diff_t',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;

                in_p.val_mea=data_mea.y-data_mea_0.y;
                in_p.is_diff=1;
                in_p.plot_mea=plot_mea;
    
%                 in_p.data_ls.grid=gridInfo_ls; %not possible?
                in_p.s=s;

                fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);      
            end

            %% plot all simulations together, difference with reference
            if flg_loc.do_all_s_diff_s && flg_loc.what_is==2
                flg_loc.plot_type=2;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=6;

                data_loc=cell(nsim,1);
                for ksim=1:nsim
                    data_loc{ksim}=reshape(data_all{ksim}(kt,:)-data_all{flg_loc.sim_ref}(kt,:),[],1);
                end

                ksim=1;

%                 data_loc=squeeze(data_all(kt,:,:)-data_all(1,:,:));
                tag_fig=sprintf('%s_all_s_diff_s',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;

                in_p.val_mea=data_mea.y-data_mea_0.y;
                in_p.is_diff=1;
                in_p.plot_mea=0;
    
%                 in_p.data_ls.grid=gridInfo_ls; %not possible?
                in_p.s=s;

                fpath_file(kplot,kt,ksim,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_s);      
            end
            
            %% plot all simulation together (special case 2 simulations differences between runs)
            if flg_loc.do_all_s_2diff
                plot_diff_2by2_together(flg_loc,in_p,data_all,data_ref,fdir_fig_loc,runid,nsim,time_dnum,kt,var_str_read,pliname,kdiff,klim,tag,layer)
            end %do_all_s_2diff

            %% disp

            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));

        end %kt
        
        %% plot all times together

        if flg_loc.do_all_t
            flg_loc.plot_type=2;
            [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
            for ksim=1:nsim
                [in_p.tim,~]=gdm_time_flow_mor(flg_loc,simdef(ksim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime); %all times

                data_loc=data_all{ksim}';
                tag_fig=sprintf('%s_all_t',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;
    
                in_p.val_mea=data_mea.y;
                in_p.is_diff=0;
                in_p.plot_mea=plot_mea;
                in_p.do_leg=0;
                in_p.do_time=1;
    
%                 in_p.data_ls.grid=gridInfo_ls{kS}; %not possible?
                in_p.s=s{ksim};

                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);               
            end %kS
        end

        %% plot all times together, difference in time
        
        if flg_loc.do_all_t_diff_t
            flg_loc.plot_type=2;
            for ksim=1:nsim
                data_loc=data_all{ksim}'-data_all{ksim}(1,:)';
                tag_fig=sprintf('%s_all_t_diff_t',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;
    
                in_p.val_mea=data_mea.y;
                in_p.is_diff=1;
                in_p.plot_mea=plot_mea;
                in_p.do_leg=0;
                in_p.do_time=1;
    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);               
            end %kS
        end
        
        %% plot all times together xt

        if flg_loc.do_all_t_xt
            flg_loc.plot_type=3;
            [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
            for ksim=1:nsim
                [~,tim_dtime]=gdm_time_flow_mor(flg_loc,simdef(ksim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime); %all times
                data_loc=data_all{ksim};
                tag_fig=sprintf('%s_all_t_xt',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;
    
                [in_p.d_m,in_p.t_m]=meshgrid(s{ksim},tim_dtime);
                in_p.val_m=data_loc;
                in_p.unit=in_p.var{kvar};
                in_p.is_diff=0;
    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);               
            end %kS
        end

        %% plot all times together xt, difference in time

        if flg_loc.do_all_t_xt_diff_t
            flg_loc.plot_type=3;
            [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
            for ksim=1:nsim
                [~,tim_dtime]=gdm_time_flow_mor(flg_loc,simdef(ksim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime); %all times
                data_loc=data_all{ksim}-data_all{ksim}(1,:);
                tag_fig=sprintf('%s_all_t_xt_diff_t',tag);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(ksim).file.runid;
    
                [in_p.d_m,in_p.t_m]=meshgrid(s{ksim},tim_dtime);
                in_p.val_m=data_loc;
                in_p.unit=in_p.var{kvar};
                in_p.is_diff=1;
    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);               
            end %kS
        end

        %% movies

        gdm_movie_paths(fid_log,flg_loc,time_dnum,fpath_file);

    end %kvar
end %kpli

end %function

%%
%% FUNCTIONS
%%

%%

function fpath_fig=fig_name_single(fdir_fig,tag,runid,time_dnum,var_str,pliname,kylim,layer)

str_b=sprintf('%s_%s_%s_%s_%s_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str,pliname,kylim);

if ~isempty(layer)
    if isinf(layer)
        str_b=sprintf('%s_Inf',str_b);
    else
        str_b=sprintf('%s_%02d',str_b,layer);
    end
end

fpath_fig=fullfile(fdir_fig,str_b);

end

%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,pliname,kdiff,kylim,layer)

if ~isempty(layer)
    if isinf(layer)
        fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_ref_%02d_ylim_%02d_Inf',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str,pliname,kdiff,kylim));
    else
        fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_ref_%02d_ylim_%02d_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str,pliname,kdiff,kylim,layer));
    end
else
    fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_ref_%02d_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str,pliname,kdiff,kylim));
end

end

%% 

function plot_diff_2by2_together(flg_loc,in_p,data_all,data_ref,fdir_fig_loc,runid,nS,time_dnum,kt,var_str_read,pliname,kdiff,kylim,tag,layer)

%% PARSE

if mod(nS,2)~=0
    warning('It is not possible to make difference of runs 2 by 2 if the number of simulations is even.')
    return
end

if ~isfield(flg_loc,'diff_idx')
    error('Matrix with indices for differences does not exist.')
end

if numel(flg_loc.diff_idx)~=nS
    error('Matrix with differenciation index does not have the right dimensions.')
end

%% CALC

fname_noext=fig_name(fdir_fig_loc,sprintf('%s_s_diff',tag),runid,time_dnum(kt),var_str_read,pliname,kdiff,kylim,layer);

in_p.fname=fname_noext;
switch kdiff
    case 1
        in_p.val=squeeze(data_all(kt,:,:));
    case 2
        in_p.val=squeeze(data_all(kt,:,:))-squeeze(data_all(1,:,:));
end

data_diff=NaN(numel(data_ref.data.val),nS/2);
leg_str_2diff=cell(nS/2,1);
for ks2=1:nS/2
    bol_g=flg_loc.diff_idx==ks2;
    if sum(bol_g)~=2
        warning('There are no 2 runs to make the difference.')
        return
    end
    data_diff(:,ks2)=diff(in_p.val(:,bol_g),1,2);
    leg_str_2diff{ks2}=flg_loc.leg_str_2diff{find(bol_g,1)};
end

in_p.cmap=NaN;
in_p.ls=NaN;
in_p.val=data_diff;
in_p.is_diff=1;
in_p.leg_str=leg_str_2diff;

fig_1D_01(in_p)

end %function

%%

function data=filter_1d_data(flg_loc,data)

if flg_loc.do_staircase
    y=data.val_staircase;
    x=data.Scor_staircase;
else
    y=data.val;
    x=data.Scen;
end

if isfield(flg_loc,'filter_lim')==0
    bol_filter=false(size(y));
else
    bol_filter=y<flg_loc.filter_lim(1) | y>flg_loc.filter_lim(2);
end

y(bol_filter)=[];
x(bol_filter)=[];

if flg_loc.do_staircase
    data.val_staircase=y;
    data.Scor_staircase=x;
else
    data.val=y;
    data.Scen=x;
end

end %function

%%

%`s` is needed for 1D plot
%`gridInfo` for 2DV plot
%
function [data_all,gridInfo,s,xlab_str,xlab_un]=load_all_data(data_all,flg_loc,simdef,kt,var_str_read,pliname,layer,str_val,tag,time_dnum,var_idx)

nS=numel(simdef);
s=cell(nS,1);
gridInfo=cell(nS,1);

for kS=1:nS
    fdir_mat=simdef(kS).file.mat.dir; 
    if flg_loc.use_local_time
        fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
        fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

        %time of local simulation
        load(fpath_mat_time,'tim');
        v2struct(tim); %time_dnum, time_dtime
    end
    fpath_mat_tmp=gdm_map_2DH_ls_mat_name(fdir_mat,tag,time_dnum(kt),var_str_read,pliname,layer,var_idx);
    if ~isfile(fpath_mat_tmp)
        error('File does not exist. This is most probably because the time of the reference does not exist in the local simulation: %s',fpath_mat_tmp)
    end
    load(fpath_mat_tmp,'data');

    %filter data
    data=filter_1d_data(flg_loc,data);

    %save data for plotting all times togehter. Better not to do it if you don't need it for memory reasons.
    data_all{kS}(kt,:,:)=data.(str_val); %needs to be 3D because for a patch plot data is 2D (and first dimension is time). 

    %we are loading the x data for all times. It is not ideal. The problem with taking it out of here is that the
    %data may be filtered. Maybe the best is a flag?
    %save x vector (1D plot only). String and units will be the same.
    [s{kS},xlab_str,xlab_un]=gdm_s_rkm_cen(flg_loc,data);

    gridInfo{kS}=data.gridInfo; %for now only one (reference) because they will all be the same? Do I have a cas
end %kS

%xlabel
if isfield(flg_loc,'xlab_str')
    xlab_str=flg_loc.xlab_str;
end

end %function

%% 

function fpath_file=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag,runid,time_dnum_kt,var_str_read,layer,pliname,data_loc,lims_loc)             

fpath_file=cell(nlims,1);
for klim=1:nlims %ylim
                
    fdir_fig_loc=fullfile(fdir_fig,pliname,var_str_read);
    mkdir_check(fdir_fig_loc,NaN,1,0);
    
    fname_noext=fig_name_single(fdir_fig_loc,tag,runid,time_dnum_kt,var_str_read,pliname,klim,layer);
    fpath_file{klim}=sprintf('%s%s',fname_noext,flg_loc.fext); %for movie 

    in_p.fname=fname_noext;
    
    switch flg_loc.plot_type
        case 1 % several vertical layers (patch plot)      
            in_p.data_ls.sal=data_loc;
            in_p.unit=var_str_read;
            if flg_loc.do_rkm
                in_p.data_ls.grid.Xcor=data.rkm_cor;
            end
            in_p.clims=lims_loc(klim,:);
            in_p.ylims=flg_loc.ylims(klim,:);
        
            fig_map_ls_01(in_p)  
    
        case 2 % single layer (line plot)
            in_p.lab_str=var_str_read;
            in_p.ylims=lims_loc(klim,:);
            in_p.xlims=flg_loc.xlims(klim,:);
            in_p.val=data_loc; %[np,1] (same as x), or cell array!
        
            fig_1D_01(in_p)
        case 3 %xt
            in_p.clims=lims_loc(klim,:);    
            fig_his_xt_01(in_p)
    end %type plot
end %kylim

end %function

%% 

function [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc)

nylims=size(flg_loc.ylims,1);
nclims=size(flg_loc.clims,1);

switch flg_loc.plot_type
    case {1,3}
        nlims=nclims;
        lims=flg_loc.clims;
        lims_diff_t=flg_loc.clims_diff_t;
        lims_diff_s=flg_loc.clims_diff_s;

        nlims_y=size(flg_loc.ylims,1);
        if nlims_y~=nlims
            flg_loc.ylims=NaN(nlims,2);
        end
    case {2}
        nlims=nylims;
        lims=flg_loc.ylims;
        lims_diff_t=flg_loc.ylims_diff_t;
        lims_diff_s=flg_loc.ylims_diff_s;
end

end





