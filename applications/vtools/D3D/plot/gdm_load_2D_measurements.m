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

function [measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements(in_p,measurements_structure,time_dtime,time_dtime_0,x_lims,y_lims)

%% PARSE

in_p=isfield_default(in_p,'is_diff',0);
in_p=isfield_default(in_p,'do_measurements',1); %flag to be passed from input to `D3D_gdm`
in_p=isfield_default(in_p,'do_measurements_this_plot',1); %flag to be passed when calling `gdm_load_2D_measurements` such that no measurements processing is done in case the plot is a difference between simulation results.

%do not unpack `in_p`. There is a lot inside. 
is_diff=in_p.is_diff;
do_measurements=in_p.do_measurements;
do_measurements_this_plot=in_p.do_measurements_this_plot;

%% SKIP

if isempty_struct(measurements_structure) || do_measurements==0 || do_measurements_this_plot==0
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
    if nf0==0 || nf==0
        messageOut(NaN,'There are no measurements at the reference time or at the final time. I cannot substract them.')
        measurements_images=cell(0,0);
        tim_mea_dtime_mean=NaT;
        return
    end
    bol_keep=true(nf,1);
    for kf=1:nf
        switch measurements_images{kf}.type
            case 'tif'
                [measurements_images{kf},bol_keep(kf)]=substract_tif(measurements_images{kf},measurements_images_0);
            case 'shp'
                if nf0~=nf
                    error('The number of shapefiles at the reference time is different than at the final time. I cannot substract them.')
                end
                measurements_images{kf}.z=measurements_images{kf}.z-measurements_images_0{kf}.z;
            otherwise
                error('Unknown measurements image type: %s',measurements_images{kf}.type)
        end %switch
    end %kf
    measurements_images=measurements_images(bol_keep);
    if isempty(measurements_images)
        messageOut(NaN,'The measurements at the reference time and at the final time do not overlap. I cannot substract them.')
        measurements_images=cell(0,0);
        tim_mea_dtime_mean=NaT;
        return
    end
end %if

end %function 

%%
%% FUNCTIONS
%%

function [measurements_image,bol_keep]=substract_tif(measurements_image,measurements_images_0)

%The reference data set does not need to be tiled in the same way as the final one. Every reference
%image contributes to the part of the final image it overlaps with. 

nx=numel(measurements_image.x);
ny=numel(measurements_image.y);

z_dif=NaN(ny,nx);
mask_dif=zeros(ny,nx);
bol_dif=false(ny,nx);

nf0=numel(measurements_images_0);
for kf0=1:nf0
    if ~strcmp(measurements_images_0{kf0}.type,'tif')
        error('Measurements at the reference time are of type %s while measurements at the final time are of type tif. I cannot substract them.',measurements_images_0{kf0}.type)
    end
    [~,x_ia,x_ib]=intersect(measurements_image.x,measurements_images_0{kf0}.x);
    [~,y_ia,y_ib]=intersect(measurements_image.y,measurements_images_0{kf0}.y);
    if isempty(x_ia) || isempty(y_ia)
        messageOut(NaN,'The measurements at the reference time and at the final time do not overlap. I will try to shift the final image by 0.5 units.')
        measurements_image.x=measurements_image.x+0.5;
        measurements_image.y=measurements_image.y+0.5;
        [~,x_ia,x_ib]=intersect(measurements_image.x,measurements_images_0{kf0}.x);
        [~,y_ia,y_ib]=intersect(measurements_image.y,measurements_images_0{kf0}.y);
    end
    if isempty(x_ia) || isempty(y_ia)
        messageOut(NaN,'The measurements at the reference time and at the final time do not overlap even when shifting.')
        continue
    end
    z_dif(y_ia,x_ia)=measurements_image.z(y_ia,x_ia)-measurements_images_0{kf0}.z(y_ib,x_ib);
    mask_dif(y_ia,x_ia)=min(measurements_image.mask(y_ia,x_ia),measurements_images_0{kf0}.mask(y_ib,x_ib)); %valid only where both are valid
    bol_dif(y_ia,x_ia)=true;
end %kf0

bol_keep=any(bol_dif(:));
if ~bol_keep
    return
end

%crop to the region covered by the reference data set
bol_x=any(bol_dif,1);
bol_y=any(bol_dif,2);

measurements_image.x=measurements_image.x(bol_x);
measurements_image.y=measurements_image.y(bol_y);
measurements_image.z=z_dif(bol_y,bol_x);
measurements_image.mask=mask_dif(bol_y,bol_x);
measurements_image.mask(isnan(measurements_image.z))=0;

end %function

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
tol_y=in_p.tol_y_measurements;

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
    measurements_images=[];
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
tol_y=in_p.tol_y_measurements;

%% CALC

nf=numel(measurements_structure);

[x_plot,y_plot]=fcn_vector_plot_tif(measurements_structure,x_lims,y_lims);

% fprintf('min x = %f\n', min(x_plot));
% fprintf('min y = %f\n', min(y_plot));
% fprintf('max x = %f\n', max(x_plot));
% fprintf('max y = %f\n', max(y_plot));

nx=numel(x_plot);
ny=numel(y_plot);
z_plot=NaN(ny,nx);
m_plot=ones(ny,nx);

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
    measurements_images_loc.z=double(measurements_images_loc.z).*measurements_structure(kf).Factor;
    %save time
    tim_mea(kf)=measurements_structure(kf).Time;

    bol_x_plot=ismember(x_plot,measurements_images_loc.x);
    bol_y_plot=ismember(y_plot,measurements_images_loc.y);
    bol_x_read=ismember(measurements_images_loc.x,x_plot);
    bol_y_read=ismember(measurements_images_loc.y,y_plot);

    %% DEBUG

    % [idx_1,min_1]=absmintol(x_plot,1.76168e5,10)
    % [idx_2,min_2]=absmintol(measurements_images_loc.x,1.76168e5,10)
    % figure;
    % hold on; 
    % plot(x_plot,ones(size(x_plot)),'-*r')
    % plot(measurements_images_loc.x,ones(size(measurements_images_loc.x)),'-ob'); 
    % figure;
    % hold on; 
    % plot(y_plot,ones(size(y_plot)),'-*r')
    % plot(measurements_images_loc.y,ones(size(measurements_images_loc.y)),'-ob'); 


    %%
    if (sum(bol_x_read) == 0)
        warning('x-coordinate shifted by 0.5 in %s', fpath);
        bol_x_plot=ismember(x_plot,measurements_images_loc.x+0.5);
        bol_x_read=ismember(measurements_images_loc.x+0.5,x_plot);
    end
    if (sum(bol_y_read) == 0)
        warning('y-coordinate shifted by 0.5 in %s', fpath);
        bol_y_plot=ismember(y_plot,measurements_images_loc.y+0.5);
        bol_y_read=ismember(measurements_images_loc.y+0.5,y_plot);
    end

    %only add values which are not alreay filled (i.e., are not NaN)
    z_plot_existing=z_plot(bol_y_plot,bol_x_plot);
    m_plot_existing=m_plot(bol_y_plot,bol_x_plot); %extract existing mask values in the selected region
    bol_xy_nan=isnan(z_plot_existing); %matrix of NaN values in the selected region

    z_plot_loc=measurements_images_loc.z(bol_y_read,bol_x_read);
    z_plot_existing(bol_xy_nan)=z_plot_loc(bol_xy_nan); %replace nan values in existing region by corresponding values from the loaded measurements
    z_plot(bol_y_plot,bol_x_plot)=z_plot_existing;

    m_plot_loc=measurements_images_loc.mask(bol_y_read,bol_x_read);
    m_plot_existing(bol_xy_nan)=m_plot_loc(bol_xy_nan); %replace nan values in existing region by corresponding values from the loaded measurements
    m_plot(bol_y_plot,bol_x_plot)=m_plot_existing;

    %% DEBUG

    % figure
    % imagesc(x_plot,fliplr(y_plot),z_plot)
    % axis equal

end %kf

measurements_images{1}.x=x_plot;
measurements_images{1}.y=y_plot;
measurements_images{1}.z=z_plot;
measurements_images{1}.mask=m_plot;
measurements_images{1}.mask(isnan(measurements_images{1}.z))=0;%
measurements_images{1}.type='tif';

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
tol_y=in_p.tol_y_measurements;
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

%%

function y_plot=fcn_vector_plot(y_vector,y_lims)

dy=diff(y_vector(1:2));
[y_vector_sort,idx_y] = sort(y_vector);
idx=absmintol(y_vector_sort,y_lims(1),'tol',1e10);
yl=y_vector_sort(idx);
idx=absmintol(y_vector_sort,y_lims(2),'tol',1e10);
yu=y_vector_sort(idx);
y_plot=construct_y_plot(yl,yu,dy);
% y_plot=yl:abs(dy):yu;
% if sign(dy)<0
%     y_plot=fliplr(y_plot); %y is reversed
% end

%% DEBUG

% fprintf('%f\n',y_vector_sort(1))
% fprintf('%f\n',y_vector(1))
% fprintf('%f\n',yl)
% fprintf('%f\n',yu)

%%

end %function

%%

function [x_plot,y_plot]=fcn_vector_plot_tif(measurements_structure,x_lims,y_lims)

dy=NaN;
dx=NaN;
yl=NaN;
yu=NaN;
xl=NaN;
xu=NaN;
for kf=1:numel(measurements_structure)

    fpath=measurements_structure(kf).Filename;
    [~,~,x_vector,y_vector]=TIF_info(fpath);

    dy_loc=diff(y_vector(1:2));
    dx_loc=diff(x_vector(1:2));

    if isnan(dy)
        dy=dy_loc;
    end
    if isnan(dx)
        dx=dx_loc;
    end
    if dx~=dx_loc || dy~=dy_loc
        messageOut(NaN,sprintf('Inconsistent grid spacing in %s\n', fpath));
    end

    y_plot_loc=fcn_vector_plot(y_vector,y_lims);
    x_plot_loc=fcn_vector_plot(x_vector,x_lims);

    yl=min(yl,min(y_plot_loc));
    yu=max(yu,max(y_plot_loc));
    xl=min(xl,min(x_plot_loc));
    xu=max(xu,max(x_plot_loc));

end

y_plot=construct_y_plot(yl,yu,dy);
x_plot=construct_y_plot(xl,xu,dx);

%% DEBUG

% fprintf('%f\n',x_vector)
% fprintf('%f\n',y_vector)
% fprintf('%f\n',x_vector(1))
% fprintf('%f\n',y_vector(1))
% fprintf('%f\n',x_lims(1))
% fprintf('%f\n',x_lims(2))
% fprintf('%f\n',y_lims(1))
% fprintf('%f\n',y_lims(2))

% figure;
% hold on;
% plot(x_vector)


end %function

%%

function y_plot=construct_y_plot(yl,yu,dy)

y_plot=yl:abs(dy):yu;
if sign(dy)<0
    y_plot=fliplr(y_plot); %y is reversed
end

end %function
