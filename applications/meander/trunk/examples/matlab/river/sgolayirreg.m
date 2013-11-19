function [y0,y1,y2,y0m] = sgolayirreg(x,y,degree,halfwin);
% x=[0:0.05:2]+0.025*rand(size([0:0.05:2]));
% y=sin(pi*[0:0.05:2])+0.025*rand(size([0:0.05:2]));
nmax =length(x);
xe = [x(1)+[-halfwin:-1]*(x(2)-x(1)),x,x(end)+[1:halfwin]*(x(end)-x(end-1))];
ye = [y(1)+[-halfwin:-1]*(y(2)-y(1)),y,y(end)+[1:halfwin]*(y(end)-y(end-1))];
for k = 1+halfwin:nmax+halfwin;
    nl = k-halfwin;%max(1,k-halfwin);
    nr = k+halfwin;%min(nmax+halfwin,k+halfwin);
p = polyfit(xe(nl:nr),ye(nl:nr),degree);
p1 = polyder(p);
p2 = polyder(p1);
y0(k-halfwin) = polyval(p,xe(k));
y1(k-halfwin) = polyval(p1,xe(k));
y2(k-halfwin) = polyval(p2,xe(k));
y0L(k-halfwin) = polyval(p,xe(k)-0.5*(xe(k)-xe(k-1)));
y0R(k-halfwin) = polyval(p,xe(k)+0.5*(xe(k+1)-xe(k)));
end
y0m=0.5*(y0L(2:nmax)+y0R(1:nmax-1));
% figure(1);
% plot(x,y,'b-',x,ps,'r-')
% %
% figure(2);
% xm = 0.5*x(1:end-1)+0.5*x(2:end);
% %plot(x,ps,x,ps1,x,ps2);
% plot(xm,diff(y)./diff(x),x,ps1,'r-')
% figure(3);
% xmm = 0.5*xm(1:end-1)+0.5*xm(2:end);
% plot(xmm,diff(diff(y)./diff(x))./diff(xm),x,ps2,'r-')

