function [xl,yl]=CompXYLim(xlim0,ylim0,xrange,yrange)

handles=getHandles;

if xlim0(2)<xlim0(1) || ylim0(2)<ylim0(1)
    xlim0=xrange;
    ylim0=yrange;
end

pos=get(gca,'Position');
asprat=pos(4)/pos(3);

if isfield(handles.ScreenParameters,'CoordinateSystem')
    if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'geographic')
        if abs(ylim0(2)-ylim0(1))<45
            fac=cos(pi*0.5*(ylim0(2)+ylim0(1))/180.0);
            asprat=asprat*fac;
        end
    end
end

xmin=xrange(1);
xmax=xrange(2);
ymin=yrange(1);
ymax=yrange(2);

xc=0.5*(xlim0(1)+xlim0(2));
yc=0.5*(ylim0(1)+ylim0(2));

dx=xlim0(2)-xlim0(1);
dy=ylim0(2)-ylim0(1);

if dy/dx>asprat
    dx=dy/asprat;
else
    dy=dx*asprat;
end

if dx>xmax-xmin
    r=(xmax-xmin)/dx;
    dx=dx*r;
    dy=dy*r;
end

if dy>ymax-ymin
    r=(ymax-ymin)/dy;
    dx=dx*r;
    dy=dy*r;
end

x0=xc-0.5*dx;
y0=yc-0.5*dy;

if x0<xmin
    x0=xmin;
end

if y0<ymin
    y0=ymin;
end

if x0+dx>xmax
    x0=xmax-dx;
end

if y0+dy>ymax
    y0=ymax-dy;
end

xl=[x0 x0+dx];
yl=[y0 y0+dy];
