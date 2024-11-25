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

tag_do='do_p';
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

flg_loc=gdm_parse_his(fid_log,flg_loc,simdef);

nvar=flg_loc.nvar;
nobs=flg_loc.nobs;
nsim=flg_loc.n_sim;
ntimint=flg_loc.ntimint;

stations=flg_loc.stations;
his_type=flg_loc.his_type;

%% PATHS

fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);

%% GRID

%Load here all the grids, which are needed for the layers. 
for ksim=1:nsim
    fpath_his=simdef(ksim).file.his;
    gridInfo(ksim)=EHY_getGridInfo(fpath_his,'no_layers');
%     gridInfo(k_sim)=gdm_load_grid_simdef(fid_log,simdef(k_sim)); %not nice to have to load it every time
end

obs_all=D3D_observation_stations(fpath_his,'simdef',simdef(1));

%% FIGURE INI

%regular
in_p=flg_loc;
in_p.fig_visible=0;

%convergence
in_p_c=flg_loc;
in_p_c.fig_visible=0;

% fext=ext_of_fig(in_p.fig_print);

%% LDB
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%% CHECKS

%allocate to save all data
if flg_loc.load_all_stations
    %if we want to plot all stations together, we need to allocate for it. 
    n_sta=nobs; %number of stations that we allocate. 
else
    %otherwise, it is a waste of memory.
    n_sta=1;
end

