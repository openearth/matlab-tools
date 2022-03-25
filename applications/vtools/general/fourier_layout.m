
%% INPUT

%spatial example
mu=5;
etab_max=1e-3;
sig=1;

x=0:0.01:10;
y=etab_max.*exp(-(x-mu).^2/sig^2);

% tim_s=data_r.tim;
% y=data_r.val;

tim_s=x;

%  varname_1='water level [m]';
%  varname_2='spectral power [m^2/s]';
 
%  varname_1='streamwise velocity [m/s]';
%  varname_2='spectral power [m^2/s^3]';

%% fft

aux=diff(tim_s);
dt_s=seconds(aux(1));
nt=numel(tim_s);
fs=1/dt_s; %[Hz]
f=(0:nt-1)*(fs/nt); %[Hz]

yf=fft(y); 
% pf=abs(yf).^2/nt;    % power of the DFT (also correct, but check the units above)
pf=abs(yf).^2/dt_s;    % power of the DFT

%% ifft

nm=2; %number of modes to reconstruct

%ifft reconstruction
yf(nm+1:end)=0;
y_rec_ifft=ifft(yf);

%manual reconstruction
y_rec_manual=zeros(size(noise));
for km=1:nm
    if km==1
        noise_add_fac=1;
    else
        fi=-((1:1:nx)-1)*(km-1);
        noise_add_fac=exp(-2*pi*1i/nx*fi);
    end
    y_rec_manual=y_rec_manual+yf(km).*noise_add_fac;
end
y_rec_manual=1/nx.*y_rec_manual;

%% PLOT POWER

figure
plot(1./f,pf);

%% PLOT reconstruction

figure
hold on
plot(tim_s,y,'k');
plot(tim_s,y_rec_ifft,'bo')
plot(tim_s,y_rec_manual,'r*')
