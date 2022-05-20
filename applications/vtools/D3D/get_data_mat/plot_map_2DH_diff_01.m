%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18016 $
%$Date: 2022-05-03 16:22:21 +0200 (Tue, 03 May 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_mass_01.m 18016 2022-05-03 14:22:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_mass_01.m $
%
%

function plot_map_2DH_diff_01(fid_log,flg_loc,simdef_ref,simdef)

tag=flg_loc.tag;
if isfield(flg_loc,'tag_fig')==0
    tag_fig=tag;
else
    tag_fig=flg_loc.tag_fig;
end

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_s'); if ret; return; end

%%

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end

%% PATHS

fdir_mat_ref=simdef_ref.file.mat.dir;
fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat_ref,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat'); %shuld be the same for reference and non-reference
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig);
mkdir_check(fdir_fig);
fpath_map_ref=simdef_ref.file.map;
fpath_map=simdef_ref.file.map;
runid_ref=simdef_ref.file.runid;
runid=simdef.file.runid;

%% LOAD

% load(fpath_mat,'data');
gridInfo_ref=gdm_load_grid(fid_log,fdir_mat_ref,fpath_map_ref);
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSIONS

nt=size(time_dnum,1);
nclim=size(flg_loc.clims,1);
nvar=numel(flg_loc.var);

%%

% max_tot=max(data(:));
[xlims,ylims]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo_ref;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    fdir_fig_var=fullfile(fdir_fig,var_str);
    mkdir_check(fdir_fig_var);
    
    in_p.unit=var_str;
    
    fpath_file=cell(nt,nclim);
    for kt=kt_v
        ktc=ktc+1;
        fpath_mat_tmp=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt),'var',var_str);
        data_ref=load(fpath_mat_tmp,'data');
        
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str);
        data=load(fpath_mat_tmp,'data');
        
        in_p.tim=time_dnum(kt);
        
        for kclim=1:nclim
            val=D3D_diff_val(data.data,data_ref.data,gridInfo,gridInfo_ref);
            
            in_p.val=val;
            in_p.clims=flg_loc.clims_diff_s(kclim,:);
            in_p.is_diff=1;

            fname_noext=fig_name(fdir_fig_var,tag_fig,time_dnum(kt),runid,runid_ref,kclim,var_str);
            fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;

            fig_map_sal_01(in_p);
        end %kclim
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag_fig,ktc/nt*100));
    end %kt
    
    %% movies

    if isfield(flg_loc,'do_movie')==0
        flg_loc.do_movie=1;
    end

    if flg_loc.do_movie
        dt_aux=diff(time_dnum);
        dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
        rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
        for kdiff=1:ndiff
            for kclim=1:nclim
               make_video(fpath_file(:,kclim,kdiff),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
            end
        end
    end
    
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,tnum,runid,runid_ref,kclim,var_str)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s-%s_%s_%s_clim_%02d',tag,runid,runid_ref,var_str,datestr(tnum,'yyyymmddHHMM'),kclim));

end %function