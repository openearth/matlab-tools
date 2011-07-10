clear variables;close all;

lifespan=50;

dxp=0.05;
xp=[1 4 3 0.5 1];
yp=[2 2.5  5 4 2];
[x,y]=randomdistributeinpolygon(xp,yp,'dx',dxp);
age=round(rand(length(x),1)*lifespan);
plot(xp,yp);hold on;axis equal;
plt=plot(0,0,'.');

set(gca,'xlim',[0 6],'ylim',[0 6]);

for k=1:200
    
%            tic
            
            x=x-0.02;

            % Dead points
    idead=find(age>=lifespan);
    for j=1:length(idead)
        ii=idead(j);
        [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
 %       [xn,yn]=addNewPoint(xp,yp,x,y,dxp);
        x(ii)=xn;
        y(ii)=yn;
        age(ii)=0;
    end
    
    iout=inpolygon(x,y,xp,yp);
    iout=find(iout==0);
    % Outside
    for j=1:length(iout)
        ii=iout(j);
        [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
 %       [xn,yn]=addNewPoint(xp,yp,x,y,dxp);
        x(ii)=xn;
        y(ii)=yn;
        age(ii)=0;
    end
    
%    toc
    set(plt,'XData',x,'YData',y);
    age=age+1;
    drawnow;
% 
% 
% 
% [xn2,yn2]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
% plot(xn2,yn2,'go');
% 
% [xn,yn]=addNewPoint(xp,yp,x,y,dxp);
% plot(xn,yn,'ro');

end

[xg,yg]=meshgrid(0:1:100,0:1:100);
ang=atan2(yg-50,xg-50);
dist=sqrt((xg-50).^2+(yg-50).^2);
amp=cos(2*pi*dist/50);
u=amp.*sin(ang-pi);
v=amp.*cos(ang);
amp2=1./dist;
amp2=min(amp2,0.5);
u2=amp2.*cos(ang-pi);
v2=amp2.*sin(ang-pi);
quiver(xg,yg,u+u2,v+v2);axis equal;
pcolor(xg,yg,ang);axis equal;colorbar;

[polx,poly,xax,yax,len,pos]=curvec(xg,yg,u2,v2,'length',0.5);

% for i=1:size(xx,1)-1;
%     for j=1:size(xx,2)-1
%         ii=find(x>xx(i,j)&x<xx(i,j+1)&y>yy(i,j)&y<yy(i+1,j));
%         n(i,j)=length(ii);
%     end
% end
% n(n==0)=1e7;
% [ii,jj]=find(n==min(min(n)));
% ii=ii(1);
% jj=jj(1);
% xpn{1}=xp;
% ypn{1}=yp;
% xpn{2}=[xx(i,j) xx(i,j+1) xx(i,j+1) xx(i,j)];
% ypn{2}=[yy(i,j) yy(i,j+1) yy(i,j+1) yy(i,j)];
% 
% [xn,yn]=randomdistributeinpolygon(xpn,ypn,'nrpoints',1);
% 

% t=triangulatePolygon(xp,yp,0.5);
