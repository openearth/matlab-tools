function [x2,y2] = editxyfromfig(x,y,figname);
button = -1;
figs = 1;
if nargin ~= 3;
    figname = '';
    figs = 0;
end
cnt = 1;
len = length(x);
%cnt2 = 1;
close all;
if figs ~= 0
    openfig(figname,'reuse');
    pause
    axis equal 
    pause
    hold on;
    if len > 2
        l  = 1:len;
        cx = spline(l,x);
        cy = spline(l,y);
        ll = 1:0.1:len;
        xs = ppval(cx,ll);
        ys = ppval(cy,ll);
    else
        xs = x;
        ys = y;
    end
    %openfig(figname,'reuse');
    hold on;
    %   if cnt2 > 1;
    %   delete(a);
    %set(a(cnt2-1,1:3),'Visible','off');
    %   end
    a(1:2) = plot(xs,ys,'r-',x,y,'ro','MarkerSize',5,'MarkerFaceColor','g');
    a(3)   = plot(x(cnt),y(cnt),'ro','MarkerSize',5,'MarkerFaceColor','r');
    hold off;

    %   a(1:2) = plot(x,y,'ro',x,y,'r-','MarkerSize',5,'MarkerFaceColor','g');
    %   a(3) = plot(x(cnt),y(cnt),'ro','MarkerSize',5,'MarkerFaceColor','r');
end
xd = diff(get(gca,'XLim'))/200;
yd = diff(get(gca,'YLim'))/200;
dd = min(xd,yd);
while (button ~= 3)
    [xc,yc,button] = ginput(1);
    if button == 113; button = 3; end;
    %   cnt2 = cnt2 + 1;
    switch(button)
        case 1;
            [md, cnt] = min(sqrt((x-xc).^2+(y-yc).^2));
        case 3
            x(cnt) = [];
            y(cnt) = [];
            break;
        case {43,61} %+, =.
            cnt = min(cnt + 1,len);
        case {45,95} %-, _.
            cnt = max(cnt - 1,1);
        case {8, 100, 127} %backspace, d, delete;
            if len <= 2;
                warning('Spline should have more than 2 points.');
            else
                len = len - 1;
                x(cnt) = [];
                y(cnt) = [];
                cnt = max(min(cnt-1,len),1);
            end
        case {97} %a = add.
            if cnt == len;
                cnt = cnt-1;
            end
            x = [x(1:cnt),mean(x(cnt:cnt+1)),x(cnt+1:len)];
            y = [y(1:cnt),mean(y(cnt:cnt+1)),y(cnt+1:len)];
            cnt = cnt + 1;
            len = len + 1;
        case {28} %left
            x(cnt) = x(cnt) - dd;
            y(cnt) = y(cnt);
            %delete(a);
            %set(a(cnt2-1,1:3),'Visible','off');
        case {29} %right
            x(cnt) = x(cnt) + dd;
            y(cnt) = y(cnt);
            %delete(a);
            %set(a(cnt2-1,1:3),'Visible','off');
        case {30} %up
            x(cnt) = x(cnt);
            y(cnt) = y(cnt) + dd;
            %delete(a);
            %set(a(cnt2-1,1:3),'Visible','off');
        case {31} %down
            x(cnt) = x(cnt);
            y(cnt) = y(cnt) - dd;
            %delete(a);
            %set(a(cnt2-1,1:3),'Visible','off');
    end
    if len > 2
        l  = 1:len;
        cx = spline(l,x);
        cy = spline(l,y);
        ll = 1:0.1:len;
        xs = ppval(cx,ll);
        ys = ppval(cy,ll);
    else
        xs = x;
        ys = y;
    end
    %openfig(figname,'reuse');
    hold on;
    %   if cnt2 > 1;
    delete(a);
    %set(a(cnt2-1,1:3),'Visible','off');
    %   end
    a(1:2) = plot(xs,ys,'r-',x,y,'ro','MarkerSize',5,'MarkerFaceColor','g');
    a(3)   = plot(x(cnt),y(cnt),'ro','MarkerSize',5,'MarkerFaceColor','r');
    hold off;
    % xold = x(cnt);   yold = y(cnt);
    x2 = x; y2 = y;
end