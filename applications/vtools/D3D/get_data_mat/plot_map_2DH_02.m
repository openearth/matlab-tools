%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19791 $
%$Date: 2024-09-23 06:11:48 +0200 (Mon, 23 Sep 2024) $
%$Author: chavarri $
%$Id: plot_map_2DH_diff_01.m 19791 2024-09-23 04:11:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_diff_01.m $
%

function plot_map_2DH_02(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% DEFAULTS

flg_loc=gdm_parse_map_2DH(fid_log,flg_loc,simdef);

%% LOAD REFERENCE DATA

%time is based on reference simulation. 
kref=flg_loc.sim_ref;
[gridInfo_ref,time_dnum_ref,time_dnum_plot]=load_time_grid(fid_log,flg_loc,simdef(kref),tag);

%% DIMENSIONS AND RENAME

var_idx=flg_loc.var_idx;
nt=numel(time_dnum_ref);
nvar=flg_loc.nvar;
nsim=flg_loc.nsim;
nxlim=size(flg_loc.xlims,1);

%% INITIALIZE

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.gridInfo=gridInfo_ref;
in_p.rkm=flg_loc.rkm_file_disp;

flg_loc.fext=ext_of_fig(in_p.fig_print);

kref=flg_loc.sim_ref;

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

ktc=0;
kvar=0;
ksim=0;
messageOut(fid_log,sprintf('Plotting %s variable %4.2f, simulation %4.2f, time %4.2f %%',tag_fig,kvar/nvar*100,ksim/nsim*100,ktc/nt*100));

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

%% LOOP

%% loop on variable

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef(1));
    
    in_p.unit=var_str;
    
    layer=gdm_layer(flg_loc,gridInfo_ref.no_layers,var_str,kvar,flg_loc.var{kvar});

    %time 0 of reference 
    kt=1;
    
    %although it is reference, we load it to skip the plot 
    %if the size is not right
    fdir_mat=simdef(kref).file.mat.dir;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_ref(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
    data_ref_t0=load(fpath_mat_tmp,'data');
    val_ref_t0=data_ref_t0.data;

    %skip if not the right size
    if any(simdef(kref).D3D.structure==[2,4]) && sum(size(val_ref_t0)==1)==0 || size(val_ref_t0,3)>1 %in D3D4 2D data has matrix form
        messageOut(fid_log,sprintf('Cannot plot variable with more than 1 dimension: %s',var_str))
        continue
    end

    nplot=5;
    fpath_file_2D=cell(nplot,nt,flg_loc.nclim_max,nxlim);
    fpath_file_3D=cell(nplot,nt,flg_loc.nclim_max,nxlim);

    %% loop on simulations

    for ksim=1:nsim

        %% load local simulation

        %grid and time of local simulation
        [gridInfo,time_dnum_loc,time_mor_dnum]=load_time_grid(fid_log,flg_loc,simdef(ksim),tag);
    
        %fxw of local simulation
        if flg_loc.do_fxw
        %     in_p.fxw=gdm_load_fxw(fid_log,fdir_mat,'fpath_fxw',simdef.file.fxw); %non-snapped and in a different structure than when reading snapped
            fdir_mat=simdef(ksim).file.mat.dir;
            in_p.fxw=gdm_load_snapped(fid_log,fdir_mat,simdef(ksim),'fxw');
        end

        %time0 of local simulation
        kt=1;
        time_plot_loc=time_dnum_plot(kt); %time0 of reference simulation for matching.
        val_ref=val_ref_t0; %we pass `val_ref_t0` just to create a NaN of the right size if time is not found. 

        fdir_mat=simdef(ksim).file.mat.dir;
        [~,val_loc_t0,~]=gdm_match_times_diff_val_2D(flg_loc,simdef(ksim),time_dnum_loc,time_mor_dnum,time_plot_loc,val_ref,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx{kvar});

        ktc=0;

        %% loop on reference time
        for kt=kt_v %time of reference
            ktc=ktc+1;
            
            %% load
    
            %local time of reference simulation.
            time_plot_loc=time_dnum_plot(kt); 
            in_p.tim=time_plot_loc; %pass to plot
            
            %local simulation at local time
            fdir_mat=simdef(ksim).file.mat.dir;
            [~,val_loc_tt,~]=gdm_match_times_diff_val_2D(flg_loc,simdef(ksim),time_dnum_loc,time_mor_dnum,time_plot_loc,val_ref,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx{kvar});
    
            %reference
            %Time loops on the reference time, hence there is no need to check
            %that it is the correct time. It is also not necessary to interpolate.
            if flg_loc.do_ref
                fdir_mat=simdef(kref).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_ref(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
                data_ref_tt=load(fpath_mat_tmp,'data');
                val_ref_tt=data_ref_tt.data;
            end
    
            %velocity vector
            %2DO: Should we also plot the vector difference? How to deal with different grids?
            in_p.plot_vector=0;
            if flg_loc.do_vector(kvar)
                [vec_x,vec_y]=load_velocity_vector(simdef(ksim),time_dnum_loc(kt),var_idx{kvar});
                in_p.vec_x=vec_x;
                in_p.vec_y=vec_y;
                in_p.plot_vector=1;
            end
    
            %% regular plot
            if flg_loc.do_p_single    
        
                kplot=1;
    
                clims_str='clims';
                tag_ref='val';
                in_p.val=val_loc_tt;
                in_p.is_diff=0;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=simdef(ksim).file.runid;
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,var_str,var_idx{kvar},fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref,clims_str);
    
            end
    
            %% difference with initial time
            if flg_loc.do_diff_t
    
                kplot=2;
    
                clims_str='clims_diff_t';
                tag_ref='diff_t';
                in_p.val=val_loc_tt-val_loc_t0;
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=simdef(ksim).file.runid;
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,var_str,var_idx{kvar},fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref,clims_str);
    
            end
    
            %% difference with reference
            if flg_loc.do_diff_s && ksim~=kref
    
                kplot=3;
                 
                clims_str='clims_diff_s';
                tag_ref='diff_s';
                in_p.val=val_loc_tt-val_ref_tt;
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,var_str,var_idx{kvar},fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref,clims_str);
    
            end
    
            %% difference with reference and initial time
            if flg_loc.do_diff_s_t && ksim~=kref
    
                kplot=4;
    
                clims_str='clims_diff_s_t';
                tag_ref='diff_s_t';
                in_p.val=(val_loc_tt-val_ref_t0)-(val_ref_tt-val_ref_t0);
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,var_str,var_idx{kvar},fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref,clims_str);
    
            end
    
            %% difference with reference and initial time in percentage terms
            if flg_loc.do_diff_s_perc && ksim~=kref
    
                kplot=5;
    
                val_ref_tt_tmp=val_ref_tt;
                bol_0=val_ref_tt_tmp==0;
                val_ref_tt_tmp(bol_0)=NaN;
    
                clims_str='clims_diff_s_perc';
                tag_ref='diff_s_perc';
                in_p.val=(val_loc_tt-val_ref_tt_tmp)./val_ref_tt_tmp.*100;
                in_p.is_diff=0;
                in_p.is_background=0;
                in_p.is_percentage=1;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,var_str,var_idx{kvar},fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref,clims_str);
    
            end
            
            %% disp
            
            messageOut(fid_log,sprintf('Plotting %s variable %4.2f, simulation %4.2f, time %4.2f %%',tag_fig,kvar/nvar*100,ksim/nsim*100,ktc/nt*100));
            
        end %kt
    
        %% movies
    
        if flg_loc.do_movie && nt>1
            for kplot=1:nplot
                %this needs to be tested. 
                nclim=sum(~isempty(fpath_file_2D{kplot,1,:,1}));
                for kclim=1:nclim
                    for kxlim=1:nxlim
                        fpath_mov=fpath_file_2D(kplot,:,kclim,kxlim);
                        fpath_mov=reshape(fpath_mov,[],1);
                        gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum_loc);   
                    end
                end
            end
    
        end %movie

    end %ksim
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,tnum,runid,kclim,var_str,tag_ref,var_idx,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s%s_%s_%s_clim_%02d_xlim_%02d',tag,runid,var_str,var_idx,tag_ref,datestr(tnum,'yyyymmddHHMMSS'),kclim,kxlim));

