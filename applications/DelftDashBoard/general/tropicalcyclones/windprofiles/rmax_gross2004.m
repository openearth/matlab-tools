function rmax=rmax_gross2004(vmax,lat)
% Computes Rmax based on Gross 2004
% Vmax : maximum wind speed in m/s
% lat  : latitude in degrees

kts2ms=0.514;
nm2km=1.852;

vmax=vmax/kts2ms;

rmax=35.37 - 0.11100*vmax + 0.5700*(abs(lat)-25);

% Convert to km
rmax=rmax*nm2km;
