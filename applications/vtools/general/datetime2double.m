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

function [tim_double,tim_str]=datetime2double(dtime,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ref_time',dtime(1));
addOptional(parin,'unit','seconds');

parse(parin,varargin{:});

ref_time=parin.Results.ref_time;
unit=parin.Results.unit;

%% CALC

switch unit
    case 'seconds'
        tim_double=seconds(dtime-ref_time);
    case 'minutes'
        tim_double=minutes(dtime-ref_time);
    otherwise
        error('add')
end

tim_str=sprintf('%s since %s %s',unit,datestr(ref_time,'yyyy-mm-dd HH:MM:SS'),ref_time.TimeZone);

end %function