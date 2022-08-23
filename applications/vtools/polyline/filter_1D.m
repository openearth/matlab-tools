%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 16:25:39 +0200 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_01.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_01.m $
%
%

function [tim_f,data_f]=filter_1D(time_dtime,data,varargin)
            
%% PARSE

parin=inputParser;

addOptional(parin,'method','mean');
addOptional(parin,'window',25*3600);

parse(parin,varargin{:});

method=parin.Results.method;
window=parin.Results.window;

%% CALC

switch method
    case 'mean'
        tim_f=time_dtime(1):seconds(window):time_dtime(end);
        data_f=interpolate_timetable({time_dtime},{data},tim_f,'disp',0); %make the input to work if several stations?
    case 'movmean'
        [data_f,tim_f]=movmean_tim(time_dtime,data,window);
    case 'godin'
        [time_dtime,data]=uniform_data(time_dtime,data);
        time_dnum_00=datenum(time_dtime);
        [data_f,tim_f_dnum]=godin(time_dnum_00,data); %deal with several stations
        tim_f=datetime(tim_f_dnum,'convertFrom','datenum','TimeZone',time_dtime.TimeZone);
end

end %function