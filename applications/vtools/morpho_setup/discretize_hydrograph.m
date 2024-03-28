%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18606 $
%$Date: 2022-12-08 08:00:50 +0100 (do, 08 dec 2022) $
%$Author: chavarri $
%$Id: interpolate_timetable.m 18606 2022-12-08 07:00:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/interpolate_timetable.m $
%
%Create a set of steady discharges from a hydrograph. Particularly
%usefull for SMT simulation.
%

function discretize_hydrograph(time_limits,dt,Q_steady,MorFac,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'location_clear','')
addOptional(parin,'fpaths_data_stations','')
addOptional(parin,'extend_time_series',0)
addOptional(parin,'power_Q_dom',5/3)
addOptional(parin,'fpath_dir_out',pwd)

parse(parin,varargin{:})

location_clear=parin.Results.location_clear;
fpaths_data_stations=parin.Results.fpaths_data_stations;
extend_time_series=parin.Results.extend_time_series;
power_Q_dom=parin.Results.power_Q_dom;
fpath_dir_out=parin.Results.fpath_dir_out;

%% CALC

[tim,val]=load_data(location_clear,fpaths_data_stations);

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

Q_disc=Q_steady(idx);
bol_tr=diff(Q_disc)~=0; %a 1 at index 5 (i.e., bol_tr(5)=1) implies that there have been 5 days with a constant discharge.
bol_trt=[false,bol_tr,false];
tim_cor=cen2cor(tim);
tim_tr=tim_cor(bol_trt);
tim_tr=[tim_cor(1),tim_tr,tim_cor(end)];
tim_dt=diff(tim_tr);
bol_q=[true,bol_tr];
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