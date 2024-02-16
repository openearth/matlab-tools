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