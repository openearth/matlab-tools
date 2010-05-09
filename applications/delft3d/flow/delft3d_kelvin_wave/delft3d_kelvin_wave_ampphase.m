function delft3d_kelvin_wave_ampphase(G, ETA0, VEL0);
%DELFT3D_KELVIN_WAVE_AMPPHASE  quick-n-dirty visual assessment of delft3d_kelvin_wave_* 
%
%See also: delft3d_kelvin_wave

[amp.c amp.h] = contour(G.coast.x,G.coast.y,ETA0.abs,'b');
[amp.t      ] = clabel (amp.c,amp.h);

hold on

[pha.c pha.h] = contour(G.coast.x,G.coast.y,-rad2deg(ETA0.arg),'k');
[pha.t      ] = clabel (pha.c,pha.h);

axis equal
