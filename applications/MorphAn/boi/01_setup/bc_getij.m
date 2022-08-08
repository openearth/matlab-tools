clear all
close all

%% input

%WLmax = rekenpeil
%Hsmax = Hs
%Tpmax = Tp


INPUT      = struct(...
                  'WLmax',            2,        ...             %	[5 m+NAP]               Max. surge level @ peak
                  'Hsmax',            9,        ...             % 	[9 m]                   Sign. wave height @ peak
                  'Tpmax',            12,       ...             % 	[12 s]                  Wave peak period @ peak
                  'tidalampl',        -4.,       ...             % 	[1 m]                   Tidal amplitude (assuming M2)
                  'phaseshift',       0,      ...             % 	[3.5 hr]        [* ]    Time difference between tidal peak and surge peak (in hours)
                  'stormlength_wl',   44,       ...             % 	[44 hr]         [* ]    Duration of waterlevel from 0 to peak to 0
                  'simlength',        44,       ...             % 	[44 hr]         [* ]    Simulation length (centered around storm peak!) - excl. optional shortening of timeseries
                  'msl',              0.,   	...           	% 	[0 m+NAP]       [**]    Mean sea level (excl. WL_addition) [affects wl_tide]
                  'dt',               0.5,      ...             % 	[0.5 hr]        [**]	Resolution of output timesteps (in hours)
                  'Hsmin',            0.5,      ...             %   [.5 m]          [**]	Minimum allowed Hs-value in timeseries [affects storm tails])
                  'Tpmin',            5.        ...             %   [5 s]           [**]	Minimum allowed Tp-value in timeseries [affects storm tails])
                ); 

% XBeach related settings
spinuptime  	= 1200;  	% [s] Spin-up of simulation     [s]
Zland        	= 5;        % [m+NAP] Most landward bedlevel >> NOTE: in MorphAn this value should be derived from input data (profile)


%%
time            = [0: INPUT.dt :INPUT.simlength]';
% --- tide
[WL_tide]   = calc_WL_tide(INPUT,time);
% -- surge
WL_surge = calc_WL_surge_trapezium(INPUT,time,WL_tide);

% --- combine
WL              = WL_tide + WL_surge;
[WLmax,itmax]	= max(WL);
t_stormpeak     = time(itmax);

% --- shorten
[time,WL] = shorten_timeseries_HR(time,WL);

% --- WLland is the waterlevel at the back side
WLland      = min(Zland-0.5, min(WL)) * ones(size(WL));

% --- add spinup time
xbtime      = time*3600;            % [s]


xbtime      = [0;xbtime+spinuptime];
WL_xb       = [WL(1);WL];
WLland_xb   = [WLland(1);WLland];


figure();grid on;box on;hold on
plot(time,WL,'-b')
legend({'WL','Hs','Tp'});set(legend,'Location','NorthWest','Box','off')
xlabel('t [hr]')

figure();grid on;box on;hold on
plot(xbtime,WL_xb,'-b')
legend({'WL','Hs','Tp'});set(legend,'Location','NorthWest','Box','off')
xlabel('t [s]')

function [WL_tide] = calc_WL_tide(DATAin,time)
%
%   FUNCTION calc_WL_tide
%       >>  Calculate WL_tide
%
    %%
    % Calculate timeseries of tides (INCL `WL_addition`)
    MSL             = DATAin.msl;
    TIDE            = DATAin.tidalampl;
    
    t_tidepeak      = DATAin.simlength/2 + DATAin.phaseshift;
    WL_tide         = MSL + TIDE * cos( 2*pi*( time-t_tidepeak  )/ 12.42 );
    
%% END
end

function [time,WL,Hs,Tp,WL_tide,WL_surge] = shorten_timeseries_HR(time,WL)
%
% FUNCTION shorten_timeseries_HR
%	Returns shortened timeseries of hydraulic boundary conditions
%   >> Simulation ends shortly after storm peak, when WL < WLmax - 2m 
%
    %%
    % % Find storm peak
    [WLmax,itmax]	= max(WL);
    
    % % Stop simulation shortly after storm peak, when WL <= WLmax - 2m 
    WLstop          = WLmax - 2;
    
    % % Find end time
    itend0          = find(time>time(itmax) & WL<=WLstop,1,'first');
    endtime0        = time(itend0);
    
    % % Find end time in hourly steps 
    itend           = find(time>=ceil(time(itend0)),1,'first');
    endtime         = time(itend);

    % % Cutoff timeseries
    it              = 1:itend;
    [time,  WL]	= deal(time(it), WL(it));
    
%% END
end

function [WL_surge,SURGE] = calc_WL_surge_trapezium(DATAin,time,WL_tide)
%
%   FUNCTION calc_WL_surge_trapezium
%       >>  Calculate WL_surge based on trapezium-shape
%
%       >>  NOTE:	SURGE_addition forces exact change of max(WL_surge)
%                   max(WL_surge) = max(WL_surge) + SURGE_addition
%                   instead of:
%                   max(WL)       = max(WL)       + SURGE_addition
%           >>  This is only relevant when DATAin.phaseshift unequals 0 !
%
    %%
    % Set trapezium parameters
    nearpeak_dur    = 2;    % hr  [2hr]
    nearpeak_dz     = 0.1;  % m   [0.1m]  (= height difference between peak surgelvl and nearpeak surgelvl)
    nosurgelvl      = 0;
    
    % Define time (local var only)
    t_surgepeak     = DATAin.simlength/2;
    t               = t_surgepeak + [-DATAin.stormlength_wl/2, nearpeak_dur*[-0.5:0.5:0.5], +DATAin.stormlength_wl/2];

    % Calculate timeseries of surge (EXCL `SURGE_addition`) 
    WLMAX           = DATAin.WLmax;
    SURGE           = WLMAX - max(WL_tide);
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);
    WL              = WL_tide + WL_surge;
    WLmax           = max(WL);

    % Required iteration to calculate surge height  >> only relevant if `phaseshift ~= 0`!
    cnt     = 0;
    while abs(WLmax - WLMAX)>1e-4
        cnt         = cnt+1;    if cnt>100; warning(['Number of required iterations > 100! Check results... dWL = ' num2str(dWL)]); break; end
        dWL         = WLmax - WLMAX;
        SURGE    	= SURGE - dWL;
        s        	= [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
        WL_surge  	= interp1(t,s,time,'linear',nosurgelvl);
        WL        	= WL_tide + WL_surge;
        WLmax    	= max(WL);
    end

    % Calculate timeseries of surge
    s               = [nosurgelvl, SURGE+[-nearpeak_dz 0 -nearpeak_dz], nosurgelvl];
    WL_surge        = interp1(t,s,time,'linear',nosurgelvl);

%% END
end