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

%do flags
flg_loc=isfield_default(flg_loc,'do_all_t',0);
flg_loc=isfield_default(flg_loc,'do_all_t_xt',0);
flg_loc=isfield_default(flg_loc,'do_all_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_all_s_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_all_t_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_all_s_2diff',0); %plot all runs in same figure making the difference between each of 2 simulations

flg_loc=isfield_default(flg_loc,'fig_print',1);
flg_loc=isfield_default(flg_loc,'do_staircase',0);
flg_loc=isfield_default(flg_loc,'do_movie',0);
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'xlims',NaN(size(flg_loc.ylims,1),2));
flg_loc=isfield_default(flg_loc,'ylims_diff_t',flg_loc.ylims);
flg_loc=isfield_default(flg_loc,'ylims_diff_s',flg_loc.ylims);
flg_loc=isfield_default(flg_loc,'clims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_t',flg_loc.clims);
flg_loc=isfield_default(flg_loc,'clims_diff_s',flg_loc.clims);
flg_loc=isfield_default(flg_loc,'do_diff',1);
flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'tol',30);
flg_loc=isfield_default(flg_loc,'plot_val0',0);

if isfield(flg_loc,'do_rkm')==0
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end

if flg_loc.do_staircase
    str_val='val_staircase';
else
    str_val='val';
end

%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% TIME

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,'');

%% DIMENSIONS

nt=numel(time_dnum);
nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);

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

        %time 1 of simulation 1 for reference
        %it is up to you to be sure that it is the same for all simulations!
%         if flg_loc.do_diff || flg_loc.plot_val0 %difference in time
            fdir_mat=simdef(1).file.mat.dir; %1 used for reference for all. Should be the same. 
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(1),'var',var_str_read,'pli',pliname,'layer',layer);
            data_ref=load(fpath_mat_tmp,'data');   
            in_p.val0=data_ref.data.(str_val);