for ktimint=1:ntimint

    %% TIME
    flg_loc.tim=flg_loc.tim_int{ktimint};
    [tim_dtime_p,tim_dtime]=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,nsim); %{nsim,1} datetime
    
    %% LOOP
    
    ks_v=gdm_kt_v(flg_loc,nobs);
    
    %loop on variables
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef(1),'res_type','his');
            
        data_all=cell(nsim,n_sta);
        data_conv=cell(nsim,n_sta);
        
        %loop on stations
        for ks=ks_v
    
            %if we do not want to plot all stations of the same run together, 
            %we always write in first dimension
            if flg_loc.load_all_stations
                k_sta=ks; %index of the station in which we save
            else
                k_sta=1;
            end
    
            stations_loc=stations{ks};
            in_p.station=stations_loc;
            
            elev=flg_loc.elev(ks);
            [layer,elev]=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks},var_str,elev);
            in_p.elev=elev;
    
            %% load data
            [data_all,layer,unit]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,nsim,k_sta,his_type,elev,tim_dtime,flg_loc.unit{kvar},kvar);
            %dimension: data_all{k_sim,k_sta}
    
            if ~isvector(size(data_all{1}))
                messageOut(fid_log,sprintf('Cannot plot more than 1 dimension. There may be more than 1 layer: %s',varname));
                continue
            end
    
            in_p.unit=unit;
    
            %% convergence
            [data_conv,unit_conv,~]=check_convergence(flg_loc,data_all,tim_dtime_p,var_str,k_sta,data_conv);
            
            %% measurements
            [do_measurements,data_mea]=add_measurements(flg_loc.measurements,stations_loc,elev,unit);
    
            flg_loc.do_measurements=do_measurements;
            [data_statistics]=gdm_statistics_measurements(flg_loc,simdef,data_mea,tim_dtime_p,data_all,stations_loc,var_str,elev,k_sta);
    
            in_p.do_measurements=do_measurements;
            in_p.data_stations=data_mea;
    
            %% filtered data
            in_p=add_filter(flg_loc,in_p,data_all,tim_dtime_p,data_mea);
            
            %% loop on simulations
            for ksim=1:nsim
                runid=simdef(ksim).file.runid;
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
    
                in_p.is_diff=0;
                val=data_all(ksim,k_sta); %we pass one simulation and one station
                
                %% plot each station individually
                if flg_loc.do_p_single
                    fcn_plot_his(flg_loc,in_p,val,runid,kvar,tim_dtime_p(ksim),tag,stations_loc,var_str,layer,elev,fdir_fig,data_mea,do_measurements);
                end
    
                %% plot salinity figure (special case)
                if flg_loc.do_sal_01
                    %We save `data_statistics` for being able to write the table. Only
                    %when the variable is salinity we save it (we also loop in water
                    %level).
                    if strcmp(var_str,'sal')
                        %we remove timeseries to save space
                        data_statistics_no_time_series=data_statistics;
                        data_statistics_no_time_series=rmfield(data_statistics_no_time_series,{'verr','v_mea','v_sim_atmea','tim_mea'});
                        data_statistics_no_time_series.tim_lim=[tim_dtime_p{ksim}(1),tim_dtime_p{ksim}(end)];
                        data_statistics_all(ks,ktimint)=data_statistics_no_time_series; %This can fail if there is more than one simulation. Test!
                    end

                    fcn_plot_sal_01(flg_loc,in_p,data_all,simdef(ksim),gridInfo(ksim),stations_loc,var_str,tag,k_sta,his_type,elev,tim_dtime_p{ksim},obs_all,data_statistics(ksim),fdir_fig,data_mea);
                end
            end %ksim
    
            %% plot all simulations together
    
            if flg_loc.do_all_sim
                ksim=1;
                runid=simdef(ksim).file.runid;
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,sprintf('%s_all',tag_fig),tag_serie);
        
                val=data_all(:,k_sta); %we pass all simulations and only one stations
                fcn_plot_his(flg_loc,in_p,val,runid,kvar,tim_dtime_p,tag,stations_loc,var_str,layer,elev,fdir_fig,data_mea,do_measurements);
            end
    
            %% difference with reference simulation
            if flg_loc.do_s && nsim>1
                for ksim=1:nsim
                    if ksim==flg_loc.sim_ref
                        continue
                    end
                    runid=sprintf('%s-%s',simdef(ksim).file.runid,simdef(flg_loc.sim_ref).file.runid);
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,sprintf('%s_diff',tag_fig),tag_serie);
    
                    val=data_all{ksim,k_sta};
                    val_ref=data_all{flg_loc.sim_ref,k_sta};
                    if any(size(val)-size(val_ref))
                        messageOut(fid_log,'Cannot plot difference when different sizes. Interpolate data for making it possible.')
                        continue
                    end
    
                    val={val-val_ref};
                    in_p.is_diff=1;
    
                    fcn_plot_his(flg_loc,in_p,val,runid,kvar,tim_dtime_p,tag,stations_loc,var_str,layer,elev,fdir_fig,data_mea,do_measurements);
                end
            end
            
        end %ks
    
        %% PLOTS FOR ALL STATIONS
    
        %% convergence
        
        if flg_loc.do_convergence
            
            fdir_fig_var=fullfile(fdir_fig,var_str);
            
            ylims_loc=flg_loc.ylims_var{kvar};
            nylim=size(ylims_loc,1);
            for kylim=1:nylim
                fname_noext=fig_name_convergence(fdir_fig_var,tag,simdef(1).file.runid,var_str,layer,kylim,'conv');
                
                in_p_c.fname=fname_noext;
                in_p_c.data=data_conv;
                in_p_c.stations=stations;
                in_p_c.unit=unit_conv;
                in_p_c.is_std=unit_conv;
                
                fig_his_convergence(in_p_c)
            end 
        end
    
        %% all obs in same figure
    
        if flg_loc.do_all_sta && n_sta>1
    
            if nsim>1
                continue
            end
    
            in_p_sta_all=in_p;
    
            fdir_fig_var=fullfile(fdir_fig,var_str);

            ylims_loc=flg_loc.ylims_var{kvar};
            nylim=size(ylims_loc,1);
            for kylim=1:nylim
                fname_noext=fig_name_convergence(fdir_fig_var,tag,simdef(1).file.runid,var_str,layer,kylim,'allsta');
                
                [in_p_sta_all.xlims,in_p_sta_all.ylims]=get_ylims(ylims_loc(kylim,:),do_measurements,data_all,data_mea,tim_dtime_p{1});
        
                in_p_sta_all.fname=fname_noext;
                in_p_sta_all.val=data_all;
                in_p_sta_all.leg_str=stations; 
                in_p_sta_all.do_title=0;
                in_p_sta_all.tim=repmat({tim_dtime_p{1,1}},1,nobs);
        
                fig_his_sal_01(in_p_sta_all)   
            end
           
        end
    
        %% plot xt (special case)
    
        if flg_loc.do_xt
    
            for ksim=1:nsim
                %leave this outside the function for when you want to make difference between simulations
                runid=simdef(ksim).file.runid;
                tag_loc=sprintf('%s_xt',tag_fig);
                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_loc,tag_serie);
                mkdir_check(fdir_fig,NaN,1,0);
    
                fcn_plot_his_xt(flg_loc,in_p,simdef(ksim),runid,data_all(ksim,:),tim_dtime_p{ksim},var_str,flg_loc.clims_var{kvar,1},tag_loc,fdir_fig);
            end
    
        end
    
    end %kvar

