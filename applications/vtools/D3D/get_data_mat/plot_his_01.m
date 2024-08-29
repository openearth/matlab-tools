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

flg_loc=gdm_parse_his(fid_log,flg_loc,simdef);

nvar=flg_loc.nvar;
ns=flg_loc.ns;
stations=flg_loc.stations;
his_type=flg_loc.his_type;

%% PATHS

n_sim=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
%fpath_his=simdef(1).file.his;
% fpath_map=simdef(1).file.map;
mkdir_check(fdir_fig);

%% TIME

tim_dtime_p=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,n_sim);

%% GRID

%Load here all the grids, which are needed for the layers. 
for k_sim=1:n_sim
    fpath_his=simdef(k_sim).file.his;
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

% fext=ext_of_fig(in_p.fig_print);

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

        stations_loc=stations{ks};
        in_p.station=stations_loc;
        
        elevation=flg_loc.elevation(ks);
        in_p.elevation=elevation;

        %% load data
        [data_all,layer,unit]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,n_sim,k_sta,his_type,elevation,tim_dtime_p,flg_loc.unit{kvar},kvar);
        
        in_p.unit=unit;

        %% convergence
        [data_conv,unit_conv,~]=check_convergence(flg_loc,data_all,tim_dtime_p,var_str,k_sta,data_conv);
        
        %% measurements
        [do_measurements,data_mea]=add_measurements(flg_loc.measurements,stations_loc,elevation,unit);

        in_p.do_measurements=do_measurements;
        in_p.data_stations=data_mea;

        %% filtered data
        in_p=add_filter(flg_loc,in_p,data_all,tim_dtime_p,data_mea);
        
        %% plot value
        
        in_p.val=data_all(:,k_sta); %we pass all simulations and only one stations
        fdir_fig_var=fullfile(fdir_fig,var_str);
        mkdir_check(fdir_fig_var,NaN,1,0);
        
        for kylim=1:nylim
            fname_noext=fig_name(fdir_fig_var,tag,simdef(1).file.runid,stations_loc,var_str,layer,kylim,elevation,tim_dtime_p{1}(1),tim_dtime_p{1}(end)); %are you sure simdef(1)? what about time for saving?
%             fpath_file=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            [in_p.xlims,in_p.ylims]=get_ylims(flg_loc.ylims_var{kvar}(kylim,:),do_measurements,data_all{k_sta},data_mea,tim_dtime_p{1});

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
        
        [in_p_sta_all.xlims,in_p_sta_all.ylims]=get_ylims(flg_loc.ylims_var{kvar}(kylim,:),do_measurements,data_all,data_mea,tim_dtime_p{1});

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

function [xlims,ylims]=get_ylims(ylims,do_measurements,data,data_mea,tim_dtime)

x_all=tim_dtime;
val_all=data;
if do_measurements
    x_all=cat(1,x_all,{data_mea.time});
    val_all=cat(1,val_all,{data_mea.waarde});
end

% [xlims,ylims]=xlim_ylim([tim_dtime(1),tim_dtime(end)],ylims,x_all,val_all);
[xlims,ylims]=xlim_ylim([NaN,NaN],ylims,x_all,val_all);
% if isnan(ylims)
%     if do_measurements
%         ylims_1=[min([data{:}]),max([data{:}])];
% %         switch data_mea.eenheid
% %             case 'mg/l'
% %                 ylims_2=[min(sal2cl(-1,data_mea.waarde)),sal2cl(-1,max(data_mea.waarde))];
% %             otherwise
%                 ylims_2=[min(data_mea.waarde),max(data_mea.waarde)];
% %         end
% 
%         ylims=[min(ylims_1(1),ylims_2(1)),max(ylims_1(2),ylims_2(2))];
%     else
%         ylims=[min([data{:}]),max([data{:}])];
%     end
% end
% 
% % dy=diff(ylims);
% % if dy==0
% %     my=mean(ylims);
% %     ylims=ylims+abs(my/100)*[-1,1];
% % end
% % if isnan(ylims)
% %     ylims=[-1e-10,1e-10];
% % end

end %function

%%

function fname=fig_name(fdir_fig_var,tag,runid,station,var_str,layer,kylim,elevation,tim_0,tim_f)

if ~isempty(layer)
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_%s-%s_layer_%04d_ylim_%02d',tag,runid,station,var_str,datestr(tim_0,'yyyymmddHHMMSS'),datestr(tim_f,'yyyymmddHHMMSS'),layer,kylim));
else
   if ~isnan(elevation)
      fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_%s-%s_elev_%f_ylim_%02d',tag,runid,station,var_str,datestr(tim_0,'yyyymmddHHMMSS'),datestr(tim_f,'yyyymmddHHMMSS'),elevation,kylim));
   else
      fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_%s-%s_ylim_%02d',tag,runid,station,var_str,datestr(tim_0,'yyyymmddHHMMSS'),datestr(tim_f,'yyyymmddHHMMSS'),kylim));
   end
end

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

function [data_all,layer,unit]=load_data_all(flg_loc,data_all,simdef,gridInfo,stations_loc,var_str,tag,n_sim,k_sta,his_type,elevation,time_dtime,unit,kvar)

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
    
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations_loc,'var',var_str,'layer',layer,'elevation',elevation,'tim',time_dtime{k_sim}(1),'tim2',time_dtime{k_sim}(end),'depth_average',flg_loc.depth_average(kvar));
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
    data_all{k_sim,k_sta}=data;

end %k_sim

end %function

%%

function tim_dtime_p=load_time_all_sim(fid_log,flg_loc,fpath_mat_time,simdef,n_sim)

tim_dtime_p=cell(n_sim,1);

for k_sim=1:n_sim %simulations            

    %time
    [nt(k_sim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef(k_sim),'results_type',flg_loc.results_type); %force his reading. Needed for SMT.
    [tim_dnum_p,tim_dtime_p{k_sim}]=gdm_time_flow_mor(flg_loc,simdef(k_sim),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

end %k_sim

end %function

%% 

function [do_measurements,data_mea]=add_measurements(measurements,stations_loc,elevation,unit)

if ~isempty(measurements)
    if isfolder(measurements) && exist(fullfile(measurements,'data_stations_index.mat'),'file')
        [str_sta,str_found]=RWS_location_clear(stations_loc);
        data_mea=read_data_stations(measurements,'location_clear',str_sta{:},'bemonsteringshoogte',elevation); %location maybe better?
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