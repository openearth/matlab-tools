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

function plot_1D_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_xvt')==0
    flg_loc.do_xvt=0;
end

%% PATHS

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig); %we create it in the loop
runid=simdef(1).file.runid;

%% LOAD

% create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

if flg_loc.tim_type==1
    tim_dnum_p=time_dnum;
    tim_dtime_p=time_dtime;
elseif flg_loc.tim_type==2
    tim_dnum_p=time_mor_dnum;
    tim_dtime_p=time_mor_dtime;
end
                
%% DIMENSION

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nrkmv=numel(flg_loc.rkm_name);
nsb=numel(flg_loc.sb_pol);
ndiff=gdm_ndiff(flg_loc);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.fig_size=[0,0,14.5,12];

% fext=ext_of_fig(in_p.fig_print);

if nS>1
    in_p.leg_str=flg_loc.leg_str;
end

%% LOOP
for ksb=1:nsb

    %summerbed
    fpath_sb_pol=flg_loc.sb_pol{ksb};
    [~,sb_pol,~]=fileparts(fpath_sb_pol);

    for krkmv=1:nrkmv %rkm polygons

        pol_name=flg_loc.rkm_name{krkmv};
        rkmv=gdm_load_rkm_polygons(fid_log,tag,fdir_mat,'','','','',pol_name);

        in_p.s=rkmv.rkm_cen;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;

        kt_v=gdm_kt_v(flg_loc,nt); %time index vector
%         fpath_file=cell(nt,1); %movie

        for kvar=1:nvar %variable
            
            
            [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));
            
            if isfield(flg_loc,'unit') && ~isempty(flg_loc.unit{kvar})
                lab_str=flg_loc.unit{kvar};
            else
                lab_str=var_str_save;
            end
            in_p.lab_str=lab_str;
            
            %time 0
            kt=1;
                %model
            for kS=1:nS    
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                load(fpath_mat_tmp,'data');            
                data_0_loc(kS)=data;
            end
            data_0=data_0_loc;
            
            %skip if multidimentional
            fn_data=fieldnames(data_0(1));
            if size(data_0(1).(fn_data{1}),2)>1
                messageOut(fid_log,sprintf('Skipping variable with multiple dimensions: %s',var_str_save));
                continue
            end
                
            ktc=0;
            for kt=kt_v %time
                ktc=ktc+1;
                
                in_p.tim=tim_dnum_p(kt);

                %% load
                for kS=1:nS
                    fdir_mat=simdef(kS).file.mat.dir;
                    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'pol',pol_name,'var',var_str_save,'sb',sb_pol);
                    load(fpath_mat_tmp,'data');
                    data_loc(kS)=data;
                end
                data=data_loc;
                
                fn_data=fieldnames(data(1));
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

                    switch statis
                        case 'val_std'
                            in_p.is_std=true;
                        otherwise
                            in_p.is_std=false;
                    end
                    
                    %allocate
                    if flg_loc.do_xvt
                        nx=numel(data.(statis));  
%                         data_xvt.(statis)=NaN(nx,nS,nt); %we cannot preallocate here! time is outside
                        data_xvt0.(statis)=NaN(nx,nS);
                    end
                    
                    for kdiff=1:ndiff
                        
                        %measurements                        
                        in_p.plot_mea=false;
                        if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
                            tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(kt),time_mor_dnum(kt));
                            data_mea=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                            if isstruct(data_mea) %there is data
                                in_p.plot_mea=true;
                                in_p.s_mea=data_mea.x;
                                if kdiff==1
                                    in_p.val_mea=data_mea.y;
                                elseif kdiff==2
                                    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum(1),time_mor_dnum(1));
                                    data_mea_0=gdm_load_measurements(fid_log,flg_loc.measurements{ksb,1},'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
                                    in_p.val_mea=data_mea.y-data_mea_0.y;
                                    %we are assuming <s_mea> is the same
                                end
                            end
                        end
                        
                        %2DO: loop on ylims and use <dgm_data_diff>
                        if kdiff==1
                            in_p.val=[data.(statis)];
                            in_p.is_diff=0;
                            str_dir='val';
                        elseif kdiff==2
                            in_p.val=[data.(statis)]-[data_0.(statis)];
                            in_p.is_diff=1;
                            str_dir='diff';
                        end
                        
                        fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,str_dir);
                        mkdir_check(fdir_fig_loc,fid_log,1,0);

                        fname_noext=fig_name(fdir_fig_loc,tag,runid,time_dnum(kt),var_str_save,statis,sb_pol,kdiff);
%                         fpath_file{kt}=sprintf('%s%s',fname_noext,fext); %for movie 
                        
                        in_p.fname=fname_noext;
                        
                        fig_1D_01(in_p);
                        
                        %save for xvt
                        if flg_loc.do_xvt
                            data_xvt.(statis)(:,:,kt)=[data.(statis)];
                            data_xvt0.(statis)(:,:,kt)=[data_0.(statis)];
                        end
                    end %kref
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
            plot_xvt(fid_log,flg_loc,rkmv.rkm_cen,tim_dtime_p,lab_str,data_xvt,data_xvt0,fdir_fig,sb_pol,pol_name,var_str_save,tag,runid);
            
        end %kvar    
    end %nrkmv
end %ksb

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,var_str,fn,sb_pol,kref)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_%02d',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),var_str,fn,sb_pol,kref));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function

%%

function fpath_fig=fig_name_xvt(fdir_fig,tag,runid,var_str,fn,sb_pol,kref,kclim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_allt_%s_%s_%s_%02d_clim_%02d',tag,runid,var_str,fn,sb_pol,kref,kclim));

end %function

%%

function plot_xvt(fid_log,flg_loc,s,tim_dtime_p,lab_str,data_xvt,data_xvt0,fdir_fig,sb_pol,pol_name,var_str_save,tag,runid)

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

[x_m,y_m]=meshgrid(s,tim_dtime_p);

in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.fig_size=[0,0,14.5,12];

in_p.x_m=x_m;
in_p.y_m=y_m;
in_p.ml=2.5;
in_p.clab_str=lab_str;
in_p.ylab_str='';
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;
%                 in_p.tit_str=branch_name;
for kfn=1:nfn
    statis=fn_data{kfn};

    %skip statistics not in list    
    if isfield(flg_loc,'statis_plot')
        if ismember(statis,flg_loc.statis_plot)==0
            continue
        end
    end

    switch statis
        case 'val_std'
            in_p.is_std=true;
        otherwise
            in_p.is_std=false;
    end
    for kdiff=1:ndiff
%         switch kdiff
%             case 1
%                 in_p.val=squeeze(data_xvt.(statis))';
%                 in_p.is_diff=0;
%                 str_dir='val';
%             case 2
%                 in_p.val=squeeze(data_xvt.(statis)-data_xvt0.(statis))';
%                 in_p.is_diff=1;
%                 str_dir='diff';
%         end
        for kclim=1:nclim
            [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,squeeze(data_xvt.(statis))',squeeze(data_xvt0.(statis))','ylims','ylims_diff',var_str_save);
            
    %                         fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,'xvt',str_dir); %subfolder maybe not needed
            fdir_fig_loc=fullfile(fdir_fig,sb_pol,pol_name,var_str_save,statis,tag_ref);
            fname_noext=fig_name_xvt(fdir_fig_loc,tag,runid,var_str_save,statis,sb_pol,kdiff,kclim);

            in_p.fname=fname_noext;
            fig_surf(in_p)
        end %kclim
    end %kdiff
end %kfn
            
end %function