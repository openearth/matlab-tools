
function [time_dtime,units]=NC_read_time(nc_map,kt)

nci=ncinfo(nc_map);
time_r=ncread(nc_map,'time',kt(1),kt(2)); %results time vector [seconds/minutes/hours since start date]
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
tok=regexp(str_time,' ','split');
if numel(tok)>4
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
else
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','+00:00');
end
units=tok{1,1};
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