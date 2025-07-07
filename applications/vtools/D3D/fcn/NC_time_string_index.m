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