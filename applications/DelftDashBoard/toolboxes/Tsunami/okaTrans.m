function [x,z]=okaTrans(depth,dip,wdt,sliprake,slip,xx)

[E,N] = meshgrid(-200:2:200,-200:2:200);
lngth=wdt;
[uE,uN,uZ] = okada85(E,N,depth,0,dip,lngth,wdt,sliprake,slip,0);


ix0=100-wdt/4;
ix=ix0+xx/2;
ix=min(ix,100);
ix=round(ix);

x=E(ix,:);
z=uZ(ix,:);