end % ktimeint

%% file summary of statistics
    
%It is currently slightly ad-hoc. It is outise the loop on variables, 
%but `data_statistics_all` varies per variable. As such, it only works
%for one variable. This is not a problem now because it is only done
%for the case of `do_sal_01`, which is only possible for one variable.

if flg_loc.do_sal_01
    for ksim=1:nsim
        %`data_statistics_all` should be passed for only one simulation. 
        %check when you have such a case. 
        if nsim>1
            error('See comment above')
        end
        fcn_write_table_sal_01(simdef(ksim),stations,data_statistics_all,flg_loc.elev);
    end %ksim
end

end %function

%%
%% FUNCTIONS
%%

function [xlims,ylims]=get_ylims(ylims,do_measurements,data,data_mea,tim_dtime)

x_all=tim_dtime; %cell array
val_all=data; %cell array
if do_measurements
%     x_all=cat(1,x_all,{data_mea.time}); %I don't think we want the xlim to be modified by measurement availablity. 
    tim_mea_nan=NaT(size(data_mea.waarde));
    tim_mea_nan.TimeZone='+00:00';
    x_all=cat(1,x_all,{tim_mea_nan});
    val_all=cat(1,val_all,{data_mea.waarde});
end

[xlims,ylims]=xlim_ylim([NaN,NaN],ylims,x_all,val_all);

end %function

%%

function fname=fig_name(fdir_fig_var,tag,runid,station,var_str,layer,kylim,elev,tim_0,tim_f,depth_average_limits,depth_average)

%base
str_b=sprintf('%s_%s_%s_%s_%s-%s_ylim_%02d',tag,runid,station,var_str,datestr(tim_0,'yyyymmddHHMMSS'),datestr(tim_f,'yyyymmddHHMMSS'),kylim);

if ~isempty(layer)
    str_b=sprintf('%s_layer_%04d',str_b,layer);
end

if ~isnan(elev)
    str_b=sprintf('%s_elev_%5.2f',str_b,elev);
end

if depth_average
    str_b=sprintf('%s_da',str_b);
end

if ~isinf(depth_average_limits(1))
    str_b=sprintf('%s_%5.2f-%5.2f',str_b,depth_average_limits(1),depth_average_limits(2));
end

fname=fullfile(fdir_fig_var,str_b);

end %function

%%

function fname=fig_name_convergence(fdir_fig_var,tag,runid,var_str,layer,kylim,anl)
%add time!
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

function [data_all,layer,unit]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,nsim,k_sta,his_type,elev,time_dtime,unit,kvar)

for ksim=1:nsim %simulations            
    fdir_mat=simdef(ksim).file.mat.dir;
    fpath_his=simdef(ksim).file.his;
    
    %variable
    switch his_type
        case 1
            layer=gdm_station_layer(flg_loc,gridInfo(ksim),fpath_his,stations_loc,var_str,elev); 
        case 2
            layer=gdm_layer(flg_loc,gridInfo(ksim).no_layers,var_str,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers
    end

    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations_loc,'var',var_str,'layer',layer,'elevation',elev,'tim',time_dtime{ksim}(1),'tim2',time_dtime{ksim}(end),'depth_average',flg_loc.depth_average(kvar),'depth_average_limits',flg_loc.depth_average_limits(kvar,:));
    load(fpath_mat_tmp,'data');

    %change units
    if isempty(unit)
        unit=var_str;
    end
    switch unit
        case 'cl' %data is in psu and we want it in cl
            data=sal2cl(1,data);
    end

    %output
    data_all{ksim,k_sta}=data;

end %k_sim

end %function

%%

%OUTPUT:
%   -tim_dtime_p = cell array with the time in datetime format that is used for plotting (can be flow or morpho) in each simulation [cell(nsim,1)]
%   -tim_dtime   = cell array with the time in datetime format that is used for loading results (it is the flow time) in each simulation [cell(nsim,1)]
%
function [tim_dtime_p,tim_dtime]=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,nsim)

tim_dtime_p=cell(nsim,1);
tim_dtime=cell(nsim,1);

