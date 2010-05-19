function PlotRectangle(tag,x0,y0,lenx,leny,rotation,varargin)

dx=[];
dy=[];
fmove=[];
fstop=[];
col='g';
lw=1.5;
marker='o';
markercol='r';
rot=1;

if nargin>6
    dx=varargin{1};
    dy=varargin{2};
    fmove=varargin{3};
    fstop=varargin{4};
    col=varargin{5};
    lw=varargin{6};
    marker=varargin{7};
    markercol=varargin{8};
    rot=varargin{9};
end

plt=findobj(gcf,'Tag',tag);

x(1)=x0;
x(2)=x(1)+lenx*cos(pi*rotation/180);
x(3)=x(2)-leny*sin(pi*rotation/180);
x(4)=x(1)-leny*sin(pi*rotation/180);
x(5)=x(1);

y(1)=y0;
y(2)=y(1)+lenx*sin(pi*rotation/180);
y(3)=y(2)+leny*cos(pi*rotation/180);
y(4)=y(1)+leny*cos(pi*rotation/180);
y(5)=y(1);

if isempty(plt)

    plt=plot(x,y);
    set(plt,'Color',col,'LineWidth',lw);
    set(plt,'Tag',tag);
    for i=1:4
        p(i)=plot3(x(i),y(i),5000);
        set(p(i),'Marker',marker,'MarkerFaceColor',markercol,'MarkerEdgeColor','k','MarkerSize',4);
        u.nr=i;
        u.parent=plt;
        set(p(i),'UserData',u);
    end
    set(p(1),'MarkerFaceColor','y','MarkerSize',5);
    
    usd.tag=tag;
    usd.fmove=fmove;
    usd.fstop=fstop;
    usd.rot=rot;
    usd.col=col;
    usd.lw=lw;
    usd.marker=marker;
    usd.markercol=markercol;
    usd.ch=p;
    usd.fmove=fmove;
    usd.fstop=fstop;
    usd.dx=dx;
    usd.dy=dy;

else
    set(plt,'XData',x,'YData',y);
    for i=1:4
        usd=get(plt,'UserData');
        set(usd.ch(i),'XData',x(i),'YData',y(i));
    end    
end

usd.xori=x0;
usd.yori=y0;
usd.lenx=lenx;
usd.leny=leny;
usd.x=x;
usd.y=y;
usd.rotation=rotation;

set(plt,'UserData',usd);
