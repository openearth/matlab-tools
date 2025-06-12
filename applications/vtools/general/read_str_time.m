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

t0_dtime=NaT;
units='';
tzone='';
tzone_num=NaN;

if iscell(str_time)
    error('input must be char')
end

%% date and time
tok=regexp(str_time,' ','split');
if numel(tok)<3
    messageOut(NaN,sprintf('This time string cannot be processed: %s',str_time))
    return
elseif numel(tok)<4
    %seconds since 1970-01-01
    date_str=tok{1,3};
    hour_str='00:00:00';
    tzone='+00:00';
    messageOut(NaN,'There is no time nor time zone. I assume 00:00:00 +00:00');
elseif numel(tok)<5
    %seconds since 2000-01-01 00:00:00
    date_str=tok{1,3};
    hour_str=tok{1,4};
    tzone='+00:00';
    messageOut(NaN,'There is no time zone. I assume +00:00');
else
    %seconds since 2000-01-01 00:00:00 +00:00
    date_str=tok{1,3};
    hour_str=tok{1,4};
    tzone=tok{1,5};
end
t0_dtime=datetime(sprintf('%s %s',date_str,hour_str),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tzone);

%% unit
units=tok{1,1};

%% timezone
tok=regexp(tzone,'([+-]?)(\d{2}):(\d{2})','tokens');
s=tok{1,1}{1,1};
h=str2double(tok{1,1}{1,2});
m=str2double(tok{1,1}{1,3});
tzone_num=h+m/60;
if strcmp(s,'-')
    tzone_num=-tzone_num;
end

end %function