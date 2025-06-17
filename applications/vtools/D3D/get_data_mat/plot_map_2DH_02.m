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

function plot_map_2DH_02(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% DEFAULTS

flg_loc=gdm_parse_map_2DH(fid_log,flg_loc,simdef);

%% LOAD REFERENCE DATA

%time is based on reference simulation. 
kref=flg_loc.sim_ref;
[gridInfo_ref,time_dnum_ref,time_dnum_plot,~,tim_dtime_plot]=gdm_load_time_grid(fid_log,flg_loc,simdef(kref),tag);

%% DIMENSIONS AND RENAME

nt=numel(time_dnum_ref);
nvar=flg_loc.nvar;
nsim=flg_loc.nsim;
nxlim=size(flg_loc.xlims,1);

%% INITIALIZE

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
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

%measurements initialization
in_p=gdm_ini_2D_mea(in_p);
in_p.tim_0=tim_dtime_plot(1); %pass to make difference of measurements

%% LOOP

%% loop on variable

for kvar=1:nvar %variable
    var_str_original=flg_loc.var{kvar};
    [~,~,varname_load_mat,in_p.unit]=D3D_var_num2str_structure(var_str_original,simdef(1));
    
    layer=gdm_layer(flg_loc,gridInfo_ref.no_layers,varname_load_mat,kvar,flg_loc.var{kvar});
    [var_idx,~]=gdm_var_idx(simdef,flg_loc,flg_loc.var_idx{kvar},flg_loc.sum_var_idx(kvar),var_str_original);

    %time 0 of reference 
    kt=1;
    
    %although it is reference, we load it to skip the plot 
    %if the size is not right
    fdir_mat=simdef(kref).file.mat.dir;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_ref(kt),'var',varname_load_mat,'var_idx',var_idx,'layer',layer);
    data_ref_t0=load(fpath_mat_tmp,'data');
    val_ref_t0=data_ref_t0.data;

    %skip if not the right size
    if any(simdef(kref).D3D.structure==[2,4]) && sum(size(val_ref_t0)==1)==0 || size(val_ref_t0,3)>1 %in D3D4 2D data has matrix form
        messageOut(fid_log,sprintf('Cannot plot variable with more than 1 dimension: %s',varname_load_mat))
        continue
    end

    nplot=5;
    fpath_file_2D=cell(nplot,nt,flg_loc.nclim_max,nxlim);
    fpath_file_3D=cell(nplot,nt,flg_loc.nclim_max,nxlim);

    %% loop on simulations

    for ksim=1:nsim

        %% load local simulation

        %grid and time of local simulation
        [gridInfo,time_dnum_loc,time_mor_dnum]=gdm_load_time_grid(fid_log,flg_loc,simdef(ksim),tag);
        in_p.gridInfo=gridInfo;

        %fxw of local simulation
        fdir_mat=simdef(ksim).file.mat.dir;
        switch flg_loc.do_fxw
            case 1
                in_p.fxw=gdm_load_fxw(fid_log,fdir_mat,'fpath_fxw',simdef.file.fxw); %non-snapped and in a different structure than when reading snapped
            case 2
                in_p.fxw=gdm_load_snapped(fid_log,fdir_mat,simdef(ksim),'fxw');
        end

        %time0 of local simulation
        kt=1;
        time_plot_loc=time_dnum_plot(kt); %time0 of reference simulation for matching.
        val_ref=val_ref_t0; %we pass `val_ref_t0` just to create a NaN of the right size if time is not found. 

        fdir_mat=simdef(ksim).file.mat.dir;
        [~,val_loc_t0,~]=gdm_match_times_diff_val_2D(flg_loc,simdef(ksim),time_dnum_loc,time_mor_dnum,time_plot_loc,val_ref,fdir_mat,tag,varname_load_mat,gridInfo,gridInfo_ref,layer,var_idx);

        ktc=0;

        %% loop on reference time
        for kt=kt_v %time of reference
            ktc=ktc+1;
            
            %% load
    
            %local time of reference simulation.
            time_plot_loc=time_dnum_plot(kt); 
            in_p.tim=tim_dtime_plot(kt); %pass to plot and to match with measurements
            
            %local simulation at local time
            fdir_mat=simdef(ksim).file.mat.dir;
            [~,val_loc_tt,~]=gdm_match_times_diff_val_2D(flg_loc,simdef(ksim),time_dnum_loc,time_mor_dnum,time_plot_loc,val_ref,fdir_mat,tag,varname_load_mat,gridInfo,gridInfo_ref,layer,var_idx);
    
            %reference
            %Time loops on the reference time, hence there is no need to check
            %that it is the correct time. It is also not necessary to interpolate.
            if flg_loc.do_ref
                fdir_mat=simdef(kref).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_ref(kt),'var',varname_load_mat,'var_idx',var_idx,'layer',layer);
                data_ref_tt=load(fpath_mat_tmp,'data');
                val_ref_tt=data_ref_tt.data;
            end
    
            %velocity vector
            %2DO: Should we also plot the vector difference? How to deal with different grids?
            in_p.plot_vector=0;
            if flg_loc.do_vector(kvar)
                [vec_x,vec_y]=load_velocity_vector(simdef(ksim),time_dnum_loc(kt),var_idx);
                in_p.vec_x=vec_x;
                in_p.vec_y=vec_y;
                in_p.plot_vector=1;
            end
    
            %% load tiles
            in_p=fcn_load_tiles(flg_loc,in_p);

            %% regular plot
            if flg_loc.do_p_single    
        
                kplot=1;
    
                tag_ref='val';
                in_p.val=val_loc_tt;
                in_p.is_diff=0;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=simdef(ksim).file.runid;
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,varname_load_mat,var_idx,fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref);
    
            end
    
            %% difference with initial time
            if flg_loc.do_diff_t && kt~=1
    
                kplot=2;
    
                tag_ref='diff_t';
                in_p.val=val_loc_tt-val_loc_t0;
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=simdef(ksim).file.runid;
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,varname_load_mat,var_idx,fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref);
    
            end
    
            %% difference with reference
            if flg_loc.do_diff_s && ksim~=kref
    
                kplot=3;
                 
                tag_ref='diff_s';
                in_p.val=val_loc_tt-val_ref_tt;
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,varname_load_mat,var_idx,fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref);
    
            end
    
            %% difference with reference and initial time
            if flg_loc.do_diff_s_t && ksim~=kref && kt~=1
    
                kplot=4;
    
                tag_ref='diff_s_t';
                in_p.val=(val_loc_tt-val_ref_t0)-(val_ref_tt-val_ref_t0);
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,varname_load_mat,var_idx,fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref);
    
            end
    
            %% difference with reference in percentage terms
            if flg_loc.do_diff_s_perc && ksim~=kref
    
                kplot=5;
    
                val_ref_tt_tmp=val_ref_tt;
                bol_0=val_ref_tt_tmp==0;
                val_ref_tt_tmp(bol_0)=NaN;
    
                tag_ref='diff_s_perc';
                in_p.val=(val_loc_tt-val_ref_tt_tmp)./val_ref_tt_tmp.*100;
                in_p.is_diff=0;
                in_p.is_background=0;
                in_p.is_percentage=1;
    
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(kref).file.runid);
                [fpath_file_2D(kplot,kt,:,:),fpath_file_3D(kplot,kt,:,:)]=fcn_plot(in_p,flg_loc,varname_load_mat,var_idx,fdir_fig,tag_fig,time_dnum_loc(kt),runid,tag_ref);
    
            end
            
            %% disp
            
            messageOut(fid_log,sprintf('Plotting %s variable %4.2f, simulation %4.2f, time %4.2f %%',tag_fig,kvar/nvar*100,ksim/nsim*100,ktc/nt*100));
            
        end %kt
    
        %% movies
    
        gdm_movie_paths(fid_log,flg_loc,time_dnum_loc,fpath_file_2D);

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

