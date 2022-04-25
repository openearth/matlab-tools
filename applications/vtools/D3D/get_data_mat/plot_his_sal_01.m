%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17979 $
%$Date: 2022-04-25 11:57:32 +0200 (Mon, 25 Apr 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_01.m 17979 2022-04-25 09:57:32Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_01.m $
%
%

function plot_his_sal_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag);
mkdir_check(fdir_fig);

%%

%load
% load(fpath_mat,'data');
% load(simdef.file.mat.grd,'gridInfo');
[nt,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,'');

nclim=size(flg_loc.clims,1);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

switch in_p.fig_print
    case 1
        fext='.png';
end

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%% LOOP

ks_v=gdm_kt_v(flg_loc,ns);

fpath_file=cell(nt,nclim);
for ks=ks_v
    for kclim=1:nclim
        fname_noext=fullfile(fdir_fig,sprintf('sal_his_01_%s_%s_clim_%02d',simdef.file.runid,stations{ks},kclim));
        fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 
        
        in_p.fname=fname_noext;
        in_p.val=data;
        in_p.tim=time_dtime;
        
        clims=flg_loc.clims(kclim,:);
        in_p.clims=clims;
        
        fig_his_sal_01(in_p);
    end %kclim
end %kt

%% movies

% dt_aux=diff(time_dnum);
% dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
% rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
% for kclim=1:nclim
%    make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
% end

end %function
