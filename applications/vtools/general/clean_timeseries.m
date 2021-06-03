%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17273 $
%$Date: 2021-05-07 21:37:43 +0200 (Fri, 07 May 2021) $
%$Author: chavarri $
%$Id: absolute_limits.m 17273 2021-05-07 19:37:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%clear time series

function [tim,val]=clean_timeseries(tim,val,TimeStep)

data_r=timetable(tim,val);
data_r=rmmissing(data_r);
data_r=sortrows(data_r);
tim_u=unique(data_r.tim);
data_r=retime(data_r,tim_u,'mean'); 
data_r=retime(data_r,'regular','linear','TimeStep',TimeStep);
tim=data_r.tim;
val=data_r.val;