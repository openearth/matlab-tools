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
%

function [tim_f,data_f]=filter_1D(time_dtime,data,varargin)
            
%% PARSE

parin=inputParser;

addOptional(parin,'method','mean');
addOptional(parin,'window',25*3600);
addOptional(parin,'time',NaN);

parse(parin,varargin{:});

method=parin.Results.method;
window=parin.Results.window;
tim_f=parin.Results.time;


%% CALC

switch method
    case 'mean'
        if ~isdatetime(tim_f)
            tim_f=time_dtime(1):seconds(window):time_dtime(end);
        end
        data_f=interpolate_timetable({time_dtime},{data},tim_f,'disp',0); %make the input to work if several stations?
    case 'movmean'
        [data_f,tim_f]=movmean_tim(time_dtime,data,window);
    case 'godin'
        if isvector(data)
            data=reshape(data,[],1);
        end
        ks=1;
        [time_dtime,data_u]=uniform_data(time_dtime,data(:,ks));
        time_dnum_00=datenum(time_dtime);
        [data_f0,tim_f_dnum]=godin(time_dnum_00,data_u); %deal with several stations
        tim_f=datetime(tim_f_dnum,'convertFrom','datenum','TimeZone',time_dtime.TimeZone);
        
        ns=size(data,2);
        np=numel(data_f0);
        data_f=NaN(np,ns);
        data_f(:,1)=data_f0;
        for ks=1:ns
            [time_dtime,data_u]=uniform_data(time_dtime,data(:,ks));
            [data_f(:,ks),~]=godin(time_dnum_00,data_u); %deal with several stations
        end
        
end

end %function