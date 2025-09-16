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

function variable=SHP_get_variable(shp,tag_variable)

if ~ischar(tag_variable)
    error('Input must be char')
end

str_pol={tag_variable}; 
polnames=cellfun(@(X)X.Name,shp.val,'UniformOutput',false);
idx=find_str_in_cell(polnames,str_pol);
if any(isnan(idx))
    polnames
    error('Could not find variable in SHP: %s',tag_variable);
end

variable=shp.val{idx}.Val;

end %function