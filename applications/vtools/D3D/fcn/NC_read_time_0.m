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
%read time 0 properties

function [t0_dtime,units,tzone,tzone_num]=NC_read_time_0(nc_map)
nci=ncinfo(nc_map);
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
[t0_dtime,units,tzone,tzone_num]=read_str_time(str_time);

end %function
