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
%THIS NEEDS A THOROUGH REFACTORING
%   -there is no loop over kylim for 1D plot.
%   -loop on `kdiff` needs to be removed to clarify.

function plot_map_1D_xv_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% PARSE

is_straigth=0;
if isfield(flg_loc,'fpath_map_curved')
    is_straigth=1;
end

do_rkm=0;
if isfield(flg_loc,'fpath_rkm')
    do_rkm=1;
end

flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_all_sim',0);
flg_loc=isfield_default(flg_loc,'do_xtv',0);
flg_loc=isfield_default(flg_loc,'do_xtv_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_xtv_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_xvallt',0);
flg_loc=isfield_default(flg_loc,'plot_val0',0);
flg_loc=isfield_default(flg_loc,'p_single_function_handles',{});

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var');
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'xlims_var');
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_s_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_t_var'); 


flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'fig_print',1);
flg_loc=isfield_default(flg_loc,'str_time','yyyymmddHHMM');


%% PATHS REFERENCE

kref=flg_loc.sim_ref;
nsim=numel(simdef);
fdir_mat=simdef(kref).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef(kref).file.fig.dir,tag_fig,tag_serie);
% mkdir_check(fdir_fig); %we create it in the loop
% runid=simdef(kref).file.runid;

fpath_map=gdm_fpathmap(simdef(kref),0);

%take coordinates from curved domain (in case the domain is straightened)
fpath_map_grd=fpath_map; 
if is_straigth
    fpath_map_grd=flg_loc.fpath_map_curved;
end