%         end

        %Preallocate for plotting all times/simulation together.
        %We could consider to only allocate if we actually want to plot it in this way. Otherwise, 
        %data is saved always in the same index. 
        data_all=NaN(nt,numel(data_ref.data.(str_val)),nS);
        
        nplot=5;
        fpath_file=cell(nplot,nt,nS,nlims);

        ktc=0; 
        for kt=kt_v %time
            ktc=ktc+1;

            [in_p.tim,~]=gdm_time_flow_mor(flg_loc,simdef(1),time_dnum(kt),time_dtime(kt),time_mor_dnum(kt),time_mor_dtime(kt));
   
            [data_all,gridInfo_ls,s,xlab_str,xlab_un]=load_all_data(data_all,flg_loc,simdef,kt,var_str_read,pliname,layer,str_val,tag,time_dnum);

            %measurements                        
            [plot_mea,data_mea,data_mea_0]=load_measurements(flg_loc,time_dnum,time_mor_dnum,var_str_save,kt,kpli);

            in_p.s_mea=data_mea.x;          
            in_p.s=s;
            in_p.xlab_str=xlab_str;
            in_p.xlab_un=xlab_un;
            in_p.data_ls.grid=gridInfo_ls;

            %% plot single simulation and single time
            if flg_loc.do_p
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=1;
                for kS=1:nS
                    data_loc=reshape(data_all(kt,:,kS),[],1);
                    tag_fig=tag;
                    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(kS).file.runid;

                    in_p.val_mea=data_mea.y;
                    in_p.is_diff=0;
                    in_p.plot_mea=plot_mea;
               
                    fpath_file(kplot,kt,kS,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);     
                end %kS
            end

            %% plot all simulations and single time (if line plot)
            if flg_loc.do_all_s
                flg_loc.plot_type=2;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=2;
                kS=1;
                data_loc=reshape(squeeze(data_all(kt,:,:)),[],1);
                tag_fig=sprintf('%s_all_s',tag);
                fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(kS).file.runid;

                in_p.val_mea=data_mea.y;
                in_p.is_diff=0;
                in_p.plot_mea=plot_mea;
    
                fpath_file(kplot,kt,kS,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);       
            end

            %% plot difference in time
            if flg_loc.do_diff_t
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=3;
                for kS=1:nS
                    data_loc=reshape(squeeze(data_all(kt,:,kS)-data_all(1,:,kS)),[],1);
                    tag_fig=sprintf('%s_diff_t',tag);
                    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(kS).file.runid;

                    in_p.val_mea=data_mea.y-data_mea_0.y;
                    in_p.is_diff=1;
                    in_p.plot_mea=plot_mea;

                    fpath_file(kplot,kt,kS,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);           
                end %kS
            end

            %% plot difference with reference simulation
            if flg_loc.do_diff_s
                flg_loc.plot_type=flg_loc.what_is;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=4;
                for kS=1:nS
                    data_loc=reshape(squeeze(data_all(kt,:,kS)-data_all(kt,:,1)),[],1);
                    tag_fig=sprintf('%s_diff_s',tag);
                    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                    mkdir_check(fdir_fig,NaN,1,0);
                    runid=simdef(kS).file.runid;

                    in_p.val_mea=data_mea.y-data_mea_0.y;
                    in_p.is_diff=1;
                    in_p.plot_mea=0;

                    fpath_file(kplot,kt,kS,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_s);               
                end %kS
            end
    
            %% plot all simulations together, difference in time
            if flg_loc.do_all_s_diff_t
                flg_loc.plot_type=2;
                [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
                kplot=5;
                kS=1;
                data_loc=squeeze(data_all(kt,:,:)-data_all(1,:,:));
                tag_fig=sprintf('%s_all_s_diff_t',tag);
                fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(kS).file.runid;

                in_p.val_mea=data_mea.y-data_mea_0.y;
                in_p.is_diff=1;
                in_p.plot_mea=plot_mea;
    
                fpath_file(kplot,kt,kS,:)=fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);      
            end

            %% plot all simulation together (special case 2 simulations differences between runs)
            if flg_loc.do_all_s_2diff
                plot_diff_2by2_together(flg_loc,in_p,data_all,data_ref,fdir_fig_loc,runid,nS,time_dnum,kt,var_str_read,pliname,kdiff,klim,tag,layer)
            end %do_all_s_2diff

            %% disp

            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));

        end %kt
        
        %% plot all times together

        if flg_loc.do_all_t
            flg_loc.plot_type=2;
            [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
            for kS=1:nS
                [in_p.tim,~]=gdm_time_flow_mor(flg_loc,simdef(kS),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime); %all times
                data_loc=data_all(:,:,kS)';
                tag_fig=sprintf('%s_all_t',tag);
                fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(kS).file.runid;
    
                in_p.val_mea=data_mea.y;
                in_p.is_diff=0;
                in_p.plot_mea=plot_mea;
                in_p.do_leg=0;
                in_p.do_time=1;
    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);               
            end %kS
        end

        %% plot all times together xt

        if flg_loc.do_all_t_xt
            flg_loc.plot_type=3;
            [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc);
            for kS=1:nS
                [~,tim_dtime]=gdm_time_flow_mor(flg_loc,simdef(kS),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime); %all times
                data_loc=data_all(:,:,kS);
                tag_fig=sprintf('%s_all_t_xt',tag);
                fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(kS).file.runid;
    
                [in_p.d_m,in_p.t_m]=meshgrid(s,tim_dtime);
                in_p.val_m=data_loc;
                in_p.unit=in_p.var{kvar};