end %function

%%

%For a certain time, it searches the results that match this time and makes 
%the difference. The reference data is passed.
%
function [val_diff,val,val_ref]=gdm_match_times_diff_val_2D(flg_loc,simdef,time_dnum,time_mor_dnum,time_ref,val_ref,fdir_mat,tag,var_str,gridInfo,gridInfo_ref,layer,var_idx_loc)

%% PARSE

tol_tim=1; %tolerance to match objective day with available day
if isfield(flg_loc,'tol_tim')
    tol_tim=flg_loc.tol_tim;
end

%% CALC

size_data=size(val_ref);

%we do not need dtime, only dnum.
[time_loc_v]=gdm_time_flow_mor(flg_loc,simdef,time_dnum,NaT,time_mor_dnum,NaT); %[nt_loc,1]

[kt_loc,~,flg_found]=absmintol(time_loc_v,time_ref,'tol',tol_tim,'do_break',0,'do_disp_list',0,'dnum',1);
if ~flg_found
    messageOut(fid_log,'No available reference data:');
    messageOut(fid_log,sprintf('     reference time   : %s',datestr(time_ref      ,'yyyy-mm-dd HH:MM:SS')));
    messageOut(fid_log,sprintf('     closest   time   : %s',datestr(time_loc_v(kt_loc),'yyyy-mm-dd HH:MM:SS')));

    val_diff=NaN(size_data);
    val=val_diff;
    val_ref=val_diff;
