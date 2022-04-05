%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 27 $
%$Date: 2022-03-31 13:12:25 +0200 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 27 2022-03-31 11:12:25Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/create_mat_map_sal_mass_01.m $
%
%

function plot_map_sal_01(fid_log,in_plot_loc,simdef)

if ~in_plot_loc.do
    messageOut(fid_log,'Not doing ''fig_map_sal_01''')
    return
end
messageOut(fid_log,'Start ''fig_map_sal_01''')

%load
load(simdef.file.mat.map_sal_01,'data_map_sal_01');
load(simdef.file.mat.grd,'gridInfo');
load(simdef.file.mat.map_sal_01_tim,'time_dnum');

nt=size(data_map_sal_01,1);
nclim=size(in_plot_loc.clims,1);

max_tot=max(data_map_sal_01(:));
xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.lan=in_plot_loc.lan;
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.fig_overwrite=in_plot_loc.fig_overwrite;
in_p.unit=in_plot_loc.unit;

switch in_p.fig_print
    case 1
        fext='.png';
end

%% LOOP

fpath_file=cell(nt,nclim);
for kt=1:nt
    for kclim=1:nclim
        fname_noext=fullfile(simdef.file.fig.map_sal_01,sprintf('sal_map_01_%s_%s_clim_%02d',simdef.file.runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim));
        fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 
        
        in_p.fname=fname_noext;
        in_p.gridInfo=gridInfo;
        in_p.val=data_map_sal_01(kt,:);
        in_p.tim=time_dnum(kt);
        
        clims=in_plot_loc.clims(kclim,:);
        if all(isnan(clims)==[0,1]) %[0,NaN]
            in_p.clims=[clims(1),max_tot];
        else
            in_p.clims=clims;
        end
        
        fig_map_sal_01(in_p);
    end %kclim
end %kt

%% movies

dt_aux=diff(time_dnum);
dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
rat=in_plot_loc.rat; %[s] we want <rat> model seconds in each movie second
for kclim=1:nclim
   make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat);
end

end %function
