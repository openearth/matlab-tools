function [x,y]=DrawPolyline(LineColor,LineWidth,Marker,MarkerEdgeColor,varargin)

usd.max=10000;

if nargin>4
    for i=1:nargin-4
        switch(lower(varargin{i})),
            case{'max'}
                usd.max=varargin{i+1};
        end
    end
end

x=[];
y=[];

set(gcf, 'windowbuttondownfcn',   {@NextPoint});
set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
usd.x=[];
usd.y=[];
usd.DottedLine=[];

usd.LineColor=LineColor;
usd.LineWidth=LineWidth;
usd.Marker=Marker;
usd.MarkerEdgeColor=MarkerEdgeColor;

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findall(gcf,'Tag','Polyline');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
end

%%
function NextPoint(imagefig, varargins) 

usd=get(0,'UserData');

mouseclick=get(gcf,'SelectionType');

if strcmp(mouseclick,'normal')
    pos=get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    np=length(usd.x);
    np=np+1;
    usd.x(np)=posx;
    usd.y(np)=posy;
    usd.z(np)=9000;
    if np==1
        usd.DottedLine=plot3(usd.x,usd.y,usd.z,usd.LineColor);
        set(usd.DottedLine,'LineWidth',usd.LineWidth);
        if ~isempty(usd.Marker)
            set(usd.DottedLine,'Marker',usd.Marker,'MarkerEdgeColor',usd.MarkerEdgeColor);
        end
        set(usd.DottedLine,'MarkerEdgeColor','r','MarkerSize',4);
        set(usd.DottedLine,'Tag','Polyline');
    else
        set(usd.DottedLine,'XData',usd.x,'YData',usd.y,'ZData',usd.z);
    end
    set(0,'UserData',usd);
    if np==usd.max
        set(usd.DottedLine,'UserData',usd);
        ddb_setWindowButtonUpDownFcn;
        ddb_setWindowButtonMotionFcn;
        set(0,'UserData',[]);
    end
else
    set(usd.DottedLine,'UserData',usd);
    ddb_setWindowButtonUpDownFcn;
    ddb_setWindowButtonMotionFcn;
    set(0,'UserData',[]);
end

%%
function MoveMouse(imagefig, varargins)

usd=get(0,'UserData');
np=length(usd.x);
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
if np>0
    x=usd.x;
    y=usd.y;
    x(np+1)=posx;
    y(np+1)=posy;
    z=zeros(1,np+1)+9000;
    set(usd.DottedLine,'XData',x,'YData',y,'ZData',z);
    set(0,'UserData',usd);
end

ddb_setWindowButtonUpDownFcn(@NextPoint,[]);
ddb_updateCoordinateText('crosshair');
