function DrawRectangle(tag,f1,f2,f3,varargin)

col='g';
marker='o';
markercol='y';
dx=[];
dy=[];
lw=1;
rot='off';

if nargin>3
    for i=1:length(varargin)
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'marker'}
                marker=varargin{i+1};
            case{'markercolor'}
                markercol=varargin{i+1};
            case{'linewidth'}
                lw=varargin{i+1};
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'rotation'}
                rot=varargin{i+1};
        end
    end
end

set(gcf,'windowbuttonmotionfcn',@MoveMouse);
set(gcf,'windowbuttondownfcn', {@StartTrack,tag,f1,f2,f3,col,lw,marker,markercol,dx,dy,rot});

%%
function StartTrack(imagefig,varargins,tag,fstart,fmove,fstop,col,lw,marker,markercol,dx,dy,rot) 

if ~isempty(fstart)
    feval(fstart);
end

set(gcf, 'windowbuttonmotionfcn', @MoveTrack);
set(gcf, 'windowbuttonupfcn',     @StopTrack);

pos = get(gca, 'CurrentPoint');

usd.tag=tag;

usd.x0=pos(1,1);
usd.y0=pos(1,2);

xori=usd.x0;
yori=usd.x0;

xori=pos(1,1);
yori=pos(1,2);
lenx=0;
leny=0;
rotation=0;

PlotRectangle(tag,xori,yori,lenx,leny,rotation,dx,dy,fmove,fstop,col,lw,marker,markercol,rot);

set(0,'UserData',usd);

%%
function MoveTrack(imagefig, varargins)

usd=get(0,'userdata');
pos=get(gca,'CurrentPoint');

posx=pos(1,1);
posy=pos(1,2);

tag=usd.tag;
x0=usd.x0;
y0=usd.y0;

h=findobj(gcf,'Tag',tag);
usd=get(h,'UserData');

usd.lenx=abs(posx-x0);
usd.leny=abs(posy-y0);

usd.xori=min(posx,x0);
usd.yori=min(posy,y0);

set(h,'UserData',usd);

feval(usd.fmove,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation);

PlotRectangle(usd.tag,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation,usd.dx,usd.dy,usd.fmove,usd.fstop,usd.col,usd.lw,usd.marker,usd.markercol,usd.rot);

ddb_updateCoordinateText('crosshair');

%%
function StopTrack(imagefig, varargins)

usd=get(0,'userdata');
tag=usd.tag;
set(0,'userdata',[]);

plt=findobj(gcf,'Tag',tag);

usd=get(plt,'UserData');

if isempty(usd.dx)
    nx=round(usd.lenx/usd.dx);
    ny=round(usd.leny/usd.dy);
    usd.lenx=nx*usd.dx;
    usd.leny=ny*usd.dy;
end
PlotRectangle(usd.tag,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation,usd.dx,usd.dy,usd.fmove,usd.fstop,usd.col,usd.lw,usd.marker,usd.markercol,usd.rot);

if ~isempty(usd.fstop)
    feval(usd.fstop,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation);
end

ch=usd.ch;
set(ch,'ButtonDownFcn',@ChangeRectangle);

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

%%
function ChangeRectangle(imagefig, varargins)

h=get(gco,'UserData');
nr=h.nr;
p=h.parent;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

tag=get(p,'Tag');
u=get(p,'UserData');
usd.tag=tag;
usd.x0=pos(1,1);
usd.y0=pos(1,2);
usd.nr=nr;
usd.rot0=180*atan2(posy-u.y(1),posx-u.x(1))/pi;
usd.rot00=u.rotation;

set(0,'UserData',usd);

usd=u;

switch get(gcf,'SelectionType')
    case{'normal'}
        % Move corner point
        set(gcf, 'windowbuttonmotionfcn', {@MoveCornerPoint});
    case{'alt'}
        if nr==1
            % Move rectangle
            set(gcf, 'windowbuttonmotionfcn', {@MoveRectangle});
        else
            if usd.rot
                % Rotate rectangle
                set(gcf, 'windowbuttonmotionfcn', {@RotateRectangle});
            end
        end
end
set(gcf, 'windowbuttonupfcn', {@StopTrack});

%%
function MoveCornerPoint(imagefig, varargins)

usd=get(0,'userdata');

tag=usd.tag;
nr=usd.nr;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

p=findobj(gcf,'Tag',tag);
usd=get(p,'UserData');

switch nr,
    case 1
        x0=[posx posy];
        x1=[usd.x(3) usd.y(3)];
        x2=[usd.x(2) usd.y(2)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        usd.lenx=det([x2-x1 ; x1-x0])/pt;
        x1=[usd.x(4) usd.y(4)];
        x2=[usd.x(3) usd.y(3)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        usd.leny=det([x2-x1 ; x1-x0])/pt;        
        usd.xori=posx;
        usd.yori=posy;

    case 2
        dx=posx-usd.xori;
        dy=posy-usd.yori;
        usd.lenx=sqrt(dx^2 + dy^2);

    case 3
        x0=[posx posy];
        x1=[usd.x(1) usd.y(1)];
        x2=[usd.x(4) usd.y(4)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        usd.lenx=det([x2-x1 ; x1-x0])/pt;
        x1=[usd.x(2) usd.y(2)];
        x2=[usd.x(1) usd.y(1)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        usd.leny=det([x2-x1 ; x1-x0])/pt;

    case 4
        dx=posx-usd.xori;
        dy=posy-usd.yori;
        usd.leny=sqrt(dx^2 + dy^2);

end
usd.lenx=max(usd.lenx,usd.dx);
usd.leny=max(usd.leny,usd.dy);

set(p,'UserData',usd);

feval(usd.fmove,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation);

PlotRectangle(usd.tag,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation,usd.dx,usd.dy,usd.fmove,usd.fstop,usd.col,usd.lw,usd.marker,usd.markercol,usd.rot);

ddb_updateCoordinateText('arrow');

%%
function RotateRectangle(imagefig, varargins)

usd=get(0,'userdata');
rot0=usd.rot0;
rot00=usd.rot00;
tag=usd.tag;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

p=findobj(gcf,'Tag',tag);

usd=get(p,'UserData');

rot=180*atan2(posy-usd.y(1),posx-usd.x(1))/pi;
drot=rot-rot0;

usd.rotation=rot00+drot;
set(p,'UserData',usd);

feval(usd.fmove,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation);

PlotRectangle(usd.tag,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation,usd.dx,usd.dy,usd.fmove,usd.fstop,usd.col,usd.lw,usd.marker,usd.markercol,usd.rot);

ddb_updateCoordinateText('arrow');

%%
function MoveRectangle(imagefig, varargins)

usd=get(0,'userdata');
tag=usd.tag;

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

p=findobj(gcf,'Tag',tag);

usd=get(p,'UserData');
usd.xori=posx;
usd.yori=posy;

set(p,'UserData',usd);

feval(usd.fmove,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation);

PlotRectangle(usd.tag,usd.xori,usd.yori,usd.lenx,usd.leny,usd.rotation,usd.dx,usd.dy,usd.fmove,usd.fstop,usd.col,usd.lw,usd.marker,usd.markercol,usd.rot);

ddb_updateCoordinateText('arrow');

%%
function MoveMouse(imagefig, varargins)
ddb_updateCoordinateText('crosshair');

