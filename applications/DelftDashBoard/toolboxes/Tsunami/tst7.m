clear variables;close all;

degrad=pi/180;

xs=[100000 180000 200000];
ys=[900000 700000 500000];


depths=[24 24 24];
dips=[14 14 14];
wdts=[120 120 120];
sliprakes=[88 88 88];
slips=[7 14 7];

pd=pathdistance(xs,ys);
dx=pd(end)/40;

xp=pd(1):dx:pd(end);
xc = spline(pd,xs,xp);
yc = spline(pd,ys,xp); 
depth=spline(pd,depths,xp);
dip=spline(pd,dips,xp);
wdt=spline(pd,wdts,xp);
sliprake=spline(pd,sliprakes,xp);
slip=spline(pd,slips,xp);

fdtop=24;

strike(1)=atan2(yc(2)-yc(1),xc(2)-xc(1));

for i=2:length(xc)
    strike(i)=atan2(yc(i)-yc(i-1),xc(i)-xc(i-1));
end
strike=strike/degrad;
strike=strike-90;

pdspline=pathdistance(xc,yc);

n0=round(1000*wdt(1)/dx);
n1=length(xc);
n2=round(1000*wdt(end)/dx);

for i=1:n0+n1+n2
    
    disp([num2str(i) ' of ' num2str(n0+n1+n2)]);
    
    if i<=n0
        ii=1;
        ixin=i-n0-1;
        xin=ixin*dx/1000; % km
        ddx=-ixin*sin(strike(1)*degrad)*dx; % m
        ddy=ixin*cos(strike(1)*degrad)*dx; % m
    elseif i>n0+n1
        ii=n1;
        ixin=i-(n0+n1);
        xin=-ixin*dx/1000; % km 
        ddx=-ixin*sin(strike(end)*degrad)*dx; % m
        ddy=ixin*cos(strike(end)*degrad)*dx; % m
    else
        ii=i-n0;
        ixin=i-n0-1;
        xin=min(ixin*dx/1000,(n0+n1-i)*dx/1000);
        ddx=0;
        ddy=0;
    end
    
    [x,z]=okaTrans(depth(ii),dip(ii),wdt(ii),sliprake(ii),slip(ii),xin);
    
    % Convert to m
    x=x*1000;
    fw = 1000*wdt(ii)*cos(dip(ii)*degrad);
%    fdtop=0;
    if (fdtop>0)
        fd = 1000*fdtop /sin(dip(ii)*degrad);
        %            fd = min(fd,0.5*fw);
    else
        fd = 0;
    end
    
    x=x+fd;
    % Rotate
    y=x*sin((strike(ii))*degrad);
    x=x*cos((strike(ii))*degrad);

    x=x+xc(ii)+ddx;
    y=y+yc(ii)+ddy;

    xx(i,:)=x;
    yy(i,:)=y;
    zz(i,:)=z;

end

% plot(xc,yc);axis equal;
% figure(2);

pcolor(xx,yy,zz);axis equal;
%caxis([-1 1]);
colorbar;
shading flat;