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

function plot_his_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

if contains(tag_fig,'all')
    tag_do='do_all';
else
    tag_do='do_p';
end
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_fil')==0
    flg_loc.do_fil=0;
end
if isfield(flg_loc,'fil_tim')==0
    flg_loc.fil_tim=25*3600;
end

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_var');

if isfield(flg_loc,'do_convergence')==0
    flg_loc.do_convergence=0;
end

%There are two inputs which are handled the same way:
%   -his-file
%   -map_2DH_his
his_type=1; %his-file
results_type='his';
if isfield(flg_loc,'obs')
    his_type=2;
    results_type='map';
end

if isfield(flg_loc,'do_all_sta')==0
    flg_loc.do_all_sta=0;
end

%% PATHS

n_sim=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
fpath_his=simdef(1).file.his;
% fpath_map=simdef(1).file.map;
mkdir_check(fdir_fig);

%% STATIONS

switch his_type
    case 1
        stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef(1).D3D.structure);
    case 2
        stations={flg_loc.obs.name};
end

%% TIME

tim_dtime_p=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,results_type,n_sim);

%% DIMENSIONS

ns=numel(stations);
nvar=numel(flg_loc.var);

%% GRID

%Load here all the grids, which are needed for the layers. 
for k_sim=1:n_sim
    gridInfo(k_sim)=EHY_getGridInfo(fpath_his,'no_layers');
%     gridInfo(k_sim)=gdm_load_grid_simdef(fid_log,simdef(k_sim)); %not nice to have to load it every time
end

%% FIGURE INI

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

in_p_c=flg_loc;
in_p_c.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p_c.fig_visible=0;

in_p.tim=tim_dtime_p;

fext=ext_of_fig(in_p.fig_print);

%% CHECKS

if flg_loc.do_all_sta && n_sim>1
    %I am now squeezeing `data_all` to pass to the plotting routine. I have to think what I want to do
    %for the case in which we want several stations from several simulations together in the same plot.
    flg_loc.do_all_sta=0;
end

%allocate to save all data
if flg_loc.do_all_sta
    %if we want to plot all stations together, we need to allocate for it. 
    n_sta=ns; %number of stations that we allocate. 
else
    %otherwise, it is a waste of memory.
    n_sta=1;
end

if ~isfield(flg_loc,'elevation')
    flg_loc.elevation=NaN(ns,1); 
end

%% LOOP

ks_v=gdm_kt_v(flg_loc,ns);

%loop on variables
for kvar=1:nvar
    
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef(1));
        
    nylim=size(flg_loc.ylims_var{kvar},1);
    data_all=cell(n_sim,n_sta);
    data_conv=cell(n_sim,n_sta);
    
    %loop on stations
    for ks=ks_v

        %if we do not want to plot all stations of the same run together, 
        %we always write in first dimension
        if flg_loc.do_all_sta
            k_sta=ks; %index of the station in which we save
        else
            k_sta=1;
        end

        in_p.unit=var_str;
        if isfield(flg_loc,'unit')
            if ~isempty(flg_loc.unit{kvar})
                in_p.unit=flg_loc.unit{kvar};
            end
        end

        stations_loc=stations{ks};
        in_p.station=stations_loc;
        
        elevation=flg_loc.elevation(ks);
        in_p.elevation=elevation;

        %% load data
        [data_all,layer]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,n_sim,k_sta,his_type,elevation);
        
        %% convergence
        [data_conv,unit_conv,~]=check_convergence(flg_loc,data_all,tim_dtime_p,var_str,k_sta,data_conv);
        
        %% measurements
       [in_p,data_mea]=add_measurements(flg_loc,in_p,stations_loc,elevation);

        %% filtered data
        in_p=add_filter(flg_loc,in_p,data_all,tim_dtime_p,data_mea);
        
        %% plot value
        
        in_p.val=data_all(:,k_sta); %we pass all simulations and only one stations
        fdir_fig_var=fullfile(fdir_fig,var_str);
        mkdir_check(fdir_fig_var,NaN,1,0);
        
        for kylim=1:nylim
            fname_noext=fig_name(fdir_fig_var,tag,simdef(1).file.runid,stations_loc,var_str,layer,kylim,elevation); %are you sure simdef(1)?
%             fpath_file=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            in_p.ylims=get_ylims(flg_loc.ylims_var{kvar}(kylim,:),in_p.do_measurements,{reshape(cell2mat(data_all(:,k_sta)),1,[])},data_mea);

            fig_his_sal_01(in_p);
        end %kylim
        
    end %ks

    %% convergence
    
    if flg_loc.do_convergence
        
        fname_noext=fig_name_convergence(fdir_fig_var,tag,simdef(1).file.runid,var_str,layer,kylim,'conv');
        
        in_p_c.fname=fname_noext;
        in_p_c.data=data_conv;
        in_p_c.stations=stations;
        in_p_c.unit=unit_conv;
        in_p_c.is_std=unit_conv;
        
        fig_his_convergence(in_p_c)
        
    end

    %% all obs in same figure

    if flg_loc.do_all_sta

        if n_sim>1
            continue
        end

        in_p_sta_all=in_p;

        fname_noext=fig_name_convergence(fdir_fig_var,tag,simdef(1).file.runid,var_str,layer,kylim,'allsta');
        
        in_p_sta_all.ylims=get_ylims(flg_loc.ylims_var{kvar}(kylim,:),in_p.do_measurements,{reshape(cell2mat(data_all),1,[])},data_mea);
        in_p_sta_all.fname=fname_noext;
        in_p_sta_all.val=data_all;
        in_p_sta_all.leg_str=stations; 
        in_p_sta_all.do_title=0;
        in_p_sta_all.tim=repmat({tim_dtime_p{1,1}},1,ns);

        fig_his_sal_01(in_p_sta_all)         
       
    end

    
