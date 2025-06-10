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

function variable=SHP_get_variable(shp,tag_variable)

if ~ischar(tag_variable)
    error('Input must be char')
end

str_pol={tag_variable}; 
polnames=cellfun(@(X)X.Name,shp.val,'UniformOutput',false);
idx=find_str_in_cell(polnames,str_pol);
if any(isnan(idx))
    tag_variables
    error('Could not find variable in SHP: %s',tag_variable);
end

variable=shp.val{idx}.Val;

end %function