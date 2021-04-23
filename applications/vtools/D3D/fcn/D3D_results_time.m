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
%get data from 1 time step in D3D, output name as in D3D

function [time_r,time_mor_r,time_dnum]=D3D_results_time(nc_map,ismor,kt)

[~,fname,~]=fileparts(nc_map);
ismap=0;
if contains(fname,'_map')
    ismap=1;
end

nci=ncinfo(nc_map);
time_r=ncread(nc_map,'time',kt(1),kt(2)); %results time vector [seconds since start date]
if ismor && ismap %morfo time not available in history
    time_mor_r=ncread(nc_map,'morft',kt(1),kt(2)); %results time vector [seconds since start date]
else 
    time_mor_r=NaN;
end
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
tok=regexp(str_time,' ','split');
if numel(tok)>4
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
else
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','+00:00');
end
switch tok{1,1}
    case 'seconds'
        time_dtime=t0_dtime+seconds(time_r);
    case 'minutes'
        time_dtime=t0_dtime+minutes(time_r);
    otherwise
        error('add')
end
time_dnum=datenum(time_dtime);