%% LOAD REFERENCE

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map_grd,'dim',1);
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%We are assuming we can loop all with the same time!
[time_dnum_v,time_dtime_v]=gdm_time_flow_mor(flg_loc,simdef(kref),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

%% DIMENSION

nt=size(time_dnum,1);
nvar=numel(flg_loc.var);
nbr=numel(flg_loc.branch);

%figures
in_p=flg_loc;
in_p.fig_visible=0;
in_p.fig_size=[0,0,14.5,12];

% fext=ext_of_fig(in_p.fig_print);

%% LOOP
for kbr=1:nbr %branches
    
    branch=flg_loc.branch{kbr};
    branch_name=flg_loc.branch_name{kbr};

    gridInfo_br=gdm_load_grid_branch(fid_log,flg_loc,fdir_mat,gridInfo,branch,branch_name);
    nx=numel(gridInfo_br.offset);    
    
    if do_rkm
        in_p.s=gridInfo_br.rkm;
        in_p.xlab_str='rkm';
        in_p.xlab_un=1/1000;
    else
        in_p.s=gridInfo_br.offset;
        in_p.xlab_str='dist';
        in_p.xlab_un=1;
    end

    kt_v=gdm_kt_v(flg_loc,nt); %time index vector
%         fpath_file=cell(nt,1); %movie

    for kvar=1:nvar %variable
    
        %ylims
        xlims=flg_loc.xlims_var{kvar,1};
        lims=flg_loc.ylims_var{kvar,1};
        lims_diff_t=flg_loc.ylims_diff_t_var{kvar,1};
        lims_diff_s=flg_loc.ylims_diff_s_var{kvar,1};
        
        [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(flg_loc.var{kvar},simdef(1));

        %% time 0

        kt=1;

            %% model
        data_0=NaN(nx,nsim);    
        for ksim=1:nsim    
            fdir_mat=simdef(ksim).file.mat.dir;
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
            load(fpath_mat_tmp,'data');            
            data_0(:,ksim)=data;
        end

            %% measurements
        [~,data_mea_0]=add_measurement(flg_loc,fid_log,time_dnum(kt),time_mor_dnum(kt),var_str_save);
        
        %% LOOP TIME

        ktc=0;
        data_T=NaN(nx,nsim,nt);
        for kt=kt_v %time
            ktc=ktc+1;

            %% load simulations
            %It is 1D, I suppose it is not a huge amount of data.

            for ksim=1:nsim
                fdir_mat=simdef(ksim).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str_read,'branch',branch_name);
                if exist(fpath_mat_tmp,'file')==2
                    load(fpath_mat_tmp,'data');
                    data_T(:,ksim,kt)=data;
                else %for the reference time there is no time in this simulation (crashed?)
                    messageOut(fid_log,sprintf('No data for comparison: %s',fpath_mat_tmp));
                end
            end
            
            %skip regular plot (needs to be here to load the data for xtv plot)
            if ~flg_loc.do_p
                continue
            end
            
            in_p.tim=time_dnum_v(kt);
            in_p.lab_str=var_str_save;
            in_p.xlims=flg_loc.xlims_var{kvar};

            %% measurements

            [do_measurements,data_mea]=add_measurement(flg_loc,fid_log,time_dnum(kt),time_mor_dnum(kt),var_str_save);

            %% regular plot
            if flg_loc.do_p_single    

                lims_loc=lims;

                for ksim=1:nsim
                    tag_ref='val';
                    in_p.val=data_T(:,ksim,kt);
                    in_p.is_diff=0;
                    in_p.val0=data_0(:,ksim);
                    if do_measurements
                        in_p.plot_mea=true;
                        in_p.val_mea=data_mea.y;
                        in_p.s_mea=data_mea.x;
                    end
                    if isfield(in_p,'leg_str')
                        in_p=rmfield(in_p,'leg_str');
                    end
                    in_p.function_handles=flg_loc.p_single_function_handles;
    
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    runid=simdef(ksim).file.runid;
    
                    fcn_plot(in_p,flg_loc,fid_log,fdir_fig,branch_name,var_str_save,tag_ref,tag,runid,time_dnum(kt),lims_loc,xlims)
                end %ksim

            end

            %% difference with initial time
            if flg_loc.do_diff_t

                lims_loc=lims_diff_t;

                for ksim=1:nsim
                    tag_ref='diff_t';
                    in_p.val=data_T(:,:,kt)-data_T(:,:,1);
                    in_p.is_diff=1;
                    in_p.val0=zeros(size(in_p.val));
                    if do_measurements
                        in_p.plot_mea=true;
                        in_p.val_mea=data_mea.y-data_mea_0.y;
                        in_p.s_mea=data_mea.x;
                    end
                    if isfield(in_p,'leg_str')
                        in_p=rmfield(in_p,'leg_str');
                    end
    
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    runid=simdef(ksim).file.runid;
    
                    fcn_plot(in_p,flg_loc,fid_log,fdir_fig,branch_name,var_str_save,tag_ref,tag,runid,time_dnum(kt),lims_loc,xlims)
                end %ksim

            end

            %% difference with reference
            if flg_loc.do_diff_s && ksim~=kref

                lims_loc=lims_diff_s;

                for ksim=1:nsim
                    tag_ref='diff_s';
                    in_p.val=data_T(:,ksim,kt)-data_T(:,kref,kt);
                    in_p.is_diff=1;
                    in_p.val0=data_T(:,ksim,1)-data_T(:,kref,1);
                    if do_measurements
                        in_p.plot_mea=false;
                        % in_p.val_mea=data_mea.y;
                        % in_p.s_mea=data_mea.x;
                    end
                    if isfield(in_p,'leg_str')
                        in_p=rmfield(in_p,'leg_str');
                    end
    
                    fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                    runid=simdef(ksim).file.runid;
    
                    fcn_plot(in_p,flg_loc,fid_log,fdir_fig,branch_name,var_str_save,tag_ref,tag,runid,time_dnum(kt),lims_loc,xlims)
                end %ksim

            end

            %% all simulation together
            if flg_loc.do_all_sim
                lims_loc=lims;

                tag_ref='val';
                in_p.val=data_T(:,:,kt);
                in_p.is_diff=0;
                in_p.val0=data_0;
                if do_measurements
                    in_p.plot_mea=true;
                    in_p.val_mea=data_mea.y;
                    in_p.s_mea=data_mea.x;
                end
                in_p.leg_str=flg_loc.leg_str;

                fdir_fig=fullfile(simdef(1).file.fig.dir,sprintf('%s_all',tag_fig),tag_serie);
                runid=simdef(1).file.runid;
                
                fcn_plot(in_p,flg_loc,fid_log,fdir_fig,branch_name,var_str_save,tag_ref,tag,runid,time_dnum(kt),lims_loc,xlims)
            end

            %%

            messageOut(fid_log,sprintf('Done plotting figure %s time %4.2f %% variable %4.2f %%',tag,ktc/nt*100,kvar/nvar*100));


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
        
        %% all times in same figure xtv
        
        if (flg_loc.do_xtv || flg_loc.do_xtv_diff_t) && nt>1
            str_dir='xtv';
            
            [x_m,y_m]=meshgrid(in_p.s,time_dtime_v);
            in_p.x_m=x_m;
            in_p.y_m=y_m;
            in_p.clab_str=var_str_save;
            in_p.ylab_str='';
            in_p.tit_str=branch_name;

            for ksim=1:nsim

                fdir_fig=fullfile(simdef(ksim).file.fig.dir,tag_fig,tag_serie);
                fdir_fig_loc=fullfile(fdir_fig,branch_name,var_str_save,str_dir);
                mkdir_check(fdir_fig_loc,fid_log,1,0);
                runid=simdef(ksim).file.runid;

                %% regular
                if flg_loc.do_xtv
                    tag_ref='val';
                    in_p.val=squeeze(data_T(:,ksim,:))';
                    in_p=reset_is(in_p);
                    in_p.is_diff=0;

                    fcn_plot_xvt(in_p,tag_ref,lims,xlims,fdir_fig_loc,tag,runid,var_str_save,branch_name);
                end
                    
                %% difference time
                if flg_loc.do_xtv_diff_t
                    tag_ref='diff_t';
                    in_p.val=squeeze(data_T(:,ksim,:)-data_T(:,ksim,1))';
                    in_p=reset_is(in_p);
                    in_p.is_diff_t=1;

                    fcn_plot_xvt(in_p,tag_ref,lims,xlims,fdir_fig_loc,tag,runid,var_str_save,branch_name);
                end

                %% difference with reference
                if flg_loc.do_xtv_diff_s && ksim~=kref
                    tag_ref='diff_s';
                    in_p.val=squeeze(data_T(:,ksim,:)-data_T(:,kref,:))';
                    in_p=reset_is(in_p);
                    in_p.is_diff_s=1;

                    fcn_plot_xvt(in_p,tag_ref,lims,xlims,fdir_fig_loc,tag,runid,var_str_save,branch_name);
                end

            end %ksim

        end %do_xtv
        
        %% all times in same figure xvt
        
        if flg_loc.do_xvallt && nsim==1 && nt>1
            error('not finished')
                
            fig_1D_01(in_p);
        end
        
    end %kvar    
end %kbr

end %function

%% 
%% FUNCTION
%%

%%

function fpath_fig=fig_name(flg_loc,fdir_fig,tag,runid,time_dnum,var_str,branch_name,str_dir,kxlim,kylim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_%s_%s_ylim_%02d_xlim_%02d',tag,runid,datestr(time_dnum,flg_loc.str_time),var_str,branch_name,str_dir,kylim,kxlim));

end %function

%%

function fpath_fig=fig_name_all(fdir_fig,tag,runid,var_str,branch_name,str_dir,kclim,kxlim)
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_allt_%s_%s_%s_clim_%d_xlim_%d',tag,runid,var_str,branch_name,str_dir,kclim,kxlim));

end %function

%%

function fcn_plot(in_p,flg_loc,fid_log,fdir_fig,branch_name,var_str_save,str_dir,tag,runid,time_dnum,ylims,xlims)

nylim=size(ylims,1);
nxlim=size(xlims,1);

fdir_fig_loc=fullfile(fdir_fig,branch_name,var_str_save,str_dir);
mkdir_check(fdir_fig_loc,fid_log,1,0);

for kylim=1:nylim
    for kxlim=1:nxlim
        fname_noext=fig_name(flg_loc,fdir_fig_loc,tag,runid,time_dnum,var_str_save,branch_name,str_dir,kxlim,kylim);
        
        in_p.xlims=xlims(kxlim,:);
        in_p.ylims=ylims(kylim,:);
        in_p.fname=fname_noext;

        fig_1D_01(in_p);
    end 
end

end %function

%%

function [do_measurements,data_mea]=add_measurement(flg_loc,fid_log,time_dnum,time_mor_dnum,var_str_save)

statis='val_mean'; %we do not loop on several variables
do_measurements=false;
data_mea=struct();
if isfield(flg_loc,'measurements') && ~isempty(flg_loc.measurements) 
    tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum);
    data_mea=gdm_load_measurements(fid_log,flg_loc.measurements,'tim',tim_search_in_mea,'var',var_str_save,'stat',statis);
    if isstruct(data_mea) %there is data
        do_measurements=true;
    end
end

end %function

%%

function fcn_plot_xvt(in_p,tag_ref,lims,xlims,fdir_fig_loc,tag,runid,var_str_save,branch_name)
    
nclim=size(lims,1);
nxlim=size(xlims,1);
for kclim=1:nclim
    for kxlim=1:nxlim

        fname_noext=fig_name_all(fdir_fig_loc,tag,runid,var_str_save,branch_name,tag_ref,kclim,kxlim);

        in_p.clims=lims(kclim,:);
        in_p.xlims=xlims(kxlim,:);

        in_p.fname=fname_noext;

        fig_surf(in_p)
    end
end

end %function

%%

function in_p=reset_is(in_p)

in_p.is_diff=0;
in_p.is_diff_t=0;
in_p.is_diff_s=0;

end %function