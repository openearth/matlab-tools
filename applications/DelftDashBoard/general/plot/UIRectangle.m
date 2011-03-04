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
movable=1;

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
            case{'movable'}
                movable=varargin{i+1};
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
        h=plot(x,y);
        set(h,'Visible','off');

        set(h,'Tag',tag);
        set(h,'Color',lineColor);
        set(h,'LineWidth',lineWidth);
                
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
        setappdata(h,'movable',movable);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);

        set(gcf, 'windowbuttondownfcn',   {@startRectangle,h});
        set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,h});
        
    case{'plot'}
        h=plot(0,0);
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
    
    h=plot(x,y,'g');
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
        set(mh(i),'ButtonDownFcn',{@moveCornerPoint});
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
    movable=getappdata(h,'movable');
    
    x=[x0 x0 x0 x0 x0];
    y=[y0 y0 y0 y0 y0];
    
    set(h,'XData',x,'YData',y);
    set(h,'Visible','on');
    
    for i=1:4
        if i==1
            % Origin
            mh(i)=plot(x(i),y(i),['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor','y','MarkerSize',markerSize+2);
        else
            mh(i)=plot(x(i),y(i),['y' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        end
        if movable
            set(mh(i),'ButtonDownFcn',{@changeRectangle,h,i});
        else
            set(mh(i),'HitTest','off');
        end
        set(mh(i),'Tag',tag);
        setappdata(mh(i),'parent',h);
        setappdata(mh(i),'number',i);
    end
    setappdata(h,'children',mh);
    
    set(gcf, 'windowbuttonupfcn',     {@finishRectangle,h});
    set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,h});

end

%%
function dragRectangle(imagefig, varargins, h)

ax=getappdata(h,'axes');

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=getappdata(h,'x0');
    y0=getappdata(h,'y0');
    
    if ~isempty(x0)

        dx=posx-x0;
        dy=posy-y0;
        setappdata(h,'dx',dx);
        setappdata(h,'dy',dy);
        rotation=0;
        ch=getappdata(h,'children');
        
        [x,y]=computeCoordinates(x0,y0,dx,dy,rotation);
        
        setappdata(h,'x',x);
        setappdata(h,'y',y);
        
        set(h,'XData',x,'YData',y);
        
        for i=1:4
            set(ch(i),'XData',x(i),'YData',y(i));
        end
        
    end
    
end

ddb_updateCoordinateText('crosshair');

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

setappdata(h,'x',x);
setappdata(h,'y',y);
setappdata(h,'rotation',rotation);

set(h,'XData',x,'YData',y);
for i=1:4
    set(ch(i),'XData',x(i),'YData',y(i));
end

callback=getappdata(h,'callback');
if ~isempty(callback)
    feval(callback,x,y,h);
end





%%
function changeRectangle(imagefig, varargins,h,i)

switch get(gcf,'SelectionType')
    case{'normal'}
        % Move corner point
        set(gcf, 'windowbuttonmotionfcn', {@moveCornerPoint,h,i,'move'});
        set(gcf, 'windowbuttonupfcn',     {@moveCornerPoint,h,i,'finish'});
    case{'alt'}
        if i==1
            % Move rectangle
            set(gcf, 'windowbuttonmotionfcn', {@moveRectangle,h,i,'move'});
            set(gcf, 'windowbuttonupfcn', {@moveRectangle,h,i,'finish'});
        else
            rotate=getappdata(h,'rotate');
            if rotate
                % Rotate rectangle
                set(gcf, 'windowbuttonmotionfcn', {@rotateRectangle,h,i,'move'});
                set(gcf, 'windowbuttonupfcn', {@rotateRectangle,h,i,'finish'});
            end
        end
end

%%
function moveCornerPoint(imagefig, varargins,h,i,opt)

ax=getappdata(h,'axes');

pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

x0=getappdata(h,'x0');
y0=getappdata(h,'y0');
dx=getappdata(h,'dx');
dy=getappdata(h,'dy');
rotation=getappdata(h,'rotation');
x=getappdata(h,'x');
y=getappdata(h,'y');

[x0,y0,dx,dy,rotation]=computeDxDy(x0,y0,dx,dy,rotation,posx,posy,x,y,i,'move');

[x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

setappdata(h,'x0',x0);
setappdata(h,'y0',y0);
setappdata(h,'dx',dx);
setappdata(h,'dy',dy);
setappdata(h,'x',x);
setappdata(h,'y',y);

set(h,'XData',x,'YData',y);

ch=getappdata(h,'children');
for i=1:4
    set(ch(i),'XData',x(i),'YData',y(i));
end

ddb_updateCoordinateText('arrow');

switch opt
    case{'finish'}
        buttonUpDownFcn=getappdata(h,'windowbuttonupdownfcn');
        buttonMotionFcn=getappdata(h,'windowbuttonmotionfcn');
        feval(buttonUpDownFcn);
        feval(buttonMotionFcn);
        callback=getappdata(h,'callback');
        if ~isempty(callback)
            feval(callback,x,y,h);
        end
end

%%
function moveRectangle(imagefig, varargins,h,i)

%%
function rotateRectangle(imagefig, varargins,h,i)

%%
function finishChangingRectangle(imagefig, varargins,h)





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




%%
function [x0,y0,dx,dy,rotation]=computeDxDy(x0,y0,dx,dy,rotation,posx,posy,x,y,i,opt)

switch opt
    case{'move'}
        switch i
            case 1
                
                x00=[posx posy];
                
                x1=[x(3) y(3)];
                x2=[x(2) y(2)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dx=det([x2-x1 ; x1-x00])/pt;
                
                x1=[x(4) y(4)];
                x2=[x(3) y(3)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dy=det([x2-x1 ; x1-x00])/pt;
                
                x0=posx;
                y0=posy;
                
            case 2
                dx=sqrt((posx-x0)^2 + (posy-y0)^2);
                
            case 3
                
                x00=[posx posy];
                
                x1=[x(1) y(1)];
                x2=[x(4) y(4)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dx=det([x2-x1 ; x1-x00])/pt;
                
                x1=[x(2) y(2)];
                x2=[x(1) y(1)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dy=det([x2-x1 ; x1-x00])/pt;
                
            case 4
                dy=sqrt((posx-x0)^2 + (posx-x0)^2);
                
        end
    case{'rotate'}
end

