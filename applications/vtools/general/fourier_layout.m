
%% RENAME
tim_s=data_r.tim;
y=data_r.val;

%  varname_1='water level [m]';
%  varname_2='spectral power [m^2/s]';
 
%  varname_1='streamwise velocity [m/s]';
%  varname_2='spectral power [m^2/s^3]';

%% CALC
aux=diff(tim_s);
dt_s=seconds(aux(1));
nt=numel(tim_s);
fs=1/dt_s; %[Hz]
f=(0:nt-1)*(fs/nt); %[Hz]

yf=fft(y); 
% pf=abs(yf).^2/nt;    % power of the DFT (also correct, but check the units above)
pf=abs(yf).^2/dt_s;    % power of the DFT

%% PLOT
plot(tim_s,y);
plot(1./f,pf);
