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

function [variable,area_cov]=SHP_filter_coverage(pol,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'coverage',0.99,@isnumeric);
addOptional(parin,'tag_variable','polygon:MEAN');
addOptional(parin,'tag_count','polygon:COUNT');
addOptional(parin,'tag_area','polygon:oppervlak_');

parse(parin,varargin{:});

coverage_thr=parin.Results.coverage;
tag_variable=parin.Results.tag_variable;
tag_count=parin.Results.tag_count;
tag_area=parin.Results.tag_area;

%% CALC

%% read

variable=SHP_get_variable(pol,tag_variable); %must be in [m]
count=SHP_get_variable(pol,tag_count);
area_cov=SHP_get_variable(pol,tag_area);

%% filter

coverage_val=count./area_cov; %there is one point (count) per m^2
bol_coverage=coverage_val<coverage_thr;
variable(bol_coverage)=NaN;

end %function