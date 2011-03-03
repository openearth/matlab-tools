function [x,y,h]=UIRectangle(h,opt,varargin)

if strcmpi(get(h,'Type'),'axes')
    ax=h;
end

% Default values
lineColor='g';
lineWidth=1.5;
marker='';
markerEdgeColor='r';
markerFaceColor='r';
markerSize=4;
maxPoints=10000;
txt=[];
callback=[];
closed=0;
userdata=[];

rotation=0;
rotate=0;

tag='';

% Not generic yet! DDB specific.
windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;
windowbuttonmotionfcn=@ddb_setWindowButtonMotionFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'linecolor','color'}
                lineColor=varargin{i+1};
            case{'linewidth','width'}
                lineWidth=varargin{i+1};
            case{'marker'}
                marker=varargin{i+1};
            case{'markeredgecolor'}
                markerEdgeColor=varargin{i+1};
            case{'markerfacecolor'}
                markerFaceColor=varargin{i+1};
            case{'markerfacesize'}
                markerSize=varargin{i+1};
            case{'text'}
                txt=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
            case{'callback'}
                callback=varargin{i+1};
            case{'userdata'}
                userdata=varargin{i+1};
            case{'x0'}
                x0=varargin{i+1};
            case{'y0'}
                y0=varargin{i+1};
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'rotation'}
                rotation=varargin{i+1};
            case{'rotate'}
                rotate=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                windowbuttonmotionfcn=varargin{i+1};
        end
    end
end

switch lower(opt)
    case{'draw'}
       
        % Plot first (invisible) point
        
        x=0;
        y=0;       
        h=plot3(x,y,9000);
        set(h,'Visible','off');

        set(h,'Tag',tag);
        set(h,'Color',lineColor);
        set(h,'LineWidth',lineWidth);
        
        if ~isempty(marker)
            set(h,'Marker',marker);
            set(h,'MarkerEdgeColor',markerEdgeColor);
            set(h,'MarkerFaceColor',markerFaceColor);
            set(h,'MarkerSize',markerSize);
        end
        
        setappdata(h,'x0',[]);
        setappdata(h,'y0',[]);
        setappdata(h,'dx',[]);
        setappdata(h,'dy',[]);
        setappdata(h,'rotation',[]);
        setappdata(h,'axes',ax);
        setappdata(h,'closed',closed);
        setappdata(h,'callback',callback);
        setappdata(h,'tag',tag);        
        setappdata(h,'color',lineColor);
        setappdata(h,'width',lineWidth);
        setappdata(h,'marker',marker);
        setappdata(h,'markeredgecolor',markerEdgeColor);
        setappdata(h,'markerfacecolor',markerFaceColor);
        setappdata(h,'markersize',markerSize);
        setappdata(h,'text',txt);
        setappdata(h,'rotate',rotate);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);

        set(gcf, 'windowbuttondownfcn',   {@startRectangle,h});
        
    case{'plot'}
        h=plot3(0,0,9000);
        setappdata(h,'callback',callback);
        set(h,'userdata',userdata);
        setappdata(h,'tag',tag);        
        setappdata(h,'x0',x0);
        setappdata(h,'y0',y0);
        setappdata(h,'dx',dx);
        setappdata(h,'dy',dy);
        setappdata(h,'rotation',rotation);
        setappdata(h,'color',lineColor);
        setappdata(h,'width',lineWidth);
        setappdata(h,'marker',marker);
        setappdata(h,'markeredgecolor',markerEdgeColor);
        setappdata(h,'markerfacecolor',markerFaceColor);
        setappdata(h,'markersize',markerSize);
        setappdata(h,'maxpoints',maxPoints);
        setappdata(h,'text',txt);
        setappdata(h,'closed',closed);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);        
        drawRectangle(h,'nocallback');

    case{'delete'}
        ch=getappdata(h,'children');
        delete(h);
        delete(ch);

end

%%
function drawRectangle(h,varargin)

opt='withcallback';
if ~isempty(varargin)
    opt=varargin{1};
end

x0=getappdata(h,'x0');
y0=getappdata(h,'y0');
dx=getappdata(h,'dx');
dy=getappdata(h,'dy');
rotation=getappdata(h,'rotation');

tag=getappdata(h,'tag');
lineColor=getappdata(h,'color');
lineWidth=getappdata(h,'width');
marker=getappdata(h,'marker');
markerEdgeColor=getappdata(h,'markeredgecolor');
markerFaceColor=getappdata(h,'markerfacecolor');
markerSize=getappdata(h,'markersize');
txt=getappdata(h,'text');
callback=getappdata(h,'callback');
ax=getappdata(h,'axes');
userdata=get(h,'userdata');
windowbuttonupdownfcn=getappdata(h,'windowbuttonupdownfcn');
windowbuttonmotionfcn=getappdata(h,'windowbuttonmotionfcn');

ch=getappdata(h,'children');
delete(h);
delete(ch);

