function xx_logo(logoname,ax,varargin),
%XX_LOGO Plot a logo in an existing coordinate system
%        XX_LOGO('LogoID',Axes)
%        Converts the Axes into a logo. Supported LogoIDs
%        are:
%          'wl' or 'dh' for WL | Delft Hydraulics
%          'ut'         for University of Twente.
%
%        XX_LOGO('LogoID',Axes,Pos)
%        where Pos is a 1x4 matrix: the position in the
%        Axes where the logo should be plotted.
%        where Pos is a 1x5 matrix: the position and
%        rotation of the logo in the Axes object. The
%        rotation should be specified in radians.
%
%        ...,options)
%        some optional arguments are supported depending
%        on the LogoID:
%        wl/dh : LineWidth,EdgeColog,FaceColor
%        ut    : LogoColor

switch lower(logoname)
case {'wl','dh'}
  if nargin>2 & ~isequal(size(varargin{1}),[1 1])
    Local_DH(ax,varargin{:}),
  else
    Local_DH(ax,[],varargin{:}),
  end
case 'ut',
  if nargin>2 & ~isequal(size(varargin{1}),[1 1])
    Local_UT(ax,varargin{:}),
  else
    Local_UT(ax,[],varargin{:}),
  end
end;


function Local_DH(ax,pos,lw,edge,face),
% LOGO_DH draws the WL|delft hydraulics logo.

% Copyright (c) WL|delft hydraulics, Delft, The Netherlands
% Made by H.R.A. Jagers

if nargin<5,
  face=[];
  if nargin<4,
    edge=[1 1 1];
    if nargin<3,
      lw=1;
    end;
  end;
end;

if isempty(pos),
  pos=[0 0 1 1];
  set(ax,'xlim',[0 1], ...
         'ylim',[0 1], ...
         'visible','off', ...
         'dataaspectratio',[1 1 1]);
elseif pos(3)<pos(4)
  pos(2)=pos(2)+(pos(4)-pos(3))/2;
  pos(4)=pos(3);
elseif pos(4)<pos(3)
  pos(1)=pos(1)+(pos(3)-pos(4))/2;
  pos(3)=pos(4);
end
if length(pos)==4
  ang=0;
else
  ang=pos(5);
end
         
N=20;
phi=55*pi/180;
rad=(sin(phi)-7*cos(phi)/6)/(10*(1-cos(phi)));

t=0:N;
phi=phi*t/N;
rx=sin(phi)*rad;
ry=(1-cos(phi))*rad;

pos(1)=pos(1)+pos(3)/2;
pos(2)=pos(2)+pos(4)/2;
% add a small offset to center the logo
%pos(2)=pos(2)+pos(4)/15;
vshf=1/15;

if ~isempty(face)
  x=[1+1/3 1+1/3 10 10]/10;
  y=[0 8+2/3 8+2/3 0]/10+vshf;
  [xr,yr]=adjustxy(x-0.5,y-0.5,pos,ang);
  patch(xr,yr,1,'facecolor',face,'edgecolor',edge,'linewidth',lw);
  x=[rx fliplr((2/10)-rx)]; x=[x (2/10)+fliplr(x)];
  y=[(17/30)-ry (1/3)+fliplr(ry)]; y=[y fliplr(y)]+vshf;
  [xr,yr]=adjustxy(0.5-x,y-0.5,pos,ang);
  patch(xr,yr,1,'facecolor',face,'edgecolor',edge,'linewidth',lw);
  [xr,yr]=adjustxy(x-0.1,y-0.5,pos,ang);
  patch(xr,yr,1,'facecolor',face,'edgecolor',edge,'linewidth',lw);
  [xr,yr]=adjustxy(0.1-x,y-0.5,pos,ang);
  patch(xr,yr,1,'facecolor',face,'edgecolor',edge,'linewidth',lw);
  [xr,yr]=adjustxy(x-0.5,y-0.5,pos,ang);
  patch(xr,yr,1,'facecolor',face,'edgecolor',edge,'linewidth',lw);
end

