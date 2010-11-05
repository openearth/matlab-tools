function [xRD,yRD,x_shift,y_shift] = rd_interp(xRD,yRD)


[c.x,c.y,c.x_shift    ] = surfer_read('x2c.grd');
[c.x,c.y,c.y_shift,OPT] = surfer_read('y2c.grd');

x_shift = nan(size(xRD));
y_shift = nan(size(yRD));

% %%
% c.x =  (1: 4)*1000;
% c.y = (11:14)*1000;
% % c.x_shift = zeros(4,4);
% c.y_shift = zeros(4,4);
% 
% [x,y] = meshgrid(c.x,c.y)
% 
% c.x_shift = [
%     0     0     0     0
%     11     1     11   0
%     0     1     1     0
%     0     0     0     0
%     ];
% 
% xRD = 2100;
% yRD =12000;
% 
% x_shift = nan;
% y_shift = nan;
% ii=1;
for ii = 1:length(xRD)
    % find nearest x,y point
    if xRD(ii)>OPT.min_x && xRD(ii)<OPT.max_x &&...
            yRD(ii)>OPT.min_y && yRD(ii)<OPT.max_y
        ix = find(c.x>xRD(ii),1,'first')+[-2 -1 0 1];
        iy = find(c.y>yRD(ii),1,'first')+[-2 -1 0 1];
        
        if ix(1)>=1 &&  ix(4)<=length(c.x)&&...
                iy(1)>=1 &&  iy(4)<=length(c.y)
            if any(any(isnan(c.x_shift(iy,ix)+c.y_shift(iy,ix))))
                % do nothing
            else    
                ddx = 1 - mod(xRD(ii),1000)/1000;
                ddy = 1 - mod(yRD(ii),1000)/1000;
                
                f(1) =    -0.5*ddx+ddx*ddx    -0.5*ddx*ddx*ddx;
                f(2) = 1.0-2.5*ddx    *ddx    +1.5*ddx*ddx*ddx;
                f(3) =     0.5*ddx+2.0*ddx*ddx-1.5*ddx*ddx*ddx;
                f(4) =    -0.5*ddx    *ddx    +0.5*ddx*ddx*ddx;
                g(1) =    -0.5*ddy+ddy*ddy    -0.5*ddy*ddy*ddy;
                g(2) = 1.0-2.5*ddy    *ddy    +1.5*ddy*ddy*ddy;
                g(3) =     0.5*ddy+2.0*ddy*ddy-1.5*ddy*ddy*ddy;
                g(4) =    -0.5*ddy    *ddy    +0.5*ddy*ddy*ddy;
                
                gfac = rot90(kron(g',f),2);
                
                x_shift(ii) = sum(sum(c.x_shift(iy,ix).*gfac));
                y_shift(ii) = sum(sum(c.y_shift(iy,ix).*gfac));
            end
        end
    end
end


% x_shift
% 
% y_shift
%%
% end
% x_shift = griddata(c.x,c.y,c.x_shift,xRD(ii),yRD(ii));
% % y_shift = griddata(c.x,c.y,c.y_shift,xRD(ii),yRD(ii));
% nans    = griddata(c.x,c.y,c.y_shift,xRD,yRD,'nearest');
x_shift(isnan(x_shift)) = 0;
y_shift(isnan(y_shift)) = 0;
xRD = xRD-x_shift;
yRD = yRD-y_shift;