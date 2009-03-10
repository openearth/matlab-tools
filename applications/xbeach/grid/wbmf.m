function wbmf
%window motion callback function

utemp=get(gcf,'UserData');
ptemp=get(utemp.h,'CurrentPoint');
ptemp=ptemp(1,1:2);
x3=ptemp(1)-10*(ptemp(2)-utemp.p1(2));
y3=ptemp(2)+10*(ptemp(1)-utemp.p1(1));
x4=utemp.p1(1)-10*(ptemp(2)-utemp.p1(2));
y4=utemp.p1(2)+10*(ptemp(1)-utemp.p1(1));
set(utemp.lh,'XData',[x4,utemp.p1(1),ptemp(1),x3], ...
             'YData',[y4,utemp.p1(2),ptemp(2),y3]);