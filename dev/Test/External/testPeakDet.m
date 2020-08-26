function testMax

t = datenum([2014 11 11 0 0 0])+(0:10/1440:20);
M2 = 2*pi/((12+25/60)/24);
S2 = 2*pi/((12)/24);
phiS2 = 25/180*pi;
M4 = M2*2;
phiM4 = 25/180*pi;
y = sin(M2.*t)+0.4.*sin(S2.*t + phiM4) + 0.2.*sin(M4.*t+phiM4) +0.25.*rand(size(t));
yR = rand(size(y));
%y(yR<0.2)  = nan;


delta= 0.5;
[maxtab, mintab] = peakdet(y, delta);
indexMin = mintab(:,1);
indexMax = maxtab(:,1);
plotMax(t,y,indexMin,indexMax);
title('maxlocs');


function plotMax(x,y,iMax,iMin)
         figure;
         plot(x,y,'-',x(iMax),y(iMax),'^',x(iMin),y(iMin),'v'  );
         grid on;