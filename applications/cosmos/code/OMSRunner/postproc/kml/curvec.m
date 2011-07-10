function [polx,poly,xax,yax,len,pos]=curvec(x,y,u,v,varargin)

% Set default values
xmin=min(min(x));
ymin=min(min(y));
xmax=max(max(x));
ymax=max(max(y));
dx=(xmax-xmin)/20;
dy=(ymax-ymin)/20;
nt=10;
dtCurVec=1;
pos=[];
iopt=0;

hdthck=0.6;
arthck=0.2;
lifespan=50;
relspeed=1;
timestep=1;

polxy=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xlim'}
                xmin=varargin{i+1}(1);
                xmax=varargin{i+1}(2);
            case{'ylim'}
                ymin=varargin{i+1}(1);
                ymax=varargin{i+1}(2);
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'position'}
                pos=varargin{i+1};
            case{'length'}
                dtCurVec=varargin{i+1};
            case{'nrvertices'}
                nt=varargin{i+1};
            case{'headthickness'}
                hdthck=varargin{i+1};
            case{'arrowthickness'}
                arthck=varargin{i+1};
            case{'lifespan'}
                lifespan=varargin{i+1};
            case{'relativespeed'}
                relspeed=varargin{i+1};
            case{'timestep'}
                timestep=varargin{i+1};
            case{'polygon'}
                polxy=varargin{i+1};
                polarea=polyarea(polxy(:,1),polxy(:,1));
            case{'coordinatesystem','cs'}
                switch lower(varargin{i+1})
                    case{'geographic','geo','spherical','latlon'}
                        iopt=1;
                    otherwise
                        iopt=0;
                end
        end
    end
end

if isempty(dy)
    dy=dx;
end

dt=dtCurVec/(nt-1);

%% Start points of curved vectors

nx=round((xmax-xmin)/dx)+1;
ny=round((ymax-ymin)/dy)+1;
n2=nx*ny;
if n2>15000
    disp(['Number of curved arrows (' num2str(n2) ') exceeds 15000!']);
    return
end

if ~isempty(pos)
    a=pos;
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
    % TODO need to include some mercator stuff here
    [x2,y2]=meshgrid(xmin:dx:xmin+(nx-1)*dx,ymin:dy:ymin+(ny-1)*dy);
    x2=x2+0.5*dx*rand(ny,nx)+0.5*dx;
    y2=y2+0.5*dx*rand(ny,nx)+0.5*dx;
    x2=reshape(x2,[nx*ny 1]);
    y2=reshape(y2,[nx*ny 1]);
    iage=round(lifespan*rand(nx*ny,1));
end

x1=x;
y1=y;

m1=size(x1,1);
n1=size(x1,2);

xmean=nanmean(reshape(x1,m1*n1,1));
ymean=nanmean(reshape(y1,m1*n1,1));

x1=x1-xmean;
y1=y1-ymean;

x2=x2-xmean;
y2=y2-ymean;

x1(isnan(x1))=-999.0;
y1(x1==-999.0)=-999.0;
u(x1==-999.0)=-999.0;
v(x1==-999.0)=-999.0;

relwdt=zeros(n2,1);
for ii=1:n2
    if iage(ii)<4
        relwdt(ii)=iage(ii)/4;
    elseif iage(ii)>lifespan-4
        relwdt(ii)=(lifespan-iage(ii)+1)/4;
    else
        relwdt(ii)=1.0;
    end
end

[xp,yp,xax,yax,len]=crvec(x2,y2,x1,y1,u,v,dt,nt,hdthck,arthck,relwdt,iopt);

xp(xp<1000.0 & xp>999.998)=NaN;
yp(yp<1000.0 & yp>999.998)=NaN;
xax(xax<1000.0 & xax>999.998)=NaN;
yax(yax<1000.0 & yax>999.998)=NaN;

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

for n=1:n2
    if len(n)<0.01
        polx(:,n)=NaN;
    end
end
poly(isnan(polx))=NaN;

polx=polx(1:end-1,:);
poly=poly(1:end-1,:);

xax=reshape(xax,[nt+1 n2]);
yax=reshape(yax,[nt+1 n2]);

nn=(nt-1)*(relspeed*timestep/dtCurVec);
nfrac=nn-floor(nn);
nn1=floor(nn)+1;
nn2=floor(nn)+2;
nn2=min(nn2,n2);
for ii=1:n2
    pos(ii,1)=xax(nn1,ii)+nfrac*(xax(nn2,ii)-xax(nn1,ii));
    pos(ii,2)=yax(nn1,ii)+nfrac*(yax(nn2,ii)-yax(nn1,ii));
    pos(ii,3)=iage(ii)+1;
end