fid_log=NaN;

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

function [fpath_file_2D,fpath_file_3D]=fcn_plot(in_p,flg_loc,var_str,var_idx_loc,fdir_fig,tag_fig,time_dnum_loc,runid,tag_ref)

%colormap
cmap_str=fcn_str_cmap_clim(tag_ref,'cmap'); %string to read from `flg_loc`
in_p.cmap=flg_loc.(cmap_str);

clims_str=fcn_str_cmap_clim(tag_ref,'clims');
clims=flg_loc.(clims_str);

clims=fcn_clims_type(flg_loc,clims);
nclim=size(clims,1);

in_p.filter_lim=flg_loc.filter_lim.(clims_str);

str_var_idx=fcn_str_var_idx(var_idx_loc);

if flg_loc.do_2D
    fdir_fig_var=fullfile(fdir_fig,var_str,str_var_idx,tag_ref);
    mkdir_check(fdir_fig_var,NaN,1,0);
end

if flg_loc.do_3D
    fdir_fig_var=fullfile(fdir_fig,var_str,str_var_idx,sprintf('%s_3D',tag_ref));
    mkdir_check(fdir_fig_var,NaN,1,0);
    Zcor=cen2cor_2D(in_p.gridInfo.Xcen,in_p.gridInfo.Ycen,in_p.gridInfo.Xcor,in_p.gridInfo.Ycor,in_p.val);
    %in_p.gridInfo.Zcen=in_p.val;  %if this is passed, the plot is with tiles. This is more correct, but not pleasent to the eye.
    in_p.gridInfo.Zcor=Zcor; %if this is passed, it is more pleasent to the eye since the solution is continuous.
