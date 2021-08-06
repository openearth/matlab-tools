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
%read string with time

function [t0_dtime,units]=read_str_time(str_time)

if iscell(str_time)
    error('input must be char')
end

tok=regexp(str_time,' ','split');
if numel(tok)>4
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
else
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','+00:00');
    messageOut(NaN,'There is no time zone. I assume +00:00');
end
units=tok{1,1};