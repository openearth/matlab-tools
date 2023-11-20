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
%Compute average of (bed level) data in shp-file and dbf-file along certain areas (L1, L2, ..., R3, R4). 
%
%E.G.
% fpath_shp=fullfile(fpaths.fdir_data_bedlevel,'02_shp','vakken_RT_totaal_v4.shp'); %full path to shp-file [char].
% fpath_dbf_csv=fullfile(fpaths.fdir_data_bedlevel,'01_dbf','AdJ.txt'); %full path to csv-file with dbf-files and tim [char].
% fdir_out=fullfile(fpaths.fdir_data_bedlevel,'08_mat'); %full path to folder to save output [char].
% % fpath_rkm=fullfile(fpaths.fdir_rkm,'rkm_rijntakken_waal_3km.csv'); %full path to rkm-file to plot along the coverage [char].
% fpath_rkm=fullfile(fpaths.fdir_rkm,'rkm_rijntakken_ijssel_3km.csv'); %full path to rkm-file to plot along the coverage [char].
% section.ident=[-3:1:-1,1:1:3]; %indices of the areas to process. From -4 (4 to the left) to 4 (for to the right) [double(1,na)]; na = number of areas.
% section.name='L3R3'; %tag of the areas to process [char]. This is added to the output filename. 
% ds=1000; %streamwise distance for mean value [m].
% rkmi=878; %initial river kilometer [km].
% rkmf=1006; %end river kilometer [km].
% br='IJ'; %river branch to process [char].
% tag_rkm='1km'; %tag of the distance to compute the mean [char]. This is added to the output filename. 
% do_plot_coverage=0; %plot the figures with coverage [double(1,1)]: 0 = no; 1 = yes; 

function create_mat_measurements_from_shp_01(fpath_shp,fpath_dbf_csv,fdir_out,fpath_rkm,section,rkmi,rkmf,ds,br,tag_rkm,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'coverage',0.99,@isnumeric);
addOptional(parin,'plot_coverage',true);
addOptional(parin,'plot_rkm',true);

parse(parin,varargin{:});

coverage_th=parin.Results.coverage;
do_plot_coverage=parin.Results.plot_coverage;
do_plot_rkm=parin.Results.plot_rkm;

fid_log=NaN; %file-log identifier (NaN = print to screen)

%% CALC

%fpath_shp = full path to the shp-file for all dbf-files [char]
%fpath_dbf_csv = full path to the csv-file with information about dbf-files [char]
%
input_struct=create_input_from_shp_01(fpath_shp,fpath_dbf_csv);
%
%input_struct = contains input data [struct(nd)]
%   -input_struct(kd).shp = full path to the shp-file [char]
%   -input_struct(kd).dbf = full path to the dbf-file [char]
%   -input_struct(kd).tim = time associated to the data [datenum(1,1)]

nd=numel(input_struct); %number of dbf-files, time.

rkm=rkmi:ds/1000:rkmf; %rkm vector 

%data = measurements data structure [struct(1,1)]
%   -data.bl.val_mean = bed level mean values
%       -data.bl.val_mean.rkm = river kilometer [double(nrkm,1)]
%       -data.bl.val_mean.rkm = time [datenum(1,nt)]
%       -data.bl.val_mean.val = values [double(nrkm,nt)]
%       -data.bl.val_mean.unit = unit [char] ('bed elevation [m+NAP]')
%       -data.bl.val_mean.source = source of the data [cell(ns,1)]
%
data.bl.val_mean.rkm=reshape(rkm,[],1);
data.bl.val_mean.tim_dnum=reshape([input_struct.tim],1,[]);
data.bl.val_mean.unit='bed elevation [m+NAP]';
data.bl.val_mean.source={input_struct.dbf};

val=NaN(numel(data.bl.val_mean.rkm),nd);

for kd=1:nd %dbf-file, time. 

    pol=load_pol_from_shp_dbf(input_struct(kd).shp,input_struct(kd).dbf);
    %
    %pol = polygon data

    %'coverage' = fraction that needs to be with data for not setting NaN.
    %
    [etab_cen,area_cen,loc_pol_num,rkm_pol_num,br_pol_num]=filter_pol_data(pol,'coverage',coverage_th);
    %
    %etab_cen = bed level of each cell in the polygon. NaN indicates that there is not enough coverage. [double(np,1)]
    %pol = polygons [struct]
    %loc_pol_num = section identifier (L4 - R4); [double(np,1)]
    %rkm_pol = river kilometer ; [double(np,1)]
    %br_pol_num = branch number ; [double(np,1)]

    if do_plot_coverage
        [~,fname_dbf,~]=fileparts(input_struct(kd).dbf);
        fdir_fig=fullfile(fdir_out,'coverage',fname_dbf);
        mkdir_check(fdir_fig);
        plot_coverage(pol,etab_cen,fpath_rkm,fdir_fig);
    end

    %sections = sections to process [struct(1,1)]
    %   -sections.ident = section identifier [double(ns,1)]
    %   -sections.name = section name [char]
    %rkm = river kilometer center points [double(nrkm,1 )]
    %br = branch identifier [char]

    [val(:,kd),idx_rkm]=compute_mean(etab_cen,area_cen,loc_pol_num,rkm_pol_num,br_pol_num,section.ident,rkm,br);

    if do_plot_rkm
        [~,fname_dbf,~]=fileparts(input_struct(kd).dbf);
        fdir_fig=fullfile(fdir_out,'rkm',fname_dbf);
        mkdir_check(fdir_fig);
        plot_coverage(pol,idx_rkm,fpath_rkm,fdir_fig,'type',2);
    end

    messageOut(fid_log,sprintf('Processed %4.2f %% files',kd/nd*100));

end %kd

%% save

data.bl.val_mean.val=val;

[~,fname_csv,~]=fileparts(fpath_dbf_csv);
fname_data=sprintf('%s_%s_%s_%s',fname_csv,tag_rkm,br,section.name);
fpath_data=fullfile(fdir_out,sprintf('%s.mat',fname_data));

save_check(fpath_data,'data');

%% plot

in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fname=fullfile(fdir_out,fname_data);
in_p.fig_visible=0;
in_p.data=data.bl.val_mean;

fig_measurments(in_p)

end %function
