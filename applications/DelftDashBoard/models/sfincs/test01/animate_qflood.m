clear variables;close all;

%% Read input
fid=fopen('bates.inp');
mmax=str2double(fgetl(fid));
nmax=str2double(fgetl(fid));
dx=str2double(fgetl(fid));
dy=str2double(fgetl(fid));
rundur=str2double(fgetl(fid));
dtout=str2double(fgetl(fid));
alfa=str2double(fgetl(fid));
vmax=str2double(fgetl(fid));
manning=str2double(fgetl(fid));
depfile=fgetl(fid);
bndfile=fgetl(fid);
bndlocfile=fgetl(fid);
fclose(fid);

%% Create grid
lenx=(mmax-1)*dx;
leny=(nmax-1)*dy;
xx=0:dx:lenx;
yy=0:dy:leny;
[x,y]=meshgrid(xx,yy);

z=load(depfile);
z(z<-90)=NaN;
z(z>90)=NaN;

s=load('output.txt');
nt=size(s,1)/nmax;
wlc = mat2cell(s,nmax*ones(nt,1),mmax);
figure(7)
p1=surf(x,y,z);hold on;
set(p1,'facecolor',[0.6 0.6 0.6]);
set(p1,'edgecolor','none');
set(gca,'zlim',[-1 10]);
zw=wlc{1};
zw(zw-z<0.01)=NaN;
p=surf(x,y,zw);
set(p,'facecolor',[0.8 0.8 1.0]);
set(p,'edgecolor','none');
set(p,'FaceAlpha',0.8);
light;
for it=1:nt
  zw=wlc{it};
  zw(zw>90)=NaN;
  zw(zw-z<0.01)=NaN;
  set(p,'zdata',  zw);
    drawnow;pause(0.05);
end


% figure(8)
% p1=plot(x(1,:),z(1,:));hold on;
% set(gca,'ylim',[-1 5]);
% zw=wlc{1};
% zw(zw-z<0.01)=NaN;
% p=plot(x(1,:),zw(1,:));
% for it=1:nt
% zw=wlc{it};
% zw(zw-z<0.01)=NaN;
%   set(p,'ydata',  zw(1,:));
%     drawnow;pause(0.5);
% end
% 
zmax=load('zmax.txt');
zmax(zmax<0)=NaN;
dp=zmax-z;
zmax(dp<0.1)=NaN;
figure(9)
% z(z<0)=NaN;
% pcolor(x,y,z);axis equal;shading flat;colorbar;
% hold on;
% zmax(~isnan(zmax))=1;
zmax(zmax<0)=NaN;
zmax(dp<0.1)=NaN;
p=pcolor(x,y,zmax);axis equal;shading flat;colorbar;

%set(p,'facecolor',[0  0 1]);
