function ddb_shiftPan(src,evnt)

handles=getHandles;

if strcmp(evnt.Modifier,'shift') | strcmp(evnt.Modifier,'control')
    set(gcf,'KeyPressFcn',[]);
    set(gcf,'KeyReleaseFcn',{@StopPan});
    setptr(gcf,'hand');
    set(gcf, 'windowbuttonmotionfcn', {@StartPan});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StartPan(imagefig, varargins) 

xl=get(gca,'xlim');
yl=get(gca,'ylim');
pos0=get(gca,'CurrentPoint');
pos0=pos0(1,1:2);
set(gcf, 'windowbuttonmotionfcn', {@Pan2D,gca,xl,yl,pos0});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Pan2D(imagefig, varargins,h,xl0,yl0,pos0) 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StopPan(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn',[]);
set(gcf,'KeyPressFcn',{@ddb_shiftPan});
set(gcf,'KeyReleaseFcn',[]);
setptr(gcf,'arrow');

