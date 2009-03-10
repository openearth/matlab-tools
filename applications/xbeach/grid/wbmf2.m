function wbmf2
%window motion callback function

utemp=get(gcf,'UserData')
x1=utemp.p1(1);y1=utemp.p1(2);
x2=utemp.p2(1);y2=utemp.p2(2);
alfa=atan2(y2-y1,x2-x1);
sina=sin(alfa);cosa=cos(alfa)
p3=get(utemp.h,'CurrentPoint');
x=p3(1,1);y=p3(1,2);
yn=-sina*(x-x1)+cosa*(y-y1);
x3=x2-yn*sina;
y3=y2+yn*cosa;
x4=x1-yn*sina;
y4=y1+yn*cosa;
xi=[x1,x2,x3,x,x4,x1];
yi=[y1,y2,y3,y,y4,y1];
set(utemp.lh,'XData',xi, ...
             'YData',yi);
utemp.xi=xi;
utemp.yi=yi;
set(gcf,'UserData',utemp);

