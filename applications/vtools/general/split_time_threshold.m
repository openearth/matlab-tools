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
%Add NaT when time series index is above a threshold such 
%that when plotting there is no line between two data
%points too far apart.

function [tim_a,val_a]=split_time_threshold(tim,val,threshold)

dt=diff(tim);
idx_a=find(dt>threshold);
idx_a=[0;idx_a;numel(tim)];
na=numel(idx_a)-1;
tim_a=[];
val_a=[];
nat_tz=NaT;
nat_tz.TimeZone=tim.TimeZone;
for ka=1:na
    tim_a=cat(1,tim_a,tim(idx_a(ka)+1:idx_a(ka+1)),nat_tz);
    val_a=cat(1,val_a,val(idx_a(ka)+1:idx_a(ka+1)),NaN);
end

end %function