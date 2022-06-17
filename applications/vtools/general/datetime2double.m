%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18084 $
%$Date: 2022-05-31 15:22:48 +0200 (Tue, 31 May 2022) $
%$Author: chavarri $
%$Id: D3D_io_input.m 18084 2022-05-31 13:22:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
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