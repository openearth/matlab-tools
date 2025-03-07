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

function create_mat_measured_bed_level_csv(LR_csv_folder,fname_save)

d = dir(fullfile(LR_csv_folder,'*.csv'));
for k = 1:length(d)
    [filepath,name,ext] = fileparts(d(k).name);
    datecsv = datenum(str2num(name),12,31);  % data is for full year, therefore we use the last date of the year. 
    T=readtable(fullfile(d(k).folder,d(k).name)); 
    T=sortrows(T,"S");
    %disp(height(T));
    if (k==1)
        data.bl.val_mean.rkm = T.hm_punt;
        data.bl.val_mean.s = T.S; 
%         data.bl.val_mean.rkm_ZN = T.hm_punt_ZN;
        data.bl.val_mean.unit = 'bed elevation [m+NAP]'; 

        data.detab_ds.val_mean.rkm = T.hm_punt;
        data.detab_ds.val_mean.s = T.S; 
%         data.bl.val_mean.rkm_ZN = T.hm_punt_ZN;
        data.detab_ds.val_mean.unit = 'bed slope [-]'; 
    end
    data.bl.source{k} = fullfile(d(k).folder,d(k).name); 
    data.bl.val_mean.tim_dnum(k) = datecsv; 
    data.bl.val_mean.val(:,k) = T.MEAN; 

    data.detab_ds.source{k} = fullfile(d(k).folder,d(k).name); 
    data.detab_ds.val_mean.tim_dnum(k) = datecsv; 
        ds=diff(cen2cor(T.S))';
        detab=diff(cen2cor(T.MEAN))';
    data.detab_ds.val_mean.val(:,k) = detab./ds; 
end

%% SAVE

fpath_out=fileparts(LR_csv_folder);
save(fullfile(fpath_out,fname_save),'data');

%% PLOT

%2DO: Also plot slope

x_v=data.bl.val_mean.rkm;
y_v=datetime(data.bl.val_mean.tim_dnum,'ConvertFrom','datenum');

[x_m,y_m]=meshgrid(x_v,y_v);
in_p.x_m=x_m;
in_p.y_m=y_m;

in_p.fig_print=1;
in_p.fig_overwrite=1;
in_p.clab_str='bl';
in_p.ylab_str='';
in_p.ylab_un=1;
in_p.xlab_str='rkm';
in_p.xlab_un=1/1000;
in_p.xlims=[175,201];
in_p.clims=[-4,1];
in_p.cmap=jet(100);
in_p.ylims=[datetime(2011,1,1),datetime(2022,1,1)];

%
fname=strrep(fname_save,'.mat','');
fpath_fig=fullfile(fpath_out,fname);
in_p.fname=fpath_fig;
in_p.val=data.bl.val_mean.val';

fig_surf(in_p);

%
idx=absmintol(y_v,in_p.ylims(1),'tol',days(30));
fname=strrep(fname_save,'.mat','_diff');
fpath_fig=fullfile(fpath_out,fname);
in_p.fname=fpath_fig;
in_p.is_diff=1;
in_p.cmap=brewermap(100,'RdYlBu');
in_p.val=data.bl.val_mean.val'-data.bl.val_mean.val(:,idx)';
in_p.clims=absolute_limits(in_p.val);

fig_surf(in_p);

idx=absmintol(y_v,in_p.ylims(1),'tol',days(30));
fname=strrep(fname_save,'.mat','_diff_2');
fpath_fig=fullfile(fpath_out,fname);
in_p.fname=fpath_fig;
in_p.is_diff=1;
in_p.cmap=brewermap(100,'RdYlBu');
in_p.val=data.bl.val_mean.val'-data.bl.val_mean.val(:,idx)';
in_p.clims=[-1,1];

fig_surf(in_p);

%%
% val=data.bl.val_mean.val;
% ny=size(val,2);
% figure
% hold on
% for k=1:ny
% plot(x_v,val(:,k))
% xlim([175,201])
% title(datestr(y_v(k)))
% pause
% end

%% AD-HOC

%The measurement assigned to 2021-12-31 can be set to after the floodwave to compare with model results
tfind=datenum(2021,12,31);
tset=datenum(2021,08,05);

idx=absmintol(data.bl.val_mean.tim_dnum,tfind);
data.bl.val_mean.tim_dnum(idx)=tset;

save(fullfile(fpath_out,strrep(fname_save,'.mat','_02.mat')),'data');

end %function



