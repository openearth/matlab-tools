function [x,z]=okaTrans(depth,dip,wdt,sliprake,slip,xx)

dx=2;
xl=round(3*wdt/2);
[E,N] = meshgrid(-xl:dx:xl,-xl:dx:xl);
lngth=wdt;
% Focal depth
focdpt = wdt*sin(dip*pi/180) + depth;
[uE,uN,uZ] = okada85(E,N,focdpt,0,dip,lngth,wdt,sliprake,slip,0);


ix0=size(E,1)/2-wdt/2/dx;
ix=ix0+xx/2;
ix=round(ix);
ix=min(ix,ceil(size(E,1)/2));
ix=max(ix,1);

x=E(ix,:);
z=uZ(ix,:);
