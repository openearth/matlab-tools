function PlotCurVec(Ax,Plt,Data)

iprint=0;

xmin=Ax.XMin-0.1*(Ax.XMax-Ax.XMin);
xmax=Ax.XMax+0.1*(Ax.XMax-Ax.XMin);

ymin=Ax.YMin-0.1*(Ax.YMax-Ax.YMin);
ymax=Ax.YMax+0.1*(Ax.YMax-Ax.YMin);

dx=Plt.DxCurVec;
dy=dx;

nt=20;
dt=Plt.DtCurVec/nt;
hdthck=Plt.HeadThickness;
arthck=Plt.ArrowThickness;

nx=round((xmax-xmin)/dx)+1;
ny=round((ymax-ymin)/dy)+1;
n2=nx*ny;
if n2>15000
    disp(['Number of curved arrows (' num2str(n2) ') exceeds 15000!']);
    return
end
ic=0;

lifespan=Plt.LifeSpanCurVec;

for jj=1:ny;
    for ii=1:nx;
        ic=ic+1;
        x2(ic)=xmin+(ii-0.5)*dx+(0.5*rand(1)-0.5)*dx;
        y2(ic)=ymin+(jj-0.5)*dy+(0.5*rand(1)-0.5)*dy;
        iage(ic)=round(lifespan*rand);
    end
end
x2=x2';
y2=y2';

x1=Data.x;
y1=Data.y;
u=Data.u;
v=Data.v;

x1(isnan(x1))=-999.0;
y1(x1==-999.0)=-999.0;
u(x1==-999.0)=-999.0;
v(x1==-999.0)=-999.0;

relwdt=zeros(n2,1)+1.0;

[xp,yp,xax,yax]=mkcurvec(x2,y2,x1,y1,u,v,dt,nt,hdthck,arthck,relwdt);

xp(xp<1000.0 & xp>999.998)=NaN;
yp(yp<1000.0 & yp>999.998)=NaN;

ic=1;
% count number of points per arrow
while ~isnan(xp(ic,1));
    ic=ic+1;
end

% put all arrows in 2D matrix;
for icel=1:size(xp,1)/(ic);
    pol{icel}(:,1)=xp((icel-1)*ic+1:icel*ic-1);
    pol{icel}(:,2)=yp((icel-1)*ic+1:icel*ic-1);
    pol{icel}(:,3)=zeros(size(pol{icel}(:,1)))+icel*10;
end

Ax.MaxZ=icel*10;

xax(xax<1000.0 & xax>999.998)=NaN;
yax(yax<1000.0 & yax>999.998)=NaN;

ic=1;
% count number of points per arrow
while ~isnan(xax(ic,1));
    ic=ic+1;
end
% put all arrows in 2D matrix;
for icel=1:size(xax,1)/(ic);
    ax{icel}(:,1)=xax((icel-1)*ic+1:icel*ic-1);
    ax{icel}(:,2)=yax((icel-1)*ic+1:icel*ic-1);
end


if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')
%    clmap=ddb_getColors(handles.ScreenParameters.ColorMaps,Plt.ColorMap,20);
    clmap=jet(20);
    lmin=Plt.CMin*Plt.DtCurVec;
    lmax=Plt.CMax*Plt.DtCurVec;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
    x=lmin:((lmax-lmin)/(length(r)-1)):lmax;
end

for ii=1:n2
    if pol{ii}(1,1)~=pol{ii}(2,1)
        fl=patch(pol{ii}(:,1),pol{ii}(:,2),pol{ii}(:,3),'k');hold on;
%        SetObjectData(fl,i,j,k,'curvedarrow');
%        set(fl,'EdgeColor','k');
        set(fl,'EdgeColor',[0.5 0.5 0.5]);
        if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')
            pd=pathdistance(ax{ii}(:,1),ax{ii}(:,2));
            len=max(min(pd(end,1),lmax),lmin);
            r1=min(max(interp1(x,r,len),0),1);
            g1=min(max(interp1(x,g,len),0),1);
            b1=min(max(interp1(x,b,len),0),1);
            set(fl,'FaceColor',[r1 g1 b1]);
            set(fl,'EdgeColor','none');
        else
            set(fl,'FaceColor','b');
%        end
%         if Plt.DDtCurVec>0
%             if iage(ii)<4
%                 alp=iage(ii)/4;
%                 alpha(fl,alp);
%             end
%             if iage(ii)>lifespan-4
%                 alp=(lifespan-iage(ii)+1)/4;
%                 alpha(fl,alp);
%             end
         end
    end
end