for ksim=1:nsim %simulations            

    %time
    [nt(ksim),tim_dnum,tim_dtime{ksim},tim_mor_dnum,tim_mor_dtime,~]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef(ksim),'results_type',flg_loc.results_type); %force his reading. Needed for SMT.
    [~,tim_dtime_p{ksim}]=gdm_time_flow_mor(flg_loc,simdef(ksim),tim_dnum,tim_dtime{ksim},tim_mor_dnum,tim_mor_dtime);

end %k_sim

end %function

%% 

function [do_measurements,data_mea]=add_measurements(measurements,stations_loc,elev,unit)

if ~isempty(measurements)
    if isfolder(measurements) && exist(fullfile(measurements,'data_stations_index.mat'),'file')
        [str_sta,str_found]=RWS_location_clear(stations_loc);
        grootheid=unit_to_grootheid(unit);
        data_mea=read_data_stations(measurements,'location_clear',str_sta{:},'bemonsteringshoogte',elev,'grootheid',grootheid); %location maybe better?
        if isempty(data_mea)
            data_mea=struct();
        end
    else
        error('do reader')
    end    
else
    data_mea=struct();
end

fn=fieldnames(data_mea);
nfn=numel(fn);
if nfn==0
    do_measurements=0;
else
    do_measurements=1;
    messageOut(NaN,sprintf('Measurements found for station: %s',stations_loc))
end

if do_measurements
    %units
    data_mea.waarde=change_units(data_mea.waarde,unit,data_mea.eenheid);
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

%%

function val=change_units(val,unit_out,unit_in)

switch unit_out
    case 'cl' %we want it in cl
        switch unit_in
            case 'mg/l'
                %it is ok
            otherwise
                error('not sure how to convert')
        end
    case 'sal' %we want it in psu
        switch unit_in
            case 'mg/l'
                val=sal2cl(-1,val);
            otherwise
                error('not sure how to convert')
        end
end %unit_out

end %function

%%

function fcn_plot_his(flg_loc,in_p,val,runid,kvar,tim_dtime_p,tag,stations_loc,var_str,layer,elev,fdir_fig,data_mea,do_measurements)
   
if in_p.is_diff
    ylims_loc=flg_loc.ylims_diff_var{kvar};
else
    ylims_loc=flg_loc.ylims_var{kvar};
end
xlims_loc=flg_loc.xlims_var{kvar};

nylim=size(ylims_loc,1);
if size(xlims_loc,1)<nylim
    xlims_loc=repmat(xlims_loc,nylim,1);
end

in_p.val=val;
in_p.tim=tim_dtime_p;

fdir_fig_var=fullfile(fdir_fig,var_str);
mkdir_check(fdir_fig_var,NaN,1,0);
for kylim=1:nylim
    in_p.ylims=ylims_loc(kylim,:);
    in_p.xlims=xlims_loc(kylim,:);
    switch flg_loc.plot_type
        case 1
            fname_noext=fig_name(fdir_fig_var,tag,runid,stations_loc,var_str,layer,kylim,elev,tim_dtime_p{1}(1),tim_dtime_p{1}(end),flg_loc.depth_average_limits(kvar,:),flg_loc.depth_average(kvar)); %are you sure simdef(1)? what about time for saving?
            in_p.fname=fname_noext;
            fig_his_sal_01(in_p);
        case 2
            fname_noext=fig_name(fdir_fig_var,sprintf('%s_2',tag),runid,stations_loc,var_str,layer,kylim,elev,tim_dtime_p{1}(1),tim_dtime_p{1}(end),flg_loc.depth_average_limits(kvar,:),flg_loc.depth_average(kvar)); %are you sure simdef(1)? what about time for saving?
            in_p.fname=fname_noext;
            in_p.ylim_sal=in_p.ylims;
            fig_his_sal_02(in_p);
    end
end %kylim

end %function

%%

function [data_statistics]=gdm_statistics_measurements(flg_loc,simdef,data_mea,tim_dtime_p,data_all,station,var_str,elev,k_sta)

thr=[-inf,inf];

if ~flg_loc.do_measurements
    data_statistics=struct();
    return
end