end

fpath_file_2D=cell(flg_loc.nclim_max,flg_loc.nxlim);
fpath_file_3D=cell(flg_loc.nclim_max,flg_loc.nxlim);

for kclim=1:nclim
    in_p.clims=clims(kclim,:);
    for kxlim=1:flg_loc.nxlim
        in_p.xlims=flg_loc.xlims(kxlim,:);
        in_p.ylims=flg_loc.ylims(kxlim,:);

        %measurements
        [in_p.measurements_images,in_p.tim_mea]=gdm_load_2D_measurements(in_p,in_p.measurements_structure,in_p.tim,in_p.tim_0,in_p.xlims,in_p.ylims);

        %2D
        if flg_loc.do_2D
            fname_noext=fig_name(fdir_fig_var,tag_fig,time_dnum_loc,runid,kclim,var_str,tag_ref,str_var_idx,kxlim);
            fpath_file_2D{kclim,kxlim}=sprintf('%s%s',fname_noext,flg_loc.fext); %for movie 
    
            in_p.fname=fname_noext;
            in_p.do_3D=0;
    
            fig_map_sal_01(in_p);
        end

        %3D
        if flg_loc.do_3D
            fname_noext=fig_name(fdir_fig_var_3d,tag_fig,time_dnum_loc,runid,runid_ref,kclim,var_str,tag_ref_3D,str_var_idx,kxlim);
            fpath_file_3D{kclim,kxlim}=sprintf('%s%s',fname_noext,flg_loc.fext); %for movie 

            in_p.fname=fname_noext;
            in_p.do_3D=1;  

            fig_map_sal_01(in_p);
        end

    end
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

%%

function in_p=fcn_load_tiles(flg_loc,in_p)

if flg_loc.plot_tiles
    if ~isfield(in_p,'tiles') || isempty(in_p.tiles)
        if isfield(flg_loc,'fpath_tiles') && isfile(flg_loc.fpath_tiles)
            load(flg_loc.fpath_tiles,'tiles')
            in_p.tiles=tiles;
        end
    end
end %plot_tiles

end %function

%%

%Create string of colormap and colorbar. diff_t -> cmap_diff_t
function cmap_str=fcn_str_cmap_clim(tag_ref,str_map)

if strcmp(tag_ref,'val')
    tag_ref='';
end
cmap_str=sprintf('%s_%s',str_map,tag_ref);
if strcmp(cmap_str(end),'_')
    cmap_str(end)='';
end

end %function

%%

function str_var_idx=fcn_str_var_idx(var_idx_loc)

str_var_idx=num2str(var_idx_loc);
str_var_idx=strrep(str_var_idx,' ','_');
str_var_idx=strrep(str_var_idx,'__','_');

end

%%

function gdm_movie_paths(fid_log,flg_loc,time_dnum_loc,fpath_file_2D)

[nplot,nt,~,nxlim]=size(fpath_file_2D);
if flg_loc.do_movie && nt>1
    
    for kplot=1:nplot
        %Do not check on the first time. It is empty for diff_t. 
        fpath_loc_t=fpath_file_2D(kplot,:,1,1);
        bol_t=cellfun(@(X)~isempty(X),fpath_loc_t);
        if any(bol_t)
            fpath_loc_t_ne=fpath_file_2D(:,bol_t,:,:);    
            fpath_loc_clim=squeeze(fpath_loc_t_ne(kplot,1,:,1)); %here the first time always exists
            bol_clim=cellfun(@(X)~isempty(X),fpath_loc_clim);
            nclim=sum(bol_clim);
            for kclim=1:nclim
                for kxlim=1:nxlim
                    fpath_mov=fpath_loc_t_ne(kplot,:,kclim,kxlim);
                    fpath_mov=reshape(fpath_mov,[],1);
                    gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum_loc);   
                end
            end
        end 
    end %kplot

end %movie

end %function