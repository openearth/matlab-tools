function varargout=curvec(x,y,u,v,varargin)
%CURVEC make curvy arrows from velocity vector fields
%
% This function computes streamlines along randomly distributed seed
% points and generates curvy arrows along these streamlines.Can be used
% for stills and animations.
%
% [polx,poly,xax,yax,len,pos] = curvec(x,y,u,v,'keyword','value')
%
% INPUT:
% x,y            : Values of the x and y coordinates of the velocity vector field.
% u,v            : Values of the velocity components.
% 
% OUTPUT:
% polx,poly      : n*2 matrix with polygons of curvy arrows.
% xax,yax        : n*2 matrix with axis coordinates of curvy arrows.
% len            : Vector with length of curvy arrows (in m).
% pos            : n*3 matrix with start coordinates for arrows in next
%                  time step, (first two columns) and age of arrow (third column).
%
% OPTIONAL INPUT ARGUMENTS:
% dx             : Average horizontal spacing (in metres) between start points of arrows.
% timestep       : Time step of animation (in seconds). Only for animations.
% length         : Length of the curvy arrows (in seconds).
% xlim           : Horizontal limits in x-direction, e.g. [3000 8000].
% ylim           : Horizontal limits in y-direction, e.g. [3000 8000].
% position       : n*3 matrix with start coordinates for arrows in next time step
%                  (first two columns) and age of arrow (third column).
%                  This option is only required for animations.
% nrvertices     : Number of vertices along axis of arrows (default 10).
% headthickness  : Relative width of arrow heads (default 0.15).
% arrowthickness : Relative width of arrows (default 0.05).
% nhead          : Number of vertices used for arrow head length (default 2, max nrvertices-1).
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
% Note: the maximum number of arrows is 15,000!
% 
% EXAMPLE 1 : Still
% 
% [x,y] = meshgrid(0:10:300,0:10:100);
% u = zeros(size(x))+1;
% v = 0.5*cos(x/30);
% [polx,poly]=curvec(x,y,u,v,'length',20,'dx',10,'headthickness',0.3,'arrowthickness',0.1);
% patch(polx,poly,'g');axis equal;
%
% EXAMPLE 2 : Animation
% 
% [x,y]= meshgrid(0:1:100,0:1:100);
% ang  = atan2(y-50,x-50);
% dist = sqrt((x-50).^2+(y-50).^2);
% amp  = cos(2*pi*dist/50);
% fig  = figure;
% set(fig,'Position',[20 20 600 600]);
% ptch=patch(0,0,'r');
% axis equal;
% set(gca,'xlim',[-10 110],'ylim',[-10 110]);
% aviobj = avifile('example.avi','fps',20,'Compression','Cinepak','Quality',100);
% pos=[];
% for t=1:200
%     disp(['Processing ' num2str(t) ' of 200 ...']);
%     u=amp.*sin(ang-pi)+0.004*t*cos(ang-pi);
%     v=amp.*cos(ang   )+0.004*t*sin(ang-pi);
%     [polx,poly,xax,yax,len,pos]=curvec(x,y,u,v,'length',10,'dx',5,'position',pos,'timestep',2);
%     set(ptch,'XData',polx,'YData',poly);
%     F = getframe(fig);
%     aviobj = addframe(aviobj,F);
% end
% close(fig)
% aviobj = close(aviobj);
%
%See also: KMLcurvedArrows, mxcurvec, quiver, arrow2, arrow
 
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

%% initiate, handle and process heyword

   OPT.length           = [];
   OPT.nrvertices       = 10;
   OPT.headthickness    = 0.15;
   OPT.arrowthickness   = 0.05;
   OPT.nhead            = 2;

   OPT.position         = [];
   OPT.geofac           = 111111;
   OPT.lifespan         =  50;
   OPT.relativespeed    = 1;
   OPT.timestep         = 0;
   OPT.polygon          = [];
   OPT.dx               = [];
   OPT.xlim             = [];
   OPT.ylim             = [];
   OPT.coordinatesystem = ''; % 'geographic','geo','spherical','latlon'
   OPT.cs               = ''; % 'geographic','geo','spherical','latlon'
     OPT.iopt           = 0;
   
   if nargin==0
      polx = OPT;return
   end
   
   OPT = setProperty(OPT,varargin{:});

   if ~isempty(OPT.xlim)
      xmin=OPT.xlim(1);
      xmax=OPT.xlim(2);
   else
      xmin=min(x(:));
      xmax=max(x(:));
   end
   
   if ~isempty(OPT.ylim)
      ymin=OPT.ylim(1);
      ymax=OPT.ylim(2);
   else
      ymin=min(y(:));
      ymax=max(y(:));
   end

   if any(strcmpi(OPT.coordinatesystem,{'geographic','geo','spherical','latlon'})) | ...
      any(strcmpi(OPT.cs              ,{'geographic','geo','spherical','latlon'}))
       OPT.iopt=1;
   end

   if isempty(OPT.length)
       error('Could not make arrows. Please specify the length of the vectors (in seconds) with the keyword LENGTH!');
   end
   
   if isempty(OPT.dx)
       % Estimate good arrow distance
       if OPT.iopt==1
           OPT.dx=OPT.geofac*(xmax-xmin)/20;
       else
           OPT.dx=(xmax-xmin)/20;
       end
   end
   
   if isempty(OPT.polygon)
       % Make polygon from xlim and ylim
       xp=[xmin xmax xmax xmin];
       yp=[ymin ymin ymax ymax];
   else
       xp=squeeze(OPT.polygon(:,1));
       yp=squeeze(OPT.polygon(:,2));
   end

