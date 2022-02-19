%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Interpolates several time series into a common time vector.
%
%INPUT:
%   -tim_ct: cell array with time of time series
%   -val_ct: cell array with values of time series
%   -dt_disc: time step to interpolate the time series
%
%OUTPUT:
%   -tt_tim: common time of all time series
%   -tt_val: interpolated values of all time series

function [tt_tim,tt_val]=interpolate_timetable(tim_ct,val_ct,dt_disc)

%% PARSE

% if nargin>3
%     do_average=true;
%     dt_av=varargin{1,1};
% end

%% CALC

%% synchronize

ng=numel(tim_ct);
tt_all=cell(ng,1);
for kg=1:ng
    tt_aux=timetable(tim_ct{1,kg},val_ct{1,kg});
    tt_all{kg,1}=tt_aux;
end
tt=synchronize(tt_all{:});
% tt1=retime(tt,'regular','linear','TimeStep',dt_disc); %linear takes the closest points and interpolates in between without considering the points in between
tt=retime(tt,'regular','mean','TimeStep',dt_disc);
tt_val=tt.Variables;
tt_tim=tt.Time;

%%
% figure
% hold on
% plot(tim_ct{1},val_ct{1},'-o')
% plot(tt1.Time,tt1.Var1_1,'-s')
% plot(tt2.Time,tt2.Var1_1,'-*')
%% average

% if do_average
%     tt_avg=retime(tt,dt_av,'mean');
% end %average

end %function