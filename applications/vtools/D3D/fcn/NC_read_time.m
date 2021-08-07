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
%read time from NC file

function [time_dtime,units,time_r]=NC_read_time(nc_map,kt)

nci=ncinfo(nc_map);
time_r=ncread(nc_map,'time',kt(1),kt(2)); %results time vector [seconds/minutes/hours since start date]
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
[t0_dtime,units]=read_str_time(str_time);
switch units
    case 'seconds'
        time_dtime=t0_dtime+seconds(time_r);
    case 'minutes'
        time_dtime=t0_dtime+minutes(time_r);
    case 'hours'
        time_dtime=t0_dtime+hours(time_r);
    otherwise
        error('add')
end

end %function