clear all
close all

%% input

%WLmax = rekenpeil
%Hsmax = Hs
%Tpmax = Tp


INPUT      = struct(...
                  'Hsmax',            9,        ...             % 	[9 m]                   Sign. wave height @ peak
                  'Tpmax',            12,       ...             % 	[12 s]                  Wave peak period @ peak
                  'tidalampl',        1.,       ...             % 	[1 m]                   Tidal amplitude (assuming M2)
                  'phaseshift',       3.5,      ...             % 	[3.5 hr]        [* ]    Time difference between tidal peak and surge peak (in hours)
                  'stormlength_wl',   44,       ...             % 	[44 hr]         [* ]    Duration of waterlevel from 0 to peak to 0
                  'stormlength_waves',1.25*44,  ...             % 	[1.25*44 hr]	[* ]    Duration of waves from 0 to peak to 0
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
time_dummy            = [0: INPUT.dt :INPUT.simlength]';



[Hs,Tp]         = calc_waves(INPUT,time_dummy);

% % Shorten timeseries MOPHAN implementation % %
%time                  = sim time. see menno_getij
%Hs[time_dummy > time] = remove
%Hs[time_dummy > time] = remove

% --- 
xbtime      = time*3600;            % [s]


xbtime      = [0;xbtime+spinuptime];
Hs_xb       = [Hs(1);Hs];
Tp_xb       = [Tp(1);Tp];

figure();grid on;box on;hold on
plot(time,Hs,'-r')
plot(time,Tp,'-m')
legend({'WL','Hs','Tp'});set(legend,'Location','NorthWest','Box','off')

function [Hs,Tp] = calc_waves(DATAin,time,INPUT.Hsmin,INPUT.Tpmin)
%
%   FUNCTION calc_waves
%       >>  Calculate Hs & Tp
%
    %%
    % Calculate timeseries of Hs
    t_surgepeak     = DATAin.simlength/2;
    Hs0             = DATAin.Hsmax * cos( pi*( time-t_surgepeak )/(DATAin.stormlength_waves) ).^2;
    
    % Calculate timeseries of Tp

    g    	= 9.81;
    s_peak 	= (2*pi/g)*(DATAin.Hsmax/DATAin.Tpmax^2);
    Tp0   	= sqrt((2*pi/g)*(Hs0./s_peak));

    
    % 
    Hs              = Hs0;
    Tp              = Tp0;
        
    % Set surge to zero outside of storm duration (only one surge peak allowed)
    nosurgetime     = time < (t_surgepeak - DATAin.stormlength_waves/2) | time > (t_surgepeak + DATAin.stormlength_waves/2);
    Hs(nosurgetime) = 0;
    Tp(nosurgetime) = 0;
    
    % Apply minimum values for Hs & Tp
    Hs              = max(Hs,DATAin.Hsmin);
    Tp              = max(Tp,DATAin.Tpmin);
    
%% END
end



