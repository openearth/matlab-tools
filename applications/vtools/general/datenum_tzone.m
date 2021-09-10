%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17450 $
%$Date: 2021-08-06 12:39:00 +0200 (Fri, 06 Aug 2021) $
%$Author: chavarri $
%$Id: read_str_time.m 17450 2021-08-06 10:39:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/read_str_time.m $
%
%datenum considering time zone

function tim_dnum=datenum_tzone(tim_dtime)

tzone=tim_dtime.TimeZone;
tok=regexp(tzone,'([+-])(\d{2}):(\d{2})','tokens');
if isempty(tok)
    error('improve the string')
end
op=tok{1,1}{1,1};
hs=str2double(tok{1,1}{1,2});
ms=str2double(tok{1,1}{1,3});
switch op
    case '+'
        tim_dnum=datenum(tim_dtime)+(hs/24+ms/(24/60));
    case '-'
        tim_dnum=datenum(tim_dtime)-(hs/24+ms/(24/60));
end
