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

function [t0_dtime,units,tzone,tzone_num]=read_str_time(str_time)

if iscell(str_time)
    error('input must be char')
end

tok=regexp(str_time,' ','split');
if numel(tok)>4
    tzone=tok{1,5};
else
    tzone='+00:00';
    messageOut(NaN,'There is no time zone. I assume +00:00');
end
t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tzone);
units=tok{1,1};
tok=regexp(tzone,'([+-]?)(\d{2}):(\d{2})','tokens');
s=tok{1,1}{1,1};
h=str2double(tok{1,1}{1,2});
m=str2double(tok{1,1}{1,3});
tzone_num=h+m/60;
if strcmp(s,'-')
    tzone_num=-tzone_num;
end