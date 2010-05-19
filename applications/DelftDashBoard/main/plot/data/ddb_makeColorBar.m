function ddb_makeColorBar(ColorMap)

h=findall(gcf,'Tag','colorbar');

if ~isempty(h)
    pos=get(h,'Position');
    delete(h);
else
    pos=[930 210 25 420];
end

clim=get(gca,'CLim');

%nocol=128;
nocol=64;

clmap=ddb_getColors(ColorMap,nocol)*255;

ax=gca;

clrbar=axes;

for i=1:nocol
    col=clmap(i,:);
    x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
    y(1)=clim(1)+(clim(2)-clim(1))*(i-1)/nocol;
    y(2)=y(1);
    y(3)=clim(1)+(clim(2)-clim(1))*(i)/nocol;
    y(4)=y(3);
    y(5)=y(1);
    fl=fill(x,y,'b');hold on;
    set(fl,'FaceColor',col,'LineStyle','none');
end

set(clrbar,'xlim',[0 1],'ylim',[clim(1) clim(2)]);
set(clrbar,'Units','pixels');
set(clrbar,'Position',pos);
set(clrbar,'XTick',[]);
set(clrbar,'YAxisLocation','right');
set(clrbar,'HitTest','off');
set(clrbar,'Tag','colorbar');

axes(ax);
