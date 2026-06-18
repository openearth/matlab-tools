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

function gdm_plot_CRS(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%% PARSE

flg_loc=isfield_default(flg_loc,'do_all_s',true);

%% PATHS REFERENCE

kref=flg_loc.sim_ref;
nsim=numel(simdef);
fdir_mat=simdef(kref).file.fdir_mat;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef(kref).file.fdir_fig,tag_fig,tag_serie);
% mkdir_check(fdir_fig); %we create it in the loop
% runid=simdef(kref).file.runid;

fpath_map=gdm_fpathmap(simdef(kref),0);

%% TIME

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%We are assuming we can loop all with the same time!
[time_dnum_v,time_dtime_v]=gdm_time_flow_mor(flg_loc,simdef(kref),time_dnum,time_dtime,time_mor_dnum,time_mor_dtime);

%% DIMENSIONS

nt=numel(time_dnum_v);
ncrs=numel(flg_loc.crs_name);
crs_names=EHY_getMapModelData(fpath_map,'varName','mesh1d_mor_crs_name'); %all cross-section names in the map file. We will use this to find the index of the cross-sections we want to load in the loop below.

%% loop on simulations

for ksim=1:nsim

    fdir_mat=simdef(ksim).file.fdir_mat;

    %time 0 for dimensions
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_v(1));
    load(fpath_mat_tmp,'data');
    nelev=size(data,3);

    data_all=NaN(2,nt,nelev,ncrs); %we will use this to plot all times of one simulation in the same plot
        
    for kt=1:nt

        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_v(kt));
        load(fpath_mat_tmp,'data');

        %% loop on cross-sections

        for kcrs=1:ncrs

            crs_name=flg_loc.crs_name{kcrs};

            idx_crs=find(contains(cellstr(crs_names.val),crs_name),1,'first'); %index of the first cross-section in the map file that contains crs_name

            if isempty(idx_crs)
                messageOut(fid_log,sprintf('Cross-section name "%s" not found in the map file. Available cross-sections are: %s',flg_loc.crs_name{kcrs},strjoin(cellstr(crs_names.val),', ')));
                continue
            end

            data_all(:,kt,:,kcrs)=data(:,idx_crs,:); %we will use this to plot all times of one simulation in the same plot
        end %kcrs
    end %kt

    %% PLOT

    for kcrs=1:ncrs

        crs_name=flg_loc.crs_name{kcrs};
        
        %% all times of one simulation and one cross-section in same plot

        if flg_loc.do_all_s
            fdir_fig=fullfile(simdef(ksim).file.fdir_fig,tag_fig,tag_serie,'val_t');
            mkdir_check(fdir_fig,fid_log,1,0);

            fname_noext=fullfile(fdir_fig,sprintf('%s_%s',tag,crs_name)); %time is not in the name

            
            in_p=flg_loc; %attention! reset

            in_p.fname=fname_noext;
            in_p.s=mat2cell(squeeze(data_all(1,:,:,kcrs)),ones(1,nt),nelev);
            in_p.val=mat2cell(squeeze(data_all(2,:,:,kcrs)),ones(1,nt),nelev);
            in_p.do_time=1;
            in_p.tim=time_dnum_v;
            in_p.xlab_str='b';
            in_p.variable='eta';
            in_p.Lref='AD';

            fig_1D_01(in_p);
        end
        
    end %kcrs

end %ksim

end %function