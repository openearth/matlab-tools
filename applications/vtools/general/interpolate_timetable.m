%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16592 $
%$Date: 2020-09-16 19:32:43 +0200 (Wed, 16 Sep 2020) $
%$Author: chavarri $
%$Id: function_layout.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/auxiliary/function_layout.m $
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

ng=numel(tim_ct);
tt_all=cell(ng,1);
for kg=1:ng
    tt_aux=timetable(tim_ct{1,kg},val_ct{1,kg});
    tt_all{kg,1}=tt_aux;
end
tt=synchronize(tt_all{:});
tt=retime(tt,'regular','linear','TimeStep',dt_disc);
tt_val=tt.Variables;
tt_tim=tt.Time;

end %function