%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create a set of steady discharges from a hydrograph. Particularly
%usefull for SMT simulation.
%
%INPUT:
%   - time_limits    = initial and final time to derive the time series [datetime(2,1) with time zone]. 
%   - Q_steadyMorFac = set of stedy discharges to discretize the time series and associated MorFac [double(nQ,2)].
%
%OUTPUT:
%   - An ASCII file in the format of Qseries for SMT. 
%
%PAIR INPUT:
%   - fpaths_data_stations = path to folder containint <data_stations> [string]
%   - location_clear       = flag `location_clear` in <data_stations> to read [string].
%   - power_Q_dom          = power of the dominant discharge for bed slope. It is by default equal to 5/3, which is the analytical value assuming Engelund-Hansen (1967) sediment transport relation. [double(1,1)]
%   - extend_time_series   = extend the time series in case the last value in the data is for a time before the end time limit. It copies the last value in the time serie to the end time of analysis. 1 = DO; 2 = DON'T DO. [double(1,1)]
%   - fpath_dir_out        = path to folder to write the output file.
%   - dt                   = time step for resampling the input time series before matching with the discharges in `Q_steady`. [duration(1,1)]

function discretize_hydrograph(time_limits,Q_steadyMorfac,varargin)

%% PARSE

%parin
parin=inputParser;

addOptional(parin,'location_clear','')
addOptional(parin,'fpaths_data_stations','')
addOptional(parin,'extend_time_series',0)
addOptional(parin,'power_Q_dom',5/3)
addOptional(parin,'fpath_dir_out',pwd)
addOptional(parin,'dt',days(1))

parse(parin,varargin{:})

location_clear=parin.Results.location_clear;
fpaths_data_stations=parin.Results.fpaths_data_stations;
extend_time_series=parin.Results.extend_time_series;
power_Q_dom=parin.Results.power_Q_dom;
fpath_dir_out=parin.Results.fpath_dir_out;
dt=parin.Results.dt;

%check
if size(Q_steadyMorfac,2)~=2
    error('`Q_steadyMorfac` should be have size [nQ,2], where `nQ` is the number of discharges.')
end

Q_steady=Q_steadyMorfac(:,1);
MorFac=Q_steadyMorfac(:,2);

%% CALC

[tim,val]=load_data(location_clear,fpaths_data_stations);

time_limits=parse_time_limits(tim,time_limits);

[tim,val]=extend_series(tim,val,time_limits,extend_time_series);

[tim,val]=filter_series(tim,val,time_limits,fpath_dir_out,'01');

[tim,val]=resample_series(tim,val,dt,time_limits,fpath_dir_out);

[tim,val]=filter_series(tim,val,time_limits,fpath_dir_out,'02');

idx=index_steady_discharge(power_Q_dom,Q_steady,val,tim,fpath_dir_out);

[tim_dt,Q_disc_join]=join_Q(Q_steady,tim,idx,MorFac);

write_Qseries(tim_dt,Q_disc_join,fpath_dir_out)

end %function

%%
%% FUNCTIONS
%%

%%
function [tim,val]=load_data(location_clear,fpaths_data_stations)

if ~isempty(location_clear) || ~isempty(fpaths_data_stations)
    data_stations=read_data_stations(fpaths_data_stations,'location_clear',location_clear,'grootheid','Q');
    
    if numel(data_stations)~=1
        error('There is more than one dataset.')
    end
    
    tim=data_stations.time;
    val=data_stations.waarde;
else
    error('Different method to load data needs to be implemented.')
end

end %function

%%

%ad_hoc! Add data to complete the year...
function [tim,val]=extend_series(tim,val,time_limits,extend_time_series)

switch extend_time_series
    case 1        
        tim=[tim;time_limits(2)];
        val=[val;val(end)];
end

end %function

%%

function [tim,val]=filter_series(tim_in,val_in,time_limits,fpath_dir_out,str_add)

bol_tim=tim_in>=time_limits(1) & tim_in<=time_limits(2);
tim=tim_in(bol_tim);
val=val_in(bol_tim);

bol_out=val<0;
if any(bol_out)
    fprintf('%d data points with negative discharge removed. \n',sum(bol_out))
    tim=tim(~bol_out);
    val=val(~bol_out);
end

bol_out=isnan(val);
if any(bol_out)
    fprintf('%d data points with NaN removed. \n',sum(bol_out))
    tim=tim(~bol_out);
    val=val(~bol_out);
