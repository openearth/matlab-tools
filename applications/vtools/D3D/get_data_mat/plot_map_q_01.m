%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17944 $
%$Date: 2022-04-07 14:24:09 +0200 (Thu, 07 Apr 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_mass_01.m 17944 2022-04-07 12:24:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_mass_01.m $
%
%

function plot_map_q_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end
if isfield(flg_loc,'load_all')==0
    flg_loc.load_all=0;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

if flg_loc.load_all
    load(fpath_mat,'data'); 
end
load(fpath_grd,'gridInfo');
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%%

nt=size(time_dnum,1);
nclim=size(flg_loc.clims,1);

if flg_loc.load_all
    max_tot=max(data(:));
else
    max_tot=NaN;
end
xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.unit='qsp';
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo;

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

fext=ext_of_fig(in_p.fig_print);

%% LOOP

fpath_file=cell(nt,nclim);
for kt=1:nt
    if flg_loc.load_all==0
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
        if exist(fpath_mat_tmp,'file')~=2; continue; end
        load(fpath_mat_tmp,'data');
        in_p.val=data;
    else
        in_p.val=data(kt,:);
    end
    
    in_p.tim=time_dnum(kt);
    for kclim=1:nclim
        clims=flg_loc.clims(kclim,:);
        fname_noext=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum);
        fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 

        in_p.fname=fname_noext;

        if all(isnan(clims)==[0,1]) %[0,NaN]
            in_p.clims=[clims(1),max_tot];
        else
            in_p.clims=clims;
        end
        
        fig_map_sal_01(in_p);
    end %kclim
end %kt

%% movies

if flg_loc.do_movie
    dt_aux=diff(time_dnum);
    dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
    rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
    for kclim=1:nclim
       make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat);
    end
end

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_clim_%02d',tag,runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim));

end %function