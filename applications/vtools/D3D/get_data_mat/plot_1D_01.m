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

function plot_1D_01(fid_log,flg_loc,simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'simdef_ref','');

parse(parin,varargin{:});

simdef_ref=parin.Results.simdef_ref;

do_ref=false;
if ~isempty(simdef_ref)
    do_ref=true;
end

%%

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

%this we have to remove. We make a flag because we pass everything <simdef> as structure and <simdef_ref>
if do_ref
    if contains(tag_fig,'all')
        tag_do='do_s_all';
    else
        tag_do='do_s';
    end
    ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end
else
    ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end
end

%% PARSE

if isfield(flg_loc,'do_p')==0
    flg_loc.do_p=1;
end

if isfield(flg_loc,'do_all')==0
    flg_loc.do_all=1;
end

if isfield(flg_loc,'do_xvt')==0
    flg_loc.do_xvt=0;
end

if isfield(flg_loc,'do_plot_structures')==0
    flg_loc.do_plot_structures=0;
end

flg_loc=isfield_default(flg_loc,'tol_time_measurements',1);

flg_loc=gdm_parse_summerbed(flg_loc,simdef(1));

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_var');

%add B_mor variables to plot
flg_loc=check_B(fid_log,flg_loc,simdef(1),'B_mor');
flg_loc=check_B(fid_log,flg_loc,simdef(1),'B');

do_legend_adhoc=0;
if isfield(flg_loc,'legend_file')
    legend_adhoc=readcell(flg_loc.legend_file,'delimiter','|||'); %I assume nobody will use ||| in the legend. 
    do_legend_adhoc=1;
end

%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

if do_ref
    fdir_mat_ref=simdef_ref.file.mat.dir;
    fpath_mat_ref=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
    fpath_mat_time_ref=strrep(fpath_mat_ref,'.mat','_tim.mat'); 
    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
else
    fdir_mat=simdef(1).file.mat.dir;
    fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
    fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
    runid=simdef(1).file.runid;
    fpath_mat_time_ref=strrep(fpath_mat,'.mat','_tim.mat'); 
end

fpath_map=simdef(1).file.map; %assuming same number of layers for all simulations!

%% LOAD

% create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_mat_time_ref,'tim');
v2struct(tim); %time_dnum, time_dtime

[tim_dnum_p,tim_dtime_p]=gdm_time_flow_mor(flg_loc,simdef(1),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

%% DIMENSION

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);
ndiff=gdm_ndiff(flg_loc);

%% GRID

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% FIGURE

in_p=flg_loc;

% fext=ext_of_fig(in_p.fig_print);

if nS>1
    in_p.leg_str=flg_loc.leg_str;
end

%% COMMON

if flg_loc.do_plot_structures
    all_struct=D3D_read_structures(simdef(1),'fpath_rkm',flg_loc.fpath_rkm); %check that either it is fine if empty or check emptyness for filling <in_p>
    if ~isempty(all_struct)
        in_p.all_struct=all_struct;
    end
else
    all_struct=struct('name',[],'xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);
    sb_def=gdm_read_summerbed(flg_loc,fid_log,fdir_mat,fpath_sb_pol,fpath_map);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;

        kt_v=gdm_kt_v(flg_loc,nt); %time index vector
%         fpath_file=cell(nt,1); %movie

        fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,'inpol');
        plot_summerbed_inpolygon(flg_loc,fdir_fig_loc,rkmv,sb_def,gridInfo);

        for kvar=1:nvar %variable
            
            in_p.frac=flg_loc.var_idx{kvar};
            in_p.do_area=flg_loc.do_area(kvar);

            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
            
            layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str_read,kvar,flg_loc.var{kvar}); 
                       
            %ylims
            flg_loc.ylims=flg_loc.ylims_var{kvar,1};
            flg_loc.ylims_diff=flg_loc.ylims_diff_var{kvar,1};
            nylim=size(flg_loc.ylims,1);
            
            %time 0
            kt=1;
                %model
            clear data_0_loc; %clear is not nice but we cannot preallocate because we do not know the fieldnames in advance and they maybe different between variables    
            for kS=1:nS    
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_save,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,flg_loc.var_idx{kvar},layer);
%                 fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'layer',layer,'flg_loc.var_idx',flg_loc.var_idx{kvar});
                
                load(fpath_mat_tmp,'data');            
                data_0_loc(kS)=data;
            end
            data_0=data_0_loc;

            %skip if multidimentional
            fn_data=fieldnames(data_0(1));
            sval=size(data_0(1).(fn_data{1}));
            multi_dim=false;
            if sval(2)>1 || numel(sval(2:end))>1
                multi_dim=true;
%                 messageOut(fid_log,sprintf('Skipping variable with multiple dimensions: %s',var_str_save));
%                 continue
            end
            
            %reference
            if do_ref
                fdir_mat=simdef_ref.file.mat.dir;
                fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_save,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,flg_loc.var_idx{kvar},layer);
