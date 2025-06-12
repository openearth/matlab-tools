%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18982 $
%$Date: 2023-06-08 10:31:31 +0200 (Thu, 08 Jun 2023) $
%$Author: chavarri $
%$Id: NC_read_time_0.m 18982 2023-06-08 08:31:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_time_0.m $
%
%Read time string and index of a NetCDF file

function [idx,tim_str]=NC_time_string_index(fpath_nc)

nci=ncinfo(fpath_nc);

tim_str_v={'time','TIME','valid_time'};
tim_str_in_data={nci.Variables.Name};
bol_tim=ismember(tim_str_in_data,tim_str_v);
if sum(bol_tim)==1
    idx=find(bol_tim);
elseif sum(bol_tim)==0
    error('No variable matches the possible time strings.')
else
    error('More than 1 ')
end

tim_str=tim_str_in_data{idx};

end %function