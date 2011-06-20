function handles=PlotCurVec(handles,i,j,k,mode)

DeleteObject(i,j,k);

Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

if Ax.AxesEqual
    xmin0=Ax.XMin; xmax0=xmin0+0.01*Ax.Position(3)*Ax.Scale;
    ymin0=Ax.YMin; ymax0=ymin0+0.01*Ax.Position(4)*Ax.Scale;
else
    xmin0=Ax.XMin; xmax0=Ax.XMax;
    ymin0=Ax.YMin;
    ymin0=merc(ymin0);
    szx=Ax.Position(3);
    szy=Ax.Position(4);
    ymax0=(szy/szx)*(xmax0-xmin0)+ymin0;
end

xmin=xmin0-0.1*(xmax0-xmin0);
xmax=xmax0+0.1*(xmax0-xmin0);

ymin=ymin0-0.1*(ymax0-ymin0);
ymax=ymax0+0.1*(ymax0-ymin0);

dx=Plt.DxCurVec;
dy=dx;

%    nt=Plt.NpCurVec;
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

if exist('.\pos1.dat','file')
    a=load('.\pos1.dat');
    x2=a(:,1);
    y2=a(:,2);
    iage=a(:,3);
    for ii=1:length(x2);
        if iage(ii)>lifespan
            x2(ii)=xmin+(xmax-xmin)*rand;
            y2(ii)=ymin+(ymax-ymin)*rand;
            iage(ii)=1;
        end
    end
else
    [x2,y2]=meshgrid(xmin:dx:xmin+(nx-1)*dx,ymin:dy:ymin+(ny-1)*dy);
    x2=x2+0.5*dx*rand(ny,nx)+0.5*dx;
    y2=y2+0.5*dx*rand(ny,nx)+0.5*dx;
    x2=reshape(x2,[nx*ny 1]);
    y2=reshape(y2,[nx*ny 1]);
    iage=round(lifespan*rand(nx*ny,1));
end

x1=Data.x;
y1=Data.y;
u=Data.u;
v=Data.v;

mfac=100000;

m1=size(x1,1);
n1=size(x1,2);

xmean=nanmean(reshape(x1,m1*n1,1));
ymean=nanmean(reshape(y1,m1*n1,1));

x1=x1-xmean;
y1=y1-ymean;

x2=x2-xmean;
y2=y2-ymean;

x1=x1*mfac;
y1=y1*mfac;
x2=x2*mfac;
y2=y2*mfac;
dt=dt*mfac;

x1(isnan(x1))=-999.0;
y1(x1==-999.0)=-999.0;
u(x1==-999.0)=-999.0;
v(x1==-999.0)=-999.0;

if Plt.DDtCurVec>0
    for ii=1:n2
        if iage(ii)<4
            relwdt(ii)=iage(ii)/4;
        elseif iage(ii)>lifespan-4
            relwdt(ii)=(lifespan-iage(ii)+1)/4;
        else
            relwdt(ii)=1.0;
        end
    end
else
    relwdt=zeros(n2,1)+1.0;
end

[xp,yp,xax,yax]=mkcurvec(x2,y2,x1,y1,u,v,dt,nt,hdthck,arthck,relwdt);

xp(xp<1000.0 & xp>999.998)=NaN;
yp(yp<1000.0 & yp>999.998)=NaN;
xax(xax<1000.0 & xax>999.998)=NaN;
yax(yax<1000.0 & yax>999.998)=NaN;

xp=xp/mfac;
yp=yp/mfac;
xax=xax/mfac;
yax=yax/mfac;

xp=xp+xmean;
yp=yp+ymean;

xax=xax+xmean;
yax=yax+ymean;

ic=1;
% count number of points per arrow
while ~isnan(xp(ic,1));
    ic=ic+1;
end

% put all arrows in 2D matrix;
polx=reshape(xp,[ic n2]);
poly=reshape(yp,[ic n2]);
polz=zeros(size(polx));

for n=1:n2
    if polx(1,n)==polx(2,n)
        polx(:,n)=NaN;
    end
end
poly(isnan(polx))=NaN;
polz(isnan(polz))=NaN;

polx=polx(1:end-1,:);
poly=poly(1:end-1,:);
polz=polz(1:end-1,:);

xax=reshape(xax,[nt+1 n2]);
yax=reshape(yax,[nt+1 n2]);

% if ~Ax.AxesEqual
%     poly=merc(poly);
% end

Ax.MaxZ=n2*10;

edgeColor=FindColor(Plt.LineColor);

if strcmpi(Plt.PlotRoutine,'plotcoloredcurvedarrows')

    % get rgb values
    clmap=GetColors(handles.ColorMaps,Plt.ColorMap,20);
    lmin=Plt.CMin*Plt.DtCurVec;
    lmax=Plt.CMax*Plt.DtCurVec;
    r=clmap(:,1);
    g=clmap(:,2);
    b=clmap(:,3);
    x=lmin:((lmax-lmin)/(length(r)-1)):lmax;

    len=zeros(1,n2);
    for ii=2:nt
        len=len+sqrt((xax(ii,:)-xax(ii-1,:)).^2 + (yax(ii,:)-yax(ii-1,:)).^2);
    end
    len=max(min(len,lmax),lmin);
    r1=min(max(interp1(x,r,len),0),1);
    g1=min(max(interp1(x,g,len),0),1);
    b1=min(max(interp1(x,b,len),0),1);       
    cl(1,:,:)=[r1;g1;b1]';
    
    fl=patch(polx,poly,polz,cl);
    set(fl,'EdgeColor',edgeColor);    
else
    faceColor=FindColor(Plt.FillColor);
    fl=patch(polx,poly,polz,'r');
    set(fl,'MarkerFaceColor',faceColor);%hold on;
    set(fl,'EdgeColor',edgeColor);%hold on;
end

SetObjectData(fl,i,j,k,'curvedarrow');

% if Plt.DDtCurVec>0
%     for ii=1:n2
%     if iage(ii)<4
%         alp=iage(ii)/4;
%         alpha(fl,alp);
%     end
%     if iage(ii)>lifespan-4
%         alp=(lifespan-iage(ii)+1)/4;
%         alpha(fl,alp);
%     end
%     end
% end

if Plt.DDtCurVec>0
    nn=round(nt*(Plt.RelSpeedCurVec*Plt.DDtCurVec/Plt.DtCurVec));
    nn=max(1,min(nn,nt-1));
    for ii=1:n2
        pos(ii,1)=xax(nn,ii);
        pos(ii,2)=yax(nn,ii);
        pos(ii,3)=iage(ii)+1;
    end
    save('.\pos1.dat','pos','-ascii');
end

clear pol pos iage xar yar xax yax ax xss yssn xx1 yy1 xx2 yy2 x1 y1 u v u2 v2 xp yp