%                 fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'layer',layer,'flg_loc.var_idx',flg_loc.var_idx{kvar});
                load(fpath_mat_tmp,'data');            
                data_0_ref=data;
            end
            
            %allocate
%             if flg_loc.do_xvt && ~multi_dim
            if flg_loc.do_xvt 
%                 nx=numel(data_0(1).(fn_data{1}));  
                [nx,nD]=size(data_0(1).(fn_data{1}));
                nfn=numel(fn_data);
                for kfn=1:nfn
                    statis=fn_data{kfn};
                    
                    data_xvt.(statis)=NaN(nx,nS,nt,nD);
                    data_xvt0.(statis)=NaN(nx,nS,nt,nD);
                end
            end
            
            ktc=0;
            for kt=kt_v %time
                ktc=ktc+1;
                
                in_p.tim=tim_dnum_p(kt);
                if isnan(in_p.tim)
                    error('Something is not going fine here.')
                end

                %% load
                clear data_load; 
                for kS=1:nS
                    fdir_mat=simdef(kS).file.mat.dir;
                    fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_save,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,flg_loc.var_idx{kvar},layer);
%                     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'layer',layer,'flg_loc.var_idx',flg_loc.var_idx{kvar});
                    load(fpath_mat_tmp,'data');
                    data_load(kS)=data;
                end
                data_sim=data_load;
                
                %reference
                if do_ref
                    fdir_mat=simdef_ref.file.mat.dir;
                    fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_save,fdir_mat,tag,pol_name,time_dnum(kt),sb_pol,flg_loc.var_idx{kvar},layer);
%                     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol,'layer',layer,'flg_loc.var_idx',flg_loc.var_idx{kvar});
                    load(fpath_mat_tmp,'data');            
                    data_ref=data;
                end
                
                fn_data=fieldnames(data_sim(1));
                nfn=numel(fn_data);
                
                in_p.xlims=flg_loc.xlims;

                for kfn=1:nfn
                    statis=fn_data{kfn};
                    
                    %skip statistics not in list    
                    if isfield(flg_loc,'statis_plot')
                        if ismember(statis,flg_loc.statis_plot)==0
                            continue
                        end
                    end
                    
                    %units (cannot be outside <fn> loop because it can be overwritten)
                    if isfield(flg_loc,'unit') && ~isempty(flg_loc.unit{kvar})
                        lab_str=flg_loc.unit{kvar};
                    else
                        lab_str=var_str_save;
                    end
                    in_p.lab_str=lab_str;
                    
                    switch statis
                        case 'val_std'
                            in_p.is_std=true;
                        case 'val_sum_length'
                            in_p.lab_str=sprintf('%s/B',in_p.lab_str);
                        otherwise
                            in_p.is_std=false;
                    end
                    
                    for kdiff=1:ndiff
                        
                        %measurements                        
                        in_p.plot_mea=false;
                        if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
                            tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                            data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis,'tol',flg_loc.tol_time_measurements);
                            if isstruct(data_mea) %there is data
                                in_p.plot_mea=true;
                                in_p.s_mea=data_mea.x;
                                if kdiff==1
                                    in_p.val_mea=data_mea.y;
                                elseif kdiff==2
                                    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
                                    data_mea_0=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis,'tol',flg_loc.tol_time_measurements);
                                    in_p.val_mea=data_mea.y-data_mea_0.y;
                                    %we are assuming <s_mea> is the same
                                end
                            end
                        end
                        
                        for kylim=1:nylim
                            
                            %regular plot
                            if flg_loc.do_p
                                for ks=1:nS 
                                    bol_ks=false(nS,1);
                                    bol_ks(ks)=true;
                                    
                                    %2DO Adjust the call such that always <simdef> is a structure
                                    [in_p,str_dir]=gdm_data_diff(in_p,flg_loc,kdiff,kylim,[data_sim(bol_ks).(statis)],[data_0(bol_ks).(statis)],'ylims','ylims_diff',var_str_save);

                                    tag_fig=flg_loc.tag;
                                    fdir_fig=fullfile(simdef(bol_ks).file.fig.dir,tag_fig,tag_serie); 
                                    runid=simdef(bol_ks).file.runid;

                                    fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                                    fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,flg_loc.var_idx{kvar},kylim);
            %                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                                    in_p.fname=fname_noext;

                                    if do_legend_adhoc
                                        in_p.leg_str=legend_adhoc{kt,1};
                                        in_p.do_leg=1;
                                    end

                                    fig_1D_01(in_p);
                                end %ks
                            end %do_p
                            
                            %plot all simulations together
                            if flg_loc.do_all && nS>1
                                bol_ks=true(nS,1);

                                [in_p,str_dir]=gdm_data_diff(in_p,flg_loc,kdiff,kylim,[data_sim(bol_ks).(statis)],[data_0(bol_ks).(statis)],'ylims','ylims_diff',var_str_save);

                                tag_fig=sprintf('%s_%s',flg_loc.tag,'all');
                                fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie); 
                                runid='';

                                fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                                mkdir_check(fdir_fig_loc,fid_log,1,0);

                                fname_noext=fig_name(fdir_fig_loc,tag_fig,runid,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,flg_loc.var_idx{kvar},kylim);
        %                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                                in_p.fname=fname_noext;

                                fig_1D_01(in_p);
                            end
                            
                            %difference with reference
                            if do_ref
                                in_p.plot_mea=false; %when plotting difference between simulations, the measurements make no sense
                                
                                for kS=1:nS
                                    %2DO: make function
                                    [in_p,str_dir]=gdm_data_diff(in_p,flg_loc,kdiff,kylim,[data_sim(kS).(statis)]-data_ref.(statis),([data_sim(kS).(statis)]-data_ref.(statis))-([data_0(kS).(statis)]-data_0_ref.(statis)),'ylims','ylims_diff',var_str_save);
                                    in_p.is_diff=1; %overwrite because it is difference between simulations
                                    
                                    tag_fig=sprintf('%s_%s',flg_loc.tag,'diff'); 
                                    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie);
                                    runid_fig=sprintf('%s-%s',simdef(kS).file.runid,simdef_ref.file.runid);
                                    
                                    fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                                    fname_noext=fig_name(fdir_fig_loc,tag_fig,runid_fig,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,flg_loc.var_idx{kvar},kylim);
            %                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                                    in_p.fname=fname_noext;

                                    fig_1D_01(in_p);
                                end
                                
                                %all together
                                if nS>1
                                    %call with function as above
                                    [in_p,str_dir]=gdm_data_diff(in_p,flg_loc,kdiff,kylim,[data_sim.(statis)]-data_ref.(statis),([data_sim.(statis)]-data_ref.(statis))-([data_0.(statis)]-data_0_ref.(statis)),'ylims','ylims_diff',var_str_save);
                                    in_p.is_diff=1; %overwrite because it is difference between simulations
                                    
                                    tag_fig=sprintf('%s_%s',flg_loc.tag,'diff'); 
                                    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
                                    runid_fig=sprintf('ref_%s',simdef_ref.file.runid);
                                    
                                    fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                                    fname_noext=fig_name(fdir_fig_loc,tag_fig,runid_fig,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,flg_loc.var_idx{kvar},kylim);
            %                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 

                                    in_p.fname=fname_noext;

                                    fig_1D_01(in_p);
                                end %nS
                            end %do_ref
                        end %kylim
                    end %kref
                    
                    %save for xvt
