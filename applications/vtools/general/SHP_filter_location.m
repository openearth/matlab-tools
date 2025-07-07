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
%Get only polygons in SHP that are R1, R2, R3, L1, ...
%Specific for Maas and Rijntakken. 

function variable=SHP_filter_location(pol,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tag_location','polygon:Locatie');
addOptional(parin,'pol_location',[-3:1:1,1:1:3]);
addOptional(parin,'tag_variable','polygon:MEAN');

parse(parin,varargin{:});

tag_location=parin.Results.tag_location;
pol_location=parin.Results.pol_location;
tag_variable=parin.Results.tag_variable;

%% CALC

%% read

variable=SHP_get_variable(pol,tag_variable); %must be in [m]
loc_str=SHP_get_variable(pol,tag_location);
loc_num=cellfun(@(X)pol_str2double(X),loc_str);

%% filter

bol_loc=ismember(loc_num,pol_location);
variable(~bol_loc)=NaN;

end %function