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

function plot_his_xt_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_fil')==0
    flg_loc.do_fil=0;
end
if isfield(flg_loc,'fil_tim')==0
    flg_loc.fil_tim=25*3600;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
fpath_his=simdef.file.his;
mkdir_check(fdir_fig);

%% STATIONS


%% TIME

[~,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his);

%% GRID

if simdef.D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end

%% DIMENSIONS

% ns=numel(stations);
nvar=numel(flg_loc.var);
ntr=numel(flg_loc.stations_track);

%% FIGURE INI

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.tim=time_dtime;
in_p.s_fact=1/1000; 

% fext=ext_of_fig(in_p.fig_print);

%ldb
% if isfield(flg_loc,'fpath_ldb')
%     in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
% end

%% LOOP

for ktr=1:ntr
    flg_loc.stations=flg_loc.stations_track{ktr};
    stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef.D3D.structure);
    
    nclim=size(flg_loc.clims{ktr},1);
    
    %%
    for kvar=1:nvar
        
        varname=flg_loc.var{kvar};
        var_str=D3D_var_num2str_structure(varname,simdef);
        
        %2DO: solve!
%         layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
        layer=1;
        
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'var',var_str,'layer',layer,'station',flg_loc.stations_track_name{ktr});
        
        load(fpath_mat_tmp,'data');
        
        in_p.unit=var_str;
        if isfield(flg_loc,'unit')
            if ~isempty(flg_loc.unit{kvar})
                in_p.unit=flg_loc.unit{kvar};
            end
        end
        
        %% measurements
        
        %2DO move to function
        in_p.do_measurements=0; %it is compulsory for this figure...
      
        if isfield(flg_loc,'measurements')
            fpath_mea=fullfile(fdir_mat,sprintf('%s_mea.mat',tag));

                if isfolder(flg_loc.measurements) && exist(fullfile(flg_loc.measurements,'data_stations_index.mat'),'file')
                    [str_sta,str_found]=RWS_location_clear(stations);
                    %pass o
                    ns=numel(str_sta);
                    clear data_mea %better to preallocate
                    for ks=1:ns
                        aux=read_data_stations(flg_loc.measurements,'location_clear',str_sta{ks}); %location maybe better?
                        if ~isempty(aux) %not nice
                            data_mea(ks)=aux;
                        end
                    end
                    if exist('data_mea','var')==0
                        in_p.do_measurements=0;
                    else
                        in_p.do_measurements=1;
                        in_p.data_stations=data_mea;
                    end
                else
                    error('do reader')
                end
                
                if exist(fpath_mea,'file')==2
                    data_mea_mat=load(fpath_mea,'data');
                else
                    x=sort([data_mea.raai]);
                    [t_m_mea,d_m_mea,val_m_mea]=interpolate_xy_data_stations(data_mea,x,time_dtime(1:2:end));
                    data=v2struct(t_m_mea,d_m_mea,val_m_mea);
                    data_mea_mat.data=data;
                    save_check(fpath_mea,'data')
                end           
            
        end

        %%

        if in_p.do_measurements
            [x,idx_s]=sort([data_mea.raai]);
            [t_m,d_m]=meshgrid(time_dtime,x);
        
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000;
            in_p.val_m=data(:,idx_s)';
       
            in_p.t_m_mea=data_mea_mat.data.t_m_mea;
            in_p.d_m_mea=data_mea_mat.data.d_m_mea.*1000;
            in_p.val_m_mea=data_mea_mat.data.val_m_mea;
        else
            [t_m,d_m]=meshgrid(time_dtime,flg_loc.s{ktr});
            
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000;
            in_p.val_m=data';
        end
        

        %% filtered data
        if flg_loc.do_fil(ktr) 
            in_p.do_fil=1;
            
            [tim_f,data_f]=filter_1D(time_dtime,data,'method','godin');
            
            in_p.val_m=data_f';
            
            [t_m,d_m]=meshgrid(tim_f,flg_loc.s{ktr});
            in_p.t_m=t_m;
            in_p.d_m=d_m.*1000;
            
            if in_p.do_measurements                
                [tim_f,data_f]=filter_1D(data_mea.time,data_mea.waarde,'method','godin');
                error('do right data type')
%                 in_p.data_stations_f.time=tim_f;
%                 in_p.data_stations_f.waarde=data_f;
            end
        end
        
        %% value
        
        fdir_fig_var=fullfile(fdir_fig,var_str);
        mkdir_check(fdir_fig_var,NaN,1,0);
        
        for kylim=1:nclim
            fname_noext=fullfile(fdir_fig_var,sprintf('%s_%s_%s_%s_layer_%04d_ylim_%02d',tag,simdef.file.runid,var_str,flg_loc.stations_track_name{ktr},layer,kylim));

            in_p.fname=fname_noext;
            
%             in_p.ylims=get_ylims(flg_loc.ylims(kylim,:),in_p.do_measurements,data,data_mea);
            in_p.clims=flg_loc.clims{ktr}(kylim,:);
            in_p.lim_t=[min(time_dtime),max(time_dtime)];
            
            fig_his_xt_01(in_p);
        end %kylim
        
    end %kvar

end %ktr

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

end %function