end

%plot
figure
hold on
plot(tim_in,val_in,'b')
plot(tim_in,val_in,'r')
legend('original','filtered')
printV(gcf,fullfile(fpath_dir_out,sprintf('filter_%s.png',str_add)))
printV(gcf,fullfile(fpath_dir_out,sprintf('filter_%s.fig',str_add)))

end %function

%%

function [tim,val]=resample_series(tim_in,val_in,dt,time_limits,fpath_dir_out)

tim=time_limits(1)+dt/2:dt:time_limits(2)-dt/2;

val=interpolate_timetable({tim_in},{val_in},tim);

%plot
figure
hold on
plot(tim_in,val_in)
plot(tim,val)
legend('filtered','resampled')
printV(gcf,fullfile(fpath_dir_out,'resample.png'))
printV(gcf,fullfile(fpath_dir_out,'resample.fig'))

end %function

%%

function idx=index_steady_discharge(power_Q_dom,Q_steady,val,tim,fpath_dir_out)

idx=interp1(Q_steady.^(power_Q_dom),1:numel(Q_steady),val.^(power_Q_dom),'nearest','extrap');

%check
if any(idx<1) || any(mod(idx,1)) || any(isnan(val)) || any(isnan(idx))
    error('Something is not correct.')
end

%plot
figure
hold on; 
plot(tim,val,'b')
plot(tim,Q_steady(idx),'r')
legend({'resampled','discrete'})
printV(gcf,fullfile(fpath_dir_out,'discrete.png'))
printV(gcf,fullfile(fpath_dir_out,'discrete.fig'))

end %function

%%

function [tim_dt,Q_disc_join]=join_Q(Q_steady,tim,idx,MorFac)

%% PARSE

if numel(MorFac)~=numel(Q_steady)
    error('The size of MorFac should be equal to the size of ')
end

%% CALC

Q_disc=Q_steady(idx); %[nidx,1]
bol_tr=diff(Q_disc)~=0; %a 1 at index 5 (i.e., bol_tr(5)=1) implies that there have been 5 days with a constant discharge.
bol_trt=[false;bol_tr;false]; %[nidx+1,1]
tim_cor=cen2cor(tim)'; %[nidx+1,1]. Output of `cen2cor` is [1,nt] no matter the input, we transpose. 
tim_tr=tim_cor(bol_trt); %[ndisc-2,1]
tim_tr=[tim_cor(1);tim_tr;tim_cor(end)]; %[ndisc,1]
tim_dt=diff(tim_tr);
bol_q=[true;bol_tr];
Q_disc_join=Q_disc(bol_q);

%check
if abs(sum(tim_dt)-(tim_cor(end)-tim_cor(1)))>1e-16
    error('Something went wrong.')
end

if abs(sum(Q_disc.*seconds(diff(tim_cor)))-sum(Q_disc_join.*seconds(tim_dt)))>1e-16
    error('Something went wrong')
end

tim_dt=apply_MorFac(bol_q,idx,tim_dt,MorFac);

end %function

%%

function tim_dt=apply_MorFac(bol_q,idx,tim_dt,MorFac)

MorFac_disc=MorFac(idx);
MorFac_disc_join=MorFac_disc(bol_q);
tim_dt=tim_dt./MorFac_disc_join;

end %function

%%

function write_Qseries(tim_dt,Q_disc_join,fpath_dir_out)

fpath_out=fullfile(fpath_dir_out,'Qseries.csv');
fid=fopen(fpath_out,'w');
fprintf(fid,'Discharge,TimeDuration \n');
for k=1:numel(Q_disc_join)
    fprintf(fid,'%.0f,%.0f\n',Q_disc_join(k),seconds(tim_dt(k)));
end
fclose(fid);

messageOut(NaN,sprintf('File written: %s',fpath_out))

end %function

%%

function time_limits=parse_time_limits(tim,time_limits)

if numel(time_limits)>2
    error('`time_limits` must have a beginning and end time only (size 2).')
end

if ~isdatetime(time_limits)
    error('`time_limits` is expected to be datetime.')
end

if isempty(time_limits.TimeZone)
    warning('There is no time zone in `time_limits`. The time zone of the time series is assumed: %s',tim.TimeZone)
    time_limits.TimeZone=tim.TimeZone;
end

if time_limits(2)<=time_limits(1)
    error('The final time (position 2) is expected to be after the initial time (position 1) in `time_limits`')
end

end %function