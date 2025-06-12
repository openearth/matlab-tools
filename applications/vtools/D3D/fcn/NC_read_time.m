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
%read time from NC file

function [time_dtime,units,time_r]=NC_read_time(fpath_nc,kt,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'type','hydro')

parse(parin,varargin{:});

tim_type=parin.Results.type;

%% CALC

[t0_dtime,units,~,~,tim_str]=NC_read_time_0(fpath_nc);

switch tim_type
    case 'morpho'
        tim_str='morft';
end

time_r=ncread(fpath_nc,tim_str,kt(1),kt(2)); %results time vector [seconds/minutes/hours since start date]

switch units
    case 'seconds'
        time_dtime=t0_dtime+seconds(time_r);
    case 'minutes'
        time_dtime=t0_dtime+minutes(time_r);
    case 'hours'
        time_dtime=t0_dtime+hours(time_r);
    case 'days'
        time_dtime=t0_dtime+days(time_r);
    otherwise
        error('add')
end

end %function