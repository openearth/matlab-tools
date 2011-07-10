function [polx,poly,xax,yax,len,pos]=curvec(x,y,u,v,varargin)
%CURVEC make curvy arrows from velocity vector fields
%
% Can be used for stills and animations. This function computes streamlines
% along randomly distributed seed points. 
%
% [polx,poly,xax,yax,len,pos] = curvec(x,y,u,v,'keyword','value')
%
% INPUT
% x,y   : values of the coordinates to be transformed
% u,v   : values of the velocity components
% 
% OUTPUT
% polx,poly  : n*2 matrix with polygons of curvy arrows
% xax,yax    : n*2 matrix with axis coordinates of curvy arrows
% len        : vector with length of curvy arrows (in m)
% pos        : n*3 matrix with start coordinates for arrows in next time step
%              (first two columns) and age of arrow (third column) 
%
% OPTIONAL INPUT ARGUMENTS
% dx             : Average horizontal distance (in metres) between start points of arrows.
% timestep       : Time step of animation (in seconds).
% length         : Length of the curvy arrows (in seconds).
% xlim           : Vector with horizontal limits in x-direction.
% ylim           : Vector with horizontal limits in y-direction.
% position       : n*3 matrix with start coordinates for arrows in next time step
%                  (first two columns) and age of arrow (third column).
%                  This option is only required for animations.
% nrvertices     : Number of vertices along axis of arrows (default 10).
% headthickness  : Relative width of arrow heads (default 1.0).
% arrowthickness : Relative width of arrows (default 0.5).
% lifespan       : Life span of arrows in animation (default 50). Only for
%                  animations.
% relativespeed  : Factor for speed of curvy arrows (default 1.0). Only for
%                  animations.
% polygon        : Matrix with coordinates of polygon within which curvy
%                  arrows will be computed (first column x, second column
%                  y). Overrides xlim and ylim.
% cs             : Type of coordinate system. Must be 'geographic' or
%                  'projected' (default).
%
% Note: the maximum number of arrows is 15000!
% 
% EXAMPLE 1 : Still
% 
% [x,y] = meshgrid(0:10:300,0:10:100);
% u = zeros(size(x))+1;
% v = 0.5*cos(x/30);
% [polx,poly]=curvec(x,y,u,v,'length',20,'dx',10,'headthickness',1,'arrowthickness',0.5);
% patch(polx,poly,'g');axis equal;
%
% EXAMPLE 2 : Animation
% 
% [x,y]=meshgrid(0:1:100,0:1:100);
% ang=atan2(y-50,x-50);
% dist=sqrt((x-50).^2+(y-50).^2);
% amp=cos(2*pi*dist/50);
% fig=figure;
% set(fig,'Position',[20 20 600 600]);
% ptch=patch(0,0,'r');
% axis equal;
% set(gca,'xlim',[-10 110],'ylim',[-10 110]);
% aviobj = avifile('example.avi','fps',20,'Compression','Cinepak','Quality',100);
% pos=[];
% for t=1:200
%     disp(['Processing ' num2str(t) ' of 200 ...']);
%     u=amp.*sin(ang-pi)+0.004*t*cos(ang-pi);
%     v=amp.*cos(ang)+0.004*t*sin(ang-pi);
%     [polx,poly,xax,yax,len,pos]=curvec(x,y,u,v,'length',10,'dx',5,'position',pos,'timestep',2);
%     set(ptch,'XData',polx,'YData',poly);
%     F = getframe(fig);
%     aviobj = addframe(aviobj,F);
% end
% close(fig)
% aviobj = close(aviobj);
%
% --------------------------------------------------------------------
% Copyright (C) 2011 Deltares
%
%       Maarten.vanOrmondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
% This library is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this library.  If not, see <http://www.gnu.org/licenses/>.
% --------------------------------------------------------------------

% Set default values
nt=10;
dtCurVec=[];
pos=[];
iopt=0;

hdthck=1;
arthck=0.5;
lifespan=50;
relspeed=1;
timestep=0;

polxy=[];

xmin=min(min(x));
ymin=min(min(y));
xmax=max(max(x));
ymax=max(max(y));
dx=(xmax-xmin)/20;

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
                xp=squeeze(polxy(:,1));
                yp=squeeze(polxy(:,2));
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

if isempty(dtCurVec)
    % Try to estimate good value for length
    vmean=nanmean(nanmean(sqrt(u.^2+v.^2)));
    dtCurVec=0.05*(xmax-xmin)/vmean;
end

if isempty(polxy)
    % Make polygon from xlim and ylim
    xp=[xmin xmax xmax xmin];
    yp=[ymin ymin ymax ymax];
