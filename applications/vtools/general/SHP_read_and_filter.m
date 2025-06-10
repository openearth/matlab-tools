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
%Read SHP file and filter data from it. 

function measurements_images=SHP_read_and_filter(fpath,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x_limits',[-inf,inf]);
addOptional(parin,'y_limits',[-inf,inf]);
addOptional(parin,'coverage',0.99,@isnumeric);
addOptional(parin,'tag_variable','polygon:MEAN');
addOptional(parin,'tag_count','polygon:COUNT');
addOptional(parin,'tag_area','polygon:oppervlak_');
addOptional(parin,'pol_location',[-3:1:1,1:1:3]);
addOptional(parin,'tag_location','polygon:Locatie');

parse(parin,varargin{:});

x_limits=parin.Results.x_limits;
y_limits=parin.Results.y_limits;
coverage_thr=parin.Results.coverage;
tag_variable=parin.Results.tag_variable;
tag_count=parin.Results.tag_count;
tag_area=parin.Results.tag_area;
pol_location=parin.Results.pol_location;
tag_location=parin.Results.tag_location;

%% CALC

shp=D3D_io_input('read',fpath,'read_val',true);

var_coverage=SHP_filter_coverage(shp,'coverage',coverage_thr,'tag_variable',tag_variable,'tag_count',tag_count,'tag_area',tag_area);
var_location=SHP_filter_location(shp,'tag_location',tag_location,'pol_location',pol_location,'tag_variable',tag_variable);
var_limits=SHP_filter_limits(shp,'tag_variable',tag_variable,'x_limits',x_limits,'y_limits',y_limits);

%remove on location, make nan of the rest. Otherwise it is not possible to
%make a difference between shp. 
variable=var_coverage; %any will do
bol_nan=isnan(var_coverage) | isnan(var_location);
bol_xy=~isnan(var_limits);

variable(bol_nan)=NaN;

measurements_images.pol=shp.xy.XY(bol_xy);
measurements_images.z=variable(bol_xy); 

end %function