%                     if flg_loc.do_xvt && ~multi_dim
                    if flg_loc.do_xvt
                        %<data_sim> has simulation in the structure.
                        %<data_xvt> has simulation in the second column. 
                        data_xvt.(statis)(:,:,kt,:)=[data_sim.(statis)];
                        data_xvt0.(statis)(:,:,kt,:)=[data_0.(statis)];
                    end

                    messageOut(fid_log,sprintf('Done plotting figure %s rkm poly %4.2f %% time %4.2f %% variable %4.2f %% statistic %4.2f %%',tag,krkmv/nrkmv*100,ktc/nt*100,kvar/nvar*100,kfn/nfn*100));
                end %kfn

                %BEGIN DEBUG

                %END DEBUG

                %% movie

%                 if isfield(flg_loc,'do_movie')==0
%                     flg_loc.do_movie=1;
%                 end
% 
%                 if flg_loc.do_movie
%                     dt_aux=diff(time_dnum);
%                     dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
%                     rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
%                     make_video(fpath_file,'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
%                 end


            end %kt
            
            %% xvt
            if flg_loc.do_xvt && ~multi_dim
               plot_xvt(fid_log,flg_loc,rkmv.rkm_cen,tim_dtime_p,lab_str,data_xvt,data_xvt0,simdef,sb_pol,pol_name,var_str_save,tag,runid,all_struct,tag_fig,tag_serie,flg_loc.var_idx{kvar})
            end
            
            %% cumulative
            if flg_loc.do_cum(kvar)
                %2DO: make function
                
                statis='val_mean';
                diff_tim=seconds(diff(tim_dtime_p));
                val_tim=data_xvt.(statis)(:,:,1:end-1,:).*repmat(reshape(diff_tim,1,1,[]),nx,nS,1,nD); %we do not use the last value. Block approach with variables 1:end-1 with time 1:end
                val_cum=cumsum(cat(3,zeros(nx,nS,1,nD),val_tim),3);

                in_p.lab_str=sprintf('%s_t',lab_str); %add time

                for kt=kt_v
                    in_p.tim=tim_dnum_p(kt);
                    in_p.val=squeeze(val_cum(:,:,kt,:));

                    fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,'cum');
                    mkdir_check(fdir_fig_loc,fid_log,1,0);

                    for kylim=1:nylim
                        fname_noext=fig_name(fdir_fig_loc,sprintf('%s_cum',tag),runid,time_dnum(kt),var_str_save,statis,sb_pol,kdiff,flg_loc.var_idx{kvar},kylim);
    
                        in_p.fname=fname_noext;
                        in_p.ylim=flg_loc.ylims(kylim,:);
    
                        fig_1D_01(in_p);
                    end
                end
            end
            
        end %kvar    
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,fn,sb_pol,kref,var_idx,kylim)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
nvi=numel(var_idx);
svi=repmat('%02d',1,nvi);
var_idx_s=sprintf(svi,var_idx);

