function [x,y,z]=MakeCoastalGrid(xs,ys,xb,yb,zb,yoff,dx,dymin,dymax,dt,c,nsmooth,drel)

dy=2;

ny=floor(yoff/dy)+1;

pd=pathdistance(xs,ys);
xp=pd(1):dx:pd(end)+dx;
xc = spline(pd,xs,xp);
yc = spline(pd,ys,xp);

pd=pathdistance(xc,yc);
xp=pd(1):dx:pd(end);
xc = spline(pd,xc,xp);
yc = spline(pd,yc,xp);

nx=length(xc);

% Compute coastline angle
for i=2:nx-1;
    anga=atan2(yc(i+1)-yc(i),  xc(i+1)-xc(i));
    angb=atan2(yc(i)  -yc(i-1),xc(i  )-xc(i-1));
    ang(i)=0.5*(anga+angb)+0.5*pi;
end
ang(1)=ang(2);
ang(nx)=ang(nx-1);

for i=1:nx
    for j=1:ny
        xg(i,j)=xc(i)+cos(ang(i))*dy*(j-1);
        yg(i,j)=yc(i)+sin(ang(i))*dy*(j-1);
    end
end


z=interp2(xb,yb,zb,xg,yg);

for j=1:ny
%    davg(j)=mean(z(:,j));
    davg(j)=nanmean(z(:,j));
    davg(j)=max(-davg(j),1);
    % Depth relation
    dy1(j)=davg(j)*drel;
    % Courant criterion
    v=sqrt(9.81*davg(j));
    dy1(j)=min(c*dt/v,dy1(j));
    % Set limits
    dy1(j)=min(dy1(j),dymax);
    dy1(j)=max(dy1(j),dymin);
end

y0=0:dy:(ny-1)*dy;

yy=0;
j=0;
while yy<yoff
    j=j+1;
    ddy(j)=interp1(y0,dy1,yy);
    if j>1
        % Ensure smoothness
        ddy(j)=min(ddy(j),ddy(j-1)*nsmooth);
    end
    yy=yy+ddy(j);
end
ny=j;

xg=xg(:,1);
yg=yg(:,1);

for i=1:nx
    for j=2:ny
        xg(i,j)=xg(i,j-1)+cos(ang(i))*ddy(j);
        yg(i,j)=yg(i,j-1)+sin(ang(i))*ddy(j);
    end
end

x=xg;
y=yg;
z=interp2(xb,yb,zb,x,y);
