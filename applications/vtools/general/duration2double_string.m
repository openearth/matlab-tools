%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17637 $
%$Date: 2021-12-08 22:21:26 +0100 (wo, 08 dec 2021) $
%$Author: chavarri $
%$Id: parse_layout.m 17637 2021-12-08 21:21:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/parse_layout.m $
%

function [str,days_d,hours_d,minutes_d,seconds_d]=duration2double_string(dur)

dur_rem=dur;
days_d=floor(days(dur_rem));

dur_rem=dur_rem-days(days_d);
hours_d=floor(hours(dur_rem));

dur_rem=dur_rem-hours(hours_d);
minutes_d=floor(minutes(dur_rem));

dur_rem=dur_rem-minutes(minutes_d);
seconds_d=floor(seconds(dur_rem));

str=sprintf('%d-%02d:%02d:%02d',days_d,hours_d,minutes_d,seconds_d);

end %function