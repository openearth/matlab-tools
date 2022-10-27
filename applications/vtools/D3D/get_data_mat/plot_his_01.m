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

%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
fpath_his=simdef(1).file.his;
fpath_map=simdef(1).file.map;
mkdir_check(fdir_fig);

%% STATIONS

stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef(1).D3D.structure);

%% TIME

%we are reading only one time
[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef(1),'results_type','his'); %force his reading. Needed for SMT.
[tim_dnum_p,tim_dtime_p]=gdm_time_flow_mor(flg_loc,simdef(1),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

%% DIMENSIONS

ns=numel(stations);
nvar=numel(flg_loc.var);

%% GRID

%Load here all the grids, which are needed for the layers. 
for kS=1:nS
    gridInfo(kS)=gdm_load_grid_simdef(fid_log,simdef(kS)); %not nice to have to load it every time
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

%ldb
% if isfield(flg_loc,'fpath_ldb')
%     in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
% end

%% LOOP

ks_v=gdm_kt_v(flg_loc,ns);

%loop on variables
for kvar=1:nvar
    
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef(1));
    
    ksc=0;

    %allocate for convergence
    if flg_loc.do_convergence
        data_conv=NaN(ns,nS);
    end
    
    nylim=size(flg_loc.ylims_var{kvar},1);
    fpath_file=cell(ns,nylim);
    
    %loop on stations
    for ks=ks_v
        
        ksc=ksc+1;

        in_p.station=stations{ks};
        data_all=NaN(nt,nS);
        for kS=1:nS
            fdir_mat=simdef(kS).file.mat.dir;
            fpath_his=simdef(kS).file.his;
            
%             gridInfo=gdm_load_grid_simdef(fid_log,simdef(kS)); %not nice to have to load it every time
            layer=gdm_station_layer(flg_loc,gridInfo(kS),fpath_his,stations{ks},var_str); 
            
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var',var_str,'layer',layer);
            load(fpath_mat_tmp,'data');
            if size(data,1)~=size(data_all,1)
                error('Not all simulations have the same output interval.') %
            end
            data_all(:,kS)=data;
        end
        
        %save for convergence
        if flg_loc.do_convergence
            %simplest form, take last two values
%             data_conv(ks,:)=diff(data_all(end-1:end,:),1,1)/seconds(diff(time_dtime(end-1:end)));
            %std of the predifined time
            [data_conv(ks,:),unit_conv,is_std_conv]=check_convergence(flg_loc,data_all,tim_dtime_p,var_str);
        end
        
        in_p.val=data_all;
        in_p.unit=var_str;
        if isfield(flg_loc,'unit')
            if ~isempty(flg_loc.unit{kvar})
                in_p.unit=flg_loc.unit{kvar};
            end
        end
        
        %% measurements
        
        %2DO move to function
        if isfield(flg_loc,'measurements')
            if isfolder(flg_loc.measurements) && exist(fullfile(flg_loc.measurements,'data_stations_index.mat'),'file')
                [str_sta,str_found]=RWS_location_clear(stations{ks});
                data_mea=read_data_stations(flg_loc.measurements,'location_clear',str_sta{:}); %location maybe better?
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

        %% filtered data
        if flg_loc.do_fil  
            in_p.do_fil=1;
            
            [tim_f,data_f]=filter_1D(time_dtime,data_all,'method','godin'); 
            
            in_p.val_f=data_f;
            in_p.tim_f=tim_f;
            
            if in_p.do_measurements                
                [tim_f,data_f]=filter_1D(data_mea.time,data_mea.waarde,'method','godin');
                
                in_p.data_stations_f.time=tim_f;
                in_p.data_stations_f.waarde=data_f;
            end
        end
        
        %% value
        
        fdir_fig_var=fullfile(fdir_fig,var_str);
        mkdir_check(fdir_fig_var,NaN,1,0);
        
        for kylim=1:nylim
            fname_noext=fig_name(fdir_fig_var,tag,simdef(1).file.runid,stations{ks},var_str,layer,kylim);
            fpath_file{ks,kylim}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            
            in_p.ylims=get_ylims(flg_loc.ylims_var{kvar}(kylim,:),in_p.do_measurements,data_all,data_mea);

            fig_his_sal_01(in_p);
        end %kylim
        
    end %ks

    %% convergence
    
    if flg_loc.do_convergence
        
        fname_noext=fig_name_convergence(fdir_fig_var,tag,simdef(1).file.runid,var_str,layer,kylim);
        
        in_p_c.fname=fname_noext;
        in_p_c.data=data_conv;
        in_p_c.stations=stations;
        in_p_c.unit=unit_conv;
        in_p_c.is_std=unit_conv;
        
        fig_his_convergence(in_p_c)
        
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
        ylims_1=[min(data(:)),max(data(:))];
        switch data_mea.eenheid
            case 'mg/l'
                ylims_2=[min(sal2cl(-1,data_mea.waarde)),sal2cl(-1,max(data_mea.waarde))];
            otherwise
                ylims_2=[min(data_mea.waarde),max(data_mea.waarde)];
        end

        ylims=[min(ylims_1(1),ylims_2(1)),max(ylims_1(2),ylims_2(2))];
    else
        ylims=[min(data(:)),max(data(:))];
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

function fname=fig_name(fdir_fig_var,tag,runid,station,var_str,layer,kylim)

if ~isempty(layer)
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_layer_%04d_ylim_%02d',tag,runid,station,var_str,layer,kylim));
else
    fname=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_ylim_%02d',tag,runid,station,var_str,kylim));
end

end %function

%%

function fname=fig_name_convergence(fdir_fig_var,tag,runid,var_str,layer,kylim)

if ~isempty(layer)
    fname=fullfile(fdir_fig_var,sprintf('%s_conv_%s_%s_layer_%04d_ylim_%02d',tag,runid,var_str,layer,kylim));
else
    fname=fullfile(fdir_fig_var,sprintf('%s_conv_%s_%s_ylim_%02d',tag,runid,var_str,kylim));
end

end %function

%%

function [data_conv,unit,is_std]=check_convergence(flg_loc,data_all,time_dtime_p,var_str)

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
        data_conv(ks,:)=diff(data_all(end-1:end,:),1,1)/seconds(diff(time_dtime_p(end-1:end)));
        
        unit=sprintf('%s/t',var_str);
        is_std=0;
    case 2 %std over time
        t0=time_dtime_p(end)-flg_loc.convergence_time;
        bol_tim=time_dtime_p>t0;
        data_conv=std(data_all(bol_tim,:));
        
        unit=var_str;
        is_std=1;
end

            
end