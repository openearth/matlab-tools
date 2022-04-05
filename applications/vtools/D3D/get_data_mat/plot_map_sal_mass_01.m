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

function plot_map_sal_mass_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    return
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

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

load(fpath_mat,'data');
load(fpath_grd,'gridInfo');
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%%

nt=size(data,1);
nclim=size(flg_loc.clims,1);

max_tot=max(data(:));
xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.unit='salm2';
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo;

fext=ext_of_fig(in_p.fig_print);

%% LOOP
nref=2;

fpath_file=cell(nt,nclim,nref);
for kt=1:nt
    in_p.tim=time_dnum(kt);
    for kclim=1:nclim
        clims=flg_loc.clims(kclim,:);
        for kref=1:nref
            switch kref
                case 1
                    in_p.is_background=0;
                case 2
                    in_p.is_background=1;
            end
            fname_noext=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum,kref);
            fpath_file{kt,kclim,kref}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            switch kref
                case 1
                    in_p.val=data(kt,:);
                    if all(isnan(clims)==[0,1]) %[0,NaN]
                        in_p.clims=[clims(1),max_tot];
                    else
                        in_p.clims=clims;
                    end
                case 2
                    in_p.val=data(kt,:)-data(1,:);
                    if all(isnan(clims)==[0,1]) %[0,NaN]
                        in_p.clims=[clims(1),max_tot];
                    else
                        in_p.clims=clims;
                    end
            end
                    
            fig_map_sal_01(in_p);
        end %kref
    end %kclim
end %kt

%% movies

dt_aux=diff(time_dnum);
dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
for kref=1:nref
    for kclim=1:nclim
       make_video(fpath_file(:,kclim,kref),'frame_rate',1/dt*rat);
    end
end

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum,kref)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_clim_%02d_ref_%02d',tag,runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim,kref));

end %function