% draw the right three (incomplete) wave parts
x=[1/10 fliplr((2/10)-rx) (2/5)-rx (2/10)+fliplr(rx) rx(1)];
y=[9/20 (1/3)+fliplr(ry) (1/3)+ry (17/30)-fliplr(ry) (17/30)-ry(1)];
[xr,yr]=adjustxy(x-0.3,-1/20-(y-9/20)+vshf,pos,ang);
line(xr,yr,'color',edge,'linewidth',lw,'parent',ax,'clipping','off');
[xr,yr]=adjustxy(x-0.1,y-0.5+vshf,pos,ang);
line(xr,yr,'color',edge,'linewidth',lw,'parent',ax,'clipping','off');
[xr,yr]=adjustxy(x+0.1,-1/20-(y-9/20)+vshf,pos,ang);
line(xr,yr,'color',edge,'linewidth',lw,'parent',ax,'clipping','off');

% draw the (complete) left wave part
x=[rx fliplr((2/10)-rx)]; x=[x (2/10)+fliplr(x) x(1)];
y=[(17/30)-ry (1/3)+fliplr(ry)]; y=[y fliplr(y) y(1)]+vshf;
[xr,yr]=adjustxy(x-0.5,y-0.5,pos,ang);
line(xr,yr,'color',edge,'linewidth',lw,'parent',ax,'clipping','off');

% compute the lower intersection point of the border with
% the left wave part
i0=max(find(x(1:(2*N))<(2/15)));
d=((2/15)-x(i0))/(x(i0+1)-x(i0));
y0=y(i0)+d*(y(i0+1)-y(i0));

% draw the border
x=[2/15 2/15 1 1 2/15 2/15];
y=[17/30 13/15 13/15 0 0 y0-vshf]+vshf;
[xr,yr]=adjustxy(x-0.5,y-0.5,pos,ang);
line(xr,yr,'color',edge,'linewidth',lw,'parent',ax,'clipping','off');


function Local_UT(ax,pos,blue),
% LOGO_UT draws the University of Twente logo.

if nargin<3,
  blue=[1 1 1];
end;

if isempty(pos)
  pos=[-1 -1 2 2];
  set(ax,'xlim',[-1 1], ...
        'ylim',[-1 1], ...
        'visible','off', ...
        'dataaspectratio',[1 1 1]);
elseif pos(3)<pos(4)
  pos(2)=pos(2)+(pos(4)-pos(3))/2;
  pos(4)=pos(3);
elseif pos(4)<pos(3)
  pos(1)=pos(1)+(pos(3)-pos(4))/2;
  pos(3)=pos(4);
end
pos(1:2)=pos(1:2)+pos(3:4)/2;
pos(3:4)=pos(3:4)/2;
if length(pos)==4
  ang=0;
else
  ang=pos(5);
end

N=40;

r1=1;
r2=0.6;
r3=0.5;
dx=0.2;
ddx=0.05;

t=0:N;

phi    = acos(dx/r1);
phi_r1 = phi+((1.5*pi-2*phi)/N)*t;
x_r1   = r1*cos(phi_r1);
y_r1   = r1*sin(phi_r1);

phi    = acos(dx/r2);
phi_r2 = phi+((1.5*pi-2*phi)/N)*t;
x_r2   = r2*cos(phi_r2);
y_r2   = r2*sin(phi_r2);

phi    = acos(dx/r3);
phi_r3 = phi+((1.5*pi-2*phi)/N)*t;
x_r3   = r3*cos(phi_r3);
y_r3   = r3*sin(phi_r3);

[xr,yr]=adjustxy([x_r1 fliplr(x_r2)],[y_r1 fliplr(y_r2)],pos,ang);
patch(xr,yr,blue,'edgecolor','none','parent',ax,'clipping','off');
[xr,yr]=adjustxy(-[x_r1 fliplr(x_r2)],-[y_r1 fliplr(y_r2)],pos,ang);
patch(xr,yr,blue,'edgecolor','none','parent',ax,'clipping','off');
[xr,yr]=adjustxy([x_r3 -dx -x_r3 dx],[y_r3 -dx -y_r3 dx],pos,ang);
patch(xr,yr,blue,'edgecolor','none','parent',ax,'clipping','off');
[xr,yr]=adjustxy([1 1 dx+ddx],[dx+ddx 1 1],pos,ang);
patch(xr,yr,blue,'edgecolor','none','parent',ax,'clipping','off');
[xr,yr]=adjustxy(-[1 1 dx+ddx],-[dx+ddx 1 1],pos,ang);
patch(xr,yr,blue,'edgecolor','none','parent',ax,'clipping','off');
      
      
function [xr,yr]=adjustxy(x,y,pos,ang)
xr=pos(1)+pos(3)*x*cos(ang)-pos(4)*y*sin(ang);
yr=pos(2)+pos(4)*y*cos(ang)+pos(3)*x*sin(ang);
