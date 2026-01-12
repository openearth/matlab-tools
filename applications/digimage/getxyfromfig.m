function [x,y] = getxyfromfig(figname);
figs = 1;
if nargin ~= 1;
    figname = '';
    figs = 0;
end
button = -1;
xold = 0; yold = 0;
x(1) = 0; y(1) = 0;
cnt = 0;
close all;
if figs ~= 0
openfig(figname,'reuse');
%xlim([-3.2 3.2])
%ylim([-2.5 1.8])
pause
axis equal
pause
end
xd = diff(get(gca,'XLim'))/200;
yd = diff(get(gca,'YLim'))/200;
dd = min(xd,yd);
while button ~= 3
   cnt = cnt + 1;
   [x(cnt),y(cnt),button] = ginput(1);
   switch(button)
       case 3 
           cnt = cnt - 1;
           x(cnt+1) = [];
           y(cnt+1) = [];
           break; 
       case {97, 28} %left
           cnt = cnt - 1;
           x(cnt+1) = [];
           y(cnt+1) = [];
           x(cnt) = xold - dd;
           y(cnt) = yold;
           set(a(cnt,1:2),'Visible','off');
       case {100, 29} %right
           cnt = cnt - 1;
           x(cnt+1) = [];
           y(cnt+1) = [];
           x(cnt) = xold + dd;
           y(cnt) = yold;
           set(a(cnt,1:2),'Visible','off');
       case {119, 30} %up
           cnt = cnt - 1;
           x(cnt+1) = [];
           y(cnt+1) = [];
           x(cnt) = xold;
           y(cnt) = yold + dd;
           set(a(cnt,1:2),'Visible','off');
       case {115, 31} %down
           cnt = cnt - 1;
           x(cnt+1) = [];
           y(cnt+1) = [];
           x(cnt) = xold;
           y(cnt) = yold - dd;           
           set(a(cnt,1:2),'Visible','off');
   end
   if cnt > 2
   l  = 1:cnt; 
   cx = spline(l,x);
   cy = spline(l,y);   
   ll = 1:0.1:cnt;
   xs = ppval(cx,ll);
   ys = ppval(cy,ll);
   else 
      xs = x;
      ys = y;
   end
   %openfig(figname,'reuse');
   hold on;
   a(cnt,1:2) = plot(x,y,'ro',xs,ys,'r-','MarkerSize',5,'MarkerFaceColor','g');
   %a(cnt,1:2) = plot(x(1:2:end),y(1:2:end),'r+',x(2:2:end),y(2:2:end),'rx');%,xs,ys,'r-','MarkerSize',5,'MarkerFaceColor','g');
   if cnt > 1; 
       set(a(cnt-1,1:2),'Visible','off');
   end
   hold off;
   xold = x(cnt);   yold = y(cnt);
end