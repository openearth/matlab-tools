%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17450 $
%$Date: 2021-08-06 12:39:00 +0200 (Fri, 06 Aug 2021) $
%$Author: chavarri $
%$Id: read_str_time.m 17450 2021-08-06 10:39:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/read_str_time.m $
%
%read time 0 properties

function [t0_dtime,units,tzone,tzone_num]=NC_read_time_0(nc_map)
nci=ncinfo(nc_map);
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
[t0_dtime,units,tzone,tzone_num]=read_str_time(str_time);

end %function
