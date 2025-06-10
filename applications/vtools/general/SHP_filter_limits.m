%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19028 $
%$Date: 2023-07-04 08:38:28 +0200 (Tue, 04 Jul 2023) $
%$Author: chavarri $
%$Id: filter_pol_data.m 19028 2023-07-04 06:38:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/filter_pol_data.m $
%
%

function variable=SHP_filter_limits(shp,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'x_limits',[-inf,inf]);
addOptional(parin,'y_limits',[-inf,inf]);
addOptional(parin,'tag_variable','polygon:MEAN');

parse(parin,varargin{:});

x_limits=parin.Results.x_limits;
y_limits=parin.Results.y_limits;
tag_variable=parin.Results.tag_variable;

%% CALC

variable=SHP_get_variable(shp,tag_variable); 

MinX=cellfun(@(X)min(X(:,1)),shp.xy.XY);
MinY=cellfun(@(X)min(X(:,2)),shp.xy.XY);
MaxX=cellfun(@(X)max(X(:,1)),shp.xy.XY);
MaxY=cellfun(@(X)max(X(:,2)),shp.xy.XY);

bol_x= MaxX>x_limits(1) & MinX<x_limits(2);
bol_y= MaxY>y_limits(1) & MinY<y_limits(2);

bol_get=bol_x & bol_y;

variable(~bol_get)=NaN;

end %function