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

function plot_map_ls_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%%

% %% BEGIN DEBUG
% 
% % load(fullfile(simdef.file.mat.dir,'map_ls_tmp_pli_01_kt_70.mat'));
% 
% %% END DEBUG

%load
load(simdef.file.mat.map_ls_01,'data_map_ls_01');
load(simdef.file.mat.map_ls_01_tim,'time_dnum');

nclim=size(flg_loc.clims,1);
npli=numel(data_map_ls_01);
nt=size(data_map_ls_01(1).sal,1);

%figures
in_p=flg_loc; %attention with unexpected input
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

if isfield(flg_loc,'fig_overwrite')
    in_p.fig_overwrite=flg_loc.fig_overwrite;
end

switch in_p.fig_print
    case 1
        fext='.png';
end

%% LOOP

fpath_file=cell(nt,nclim,npli);
for kpli=1:npli
    in_p.xlims=[0,data_map_ls_01(kpli).Scor(end)];
    in_p.ylims=flg_loc.ylims(kpli,:); %move to input
    in_p.data_ls=data_map_ls_01(kpli);
    for kt=1:nt
        for kclim=1:nclim
            fname_noext=fullfile(simdef.file.fig.map_ls_01,sprintf('sal_ls_01_%s_%s_clim_%02d_pli_%02d',simdef.file.runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim,kpli));
            fpath_file{kt,kclim,kpli}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            in_p.kt=kt;
            in_p.tim=time_dnum(kt);

            clims=flg_loc.clims(kclim,:);
            if all(isnan(clims)==[0,1]) %[0,NaN]
                error('do')
%                 in_p.clims=[clims(1),max_tot];
            else
                in_p.clims=clims;
            end

            fig_map_ls_01(in_p);
        end %kclim
    end %kt
end %kpli

%% movies

dt_aux=diff(time_dnum);
dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
for kpli=1:npli
for kclim=1:nclim
   make_video(fpath_file(:,kclim,kpli),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
end
end

end %function
