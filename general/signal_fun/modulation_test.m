function nan=modulation_test
%MODULATION_TEST   Test script for modulation
%
%See also: modulation

%% settings
time       = datenum(1990,5,linspace(0,31,5000)); % [days]
freq       = [1.9323  2       ];                  % [cyc/day]
omega      =  2*pi*freq;                          % [rad/day]
amplitudes = [0.67238 0.16315];                   % [m]
phases     = [108.02  174    ];                   % [deg]
names      = {'M2','S2'};

%% t_predic requires freq in 1/hr
f        = 1;tidecon = [amplitudes(f) eps phases(f) eps];
M2       = t_predic(time,{'M2'},freq(f)./24,tidecon);

f        = 2;tidecon = [amplitudes(f) eps phases(f) eps];
S2       = t_predic(time,{'S2'},freq(f)./24,tidecon);

[FIT]    = harmanal(time,M2+S2,'omega',omega,'screenoutput',0);

%% get envelope
envelope = modulation(omega,FIT.hamplitudes,FIT.hphases,time);

%% plot
plot    (time,envelope,'r','displayname','envelope');
hold     on
plot    (time,M2','g'    ,'displayname','M2');
plot    (time,S2,'b'     ,'displayname','S2');
plot    (time,M2 + S2,'k','displayname','M2 + S2');
timeaxis(datenum(1990,5,1:2:32),[],'dd-mmm');
grid     on
legend   show
xlabel  (num2str(unique(year(xlim))))
ylabel  ('waterlevel [m]')