if flg_loc.interp_measurements
    
    data_all_at_mea=interpolate_timetable(tim_dtime_p,data_all(:,k_sta),data_mea.time,'disp',0);
    
    if flg_loc.do_statistics
        v_mea=data_mea.waarde;

        for ksim=1:numel(data_all)
            fdir_mat=simdef(ksim).file.mat.dir;
            runid=simdef(ksim).file.runid;
            v_sim_atmea=data_all_at_mea(:,ksim);
            tim_0=tim_dtime_p{ksim}(1);
            tim_f=tim_dtime_p{ksim}(end);
            fpath_mat_tmp=fname_stat(fdir_mat,runid,station,var_str,tim_0,tim_f,elev);
            if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite 
                messageOut(NaN,sprintf('Loading file: %s',fpath_mat_tmp));
                load(fpath_mat_tmp,'data')
            else
                [verr,vbias,vstd,vrmse,corr_R,corr_P,bias_01,rmsd_01]=statisticsV(v_mea,v_sim_atmea,thr);
                tim_mea=data_mea.time;
                data=v2struct(verr,vbias,vstd,vrmse,corr_R,corr_P,bias_01,rmsd_01,v_mea,v_sim_atmea,thr,tim_mea);
                save_check(fpath_mat_tmp,'data');
            end
            data_statistics=data(ksim);
        end %ksim
    end
    
end

end %function

%%

function fname=fname_stat(fdir,runid,station,var_str,tim_0,tim_f,elev)

%base
str_b=sprintf('stat_%s_%s_%s_%s-%s_ylim_%02d',runid,station,var_str,datestr(tim_0,'yyyymmddHHMMSS'),datestr(tim_f,'yyyymmddHHMMSS'));

if ~isnan(elev)
    str_b=sprintf('%s_elev_%5.2f',str_b,elev);
end

fname=fullfile(fdir,sprintf('%s.mat',str_b));

end %function

%%

function fcn_plot_sal_01(flg_loc,in_p,data_all,simdef,gridInfo,stations_loc,var_str,tag,k_sta,his_type,elev,tim_dtime_p_sim,obs_all,data_statistics,fdir_fig,data_mea)

if ~strcmp(var_str,'sal')
    %we only plot when it is salinity, as we will also be here when water level (both need to be read)
    return
end

% [data_mea.time,data_mea.waarde]=split_time_threshold(data_mea.time,data_mea.waarde,days(1));
tim_mea=data_statistics.tim_mea;
[data_statistics.tim_mea,data_statistics.v_mea]=split_time_threshold(tim_mea,data_statistics.v_mea,days(1));
[~                      ,data_statistics.verr ]=split_time_threshold(tim_mea,data_statistics.verr ,days(1));

%load water level for that simulation, which is stored in position 2
kvar=2;
[data_all_wl,layer,unit]=load_data_all(flg_loc,{},simdef,gridInfo,stations_loc,'wl',tag,1,k_sta,his_type,[],{tim_dtime_p_sim},flg_loc.unit{kvar},kvar);

%station
idx_station=find_str_in_cell(obs_all.name,{stations_loc});

in_p.station_xy=[obs_all.x(idx_station),obs_all.y(idx_station)];

%water level
in_p.tim_wl=tim_dtime_p_sim;
in_p.wl=data_all_wl{1};

in_p.verr=data_statistics.verr;
in_p.v_mea=data_statistics.v_mea;
in_p.vbias=data_statistics.vbias;
in_p.vstd=data_statistics.vstd;
in_p.vrmse=data_statistics.vrmse;
in_p.corr_R=data_statistics.corr_R;
in_p.corr_P=data_statistics.corr_P;
in_p.v_sim_atmea=data_statistics.v_sim_atmea;
in_p.tim_mea=data_statistics.tim_mea;
in_p.tim_sim=tim_dtime_p_sim;
in_p.v_sim=data_all{1,k_sta};

runid=simdef.file.runid;
kvar=1; %sal
do_measurements=1;
fcn_plot_his(flg_loc,in_p,data_all(1,k_sta),runid,kvar,{tim_dtime_p_sim},tag,stations_loc,var_str,layer,elev,fdir_fig,data_mea,do_measurements);


end %function

%%

function grootheid=unit_to_grootheid(unit)

switch unit
    case {'sal','cl','cl_surf'}
        grootheid='CONCTTE';
    case 'wl'
        grootheid='WATHTE';
    otherwise
        error('add')
end
end

%%

function [data,do_measurements]=load_interpolated_measurements(flg_loc,fpath_mea,time_dtime,unit)

