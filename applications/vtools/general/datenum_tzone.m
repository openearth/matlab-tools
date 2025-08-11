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
%datenum considering time zone

function tim_dnum=datenum_tzone(tim_dtime)

tzone=tim_dtime.TimeZone;
if isempty(tzone)
    op='+';
    hs=0;
    ms=0;
else
    tok=regexp(tzone,'([+-])(\d{2}):(\d{2})','tokens');
    if isempty(tok)
        error('improve the string')
    end
    op=tok{1,1}{1,1};
    hs=str2double(tok{1,1}{1,2});
    ms=str2double(tok{1,1}{1,3});
end

%If the time zone is positive, we have to subtract and viceversa!
switch op
    case '+'
        tim_dnum=datenum(tim_dtime)-(hs/24+ms/(24/60));
    case '-'
        tim_dnum=datenum(tim_dtime)+(hs/24+ms/(24/60));
end

end %function