%% Start points of curved vectors

   if ~isempty(OPT.position)
       x2   = OPT.position(:,1);
       y2   = OPT.position(:,2);
       iage = OPT.position(:,3);
       n2   = length(x2);
   else
       % Total number of arrows
       if OPT.iopt==1
           % Geographic
           polarea=polyarea(xp*OPT.geofac,invmerc(yp)*OPT.geofac);
       else
           polarea=polyarea(xp,yp);
       end
       n2=round(polarea/OPT.dx^2);
       n2=max(n2,5);
       if OPT.iopt==1
           % Geographic
           [x2,y2]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',n2);
           y2=merc(y2);
       else
           [x2,y2]=randomdistributeinpolygon(xp,yp,'nrpoints',n2);
       end
       iage=round(OPT.lifespan*rand(n2,1));
       if OPT.timestep==0
           iage=min(iage,47);
           iage=max(iage,3);
       end
   end
   
   if n2>15000
       disp(['Number of curved arrows (' num2str(n2) ') exceeds 15000!']);
       return
   end

%% Check for points past their lifespan

   idead=find(iage>=OPT.lifespan);
   for j=1:length(idead)
       ii=idead(j);
       if OPT.iopt==1
           % Geographic
           [xn,yn]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',1);
           yn=merc(yn);
       else
           [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
       end
       x2(ii)=xn;
       y2(ii)=yn;
       iage(ii)=0;
   end

%% Check for points outside polygon

   iout=find(inpolygon(x2,y2,xp,yp)==0);
   for j=1:length(iout)
       ii=iout(j);
       if OPT.iopt==1
           % Geographic
           [xn,yn]=randomdistributeinpolygon(xp,invmerc(yp),'nrpoints',1);
           yn=merc(yn);
       else
           [xn,yn]=randomdistributeinpolygon(xp,yp,'nrpoints',1);
       end
       x2(ii)=xn;
       y2(ii)=yn;
       iage(ii)=0;
   end
   
   x1=x;
   y1=y;
   
   y1(isnan(x1))=-999.0;
   u (isnan(x1))=-999.0;
   v (isnan(x1))=-999.0;
   x1(isnan(x1))=-999.0; % last itself

%% Make arrows narrower that were just seeded or which are about to die

   relwdt=zeros(n2,1)+1;
   if OPT.timestep>0
       for ii=1:n2
           if iage(ii)<4
               relwdt(ii)=iage(ii)/4;
           elseif iage(ii)>OPT.lifespan-4
               relwdt(ii)=(OPT.lifespan-iage(ii)+1)/4;
           else
               relwdt(ii)=1.0;
           end
       end
   end

%% Compute arrows using mex file

   [xp,yp,xax,yax,len]=mxcurvec(x2,y2,x1,y1,u,v,OPT.length,OPT.nrvertices,OPT.headthickness,OPT.arrowthickness,OPT.nhead,relwdt,OPT.iopt);

%% Set nan values

   xp (xp <1000.0 & xp >999.998)=NaN;
   yp (yp <1000.0 & yp >999.998)=NaN;
   xax(xax<1000.0 & xax>999.998)=NaN;
   yax(yax<1000.0 & yax>999.998)=NaN;

%% Count number of points per arrow

   ic=1;while ~isnan(xp(ic,1));ic=ic+1;end % NOT: ic =  (OPT.nrvertices - OPT.nhead)*2+5 due to nhead cut-off in mxcurvec

%% Put all arrows in 2D matrix

   polx=reshape(xp ,[ic               n2]);
   poly=reshape(yp ,[ic               n2]);
   xax =reshape(xax,[OPT.nrvertices+1 n2]);
   yax =reshape(yax,[OPT.nrvertices+1 n2]);

%% Get rid of very short arrows

   ishort=len<0.01;
   polx(:,ishort)=NaN;
   poly(isnan(polx))=NaN;

%% Get rid of NaN row

   polx=polx(1:end-1,:);
   poly=poly(1:end-1,:);
   xax=xax(1:end-1,:);
   yax=yax(1:end-1,:);

%% Determine position of arrows in next time step

   if isempty(OPT.timestep)
       OPT.timestep=0;
   end
   if OPT.timestep>OPT.length
      OPT.timestep=OPT.length;
   end
   nn=(OPT.nrvertices-1)*(OPT.relativespeed*OPT.timestep/OPT.length);
   nfrac=nn-floor(nn);
   nn1=floor(nn)+1;
   nn2=floor(nn)+2;
   nn2=min(nn2,OPT.nrvertices);
   OPT.position(:,1)=xax(nn1,:)+nfrac*(xax(nn2,:)-xax(nn1,:));
   OPT.position(:,2)=yax(nn1,:)+nfrac*(yax(nn2,:)-yax(nn1,:));
   OPT.position(:,3)=iage+1;

   varargout = {polx,poly,xax,yax,OPT.length,OPT.position};
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

