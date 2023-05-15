%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18607 $
%$Date: 2022-12-08 08:02:01 +0100 (do, 08 dec 2022) $
%$Author: chavarri $
%$Id: gdm_adhoc_export_for_groundwater.m 18607 2022-12-08 07:02:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_adhoc_export_for_groundwater.m $
%
%

function gdm_adhoc_cummulative_energy_loss(fid_log,flg_loc,simdef)

%%

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%%

if isfield(flg_loc,'var_idx')==0
    flg_loc.var_idx=cell(1,numel(flg_loc.var));
end
var_idx=flg_loc.var_idx;

%%

nS=numel(simdef);
fdir_mat=simdef(1).file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
runid=simdef(1).file.runid;

%% LOAD

% load(fpath_mat,'data');
gridInfo=gdm_load_grid(fid_log,fdir_mat,'');

load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%%

%% DIMENSIONS

nt=size(time_dnum,1);
% nclim=size(flg_loc.clims,1);
nvar=numel(flg_loc.var);
% nxlim=size(flg_loc.xlims,1);

%%

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.gridInfo=gridInfo;
in_p=gdm_read_plot_along_rkm(in_p,flg_loc);

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

for kvar=1:nvar %variable
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef(1));
    
    layer=gdm_layer(flg_loc,gridInfo.no_layers,var_str,kvar,flg_loc.var{kvar});
    in_p.str_idx=layer; %maybe it is <var_idx> in other plots. 
    
    for kt=kt_v
        for kS=1:nS
            fdir_mat=simdef(kS).file.mat.dir;
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'var',var_str,'var_idx',var_idx{kvar},'layer',layer);
            load(fpath_mat_tmp,'data');
            data_all(:,kS)=data;
        end %kS

%         switch flg_loc.tim_type
%             case 1
%                 in_p.tim=time_dnum(kt);
%             case 2
%                 in_p.tim=time_mor_dnum(kt);
%         end
        
    end %kt


%% CALC

bol_0=data_all(:,1)==0; %assume all of them have the same NaN
xf=gridInfo.Xu(~bol_0);
yf=gridInfo.Yu(~bol_0);

rkm=convert2rkm(flg_loc.fpath_rkm,[xf,yf],'TolMinDist',10000);

[rkm_s,idx_s]=sort(rkm);

en1f=data_all(~bol_0,:);
en1fs=en1f(idx_s,:);
en1fc=cumsum(en1fs,1,'reverse');

%%

in_p=flg_loc;
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;
in_p.do_title=0;
in_p.fig_visible=0;
in_p.fig_print=1;
in_p.fig_overwrite=1;
in_p.leg_str=flg_loc.str_sim;

fdir_loc=fullfile(fdir_fig,varname,'projected_rkm');
mkdir_check(fdir_loc);

%%

in_p.s=rkm_s;
in_p.val=en1fs;
in_p.ylab='';
in_p.lab_str=varname;

fpath_fig=fullfile(fdir_loc,sprintf('%s_projected_rkm_%s_%s_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str));

in_p.fname=fpath_fig;

fig_1D_01(in_p);

%%

in_p.s=rkm_s;
in_p.val=en1fc;
in_p.ylab=sprintf('cumulative %s',labels4all(varname,1,flg_loc.lan));

fpath_fig=fullfile(fdir_loc,sprintf('%s_projected_rkm_cumsum_%s_%s_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMMSS'),var_str));

in_p.fname=fpath_fig;

fig_1D_01(in_p);

end %kvar

end %function