end %kvar


%% movies

% dt_aux=diff(time_dnum);
% dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
% rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
% for kclim=1:nclim
%    make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
% end

end %function

%%
%% FUNCTIONS
%%

function ylims=get_ylims(ylims,do_measurements,data,data_mea)

if isnan(ylims)
    if do_measurements
        ylims_1=[min([data{:}]),max([data{:}])];
        switch data_mea.eenheid
            case 'mg/l'
                ylims_2=[min(sal2cl(-1,data_mea.waarde)),sal2cl(-1,max(data_mea.waarde))];
            otherwise
                ylims_2=[min(data_mea.waarde),max(data_mea.waarde)];
        end

        ylims=[min(ylims_1(1),ylims_2(1)),max(ylims_1(2),ylims_2(2))];
    else
        ylims=[min([data{:}]),max([data{:}])];
    end
end

dy=diff(ylims);
if dy==0
    my=mean(ylims);
    ylims=ylims+abs(my/100)*[-1,1];
end
if isnan(ylims)
    ylims=[-1e-10,1e-10];
end

end %function

%%

function fname=fig_name(fdir_fig_var,tag,runid,station,var_str,layer,kylim,elevation)

if ~isempty(layer)
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_layer_%04d_ylim_%02d',tag,runid,station,var_str,layer,kylim));
else
   if ~isnan(elevation)
      fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_elev_%f_ylim_%02d',tag,runid,station,var_str,elevation,kylim));
   else
      fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_ylim_%02d',tag,runid,station,var_str,kylim));
   end
end

end %function

%%

function fname=fig_name_convergence(fdir_fig_var,tag,runid,var_str,layer,kylim,anl)

if ~isempty(layer)
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_layer_%04d_ylim_%02d',tag,anl,runid,var_str,layer,kylim));
else
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_ylim_%02d',tag,anl,runid,var_str,kylim));
end

end %function

%%

function [data_conv,unit,is_std]=check_convergence(flg_loc,data_all,time_dtime_p,var_str,k_sta,data_conv)

unit='';
is_std=NaN;

if flg_loc.do_convergence

%% PARSE

if isfield(flg_loc,'convergence_type')==0
    flg_loc.convergence_type=2;
end
if isfield(flg_loc,'convergence_time')==0
    flg_loc.convergence_time=seconds(3600);
end

%% CALC

switch flg_loc.convergence_type
    case 1 %simplest form, take last two values
        error('repair')
%         data_conv(ks,:)=diff(data_all(end-1:end,:),1,1)/seconds(diff(time_dtime_p(end-1:end)));
%         
%         unit=sprintf('%s/t',var_str);
%         is_std=0;
    case 2 %std over time
        for k_sim=1:n_sim
            t0=time_dtime_p{k_sim}(end)-flg_loc.convergence_time;
            bol_tim=time_dtime_p{k_sim}>t0;
            data_conv{k_sim,k_sta}=std(data_all{k_sim,k_sta}(bol_tim));
            
            unit=var_str;
            is_std=1;
        end
end
   
end

end %function

%%

function [data_all,layer]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,n_sim,k_sta,his_type,elevation)

for k_sim=1:n_sim %simulations            
    fdir_mat=simdef(k_sim).file.mat.dir;
    fpath_his=simdef(k_sim).file.his;
    
    %variable
    switch his_type
        case 1
            layer=gdm_station_layer(flg_loc,gridInfo(k_sim),fpath_his,stations_loc,var_str,elevation); 
        case 2
            layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
    end
    
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations_loc,'var',var_str,'layer',layer,'elevation',elevation);
    load(fpath_mat_tmp,'data');
    data_all{k_sim,k_sta}=data;

end %k_sim

end %function

%%

function tim_dtime_p=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,results_type,n_sim)

tim_dtime_p=cell(n_sim,1);

for k_sim=1:n_sim %simulations            

    %time
    [nt(k_sim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef(k_sim),'results_type',results_type); %force his reading. Needed for SMT.
    [tim_dnum_p,tim_dtime_p{k_sim}]=gdm_time_flow_mor(flg_loc,simdef(k_sim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

end %k_sim

end %function

%% 

function [in_p,data_mea]=add_measurements(flg_loc,in_p,stations_loc,elevation)

if isfield(flg_loc,'measurements')
    if isfolder(flg_loc.measurements) && exist(fullfile(flg_loc.measurements,'data_stations_index.mat'),'file')
        [str_sta,str_found]=RWS_location_clear(stations_loc);
        data_mea=read_data_stations(flg_loc.measurements,'location_clear',str_sta{:},'bemonsteringshoogte',elevation); %location maybe better?
        if isempty(data_mea)
            in_p.do_measurements=0;
            data_mea=NaN;
        else
            in_p.do_measurements=1;
            in_p.data_stations=data_mea;
        end
    else
        error('do reader')
    end
else
    in_p.do_measurements=0;
    data_mea=NaN;
end

end %function

%%

function in_p=add_filter(flg_loc,in_p,data_all,time_dtime,data_mea,k_sta)

if flg_loc.do_fil  
    for k_sim=1:n_sim
        in_p.do_fil=1;
        
        [tim_f,data_f]=filter_1D(time_dtime{k_sim},data_all{k_sim,k_sta},'method','godin'); 
        
        in_p.val_f{k_sim,k_sta}=data_f;
        in_p.tim_f{k_sim,k_sta}=tim_f;
        
        if in_p.do_measurements                
            [tim_f,data_f]=filter_1D(data_mea.time,data_mea.waarde,'method','godin');
            
            in_p.data_stations_f.time=tim_f;
            in_p.data_stations_f.waarde=data_f;
        end
    end
end

end %function