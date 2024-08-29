%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19748 $
%$Date: 2024-08-23 18:06:15 +0200 (Fri, 23 Aug 2024) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_ls_01.m 19748 2024-08-23 16:06:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_ls_01.m $
%
%

function gdm_adhoc_mean_u5(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if ~isfield(flg_loc,'do_rkm')
    if isfield(flg_loc,'fpath_rkm')
        flg_loc.do_rkm=1;
    else
        flg_loc.do_rkm=0;
    end
end
if flg_loc.do_rkm==1
    if ~isfield(flg_loc,'fpath_rkm')
        error('Provide rkm file')
    elseif exist(flg_loc.fpath_rkm,'file')~=2
        error('rkm file does not exist')
    end
end
if ~isfield(flg_loc,'TolMinDist')
    flg_loc.TolMinDist=1000;
end

if ~isfield(flg_loc,'tol_t')
    flg_loc.tol_t=5/60/24;
end

%% PATHS

load('simdef_all.mat','simdef_all')
%ad-hoc! problem with p-drive folder, for now only process second run. 
% simdef=simdef_all(2);
simdef=simdef_all;

nS=numel(simdef);

%%

fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fpath_map=simdef.file.map;

%% OVERWRITE

% ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% DIMENSIONS

nvar=numel(flg_loc.var);
npli=numel(flg_loc.pli);

%% LOAD TIME

[nt,time_dnum,tim_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef(1));
   
%% GRID

fpath_map=gdm_fpathmap(simdef(1),sim_idx(1));
gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0; kpli=0;
messageOut(fid_log,sprintf('Reading map_ls_01 pli %4.2f %% kt %4.2f %%',kpli/npli*100,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    for kpli=1:npli

        %pli name
        fpath_pli=flg_loc.pli{kpli,1};
        pliname=gdm_pli_name(fpath_pli);

        for kvar=1:nvar %variable
            if ~ischar(flg_loc.var{kvar})
                error('cannot read section along variables not from EHY')
            end
            varname=flg_loc.var{kvar};
            var_str=D3D_var_num2str_structure(varname,simdef(1));
            
            layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str,kvar,flg_loc.var{kvar}); %we use <layer> for flow and sediment layers

            for kS=1:nS
                fdir_mat=simdef(kS).file.mat.dir;
                fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'pli',pliname,'layer',layer);
                load(fpath_mat_tmp,'data')
                data_all.val(kt,:,kS)=data.val;
            end

            %the same for all
            data_all.rkm=data.rkm_cen; 
            data_all.time_dnum=time_dnum;
            data_all.time_dtime=tim_dtime;
            
            messageOut(fid_log,sprintf('Reading %s kt %4.2f %% kpli %4.2f %% kvar %4.2f %%',tag,ktc/nt*100,kpli/npli*100,kvar/nvar*100));
        end
    end
end %kt

fdir_mat=simdef(1).file.mat.dir;
% fpath_mat_tmp=fullfile(fdir_mat,'ad_hoc.mat');
fpath_mat_tmp=fullfile(fdir_mat,'ad_hoc2.mat');
save(fpath_mat_tmp,'data_all');

%% power

fdir_fig=simdef(1).file.fig.dir;
% fdir_fig_loc=fullfile(fdir_fig,'mean_u');
fdir_fig_loc=fullfile(fdir_fig,'mean_u2');
mkdir_check(fdir_fig_loc);

for pw=1:5
idx=1:1:size(data_all.val,1); %all
% pw=3;
val=data_all.val(idx,:,:).^pw;
val_m=mean(val,1);

% %%
% figure
% surf(data_all.val,'EdgeColor','none')
% colorbar

%%
figure
plot(data_all.rkm,squeeze(val_m))
ylabel(sprintf('mean longitudinal velocity to the power %d [m^%d/s^%d]',pw,pw,pw))
xlabel(labels4all('rkm',1/1000,'en'));
title(sprintf('%s  -  %s',datestr(data_all.time_dtime(1)),datestr(data_all.time_dtime(end))));
fpath_fig=fullfile(fdir_fig_loc,sprintf('ah_p%d.png',pw));
ha=gca;
ha.XAxis.Direction='reverse';
legend(flg_loc.str_sim)
printV(gcf,fpath_fig);

%%
figure
plot(data_all.rkm,val_m(:,:,2)-val_m(:,:,1))
ylabel(sprintf('difference in mean longitudinal velocity to the power %d [m^%d/s^%d]',pw,pw,pw))
xlabel(labels4all('rkm',1/1000,'en'));
title(sprintf('%s  -  %s',datestr(data_all.time_dtime(1)),datestr(data_all.time_dtime(end))));
fpath_fig=fullfile(fdir_fig_loc,sprintf('ah_d_p%d.png',pw));
ha=gca;
ha.XAxis.Direction='reverse';
printV(gcf,fpath_fig);

end

end %function

%% 
%% FUNCTION
%%