if isempty(runid)
    fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%02d_ylim_%02d',tag,datestr(time_dnum,'yyyymmddHHMM'),var_str,var_idx_s,fn,sb_pol,kref,kylim));
else
    fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%s_%02d_ylim_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,var_idx_s,fn,sb_pol,kref,kylim));
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

function plot_xvt(fid_log,flg_loc,s,tim_dtime_p,lab_str,data_xvt,data_xvt0,simdef,sb_pol,pol_name,var_str_save,tag,runid,all_struct,tag_fig,tag_serie,var_idx)

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
nclim=size(flg_loc.ylims,1);
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
in_p.clab_str=lab_str;
in_p.ylab_str='';
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;
in_p.frac=var_idx;
%                 in_p.tit_str=branch_name;

for kS=1:nS

    fdir_fig=fullfile(simdef(kS).file.fig.dir,tag_fig,tag_serie); 
    
    for kfn=1:nfn
        statis=fn_data{kfn};

        %skip statistics not in list    
        if isfield(flg_loc,'statis_plot')
            if ismember(statis,flg_loc.statis_plot)==0
                continue
            end
        end

        %skip if multidimensional    
    %     if size(data_xvt.(statis),3)>1; continue; end %NO! in third dimension it is time

        val_1=squeeze(data_xvt.(statis)(:,kS,:))';
        val_0=squeeze(data_xvt0.(statis)(:,kS,:))';

        switch statis
            case 'val_std'
                in_p.is_std=true;
            otherwise
                in_p.is_std=false;
        end
        for kdiff=1:ndiff
            for kclim=1:nclim

                [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,val_1,val_0,'ylims','ylims_diff',var_str_save);
                in_p.clims=in_p.ylims; %the output from `gdm_data_diff` is saved in the variable we call first (`ylims`) and we want it here for `clims`.
                in_p.ylims=NaN;
        %                         fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,'xvt',str_dir); %subfolder maybe not needed
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

function flg_loc=check_B(fid_log,flg_loc,simdef,str_in)

flg_loc.var=reshape(flg_loc.var,1,numel(flg_loc.var));
flg_loc.do_cum=reshape(flg_loc.do_cum,1,numel(flg_loc.do_cum));
flg_loc.unit=reshape(flg_loc.unit,1,numel(flg_loc.unit));

str_do=sprintf('do_val_%s',str_in);
if isfield(flg_loc,str_do)==0
    flg_loc.(str_do)=zeros(size(flg_loc.var));
end
nvar_tmp=numel(flg_loc.var);
for kvar=1:nvar_tmp
    if flg_loc.(str_do)(kvar)
        [~,~,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef);
        flg_loc.var=cat(2,flg_loc.var,sprintf('%s_%s',var_str_save,str_in));
        flg_loc.ylims_var=cat(1,flg_loc.ylims_var,flg_loc.ylims_var{kvar,1});
        flg_loc.ylims_diff_var=cat(1,flg_loc.ylims_diff_var,flg_loc.ylims_diff_var{kvar,1});

        %add one more entry with default values
        flg_loc=gdm_add_flags_plot(flg_loc);

        %modify last entry
        flg_loc.unit{end}=sprintf('%s_%s',flg_loc.unit{kvar},str_in);
        flg_loc.var_idx{end}=flg_loc.var_idx{kvar};
        flg_loc.do_area(end)=flg_loc.do_area(kvar);
        flg_loc.do_cum(end)=flg_loc.do_cum(kvar);
    end
end

end %function

%%

function plot_summerbed_inpolygon(flg_loc,fdir_fig_loc,rkmv,sb_def,gridInfo)

%% PARSE

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
        
        in_p.xlims=flg_loc.rkm_file{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
        in_p.ylims=flg_loc.rkm_file{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];

        in_p.fname=fullfile(fdir_fig_loc,sprintf('inpoly_%02d',krkm));

        fig_map_sal_01(in_p);
    end %krkm
end %do

end %function