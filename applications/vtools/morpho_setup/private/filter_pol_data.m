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
%

function [etab_cen,area_cen,loc_pol_num,rkm_pol_num,br_pol_num]=filter_pol_data(pol,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'coverage',0.99,@isnumeric);

parse(parin,varargin{:});

coverage_thr=parin.Results.coverage;

% fid_log=NaN; %file-log identifier (NaN = print to screen)

%% CALC

%% read

str_pol={'polygon:MEAN','polygon:COUNT','polygon:hm_nummer','polygon:Locatie','polygon:oppervlak_'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol))
    error('Could not find variable in shapefile %s. Maybe the variable name is different.',fpath_shp_tmp);
end

etab_cen=pol.val{idx_pol(1)}.Val; %should be in [m]

count=pol.val{idx_pol(2)}.Val;

ident_pol_str=pol.val{idx_pol(3)}.Val;
rkm_pol_num=cellfun(@(X)str2double(X(4:end)),ident_pol_str);
br_pol_num=cellfun(@(X)branch_rijntakken_str2double(X(1:2)),ident_pol_str);

loc_str=pol.val{idx_pol(4)}.Val;
loc_pol_num=cellfun(@(X)pol_str2double(X),loc_str);

area_cen=pol.val{idx_pol(5)}.Val;

%!!!!!!!!!!!!!!!!!!!
% CALL SHP_filer_coverage

%% filter

coverage_val=count./area_cen; %there is one point (count) per m^2
bol_coverage=coverage_val<coverage_thr;
etab_cen(bol_coverage)=NaN;

end %function