end

%% Start points of curved vectors
if ~isempty(pos)
    x2=pos(:,1);
    y2=pos(:,2);
    iage=pos(:,3);
    n2=length(x2);
else
   % Total number of arrows
    polarea=polyarea(xp,yp);
    n2=round(polarea/dx^2);
    [x2,y2]=randomdistributeinpolygon(xp,yp,'nrpoints',n2);
    iage=round(lifespan*rand(n2,1));
    iage=min(iage,47);
    iage=max(iage,3);
end

if n2>15000
    disp(['Number of curved arrows (' num2str(n2) ') exceeds 15000!']);
    return
end

% Check for points past their lifespan
idead=find(iage>=lifespan);
for j=1:length(idead)
    ii=idead(j);
    [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
    x2(ii)=xn;
    y2(ii)=yn;
    iage(ii)=0;
end

% Check for points outside polygon
iout=find(inpolygon(x2,y2,xp,yp)==0);
for j=1:length(iout)
    ii=iout(j);
    [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
    x2(ii)=xn;
    y2(ii)=yn;
    iage(ii)=0;
end

% Getting the mean values for x and y. This is necessary because of
% precision issues in the mex file. The data is first translated. The
% arrows are translated back after they are generated.
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

% Make arrows narrower that were just seeded or which are about to die
relwdt=zeros(n2,1)+1;
if timestep>0
    for ii=1:n2
        if iage(ii)<4
            relwdt(ii)=iage(ii)/4;
        elseif iage(ii)>lifespan-4
            relwdt(ii)=(lifespan-iage(ii)+1)/4;
        else
            relwdt(ii)=1.0;
        end
    end
end

% Length of each section in the arrow
dt=dtCurVec/(nt-1);

% Compute arrows using mex file
[xp,yp,xax,yax,len]=crvec(x2,y2,x1,y1,u,v,dt,nt,hdthck,arthck,relwdt,iopt);

% Set nan values
xp(xp<1000.0 & xp>999.998)=NaN;
yp(yp<1000.0 & yp>999.998)=NaN;
xax(xax<1000.0 & xax>999.998)=NaN;
yax(yax<1000.0 & yax>999.998)=NaN;

% Translate back
xp=xp+xmean;
yp=yp+ymean;
xax=xax+xmean;
yax=yax+ymean;

% Count number of points per arrow
ic=1;
while ~isnan(xp(ic,1));
    ic=ic+1;
end

% Put all arrows in 2D matrix
polx=reshape(xp,[ic n2]);
poly=reshape(yp,[ic n2]);
xax=reshape(xax,[nt+1 n2]);
yax=reshape(yax,[nt+1 n2]);

% Get rid of very short arrows
ishort=len<0.01;
polx(:,ishort)=NaN;
poly(isnan(polx))=NaN;

% Get rid of NaN row
polx=polx(1:end-1,:);
poly=poly(1:end-1,:);
xax=xax(1:end-1,:);
yax=yax(1:end-1,:);

% Determine position of arrows in next time step
if timestep>dtCurVec
    timestep=dtCurVec;
end
nn=(nt-1)*(relspeed*timestep/dtCurVec);
nfrac=nn-floor(nn);
nn1=floor(nn)+1;
nn2=floor(nn)+2;
nn2=min(nn2,n2);
pos(:,1)=xax(nn1,:)+nfrac*(xax(nn2,:)-xax(nn1,:));
pos(:,2)=yax(nn1,:)+nfrac*(yax(nn2,:)-yax(nn1,:));
pos(:,3)=iage+1;

%%
function [x,y]=randomdistributeinpolygon(xp,yp,varargin)

np=[];
dxp=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'nrpoints'}
                np=varargin{i+1};
            case{'dx'}
                dxp=varargin{i+1};
        end
    end
end

if isempty(np)
    parea=polyarea(xp,yp);
    np=round(parea/dxp^2);
end

xmin=min(min(xp));
xmax=max(max(xp));
ymin=min(min(yp));
ymax=max(max(yp));

nrInPol=0;
x=zeros(np,1);
y=zeros(np,1);
while nrInPol<np
    nrnew=np-nrInPol;
    xr=xmin+rand(nrnew,1)*(xmax-xmin);
    yr=ymin+rand(nrnew,1)*(ymax-ymin);
    inp=inpolygon(xr,yr,xp,yp);
    iinp=find(inp==1);
    sumInp=length(iinp);
    if sumInp>0
        x(nrInPol+1:nrInPol+sumInp)=xr(iinp);
        y(nrInPol+1:nrInPol+sumInp)=yr(iinp);
    end
    nrInPol=nrInPol+sumInp;
end
