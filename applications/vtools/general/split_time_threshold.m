%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19773 $
%$Date: 2024-09-05 16:20:30 +0200 (Thu, 05 Sep 2024) $
%$Author: chavarri $
%$Id: plot_his_01.m 19773 2024-09-05 14:20:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_01.m $
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