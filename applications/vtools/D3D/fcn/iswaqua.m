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

function [is_wa,tim_str,tim_str_morpho,idx]=iswaqua(nc_map)

nci=ncinfo(nc_map);

tim_str='time';
tim_str_morpho='morft';
idx=find_str_in_cell({nci.Variables.Name},{tim_str});
is_wa=0;

if isnan(idx) %maybe it is WAQUA
    tim_str='TIME';
    tim_str_morpho='';
    idx=find_str_in_cell({nci.Variables.Name},{tim_str});
    is_wa=1;
end
if isnan(idx)
    error('Cannot find time variable here: %s',nc_map)
end

end %function