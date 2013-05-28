function muppet_zoomInOutPan(src,eventdata,zoommode)

handles=getHandles;

ifig=get(gcf,'UserData');

zoom off;
pan off;
rotate3d off;

muppet_setPlotEdit(0);

set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf,'pointer','arrow');

h(1)=findall(gcf,'ToolTipString','Zoom In');
h(2)=findall(gcf,'ToolTipString','Zoom Out');
h(3)=findall(gcf,'ToolTipString','Pan');
h(4)=findall(gcf,'ToolTipString','Rotate 3D');

set(h(1),'State','off');
set(h(2),'State','off');
set(h(3),'State','off');
set(h(4),'State','off');

switch zoommode
    case 1
        if strcmp(handles.figures(ifig).figure.zoom,'zoomin')
            handles.figures(ifig).figure.zoom='none';
        else
            set(h(1),'State','on');
            handles.figures(ifig).figure.zoom='zoomin';
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
        end
    case 2
        if strcmp(handles.figures(ifig).figure.zoom,'zoomout')
            handles.figures(ifig).figure.zoom='none';
        else
            set(h(2),'State','on');
            handles.figures(ifig).figure.zoom='zoomout';
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
        end
    case 3
        if strcmp(handles.figures(ifig).figure.zoom,'pan')
            handles.figures(ifig).figure.zoom='none';
        else
            set(h(3),'State','on');
            handles.figures(ifig).figure.zoom='pan';
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
        end
    case 4
        if strcmp(handles.figures(ifig).figure.zoom,'rotate3d')
            handles.figures(ifig).figure.zoom='none';
        else
            set(h(4),'State','on');
            handles.figures(ifig).figure.zoom='rotate3d';
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
        end
end        
 
setHandles(handles);

%%
function zoomInOut(imagefig, varargins,h,zoomin) 

handles=getHandles;
ifig=get(gcf,'UserData');

usd=get(h,'UserData');
j=usd(2);

if strcmp(get(gca,'Tag'),'axis') && ~isempty(usd)
    if handles.figures(ifig).figure.subplots(j).subplot.axesequal
        axesequal=1;
    else
        axesequal=0;
    end
else
    return
end

pos=get(h,'Position');
asprat=pos(4)/pos(3);

leftmouse=strcmp(get(gcf,'SelectionType'),'normal');
rightmouse=strcmp(get(gcf,'SelectionType'),'alt');

if ~strcmp(handles.figures(ifig).figure.subplots(j).subplot.type,'3d')
    if (leftmouse && zoomin==1) || (rightmouse && zoomin==0)
        point1 = get(h,'CurrentPoint');
        rect = rbbox;
        point2 = get(h,'CurrentPoint');
        if rect(3)==0
            xl=get(h,'xlim');
            yl=get(h,'ylim');
            point1=point1(1,1:2);
            p1(1)=point1(1)-((xl(2)-xl(1))/4);
            p1(2)=point1(2)-((yl(2)-yl(1))/4);
            offset(1)=((xl(2)-xl(1))/2);
            offset(2)=((yl(2)-yl(1))/2);
        else
            if axesequal
                point1 = point1(1,1:2);
                point2 = point2(1,1:2);
                p1 = min(point1,point2);
                offset = abs(point1-point2);
                if offset(2)/offset(1)>asprat
                    p1(1)=p1(1)+0.5*offset(1)-0.5*offset(2)/asprat;
                    offset(1)=offset(2)/asprat;
                else
                    p1(2)=(p1(2)+0.5*offset(2))-0.5*asprat*offset(1);
                    offset(2)=asprat*offset(1);
                end
            else
                point1=point1(1,1:2);
                point2=point2(1,1:2);
                p1 = min(point1,point2);
                p2 = max(point1,point2);
                offset=p2-p1;
            end
        end
    else
        point1 = get(h,'CurrentPoint');
        xl=get(h,'xlim');
        yl=get(h,'ylim');
        point1=point1(1,1:2);
        p1(1)=point1(1)-0.66667*((xl(2)-xl(1)));
        p1(2)=point1(2)-0.66667*((yl(2)-yl(1)));
        offset(1)=1.5*(xl(2)-xl(1));
        offset(2)=1.5*(yl(2)-yl(1));
    end
    set(h,'xlim',[p1(1) p1(1)+offset(1)]);
    set(h,'ylim',[p1(2) p1(2)+offset(2)]);
else
    if (leftmouse && zoomin==1) || (rightmouse && zoomin==0)
        fac=1.5;
    else
        fac=2/3;
    end
    camzoom(h,fac);
end

updateLimits;

%%
function startRotateView(imagefig, varargins,h) 

[az0,el0]=view(h);
target0=get(h,'CameraTarget');
pos0=get(gcf,'CurrentPoint');
set(gcf, 'windowbuttonmotionfcn', {@rotateView,h,az0,el0,target0,pos0});
set(gcf, 'windowbuttonupfcn', {@stopRotateView});

%%
function rotateView(imagefig, varargins,h,az0,el0,target0,pos0) 

