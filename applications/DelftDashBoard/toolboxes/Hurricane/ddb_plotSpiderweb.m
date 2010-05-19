function ddb_plotSpiderweb(fname,x,y,z,xldb,yldb,handles)

c=load([handles.SettingsDir '\icons\icons_muppet.mat']);

fig=MakeNewWindow('Spiderweb',[600 400],[handles.SettingsDir '\icons\deltares.gif']);

figure(fig);

tbh = uitoolbar;

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,1,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback',{@ddb_zoomInOutPan,2,'dummy',[],[],[]});
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);


% h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
% set(h,'ClickedCallback',{@ddb_zoomInOutPan,1});
% set(h,'Tag','UIToggleToolZoomIn');
% set(h,'cdata',c.ico.zoomin16);
% 
% h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
% set(h,'ClickedCallback',{@ddb_zoomInOutPan,2});
% set(h,'Tag','UIToggleToolZoomOut');
% set(h,'cdata',c.ico.zoomout16);

% h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
% set(h,'ClickedCallback',{@ddb_zoomInOutPan,3,'dummy',[],[],[]}');
% set(h,'Tag','UIToggleToolPan');
% set(h,'cdata',cpan.icons.pan);

[x,y,u,v,p,t]=ReadSpw(fname,1,handles);

u=u/111000;
v=v/111000;

Ax.XMin=min(min(x));
Ax.XMax=max(max(x));
Ax.YMin=min(min(y));
Ax.YMax=max(max(y));
Ax.MaxZ=100;


Plt.DxCurVec=20000/110000;
Plt.DtCurVec=1200;
Plt.HeadThickness=3;
Plt.ArrowThickness=1;
Plt.LifeSpanCurVec=50;
Plt.DDtCurVec=0;
Plt.PlotRoutine='plotcoloredcurvedarrows';
Plt.CMin=0;
Plt.CMax=max(max(u));

Data.x=x;
Data.y=y;
Data.u=u;
Data.v=v;
%quiver(x,y,u,v);hold on;

PlotCurVec(Ax,Plt,Data);
axis equal;
hold on;
plot(xldb,yldb);

set(gca,'Units','pixels');
set(gca,'CLim',[Plt.CMin*111000 Plt.CMax*111000]);

ddb_makeColorBar(jet);
sz=get(gca,'Position');
h=findall(gcf,'Tag','colorbar');
if ~isempty(h)
    set(h,'Position',[sz(1)+sz(3)+20 sz(2) 15 sz(4)]);
end

%set(gca,'xlim',[-1000000 1000000],'ylim',[2000000 3000000]);
%quiver(x,y,u,v);axis equal;
%surf(x,y,p);axis equal;shading interp;view(2);colorbar;
% handles.ScreenParameters.XMaxRange=[0 1000000];
% handles.ScreenParameters.YMaxRange=[-1000 1000];
% guidata(gcf,handles);
% 
% plot(times,prediction);
% xtck=datestr(get(gca,'Xtick'),24);
% %xtck=datestr(get(gca,'Xtick'));
% set(gca,'XTickLabel',xtck);
% grid on;
% xlabel('Date');
% ylabel('Water Level (m)');
% title(name);
% 


function [x,y,u,v,p,t]=ReadSpw(fname,nt,handles)
x=[];
y=[];
u=[];
v=[];
p=[];
t=[];

fid=fopen(fname,'r');
s=fgets(fid);
s=fgets(fid);
tstr=s(3:end);
ItDate=datenum(tstr,'yyyymmddHHMMSS');
s=fgets(fid);
tstr=s(3:end);
nrns=str2num(tstr);
nr=nrns(1);
ns=nrns(2);
s=fgets(fid);
rmax=str2double(s(2:end));
s=fgets(fid);
s=fgets(fid);
s=fgets(fid);
s=fgets(fid);
s=fgets(fid);
for ii=1:nt-1
    s=fgets(fid);
    s=fgets(fid);
    fmt='%f';
    a = textscan(fid,fmt,nr*ns);
end
s=fgets(fid);
t=str2num(s(1:28));
s=fgets(fid);
v=str2num(s);
lon0=v(1);
lat0=v(2);
fmt='%f';
vel0 = textscan(fid,fmt,nr*ns);
dir0 = textscan(fid,fmt,nr*ns);
p0   = textscan(fid,fmt,nr*ns);
vel=reshape(vel0{1},ns,nr);
dirc=reshape(dir0{1},ns,nr);
p=reshape(p0{1},ns,nr);
u=vel.*cos((270-dirc)*pi/180);
v=vel.*sin((270-dirc)*pi/180);
dr=rmax/nr;
rr=dr:dr:rmax;
ds=2*pi/ns;
ss=ds:ds:2*pi;
[xx0,yy0]=meshgrid(rr,ss);
x=xx0.*cos(0.5*pi-yy0);
y=xx0.*sin(0.5*pi-yy0);

cs0.Name='WGS 84';
cs0.Type='geo';
cs1.Name='WGS 84 / UTM zone 16N';
cs1.Type='xy';
[x0,y0]=ddb_coordConvert(lon0,lat0,cs0,cs1);

x=x+x0;
y=y+y0;

cs0.Name='WGS 84 / UTM zone 16N';
cs0.Type='xy';
cs1.Name='WGS 84';
cs1.Type='geo';
[x,y]=ddb_coordConvert(x,y,cs0,cs1);

x(ns+1,:)=x(1,:);
y(ns+1,:)=y(1,:);
u(ns+1,:)=u(1,:);
v(ns+1,:)=v(1,:);
fclose(fid);
