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