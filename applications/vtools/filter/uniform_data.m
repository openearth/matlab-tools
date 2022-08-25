%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18328 $
%$Date: 2022-08-23 14:42:59 +0200 (Tue, 23 Aug 2022) $
%$Author: chavarri $
%$Id: uniform_data.m 18328 2022-08-23 12:42:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/uniform_data.m $
%
%

function [time_uni,data_uni]=uniform_data(time_dtime,data)

% time_dnum=datenum(time_dtime); %we do operations in +00:00

% dt=diff(time_dtime);
dt_dtime_v=diff(time_dtime);
dt_dtime=dt_dtime_v(1); 
% if any(abs(dt-dt(1))>1e-8)
if any(abs(dt_dtime_v-dt_dtime)>seconds(1))
    time_uni=time_dtime(1):dt_dtime:time_dtime(end); %make input the step?
    data_uni=interpolate_timetable({time_dtime},{data},time_uni,'disp',0);
else
    time_uni=time_dtime;
    data_uni=data;
end
