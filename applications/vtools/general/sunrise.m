
%%

clear
%%
phi=52; %latitude [deg]

%%

rad2deg=360/2/pi;
d=datetime(2000,01,01):days(7):datetime(2000,12,31);
d_e=days(d-datetime(2000,03,21)); %number of days after spring equinox
delta=(23+27/60)*sin(360*d_e/365.25/rad2deg); %sun declination [deg]
w0=acos(-tan(phi/rad2deg)*tan(delta/rad2deg))*rad2deg; %solar hour angle at either sunrise (when negative value is taken) or sunset (when positive value is taken) [deg]
t_half=w0/15;
t_tot=2*t_half;

%%
tp=t_tot';
tp_inp=flipud([(1:1:53)',t_tot']);
%%


figure
hold on
% plot(d,delta)
% plot(d,t_half)
plot(d,t_tot)
% plot(d,w0)
% plot(d,cos_w0)