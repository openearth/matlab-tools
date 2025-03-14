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

function create_mat_measured_bed_level_csv(LR_csv_folder,fname_save,fpath_out,varargin)

d = dir(fullfile(LR_csv_folder,'*.csv'));
if numel(d)==0
    error('Nothing to process in this folder: %s',LR_csv_folder)
end
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

save(fullfile(fpath_out,fname_save),'data');

%% AD-HOC

%The measurement assigned to 2021-12-31 can be set to after the floodwave to compare with model results

tfind=datenum(2021,12,31);
tset=datenum(2021,08,05);

idx=absmintol(data.bl.val_mean.tim_dnum,tfind);
data.bl.val_mean.tim_dnum(idx)=tset;

save(fullfile(fpath_out,sprintf('%s_02',fname_save)),'data');

%% PLOT

plot_data_measurements(fullfile(fpath_out,fname_save),varargin{:});

end %function



