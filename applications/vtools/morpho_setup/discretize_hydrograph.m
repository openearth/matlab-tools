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
%   - time_limits    = times to derive the time series [datetime(N,1) with time zone]. N>=2
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
%   - compress_below_Q     = Q below which discharges are combined [double(1,1)]
%   - fall_ratio           = distribution of time of discharges for compress_below_Q for falling limb of the discharge wave (between 0 and 1) [double(1,1)]

function [tim_dt,Q_disc_join]=discretize_hydrograph(time_limits,Q_steadyMorfac,varargin)

%% PARSE

%parin
parin=inputParser;

addOptional(parin,'location_clear','')
addOptional(parin,'fpaths_data_stations','')
addOptional(parin,'extend_time_series',0)
addOptional(parin,'power_Q_dom',5/3)
addOptional(parin,'fpath_dir_out',pwd)
addOptional(parin,'dt',days(1))
addOptional(parin,'compress_below_Q',0);
addOptional(parin,'fall_ratio',0.75)
parse(parin,varargin{:})

location_clear=parin.Results.location_clear;
fpaths_data_stations=parin.Results.fpaths_data_stations;
extend_time_series=parin.Results.extend_time_series;
power_Q_dom=parin.Results.power_Q_dom;
fpath_dir_out=parin.Results.fpath_dir_out;
dt=parin.Results.dt;
compress_below_Q=parin.Results.compress_below_Q;
fall_ratio=parin.Results.fall_ratio;

%check
assert(size(Q_steadyMorfac,2)==2, '`Q_steadyMorfac` should be have size [nQ,2], where `nQ` is the number of discharges.');
assert(compress_below_Q>=0, 'compress_below_Q is %g should be 0 or larger',compress_below_Q);
if compress_below_Q > 0
    assert(fall_ratio<=1,'fall_ratio is %g. It should be less or equal to 1',fall_ratio);
    assert(fall_ratio>=0,'fall_ratio is %g. It should be larger or equal to 0',fall_ratio);
end 

Q_steady=Q_steadyMorfac(:,1);
MorFac=Q_steadyMorfac(:,2);

%% CALC

[tim,val]=load_data(location_clear,fpaths_data_stations);
time_limits_start_end = time_limits([1,end]);
time_limits_start_end=parse_time_limits(tim,time_limits_start_end);

[tim,val]=extend_series(tim,val,time_limits_start_end,extend_time_series);

[tim,val]=filter_series(tim,val,time_limits_start_end,fpath_dir_out,'01');
 
[tim,val]=resample_series(tim,val,dt,time_limits_start_end,fpath_dir_out);

[tim,val]=filter_series(tim,val,time_limits_start_end,fpath_dir_out,'02');

[tim,val]=add_intermediate_dates(tim,val,time_limits);

idx=index_steady_discharge(power_Q_dom,Q_steady,val,tim,fpath_dir_out);

plot_cdfs(val,Q_steady, idx, fpath_dir_out);

