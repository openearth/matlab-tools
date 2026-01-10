function [xC0, yC0, xC1, yC1,xC2, yC2, sC0, angC0, iR0, xm0, ym0] = getcurv2(xC,yC,degree,halfwin,intnum)

sC=[0,cumsum(sqrt(diff(xC).^2+diff(yC).^2))];
[xC0,xC1,xC2,xm0] = sgolayirreg(sC,xC,degree,halfwin);
[yC0,yC1,yC2,ym0] = sgolayirreg(sC,yC,degree,halfwin);
% plot(xC(1:end),yC(1:end),'.',xC0,yC0,'r.',xm0,ym0,'rx')
sC0=sC;%[0,cumsum(sqrt(diff(xC0).^2+diff(yC0).^2))];
zt = (xC1.^2 + yC1.^2);
iR0 = sign(yC1.*xC2 - xC1.*yC2).*sqrt(zt.*(xC2.^2 + yC2.^2)-((xC1.*xC2+yC1.*yC2).^2))./(zt.^(3/2));
angC0 = angle((yC1-i*xC1));
%plot(sC0,iR0)
end