else
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt_loc),'var',var_str,'var_idx',var_idx_loc,'layer',layer);
    data=load(fpath_mat_tmp,'data');
    
%     val=data.data;
    [val_diff,val,val_ref]=D3D_diff_val(data.data,val_ref,gridInfo,gridInfo_ref);
end    

end %function

%%

function [gridInfo,time_dnum,time_dnum_plot,time_mor_dnum]=load_time_grid(fid_log,flg_loc,simdef,tag)

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); 
fpath_map=simdef.file.map;

tim=load(fpath_mat_time,'tim');
time_dnum=tim.tim.time_dnum; %used to load the data (always flow time)
time_mor_dnum=tim.tim.time_mor_dnum; %used to match data (can be morpho time)

[time_dnum_plot,~]=gdm_time_flow_mor(flg_loc,simdef,tim.tim.time_dnum,tim.tim.time_dtime,tim.tim.time_mor_dnum,tim.tim.time_mor_dtime); %[nt_ref,1] 

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map,'disp',0);

end %function

%%

function [vec_x,vec_y]=load_velocity_vector(simdef,time_dnum_loc,var_idx_loc)

fdir_mat=simdef.file.mat.dir;
fpath_mat_tmp=mat_tmp_name(fdir_mat,'uv','tim',time_dnum_loc,'var_idx',var_idx_loc);
data_uv=load(fpath_mat_tmp,'data');
switch simdef.D3D.structure
    case {1}
        if ndims(data_uv.data.vel_x)~=3 || size(data_uv.data.vel_x,1)>1
            error('It may be a 3D simulation. Work out this case.')
        end
        vec_x=squeeze(data_uv.data.vel_x); 
        vec_y=squeeze(data_uv.data.vel_y);
    case {2,4,5}
        if size(data_uv.data.vel_x,3)>1 %3D simulation, a single direction must be given for arrows
            %ATTENTION!
            %This only holds for sigma layers. Otherwise, we have to average considering the thickness of
            %the layers. 
            %Another improvement is to search for the index of the layers rather than assuming it is 3.
            vec_x=mean(data_uv.data.vel_x,3,'omitnan');
            vec_y=mean(data_uv.data.vel_y,3,'omitnan');
        else
            vec_x=data_uv.data.vel_x;
            vec_y=data_uv.data.vel_y;
        end
    otherwise
        error('I do not know how to plot vectors for simulation type %d',simdef.D3D.Structure)
end
%It must be a column vector [1,np]
vec_x=reshape(vec_x,1,[]); 
vec_y=reshape(vec_y,1,[]); 

end

%% 

function [fpath_file_2D,fpath_file_3D]=fcn_plot(in_p,flg_loc,var_str,var_idx_loc,fdir_fig,tag_fig,time_dnum_loc,runid,tag_ref,clims_str)

clims=flg_loc.(clims_str);
clims=fcn_clims_type(flg_loc,clims);
nclim=size(clims,1);

in_p.filter_lim=flg_loc.filter_lim.(clims_str);

if flg_loc.do_2D
    fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx_loc),tag_ref);
    mkdir_check(fdir_fig_var,NaN,1,0);
end

