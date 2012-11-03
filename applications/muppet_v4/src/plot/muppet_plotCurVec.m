function handles=muppet_plotCurVec(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

xmin0=plt.xmin; xmax0=plt.xmax;
ymin0=plt.ymin; ymax0=plt.ymax;

xmin=xmin0-0.1*(xmax0-xmin0);
xmax=xmax0+0.1*(xmax0-xmin0);

ymin=ymin0-0.1*(ymax0-ymin0);
ymax=ymax0+0.1*(ymax0-ymin0);

dx=opt.curvecspacing;
nt=20;

hdthck=opt.headthickness;
arthck=opt.arrowthickness;
lifespan=opt.curveclifespan;

pos=[];    
if exist(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat'],'file')
    pos=load(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat']);
end

x1=data.x;
y1=data.y;
u=data.u;
v=data.v;

timestep=0;
if ~isempty(handles.animationsettings.timestep)
    timestep=handles.animationsettings.timestep;
end

plt.coordinatesystem.type='projected';

[polx,poly,xax,yax,len,pos]=curvec(x1,y1,u,v,'dx',dx,'length',opt.curveclength,'nrvertices',nt,'nhead',4, ...
    'xlim',[xmin xmax],'ylim',[ymin ymax],'position',pos,'lifespan',lifespan,'timestep',timestep, ...
    'headthickness',hdthck,'arrowthickness',arthck,'cs',plt.coordinatesystem.type,'relativespeed',opt.curvecrelativespeed);
% polz=zeros(size(polx))+100;

edgecolor=colorlist('getrgb','color',opt.edgecolor);

if strcmpi(opt.plotroutine,'plotcoloredcurvedarrows')
    % get rgb values
    speed=len/opt.curveclength;
    speed=min(speed,opt.cmax);
    speed=max(speed,opt.cmin);
    clmap=muppet_getColors(handles.colormaps,opt.colormap,20);
    lmin=opt.cmin;
    lmax=opt.cmax;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
    x=lmin:((lmax-lmin)/(length(r)-1)):lmax;
    r1=min(max(interp1(x,r,speed),0),1);
    g1=min(max(interp1(x,g,speed),0),1);
    b1=min(max(interp1(x,b,speed),0),1);
    cl(1,:,1)=r1;    
    cl(1,:,2)=g1;    
    cl(1,:,3)=b1;    
    fl=patch(polx,poly,cl);
    set(fl,'EdgeColor',edgecolor);    
else
    facecolor=colorlist('getrgb','color',opt.facecolor);
    fl=patch(polx,poly,'r');
    set(fl,'FaceColor',facecolor);
    set(fl,'EdgeColor',edgecolor);
end

if ~isempty(timestep)
    save(['curvecpos.' num2str(j,'%0.3i') '.' num2str(k,'%0.3i') '.dat'],'pos','-ascii');
end