do_measurements=0;
data=struct('t_m_mea',[],'d_m_mea',[],'val_m_mea',[]);
if isfile(fpath_mea)
    do_measurements=1;
    load(fpath_mea,'data');
else
    %rather than taking a measurement for each station, we take measurements ad-hoc
    grootheid=unit_to_grootheid(unit);
    data_mea=read_data_stations(flg_loc.measurements,'branch',flg_loc.measurements_branch,'grootheid',grootheid); %location maybe better?
    if ~isempty_struc(data_mea)
        do_measurements=1;

        [t_m_mea,d_m_mea,val_m_mea]=interpolate_xy_data_stations(data_mea,time_dtime,'order','dist_mouth');
        data=v2struct(t_m_mea,d_m_mea,val_m_mea);
        save_check(fpath_mea,'data')
    end
end

end %function

%%

%We pass information of only one simulation
function fcn_plot_his_xt(flg_loc,in_p,simdef,runid,data_sim,tim_dtime_p_sim,var_str,clims_var,tag_loc,fdir_fig)

if flg_loc.measurements_input_type==2
    fpath_mea=fullfile(simdef.file.mat.dir,'interpolated_measurements.mat');
    [data_mea_mat,in_p.do_measurements]=load_interpolated_measurements(flg_loc,fpath_mea,tim_dtime_p_sim,in_p.unit); 
end

nclim=size(clims_var,1);
for kclim=1:nclim
    
    fdir_fig_var=fullfile(fdir_fig,var_str);
    mkdir_check(fdir_fig_var,NaN,1,0);
    fname_noext=fig_name(fdir_fig_var,tag_loc,runid,'',var_str,'',kclim,'',tim_dtime_p_sim(1),tim_dtime_p_sim(end),[-inf,inf],[]);

    data_sim_mat=cell2mat(data_sim); %(nt,nobs) 
    [nt,ns]=size(data_sim_mat);

    in_p.fname=fname_noext;
    in_p.clims=clims_var(kclim,:);
    in_p.val_m=data_sim_mat;
    in_p.d_m=repmat(flg_loc.s,nt,1);
    in_p.t_m=repmat(tim_dtime_p_sim,1,ns);
    in_p.d_m_mea=data_mea_mat.d_m_mea;
    in_p.t_m_mea=data_mea_mat.t_m_mea;
    in_p.val_m_mea=data_mea_mat.val_m_mea;

    fig_his_xt_01(in_p);
end %kclim

end %function

%%

function fcn_write_table_sal_01(simdef,stations,data_statistics_all,elev)

%The function for writing salinity data requires input organized for all simulations, 
%(i.e., a cell on `ksim`), but it is not used. It should be cleaned.
ksim=1;

ntimint=size(data_statistics_all,2);

fdir_tab=fullfile(fullfile(simdef.file.fig.dir),'sal_table');
mkdir_check(fdir_tab,NaN,1,0);
path_f_sal_cmp=fullfile(fdir_tab,'sal_table.txt');

[stations_u,~,idx_u2]=unique(stations);
n_sim_u=numel(stations_u);

station_s=cell(n_sim_u,1);
for ks=1:n_sim_u
    station_s{ksim,1}(ks,1)=RWS_location_clear(stations_u{ks});

    bol_sta=idx_u2==ks;
    ds_sta=data_statistics_all(bol_sta);
    elev_sta=elev(bol_sta);
    nelev=numel(elev_sta);

    for km=1:nelev
        z_mea_s_1{ksim,1}{ks,1}{km,1}=elev_sta(km);
        for klim=1:ntimint
            sal_bias_s{ksim,1}{ks,1}{km,1}{klim,1}=ds_sta(km).vbias;
            sal_std_s{ksim,1}{ks,1}{km,1}{klim,1}=ds_sta(km).vstd;
            sal_rmse_s{ksim,1}{ks,1}{km,1}{klim,1}=ds_sta(km).vrmse;
            sal_corr_R_s{ksim,1}{ks,1}{km,1}{klim,1}=ds_sta(km).corr_R;
            x_lims_v(klim,1:2)=ds_sta(km).tim_lim;
        end %klim
    end %kelev
end %ksu

fileSummarySalinity(path_f_sal_cmp,station_s,z_mea_s_1,sal_bias_s,sal_std_s,sal_rmse_s,sal_corr_R_s,ksim,x_lims_v,NaN);

end