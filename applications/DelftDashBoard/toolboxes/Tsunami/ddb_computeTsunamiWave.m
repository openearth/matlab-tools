function [xg,yg,zg]=ddb_computeTsunamiWave(xs,ys,depths,dips,wdts,sliprakes,slips)

degrad=pi/180;

pd=pathdistance(xs,ys);
dx=pd(end)/10;

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
strike=90-strike;

n0=round(1000*wdt(1)/dx);
n1=length(xc);
n2=round(1000*wdt(end)/dx);

%figure(4)

for i=1:n0+n1+n2
    
    disp([num2str(i) ' of ' num2str(n0+n1+n2)]);
    
    if i<=n0
        ii=1;
        ixin=i-n0-1;
        xin=ixin*dx/1000; % km
        phirot=(90-strike(1))*degrad;
        ddx=ixin*cos(phirot)*dx; % m
        ddy=ixin*sin(phirot)*dx; % m
    elseif i>n0+n1
        ii=n1;
        ixin=i-(n0+n1);
        xin=-ixin*dx/1000; % km 
        phirot=(90-strike(end))*degrad;
        ddx=ixin*cos(phirot)*dx; % m
        ddy=ixin*sin(phirot)*dx; % m
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
    y=x*sin(-(strike(ii))*degrad);
    x=x*cos(-(strike(ii))*degrad);

    x=x+xc(ii)+ddx;
    y=y+yc(ii)+ddy;

%    plot(x,y);hold on;axis equal
    
    xx(i,:)=x;
    yy(i,:)=y;
    zz(i,:)=z;

end

xg(1)=min(min(xx));
xg(2)=max(max(xx));
yg(1)=min(min(yy));
yg(2)=max(max(yy));
dborder=0.1*(xg(2)-xg(1));
xg(1)=xg(1)-dborder;
xg(2)=xg(2)+dborder;
yg(1)=yg(1)-dborder;
yg(2)=yg(2)+dborder;

dxg=2000;
dyg=2000;

[xg,yg]=meshgrid(xg(1):dxg:xg(2),yg(1):dyg:yg(2));
zg=griddata(xx,yy,zz,xg,yg);