tim_sep_idx = discretize(tim.', time_limits);

[tim_dt,Q_disc_join,tim_join]=join_Q(Q_steady,tim,idx,MorFac,tim_sep_idx);

[tim_dt,Q_disc_join]=compress_Qseries(tim_dt,Q_disc_join,compress_below_Q,tim_join,time_limits,fall_ratio,fpath_dir_out);

write_Qseries(tim_dt,Q_disc_join,fpath_dir_out);

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
figure;
hold on; 
plot(tim,val,'b')
plot(tim,Q_steady(idx),'r')
legend({'resampled','discrete'})
printV(gcf,fullfile(fpath_dir_out,'discrete.png'));
printV(gcf,fullfile(fpath_dir_out,'discrete.fig'));

end %function

function plot_cdfs(val,Q_steady, idx, fpath_dir_out )
edges = 0:1:ceil(max(val));
[N_in,edges_in] = histcounts(val, edges, 'Normalization', 'probability');
[N_out,edges_out] = histcounts(Q_steady(idx),edges, 'Normalization', 'probability');
figure;
hold on; 
plot(cumsum(N_in), edges_in(1:end-1)+0.5*diff(edges_in), 'b', 'DisplayName','resampled');
plot(cumsum(N_out), edges_out(1:end-1)+0.5*diff(edges_out), 'r', 'DisplayName','discrete');
ylabel(labels4all('Q', 1, 'en'));
set(gca,'YScale', 'log'	)
xlabel('cumulative frequency [-]');
legend('location', 'southeast')
box on; 
grid on;
xlim([0 1]);
ylim([10 10^(ceil(log10(max(val))*2)/2)]);
printV(gcf,fullfile(fpath_dir_out,'histogram.png'));
printV(gcf,fullfile(fpath_dir_out,'histogram.fig'));
end


%%

function [tim_dt,Q_disc_join,tim_join]=join_Q(Q_steady,tim,idx,MorFac,tim_sep_idx)

%% PARSE

if numel(MorFac)~=numel(Q_steady)
    error('The size of MorFac should be equal to the size of ')
end

%% CALC
tim=tim(:);
Q_disc=Q_steady(idx); %[nidx,1]
bol_tr=((diff(Q_disc)~=0) | (diff(tim_sep_idx)~=0)); %a 1 at index 5 (i.e., bol_tr(5)=1) implies that there have been 5 days with a constant discharge or an exact time wanted in the qseries.
bol_trt=[false;bol_tr]; %[nidx,1]
%tim_cor=cen2cor(tim)'; %[nidx+1,1]. Output of `cen2cor` is [1,nt] no matter the input, we transpose. 
tim_tr=union(tim(bol_trt),tim([1,end])); 
% tim_tr=[~, ia, ib] = union(tim_tr,tim([1,end]));
% tim_tr=[tim(1),union(tim_tr,tim(end))]; %[ndisc+1,1]
tim_dt=diff(tim_tr);
%tim_dt=[tim_dt]; 
bol_q=[true;bol_tr];
Q_disc_join=interp1(tim, Q_disc, tim_tr(1:end-1)); % Q_disc(bol_q);
MorFac_disc_join=interp1(tim, MorFac(idx), tim_tr(1:end-1));
tim_join=[tim(1); tim(1)+cumsum(tim_dt(1:end-1))];
%check
assert(abs(sum(tim_dt)-(tim(end)-tim(1)))<1e-16 , ...
    'Something went wrong.')

assert(abs(sum(Q_disc(1:end-1).*seconds(diff(tim)))-sum(Q_disc_join.*seconds(tim_dt)))<1e-16, ...
    'Something went wrong')

tim_dt=apply_MorFac(tim_dt,MorFac_disc_join);

end %function

%%

function tim_dt=apply_MorFac(tim_dt,MorFac_disc_join)

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

%%
function [TimeDuration,Discharge] = compress_Qseries(tim_dt,Q_disc_join,compress_below_Q,tim_join,time_limits,fall_ratio, fpath_dir_out)

if compress_below_Q > 0
    % flood_idx = find(Q_disc_join>=compress_below_Q); 
    % Discharge = Q_disc_join(1:flood_idx(1)-1);
    % TimeDuration = tim_dt(1:flood_idx(1)-1);
    tolerance = 1e-10;
    bol_q = discretize(Q_disc_join,[0,compress_below_Q,Inf]);
    N_Qc = length(unique(Q_disc_join(Q_disc_join<compress_below_Q)));
    [~, ia, ~] = intersect(tim_join,time_limits);
    idx_keep = union(find(bol_q>1),union([1,length(Q_disc_join)],ia)); 
    idx_start = idx_keep(diff(idx_keep)>(2*N_Qc-1));       % (2*N_Qc-1) required for enough space for assignment - otherwise keep original 
    idx_end = idx_keep(find(diff(idx_keep)>(2*N_Qc-1))+1);
    % figure
    % clf; 
    % hold on; 
    % plot(tim_join, Q_disc_join)
    % plot(tim_join(idx_start), Q_disc_join(idx_start), 'bo')
    % plot(tim_join(idx_end), Q_disc_join(idx_end), 'b*')

    N_dt = length(tim_dt);

    TimeDuration = duration(0,0,zeros(N_dt,1));
    Discharge = zeros(size(tim_dt));

    N = length(idx_end);

    TimeDuration(1:idx_start(1))=tim_dt(1:idx_start(1));
    Discharge(1:idx_start(1))=Q_disc_join(1:idx_start(1));
    for k = 1:N
        assert(abs(sum(TimeDuration(1:idx_start(k))) - sum(tim_dt(1:idx_start(k))))<tolerance);

        idx_compress = idx_start(k)+1:idx_end(k)-1;
        tim_dt_compress=tim_dt(idx_compress); 
        Q_disc_compress=Q_disc_join(idx_compress);
        Q_first = Q_disc_join(idx_start(k));
        Q_last = Q_disc_join(idx_end(k));
    
        [Qs, ~, ib] = unique(Q_disc_compress);
    
        t_combine = duration(0,0,accumarray(ib, seconds(tim_dt_compress))); 
    
        t_fall = t_combine(2:end)*fall_ratio;
        Q_fall = Qs(2:end);
        t_min = t_combine(1);
        Q_min = Qs(1); 
        t_rise  = t_combine(2:end)-t_fall; 
        Q_rise = Qs(2:end);
    
        t_rise(Q_fall >= Q_first) = t_rise(Q_fall >= Q_first) + t_fall(Q_fall >= Q_first); 
        t_fall(Q_fall >= Q_first) = 0;
        t_fall(Q_rise >= Q_last) = t_fall(Q_rise >= Q_last) + t_rise(Q_rise >= Q_last); 
        t_rise(Q_rise >= Q_last) = 0;

        TimeDuration(idx_start(k)+1:idx_start(k)+2*length(Qs)-1) = [flipud(t_fall); t_min; t_rise];
        Discharge(idx_start(k)+1:idx_start(k)+2*length(Qs)-1) = [flipud(Q_fall); Q_min; Q_rise];
        assert(abs(sum(TimeDuration(idx_start(k)+1:idx_end(k)-1)) - sum(tim_dt(idx_start(k)+1:idx_end(k)-1)))<1e-10);

        % figure(1); 
        % clf; 
        % plot(time_limits(1)+cumsum(TimeDuration(TimeDuration>0)),Discharge(TimeDuration>0));
        % hold on; 
        % plot(time_limits(1)+cumsum(tim_dt),Q_disc_join);

        for gg = 1:k 
            assert(abs(sum(TimeDuration(1:idx_end(gg)-1)) - sum(tim_dt(1:idx_end(gg)-1)))<tolerance);
        end

        if k < N
            TimeDuration(idx_end(k):idx_start(k+1)) = tim_dt(idx_end(k):idx_start(k+1));
            Discharge(idx_end(k):idx_start(k+1)) = Q_disc_join(idx_end(k):idx_start(k+1));
            assert(abs(sum(TimeDuration(1:idx_start(k+1))) - sum(tim_dt(1:idx_start(k+1))))<tolerance);
        else
            TimeDuration(idx_end(k)) = tim_dt(idx_end(k));
            Discharge(idx_end(k)) = Q_disc_join(idx_end(k));
        end

    end

    TimeDuration(idx_end(N):N_dt)=tim_dt(idx_end(N):N_dt);
    Discharge(idx_end(N):N_dt)=Q_disc_join(idx_end(N):N_dt);

    assert(abs(sum(TimeDuration) - sum(tim_dt))<tolerance);
    
    Discharge = Discharge(TimeDuration > 0); 
    TimeDuration = TimeDuration(TimeDuration > 0); 
else
    Discharge = Q_disc_join;
    TimeDuration = tim_dt;
end

figure(1); 
clf
hold on;
plot_step(time_limits(1)+[0; cumsum(tim_dt)],[Q_disc_join; NaN ],'b-', 'discrete');
plot_step(time_limits(1)+[0; cumsum(TimeDuration)],[Discharge; NaN ],'r', 'compressed');
datetick('x')
ylabel(labels4all('Q', 1, 'en'));
set(gca,'YScale', 'linear'	)
%xlabel('days');
legend('location', 'best')
box on; 
grid on;
%xlim([0 1])
%ylim([10 10^(ceil(log10(max(val))*2)/2)]);
printV(gcf,fullfile(fpath_dir_out,'Qseries_compress.png'));
printV(gcf,fullfile(fpath_dir_out,'Qseries_compress.fig'));

end %function

function [tim_new,val_new]=add_intermediate_dates(tim,val,time_limits) 
    tim_new = union(tim, time_limits(time_limits>tim(1) & time_limits<tim(end)));
    val_new = interp1(tim,val,tim_new);
end

function p = plot_step(x,y,colstr,dispname) 
x = x(:);
y = y(:);

x1 = x(1:end-1); 
x2 = x(2:end); 
y1 = y(1:end-1); 
y2 = y(2:end); 

p = plot([x1 x2 x2].',[y1 y1 y2].',colstr,'DisplayName',dispname, 'HandleVisibility','off'); 
set(p(1), 'HandleVisibility','on');
end

