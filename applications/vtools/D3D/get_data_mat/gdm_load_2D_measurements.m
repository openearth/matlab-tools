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

function [measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements(in_p,measurements_structure,time_dtime,time_dtime_0,xlims,ylims)

%% PARSE

in_p=isfield_default(in_p,'tol_x_measurements',1000); 
in_p=isfield_default(in_p,'tol_y_measurements',1000); 
in_p=isfield_default(in_p,'tol_time_measurements',days(30)); 
in_p=isfield_default(in_p,'is_diff',0); 
if ~isduration(in_p.tol_time_measurements)
    in_p.tol_time_measurements=days(in_p.tol_time_measurements);
end

tim_tol_dur=in_p.tol_time_measurements; 
tol_x=in_p.tol_x_measurements;
tol_y=in_p.tol_x_measurements;
is_diff=in_p.is_diff;

%% SKIP

% in_p.do_measurements=0; %better to pass the actual output

if isempty_struct(measurements_structure)
    measurements_images=cell(0,0);
    tim_mea_dtime_mean=NaT;
    return
end

%% CALC

[measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements_single(measurements_structure,time_dtime,xlims,ylims,tim_tol_dur,tol_x,tol_y);   

if is_diff
    measurements_images_0=gdm_load_2D_measurements_single(measurements_structure,time_dtime_0,xlims,ylims,tim_tol_dur,tol_x,tol_y);   
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

function [measurements_images,tim_mea_dtime_mean]=gdm_load_2D_measurements_single(measurements_structure,time_dtime,xlims,ylims,tim_tol_dur,tol_x,tol_y)

if isempty(measurements_structure(1).Time(1).TimeZone)
    error('There is no timezone! This should be dealt when initializing. Not sure how you got here. ')
end

bol_tim=[measurements_structure.Time]>time_dtime      -tim_tol_dur & [measurements_structure.Time]<time_dtime      +tim_tol_dur;
bol_x=  [measurements_structure.MaxX]>xlims(1)        -tol_x       & [measurements_structure.MinX]<xlims(2)        +tol_x;
bol_y=  [measurements_structure.MaxY]>ylims(1)        -tol_y       & [measurements_structure.MinY]<ylims(2)        +tol_y;

idx_get=find(bol_tim & bol_x & bol_y);

nf=numel(idx_get);
measurements_images=cell(nf,1);
tim_mea=NaT(nf,1);
tim_mea.TimeZone=time_dtime.TimeZone;

for kf=1:nf
    fpath=measurements_structure(idx_get(kf)).Filename;
    [~,~,fext]=fileparts(fpath);
    switch fext
        case '.tif'
            %read image
            measurements_images{kf}=readgeotiff(fpath,'x_limits',xlims+[-tol_x,+tol_x],'y_limits',ylims+[-tol_y,+tol_y]);
        case '.shp'
            measurements_images{kf}=read_shp(fpath,'x_limits',xlims+[-tol_x,+tol_x],'y_limits',ylims+[-tol_y,+tol_y]);
        otherwise
            error('Unknown format: %s',fpath)
    end
    %apply factor
    measurements_images{kf}.z=measurements_images{kf}.z.*measurements_structure(idx_get(kf)).Factor;
    %save time
    tim_mea(kf)=measurements_structure(idx_get(kf)).Time;
end %kf

tim_mea_dtime_mean=mean(tim_mea);

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