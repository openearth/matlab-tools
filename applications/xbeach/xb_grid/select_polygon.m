function [xi,yi]=select_polygon
% Select polygon to include in bathy
xi = [];yi=[];
n = 0;
% Loop, picking up the points.
disp('Select polygon to include in bathy')
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
but = 1;
while but == 1
    n = n+1;
    [xi(n),yi(n),but] = ginput(1);
    plot(xi,yi,'r-o');
end
