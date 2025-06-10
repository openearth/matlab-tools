%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20161 $
%$Date: 2025-05-22 17:11:27 +0200 (Thu, 22 May 2025) $
%$Author: chavarri $
%$Id: fig_map_sal_01.m 20161 2025-05-22 15:11:27Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_map_sal_01.m $
%

function [measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements(in_p,measurements_structure,time_dtime,time_dtime_0,x_lims,y_lims)

%% PARSE

is_diff=in_p.is_diff;

%% SKIP

% in_p.do_measurements=0; %better to pass the actual output

if isempty_struct(measurements_structure)
    measurements_images=cell(0,0);
    tim_mea_dtime_mean=NaT;
    return
end

%% CALC

[measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements_single(in_p,measurements_structure,time_dtime,x_lims,y_lims);   

if is_diff
    measurements_images_0=gdm_load_2D_measurements_single(in_p,measurements_structure,time_dtime_0,x_lims,y_lims);   
    nf0=numel(measurements_images_0);
    nf=numel(measurements_images);
    if nf0~=nf
        messageOut(NaN,'The number of tiles for the reference time is different than for the final time. I cannot substract them.')
        measurements_images=cell(0,0);
        tim_mea_dtime_mean=NaT;
        return
    end
    for kf=1:nf
        measurements_images{kf}.z=measurements_images{kf}.z-measurements_images_0{kf}.z;
    end
end

end %function 

%%
%% FUNCTIONS
%%

function [measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements_single(in_p,measurements_structure,time_dtime,x_lims,y_lims)

%% PARSE

in_p=isfield_default(in_p,'tol_x_measurements',1000); 
in_p=isfield_default(in_p,'tol_y_measurements',1000); 
in_p=isfield_default(in_p,'tol_time_measurements',days(30)); 
if ~isduration(in_p.tol_time_measurements)
    in_p.tol_time_measurements=days(in_p.tol_time_measurements);
end

%`v2struct` is a bit dangerous. 
tim_tol_dur=in_p.tol_time_measurements; 
tol_x=in_p.tol_x_measurements;
tol_y=in_p.tol_x_measurements;

%% CALC

if isempty(measurements_structure(1).Time(1).TimeZone)
    error('There is no timezone! This should be dealt when initializing. Not sure how you got here. ')
end

x_limits_tol=x_lims+[-tol_x,+tol_x];
y_limits_tol=y_lims+[-tol_y,+tol_y];

bol_tim=[measurements_structure.Time]>time_dtime-tim_tol_dur & [measurements_structure.Time]<time_dtime+tim_tol_dur;
bol_x=  [measurements_structure.MaxX]>x_limits_tol(1)        & [measurements_structure.MinX]<x_limits_tol(2);
bol_y=  [measurements_structure.MaxY]>y_limits_tol(1)        & [measurements_structure.MinY]<y_limits_tol(2);

bol_get=bol_tim & bol_x & bol_y;
measurements_structure_get=measurements_structure(bol_get);
nf=numel(measurements_structure_get);

%get out if nothing
if nf==0
    measurements_images=cell(nf,1);
    tim_mea_dtime_mean=NaT(nf,1);
    tim_mea_dtime_mean.TimeZone=time_dtime.TimeZone;
    return
end

%all must be the same type. 
fpath=measurements_structure_get(1).Filename;
[~,~,fext]=fileparts(fpath);
switch fext
    case '.tif'
        [measurements_images,tim_mea_dtime_mean]=read_and_project_tif(in_p,measurements_structure_get,x_lims,y_lims,time_dtime);
    case '.shp'
        [measurements_images,tim_mea_dtime_mean]=read_and_project_shp(in_p,measurements_structure_get,x_lims,y_lims,time_dtime);
end %fext


% %possibility of combining tif and shp: just read and save in cell array.
% %Check on the plotting side though. 
% idx_get=find(bol_tim & bol_x & bol_y);
% measurements_structure_get=measurements_structure(idx_get);
% nf=numel(idx_get);
% measurements_images=cell(nf,1);
% for kf=1:nf
%     fpath=measurements_structure(idx_get(kf)).Filename;
%     [~,~,fext]=fileparts(fpath);
%     switch fext
%         case '.tif'
%             %read image
%             measurements_images{kf}=readgeotiff(fpath,'x_limits',x_limits_tol,'y_limits',y_limits_tol);
%         case '.shp'
%             measurements_images{kf}=read_shp(fpath,'x_limits',x_limits_tol,'y_limits',y_limits_tol);
%         otherwise
%             error('Unknown format: %s',fpath)
%     end
%     %apply factor
%     measurements_images{kf}.z=measurements_images{kf}.z.*measurements_structure(idx_get(kf)).Factor;
%     %save time
%     tim_mea(kf)=measurements_structure(idx_get(kf)).Time;
% end %kf

% tim_mea_dtime_mean=mean(tim_mea);

end %function

%%
%% FUNCTIONS
%%

function measurements_images=read_shp(fpath,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x_limits',[-inf,inf]);
addOptional(parin,'y_limits',[-inf,inf]);
addOptional(parin,'variable_tag','polygon:MEAN');

parse(parin,varargin{:});

x_limits=parin.Results.x_limits;
y_limits=parin.Results.y_limits;
variable_tag=parin.Results.variable_tag;

%% CALC

shp=D3D_io_input('read',fpath,'read_val',true);

str_pol={variable_tag}; 
polnames=cellfun(@(X)X.Name,shp.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol))
    error('Could not find variable in shapefile %s. Maybe the variable name is different.',fpath_shp_tmp);
end

MinX=cellfun(@(X)min(X(:,1)),shp.xy.XY);
MinY=cellfun(@(X)min(X(:,2)),shp.xy.XY);
MaxX=cellfun(@(X)max(X(:,1)),shp.xy.XY);
MaxY=cellfun(@(X)max(X(:,2)),shp.xy.XY);

bol_x= MaxX>x_limits(1) & MinX<x_limits(2);
bol_y= MaxY>y_limits(1) & MinY<y_limits(2);

bol_get=bol_x & bol_y;

measurements_images.pol=shp.xy.XY(bol_get);
measurements_images.z=shp.val{1,idx_pol(1)}.Val(bol_get);

end %function

%%

function [measurements_images,tim_mea_dtime_mean]=read_and_project_tif(in_p,measurements_structure,x_lims,y_lims,time_dtime)

%% PARSE

in_p=isfield_default(in_p,'tol_x_measurements',1000); 
in_p=isfield_default(in_p,'tol_y_measurements',1000); 

%`v2struct` is a bit dangerous. 
tol_x=in_p.tol_x_measurements;
tol_y=in_p.tol_x_measurements;

%% CALC

nf=numel(measurements_structure);
dx=1;
dy=1;
x_plot=floor(x_lims(1)):dx:ceil(x_lims(2));
y_plot=floor(y_lims(1)):dy:ceil(y_lims(2));
nx=numel(x_plot);
ny=numel(y_plot);
z_plot=NaN(ny,nx);
m_plot=NaN(ny,nx);

tim_mea=NaT(nf,1);
tim_mea.TimeZone=time_dtime.TimeZone;

x_limits_tol=x_lims+[-tol_x,+tol_x];
y_limits_tol=y_lims+[-tol_y,+tol_y];

for kf=1:nf
    fpath=measurements_structure(kf).Filename;
    [~,~,fext]=fileparts(fpath);
    switch fext
        case '.tif'
            %read image
            measurements_images_loc=readgeotiff(fpath,'x_limits',x_limits_tol,'y_limits',y_limits_tol);
        otherwise
            error('If one image is tif, all of them must be tif. Check the option to combine types: %s',fpath)
    end %fext
    %apply factor
    measurements_images_loc.z=measurements_images_loc.z.*measurements_structure(kf).Factor;
    %save time
    tim_mea(kf)=measurements_structure(kf).Time;

    bol_x_plot=ismember(x_plot,measurements_images_loc.x);
    bol_y_plot=ismember(y_plot,measurements_images_loc.y);
    bol_x_read=ismember(measurements_images_loc.x,x_plot);
    bol_y_read=ismember(measurements_images_loc.y,y_plot);

    z_plot(bol_y_plot,bol_x_plot)=measurements_images_loc.z(bol_y_read,bol_x_read);
    m_plot(bol_y_plot,bol_x_plot)=measurements_images_loc.mask(bol_y_read,bol_x_read);

end %kf

measurements_images{1}.x=x_plot;
measurements_images{1}.y=y_plot;
measurements_images{1}.z=z_plot;
measurements_images{1}.mask=m_plot;

tim_mea_dtime_mean=mean(tim_mea);

end %function

%%

function [measurements_images,tim_mea_dtime_mean]=read_and_project_shp(in_p,measurements_structure,x_lims,y_lims,time_dtime)

%% PARSE

in_p=isfield_default(in_p,'tol_x_measurements',1000); 
in_p=isfield_default(in_p,'tol_y_measurements',1000); 
in_p=isfield_default(in_p,'measurements_tag_variable','polygon:MEAN'); 
in_p=isfield_default(in_p,'measurements_tag_count','polygon:COUNT'); 
in_p=isfield_default(in_p,'measurements_tag_area','polygon:oppervlak_'); 
in_p=isfield_default(in_p,'measurements_tag_location','polygon:Locatie'); 
in_p=isfield_default(in_p,'measurements_coverage',0.99); 
in_p=isfield_default(in_p,'measurements_pol_location',[-3:1:1,1:1:3]); 

%`v2struct` is a bit dangerous. 
tol_x=in_p.tol_x_measurements;
tol_y=in_p.tol_x_measurements;
tag_variable=in_p.measurements_tag_variable;
tag_count=in_p.measurements_tag_count;
tag_area=in_p.measurements_tag_area;
tag_location=in_p.measurements_tag_location;
coverage=in_p.measurements_coverage;
pol_location=in_p.measurements_pol_location;

%% CALC

nf=numel(measurements_structure);
measurements_images=cell(nf,1);

x_limits_tol=x_lims+[-tol_x,+tol_x];
y_limits_tol=y_lims+[-tol_y,+tol_y];

tim_mea=NaT(nf,1);
tim_mea.TimeZone=time_dtime.TimeZone;
for kf=1:nf
    fpath=measurements_structure(kf).Filename;
    [~,~,fext]=fileparts(fpath);
    switch fext
        case '.shp'
            measurements_images{kf}=SHP_read_and_filter(fpath,'x_limits',x_limits_tol,'y_limits',y_limits_tol,'tag_variable',tag_variable,'coverage',coverage,'tag_count',tag_count,'tag_area',tag_area,'pol_location',pol_location,'tag_location',tag_location);
        otherwise
            error('If one image is shp, all of them must be shp. Check the option to combine types: %s',fpath)
    end
    %apply factor
    measurements_images{kf}.z=measurements_images{kf}.z.*measurements_structure(kf).Factor;
    %save time
    tim_mea(kf)=measurements_structure(kf).Time;
end %kf

tim_mea_dtime_mean=mean(tim_mea);

end %function