if flg_loc.do_3D
    fdir_fig_var=fullfile(fdir_fig,var_str,num2str(var_idx_loc),sprintf('%s_3D',tag_ref));
    mkdir_check(fdir_fig_var,NaN,1,0);
    Zcor=cen2cor_2D(in_p.gridInfo.Xcen,in_p.gridInfo.Ycen,in_p.gridInfo.Xcor,in_p.gridInfo.Ycor,in_p.val);
    %in_p.gridInfo.Zcen=in_p.val;  %if this is passed, the plot is with tiles. This is more correct, but not pleasent to the eye.
    in_p.gridInfo.Zcor=Zcor; %if this is passed, it is more pleasent to the eye since the solution is continuous.
end

fpath_file_2D=cell(nclim,flg_loc.nxlim);
fpath_file_3D=cell(nclim,flg_loc.nxlim);

for kclim=1:nclim
    in_p.clims=clims(kclim,:);
    for kxlim=1:flg_loc.nxlim
        in_p.xlims=flg_loc.xlims(kxlim,:);
        in_p.ylims=flg_loc.ylims(kxlim,:);

        %2D
        if flg_loc.do_2D
            fname_noext=fig_name(fdir_fig_var,tag_fig,time_dnum_loc,runid,kclim,var_str,tag_ref,num2str(var_idx_loc),kxlim);
            fpath_file_2D{kclim,kxlim}=sprintf('%s%s',fname_noext,flg_loc.fext); %for movie 
    
            in_p.fname=fname_noext;
            in_p.do_3D=0;
    
            fig_map_sal_01(in_p);
        end

        %3D
        if flg_loc.do_3D
            fname_noext=fig_name(fdir_fig_var_3d,tag_fig,time_dnum_loc,runid,runid_ref,kclim,var_str,tag_ref_3D,num2str(var_idx_loc),kxlim);
            fpath_file_3D{kclim,kxlim}=sprintf('%s%s',fname_noext,flg_loc.fext); %for movie 

            in_p.fname=fname_noext;
            in_p.do_3D=1;  

            fig_map_sal_01(in_p);
        end

    end
end

end %function

%%

function flg_loc=gdm_parse_map_2DH(fid_log,flg_loc,simdef)

flg_loc=gdm_default_flags(flg_loc);

flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_perc',0);
flg_loc=isfield_default(flg_loc,'do_2D',1);
flg_loc=isfield_default(flg_loc,'do_3D',0);

flg_loc=isfield_default(flg_loc,'do_movie',0);
flg_loc=isfield_default(flg_loc,'do_fxw',0);
flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'var_idx',cell(1,numel(flg_loc.var)));
flg_loc=isfield_default(flg_loc,'sim_ref',1);
flg_loc=isfield_default(flg_loc,'xlims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);

%% clims

flg_loc=isfield_default(flg_loc,'clims_type',1);
flg_loc=isfield_default(flg_loc,'clims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_t',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s_t',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'clims_diff_s_perc',[NaN,NaN]);

if isfield(flg_loc,'filter_lim')==0
    flg_loc.filter_lim.clims=[inf,-inf];
    flg_loc.filter_lim.clims_diff_t=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s_t=[inf,-inf];
    flg_loc.filter_lim.clims_diff_s_perc=[inf,-inf];
else
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_t',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s_t',[inf,-inf]);
    flg_loc.filter_lim=isfield_default(flg_loc.filter_lim,'clims_diff_s_perc',[inf,-inf]);
end

%%

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

%% dimensions

flg_loc.nclim_max=max([size(flg_loc.clims,1),size(flg_loc.clims_diff_t,1),size(flg_loc.clims_diff_s,1),size(flg_loc.clims_diff_s_t,1),size(flg_loc.clims_diff_s_perc,1)]);
flg_loc.nsim=numel(simdef);
flg_loc.nxlim=size(flg_loc.xlims,1);
flg_loc.nvar=numel(flg_loc.var);

%% 

flg_loc.do_ref=0;
if flg_loc.nsim>1 && (flg_loc.do_diff_s || flg_loc.do_diff_s_t || flg_loc.do_diff_s_perc)
    flg_loc.do_ref=1;
end

end %function

%%

function clims=fcn_clims_type(flg_loc,clims,time_dnum_loc)

switch flg_loc.clims_type
%     case 1
%         clims=clims;
    case 2
        tim_up=max(time_dnum_loc-flg_loc.clims_type_var,0);
        clims=[0,tim_up];
end

end %function