if ~isempty(x0)
    
    % Compute coordinates of corner points
    
    [x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

    z=zeros(size(x))+100;
    
    h=plot3(x,y,z,'g');
    set(h,'Tag',tag);
    set(h,'Color',lineColor);
    set(h,'LineWidth',lineWidth);
    set(h,'HitTest','off');
    
    setappdata(h,'color',lineColor);
    setappdata(h,'width',lineWidth);
    setappdata(h,'marker',marker);
    setappdata(h,'markeredgecolor',markerEdgeColor);
    setappdata(h,'markerfacecolor',markerFaceColor);
    setappdata(h,'markersize',markerSize);
    setappdata(h,'rotate',rotate);
    setappdata(h,'text',txt);
    set(h,'userdata',userdata);
    setappdata(h,'callback',callback);
    setappdata(h,'x0',x0);
    setappdata(h,'y0',y0);
    setappdata(h,'dx',dx);
    setappdata(h,'dy',dy);
    setappdata(h,'rotation',rotation);
    setappdata(h,'tag',tag);
    setappdata(h,'axes',ax);
    setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
    setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);
    
    for i=1:length(x)-1
        if i==1
            % Origin
            mh(i)=plot3(x(i),y(i),200,['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        else
            mh(i)=plot3(x(i),y(i),200,['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        end
        set(mh(i),'ButtonDownFcn',{@moveVertex});
        set(mh(i),'Tag',tag);
        setappdata(mh(i),'parent',h);
        setappdata(mh(i),'number',i);
    end
    setappdata(h,'children',mh);
    
    if ~isempty(callback) && strcmpi(opt,'withcallback')
        feval(callback,x,y,h);
    end
end

%%
function startRectangle(imagefig, varargins,h)

ax=getappdata(h,'axes');

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=posx;
    y0=posy;
    
    setappdata(h,'x0',posx);
    setappdata(h,'y0',posy);
    
    marker=getappdata(h,'marker');
    markerEdgeColor=getappdata(h,'markeredgecolor');
    markerFaceColor=getappdata(h,'markerfacecolor');
    markerSize=getappdata(h,'markersize');
    tag=get(h,'Tag');
    
    x=[x0 x0 x0 x0 x0];
    y=[y0 y0 y0 y0 y0];
    z=zeros(size(x))+100;
    
    set(h,'XData',x,'YData',y,'ZData',z);
    set(h,'Visible','on');
    
    for i=1:4
        if i==1
            % Origin
            mh(i)=plot3(x(i),y(i),200,['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        else
            mh(i)=plot3(x(i),y(i),200,['y' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        end
        set(mh(i),'ButtonDownFcn',{@moveVertex});
        set(mh(i),'Tag',tag);
        setappdata(mh(i),'parent',h);
        setappdata(mh(i),'number',i);
    end
    setappdata(h,'children',mh);
    
    set(gcf, 'windowbuttonupfcn',     {@finishRectangle,h});
    set(gcf, 'windowbuttonmotionfcn', {@moveMouse,h});

end

%%
function moveMouse(imagefig, varargins, h)

ax=getappdata(h,'axes');

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=getappdata(h,'x0');
    y0=getappdata(h,'y0');
    dx=posx-x0;
    dy=posy-y0;
    setappdata(h,'dx',dx);
    setappdata(h,'dy',dy);
    rotation=0;
    ch=getappdata(h,'children');

    [x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

    set(h,'XData',x,'YData',y);
    
    for i=1:4
        set(ch(i),'XData',x(i),'YData',y(i));
    end

end

ddb_updateCoordinateText('crosshair');

%%
function moveVertex(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@followTrack});
set(gcf, 'windowbuttonupfcn',     {@stopTrack});

%%
function followTrack(imagefig, varargins)
h=get(gcf,'CurrentObject');
p=getappdata(h,'parent');
x=getappdata(p,'x');
y=getappdata(p,'y');
ch=getappdata(p,'children');
nr=getappdata(h,'number');
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
x(nr)=xi;
y(nr)=yi;
closed=getappdata(p,'closed');
if closed
    if nr==1
        x(end)=x(1);
        y(end)=y(1);
    elseif nr==length(x)
        x(1)=x(end);
        y(1)=y(end);
    end
end
setappdata(p,'x',x);
setappdata(p,'y',y);
set(p,'XData',x,'YData',y);
if closed
    if nr==1
        set(ch(1),'XData',x(nr),'YData',y(nr));
        set(ch(end),'XData',x(nr),'YData',y(nr));
    elseif nr==length(x)
        set(ch(1),'XData',x(nr),'YData',y(nr));
        set(ch(end),'XData',x(nr),'YData',y(nr));
    else
        set(ch(nr),'XData',x(nr),'YData',y(nr));
    end
else
    set(ch(nr),'XData',x(nr),'YData',y(nr));
end
ddb_updateCoordinateText('arrow');

%%
function finishRectangle(imagefig, varargins,h)

buttonUpDownFcn=getappdata(h,'windowbuttonupdownfcn');
buttonMotionFcn=getappdata(h,'windowbuttonmotionfcn');
feval(buttonUpDownFcn);
feval(buttonMotionFcn);
x0=getappdata(h,'x0');
y0=getappdata(h,'y0');
ch=getappdata(h,'children');
pos = get(gca, 'CurrentPoint');

x=pos(1,1);
y=pos(1,2);

dx=x-x0;
dy=y-y0;

setappdata(h,'dx',dx);
setappdata(h,'dy',dy);
rotation=0;

[x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

set(h,'XData',x,'YData',y);
for i=1:4
    set(ch(i),'XData',x(i),'YData',y(i));
end

callback=getappdata(h,'callback');
if ~isempty(callback)
    feval(callback,x,y,h);
end

%%
function [x,y]=computeCoordinates(x0,y0,dx,dy,rotation)
x(1)=x0;
y(1)=y0;
x(2)=x(1)+dx*cos(pi*rotation/180);
y(2)=y(1)+dx*sin(pi*rotation/180);
x(3)=x(2)+dy*cos(pi*(rotation+90)/180);
y(3)=y(2)+dy*sin(pi*(rotation+90)/180);
x(4)=x(3)+dx*cos(pi*(rotation+180)/180);
y(4)=y(3)+dx*sin(pi*(rotation+180)/180);
x(5)=x0;
y(5)=y0;
