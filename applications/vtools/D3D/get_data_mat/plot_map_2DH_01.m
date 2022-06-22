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

function plot_map_2DH_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_p'); if ret; return; end

%%

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end

if isfield(flg_loc,'clims')==0
    flg_loc.clims=[NaN,NaN];
    flg_loc.clims_diff_t=[NaN,NaN];
end
if isfield(flg_loc,'clims_diff_t')==0
    flg_loc.clims_diff_t=flg_loc.clims;
end

if isfield(flg_loc,'do_diff')==0
    flg_loc.do_diff=1;
end

if isfield(flg_loc,'xlims')==0
    flg_loc.xlims=[NaN,NaN];
    flg_loc.ylims=[NaN,NaN];
end

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

% load(fpath_mat,'data');
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%% DIMENSIONS

nt=size(time_dnum,1);
nclim=size(flg_loc.clims,1);
nvar=numel(flg_loc.var);
nxlim=size(flg_loc.xlims,1);

%%

% max_tot=max(data(:));
[xlims_all,ylims_all]=D3D_gridInfo_lims(gridInfo);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.gridInfo=gridInfo;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

if flg_loc.do_diff==0
    ndiff=1;
else 
    ndiff=2;
end

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    in_p.unit=var_str;
    
    %time 1 for difference
    kt=1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str);
    data_ref=load(fpath_mat_tmp,'data');
    if sum(size(data_ref.data)==1)==0
        messageOut(fid_log,sprintf('Cannot plot variable with more than 1 dimension: %s',var_str))
        continue
    end
    
    fpath_file=cell(nt,nclim,ndiff);
    for kt=kt_v
        ktc=ktc+1;
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str);
        load(fpath_mat_tmp,'data');
        
        switch flg_loc.tim_type
            case 1
                in_p.tim=time_dnum(kt);
            case 2
                in_p.tim=time_mor_dnum(kt);
        end
        
        for kclim=1:nclim
            for kxlim=1:nxlim

                %xlim
                xlims=flg_loc.xlims(kxlim,:);
                ylims=flg_loc.ylims(kxlim,:);
                if isnan(xlims(1))
                    xlims=xlims_all;
                    ylims=ylims_all;
                end
                in_p.xlims=xlims;
                in_p.ylims=ylims;

                for kdiff=1:ndiff
                    switch kdiff
                        case 1
                            in_p.val=data;
                            in_p.clims=flg_loc.clims(kclim,:);
                            in_p.is_diff=0;
                            tag_ref='val';
                        case 2
                            in_p.val=data-data_ref.data;
                            in_p.clims=flg_loc.clims_diff_t(kclim,:);
                            in_p.is_diff=1;
                            tag_ref='diff';
                    end

                    fdir_fig_var=fullfile(fdir_fig,var_str,tag_ref);
                    mkdir_check(fdir_fig_var,NaN,1,0);

                    fname_noext=fig_name(fdir_fig_var,tag,runid,time_dnum(kt),kdiff,kclim,var_str,kxlim);
                    fpath_file{kt,kclim,kdiff}=sprintf('%s%s',fname_noext,fext); %for movie 

                    in_p.fname=fname_noext;

                    fig_map_sal_01(in_p);
                end %kdiff
            end%kxlim
        end %kclim
        messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
    end %kt
    
    %% movies
    
    for kdiff=1:ndiff
        for kclim=1:nclim
            fpath_mov=fpath_file(:,kclim,kdiff);
            gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum);   
        end
    end
    
end %kvar

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,tnum,kref,kclim,var_str,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_clim_%02d_xlim_%02d_ref_%02d',tag,runid,var_str,datestr(tnum,'yyyymmddHHMMSS'),kclim,kref,kxlim));

end %function