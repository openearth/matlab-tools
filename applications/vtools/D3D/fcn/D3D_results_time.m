%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17180 $
%$Date: 2021-04-12 14:58:48 +0200 (Mon, 12 Apr 2021) $
%$Author: chavarri $
%$Id: NC_read_map.m 17180 2021-04-12 12:58:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map.m $
%
%get data from 1 time step in D3D, output name as in D3D

function [time_r,time_mor_r,time_dnum]=D3D_results_time(nc_map,ismor)

nci=ncinfo(nc_map);
time_r=ncread(nc_map,'time',kt(1),kt(2)); %results time vector [seconds since start date]
if ismor
    time_mor_r=ncread(nc_map,'morft',kt(1),kt(2)); %results time vector [seconds since start date]
else 
    time_mor_r=NaN;
end
idx=find_str_in_cell({nci.Variables.Name},{'time'});
str_time=nci.Variables(idx).Attributes(2).Value;
tok=regexp(str_time,' ','split');
t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
switch tok{1,1}
    case 'seconds'
        time_dtime=t0_dtime+seconds(time_r);
    case 'minutes'
        time_dtime=t0_dtime+minutes(time_r);
    otherwise
        error('add')
end
time_dnum=datenum(time_dtime);