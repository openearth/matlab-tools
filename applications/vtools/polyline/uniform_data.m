%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 16:25:39 +0200 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_01.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_01.m $
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
