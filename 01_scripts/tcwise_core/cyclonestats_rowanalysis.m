function [s1] = cyclonestats_rowanalysis(s,inrange)
% Simple function that sortes out output of TCWiSE
% Forward speed
u0=s.u0(inrange);
v0=s.v0(inrange);
u1=s.u1(inrange);
v1=s.v1(inrange);
lon=s.lon(inrange);
lat=s.lat(inrange);
time=s.time(inrange);

% Get rid of NaNs
u0(isnan(u1))=NaN;
v0(isnan(v1))=NaN;
u1(isnan(u0))=NaN;
v1(isnan(v0))=NaN;
lon(isnan(v0))=NaN;
lat(isnan(v0))=NaN;
time(isnan(v0))=NaN;

u0=u0(~isnan(u0));
v0=v0(~isnan(v0));
u1=u1(~isnan(u1));
v1=v1(~isnan(v1));
lon=lon(~isnan(v1));
lat=lat(~isnan(v1));
time=time(~isnan(v1));

spd0=sqrt(u0.^2+v0.^2);
phi0=atan2(v0,u0);
phi0=mod(phi0,2*pi);

spd1=sqrt(u1.^2+v1.^2);
phi1=atan2(v1,u1);
phi1=mod(phi1,2*pi);

dspd=spd1-spd0;
dphi=phi1-phi0;
dphi=dphi;
idnegative = dphi<pi*-1;
idpostive  = dphi>pi;
dphi(idnegative)    = dphi(idnegative)+2*pi;
dphi(idpostive)     = dphi(idpostive)-2*pi;

forward_speed=spd0;
forward_speed_change=dspd;

% Foreward direction
heading=phi0 / pi * 180; %convert radians to degrees
heading_change=dphi / pi * 180; %convert radians to degrees;

% Vmax
vmax0=s.vmax0(inrange);
vmax1=s.vmax1(inrange);
vmax2=s.vmax2(inrange);
vmax0=vmax0(~isnan(vmax0));
vmax1=vmax1(~isnan(vmax1));
vmax2=vmax2(~isnan(vmax2));

vmax=vmax1;
vmax_change=vmax2-vmax1;
dvmax0=vmax1-vmax0;

knts_ms = 0.51444444444;

% Save in structure
s1.lon  = lon;
s1.lat  = lat;
s1.vmax = vmax * knts_ms;
s1.heading = heading;
s1.forward = forward_speed;
s1.time = time;
end