pos1=get(gcf,'CurrentPoint');
dpos=pos1-pos0;
az1=az0-dpos(1)/2.5;
el1=el0-dpos(2)/2.5;
view(h,[az1,el1]);
set(h,'CameraTarget',target0);

%%
function stopRotateView(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
set(gcf, 'windowbuttonupfcn',[]);

updateLimits;

%%
function startPan2D(imagefig, varargins,h) 

pos0=get(h,'CurrentPoint');
pos0=pos0(1,1:2);
xl0=get(h,'XLim');
yl0=get(h,'YLim');
set(gcf, 'windowbuttonmotionfcn', {@pan2D,h,xl0,yl0,pos0});
set(gcf, 'windowbuttonupfcn', {@stopPan});
setptr(gcf,'closedhand');

%%
function pan2D(imagefig, varargins,h,xl0,yl0,pos0) 

xl1=get(h,'XLim');
yl1=get(h,'YLim');
pos1=get(h,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
set(h,'XLim',xl,'YLim',yl);

%%
function startPan3D(imagefig, varargins,h) 

target0=get(h,'CameraTarget');
[az,el]=view(h);
pos0=get(gcf,'CurrentPoint');
xl=get(h,'XLim');
yl=get(h,'YLim');
dx=xl(2)-xl(1);
dy=yl(2)-yl(1);
d=sqrt(dx^2+dy^2);
set(gcf, 'windowbuttonmotionfcn', {@pan3D,h,pos0,target0,d,az});
set(gcf, 'windowbuttonupfcn', {@stopPan});
setptr(gcf,'closedhand');

%%
function pan3D(imagefig, varargins,h,pos0,target0,d,az) 

pos1=get(gcf,'CurrentPoint');
dpos=pos1-pos0;
target1(1)=target0(1)+0.001*d*dpos(2)*sin(pi*az/180)-0.001*d*dpos(1)*cos(pi*az/180);
target1(2)=target0(2)-0.001*d*dpos(2)*cos(pi*az/180)-0.001*d*dpos(1)*sin(pi*az/180);
target1(3)=target0(3);
set(h,'CameraTarget',target1);

%%
function stopPan(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn', {@moveMouse});
set(gcf, 'windowbuttonupfcn',[]);
setptr(gcf,'hand');

updateLimits;

%%
function moveMouse(imagefig, varargins)

handles=getHandles;
ifig=get(gcf,'UserData');

posgcf = get(gcf, 'CurrentPoint')/handles.figures(ifig).figure.cm2pix;

typ='none';

for j=1:handles.figures(ifig).figure.nrsubplots
    h0=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    if ~isempty(h0)
        pos=get(h0,'Position')/handles.figures(ifig).figure.cm2pix;
        if posgcf(1)>pos(1) && posgcf(1)<pos(1)+pos(3) && posgcf(2)>pos(2) && posgcf(2)<pos(2)+pos(4)
            typ=handles.figures(ifig).figure.subplots(j).subplot.type;
            h=h0;
        end
    end
end

oktypes={'2d','map','3d','timeseries','xy','timestack'};
ii=strmatch(lower(typ),oktypes,'exact');

if isempty(ii)
    set(gcf,'Pointer','arrow');
    set(gcf,'WindowButtonDownFcn',[]);
    return
else
    switch(handles.figures(ifig).figure.zoom),
        case{'zoomin'}
            set(gcf,'WindowButtonDownFcn',{@zoomInOut,h,1});
            setptr(gcf,'glassplus');
        case{'zoomout'}
            set(gcf,'WindowButtonDownFcn',{@zoomInOut,h,0});
            setptr(gcf,'glassminus');
        case{'pan'}
            if strcmp(typ,'3d')
                setptr(gcf,'hand');
                set(gcf,'WindowButtonDownFcn',{@startPan3D,h});
            else
                setptr(gcf,'hand');
                set(gcf,'WindowButtonDownFcn',{@startPan2D,h});
            end
        case{'rotate3d'}
            if strcmp(typ,'3d')
                setptr(gcf,'rotate');
                set(gcf,'WindowButtonDownFcn',{@startRotateView,h});
            end
        otherwise
            set(gcf,'WindowButtonDownFcn',[]);
            setptr(gcf,'arrow');
    end
end

%%
function updateLimits

fig=getappdata(gcf,'figure');
usd=get(gca,'UserData');
xl=get(gca,'XLim');
yl=get(gca,'YLim');
isub=usd(2);
plt=fig.subplots(isub).subplot;

xmin=xl(1);
xmax=xl(2);
ymin=yl(1);
ymax=yl(2);

switch plt.type
    case{'map'}
        plt.xminproj=xmin;
        plt.xmaxproj=xmax;
        plt.yminproj=ymin;
        plt.ymaxproj=ymax;
        plt=muppet_updateLimits(plt,'zoom');
        set(gca,'xlim',[plt.xminproj plt.xmaxproj],'ylim',[plt.yminproj plt.ymaxproj]);
    otherwise
        plt.xmin=xmin;
        plt.xmax=xmax;
        plt.ymin=ymin;
        plt.ymax=ymax;
end

plt.limitschanged=1;
fig.subplots(isub).subplot=plt;
fig.changed=1;
setappdata(gcf,'figure',fig);
