%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20027 $
%$Date: 2025-01-20 16:58:11 +0100 (Mon, 20 Jan 2025) $
%$Author: chavarri $
%$Id: plot_all_runs_one_figure.m 20027 2025-01-20 15:58:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_all_runs_one_figure.m $
%
%Create a mat-file of the bed level for several years given after
%processing in QGIS. 

function plot_data_measurements(fpath_data,flg)

%2DO limits are very adhoc

%% PARSE

flg=isfield_default(flg,'xlims',[NaN,NaN]);
flg=isfield_default(flg,'clims',[NaN,NaN]);
flg=isfield_default(flg,'clims_diff',[NaN,NaN]);
flg=isfield_default(flg,'ylims',[NaN,NaN]);

nclims=size(flg.clims,1);
nclims_diff=size(flg.clims_diff,1);
nxlims=size(flg.xlims,1);

%% CALC

load(fpath_data,'data');
[fpath_out,fname_save]=fileparts(fpath_data);

fn=fieldnames(data);
nfn=numel(fn);

for kfn=1:nfn
    x_v=data.(fn{kfn}).val_mean.rkm;
    y_v=datetime(data.(fn{kfn}).val_mean.tim_dnum,'ConvertFrom','datenum');
    
    [x_m,y_m]=meshgrid(x_v,y_v);
    in_p.x_m=x_m;
    in_p.y_m=y_m;
    
    in_p.fig_visible=0;
    in_p.fig_print=1;
    in_p.fig_overwrite=1;
    in_p.clab_str=fn{kfn};
    in_p.ylab_str='';
    in_p.ylab_un=1;
    in_p.xlab_str='rkm';
    in_p.xlab_un=1/1000;

    for kxlim=1:nxlims
        in_p.xlims=flg.xlims(kxlim,:);
    
        in_p.cmap=jet(100);
        in_p.ylims=flg.ylims;
    
        %surf variable
        for kclim=1:nclims
            in_p.clims=flg.clims(kclim,:);
                fname=sprintf('%s_%s_%02d_%02d',fname_save,fn{kfn},kclim,kxlim);
                fpath_fig=fullfile(fpath_out,fname);
            in_p.fname=fpath_fig;
            in_p.val=data.(fn{kfn}).val_mean.val';
            
            fig_surf(in_p);
        end
        
        %surf diff in time
        for kclim=1:nclims_diff
                idx=absmintol(y_v,in_p.ylims(1),'tol',days(30));
                fname=sprintf('%s_%s_diff_%02d_%02d',fname_save,fn{kfn},kclim,kxlim);
                fpath_fig=fullfile(fpath_out,fname);
            in_p.fname=fpath_fig;
            in_p.is_diff=1;
            in_p.cmap=brewermap(100,'RdYlBu');
            in_p.val=data.(fn{kfn}).val_mean.val'-data.(fn{kfn}).val_mean.val(:,idx)';
            in_p.clims=flg.clims_diff(kclim,:);
            
            fig_surf(in_p);
        end
    
        %surf diff with previous
        for kclim=1:nclims_diff
                idx=absmintol(y_v,in_p.ylims(1),'tol',days(30));
                fname=sprintf('%s_%s_cel_%02d_%02d',fname_save,fn{kfn},kclim,kxlim);
                fpath_fig=fullfile(fpath_out,fname);
            in_p.fname=fpath_fig;
            in_p.is_diff=0;
            in_p.cmap=brewermap(100,'RdYlBu');
                val=data.(fn{kfn}).val_mean.val;
                val=diff(val); %difference in the direction of time
                val=cat(2,zeros(size(val,1),1),val);
                dt=diff(data.(fn{kfn})) %time
                val=val./dt;
                val=val';
            in_p.val=val;
            in_p.clims=flg.clims_diff(kclim,:);
            
            fig_surf(in_p);
        end
    
        %add figure plot
                fname=sprintf('%s_%s_lp_%02d',fname_save,fn{kfn},kxlim);
                fpath_fig=fullfile(fpath_out,fname);
        in_p.fname=fpath_fig;
        in_p.s=x_v;
    
    
        in_p.is_diff=0;
        in_p.lab_str=fn{kfn};
                idx_1=absmintol(y_v,in_p.ylims(1),'tol',days(30));
                idx_2=absmintol(y_v,in_p.ylims(2),'tol',days(150));
        in_p.val=data.(fn{kfn}).val_mean.val(:,idx_1:idx_2);
        in_p.leg_str=datestr(data.(fn{kfn}).val_mean.tim_dnum(idx_1:idx_2));
        in_p.ylims=NaN; %watch out. solve
        in_p.cmap=NaN;
    
        fig_1D_01(in_p)
    
        %%
        %         fname=sprintf('%s_%s_lp_diff',fname_save,fn{kfn});
        %         fpath_fig=fullfile(fpath_out,fname);
        % in_p.fname=fpath_fig;
        % in_p.s=x_v;
        % 
        % in_p.ylims=flg.ylims;
        % 
        % in_p.is_diff=1;
        % in_p.lab_str=fn{kfn};
        %         idx_1=absmintol(y_v,in_p.ylims(1),'tol',days(30));
        %         idx_2=absmintol(y_v,in_p.ylims(2),'tol',days(150));
        % in_p.val=data.(fn{kfn}).val_mean.val(:,idx_1:idx_2)-data.(fn{kfn}).val_mean.val(:,idx_1);
        % in_p.leg_str=datestr(data.(fn{kfn}).val_mean.tim_dnum(idx_1:idx_2));
        % in_p.ylims=NaN; %watch out. solve
        % in_p.cmap=NaN;
        % 
        % fig_1D_01(in_p)
    end %kxlim
end %kfn

end %function