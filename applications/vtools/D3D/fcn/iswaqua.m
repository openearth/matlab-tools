%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 11:17:04 +0200 (do, 30 sep 2021) $
%$Author: chavarri $
%$Id: NC_read_time_0.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_time_0.m $
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