%                 in_p.t_m
%                 in_p.is_diff=0;
%                 in_p.plot_mea=plot_mea;
%                 in_p.do_leg=0;
%                 in_p.do_time=1;

    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims);               
            end %kS
        end

        %% plot all times together, difference in time
        
        if flg_loc.do_all_t_diff_t
            flg_loc.plot_type=2;
            for kS=1:nS
                data_loc=(data_all(:,:,kS)-data_all(1,:,kS))';
                tag_fig=sprintf('%s_all_t_diff_t',tag);
                fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
                runid=simdef(kS).file.runid;
    
                in_p.val_mea=data_mea.y;
                in_p.is_diff=1;
                in_p.plot_mea=plot_mea;
                in_p.do_leg=0;
                in_p.do_time=1;
    
                fcn_plot(in_p,flg_loc,nlims,fdir_fig,tag_fig,runid,time_dnum(kt),var_str_read,layer,pliname,data_loc,lims_diff_t);               
            end %kS
        end
        
        %% movies

        if flg_loc.do_movie && nt>1

            for kplot=1:nplot
                fpath_loc=fpath_file{kplot,1,1,:};
                nylims=sum(~isempty(fpath_loc));
                for klim=1:nylims
                    for kS=1:nS
                        fpath_mov=fpath_file(kplot,:,kS,klim);
                        fpath_mov=reshape(fpath_mov,[],1);
                        gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
                    end %ks
                end
            end %kplo

        end %movie

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

function [data_all,gridInfo,s,xlab_str,xlab_un]=load_all_data(data_all,flg_loc,simdef,kt,var_str_read,pliname,layer,str_val,tag,time_dnum)

nS=numel(simdef);

for kS=1:nS
    fdir_mat=simdef(kS).file.mat.dir; 
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'pli',pliname,'layer',layer);
    load(fpath_mat_tmp,'data');

    %filter data
    data=filter_1d_data(flg_loc,data);

    %save data for plotting all times togehter. Better not to do it if you don't need it for memory reasons.
    data_all(kt,:,kS)=data.(str_val);
end %kS

gridInfo=data.gridInfo;
[s,xlab_str,xlab_un]=gdm_s_rkm_cen(flg_loc,data);

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
            in_p.val=data_loc; %[np,1] (same as x)
        
            fig_1D_01(in_p)
        case 3 %xt
            in_p.clims=lims_loc(klim,:);    
            fig_his_xt_01(in_p)
    end %type plot
end %kylim

end %function

%%

function [plot_mea,data_mea,data_mea_0]=load_measurements(flg_loc,time_dnum,time_mor_dnum,var_str_save,kt,kpli)

data_mea.x=[];
data_mea.y=[];
data_mea_0.y=NaN;
plot_mea=false;

if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
%     gdm_time_flow_mor(flg_loc,simdef,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);
    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
    data_mea=gdm_load_measurements(NaN,flg_loc.measurements{kpli,1},'tim',tim_search_in_mea,'var',var_str_save,'stat','val_mean','tol',flg_loc.tol,'do_rkm',flg_loc.do_rkm);
    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
    data_mea_0=gdm_load_measurements(NaN,flg_loc.measurements{kpli,1},'tim',tim_search_in_mea,'var',var_str_save,'stat','val_mean');
    if ~isempty(data_mea.x) %there is data
        plot_mea=true;
    end
end

end %function

%% 

function [nlims,lims,lims_diff_t,lims_diff_s]=fcn_lims(flg_loc)

nylims=size(flg_loc.ylims,1);
nclims=size(flg_loc.clims,1);

switch flg_loc.plot_type
    case 1
        nlims=nclims;
        lims=flg_loc.clims;
        lims_diff_t=flg_loc.clims_diff_t;
        lims_diff_s=flg_loc.clims_diff_s;

        nlims_y=size(flg_loc.ylims,1);
        if nlims_y~=nlims
            flg_loc.ylims=NaN(nlims,2);
        end
    case {2,3}
        nlims=nylims;
        lims=flg_loc.ylims;
        lims_diff_t=flg_loc.ylims_diff_t;
        lims_diff_s=flg_loc.ylims_diff_s;
end

end





