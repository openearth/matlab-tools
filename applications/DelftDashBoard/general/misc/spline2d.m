function [xs2,ys2]=spline2d(xp,yp)
% Generates spline in xy spaces with equidistant points

if length(xp)<2
    xs2=xp;
    ys2=yp;
    return
end

xy=[xp';yp'];

np=20;
n=length(xp);

t=1:n;
ts=1:(1/np):n;
xys=spline(t,xy,ts);

xs=xys(1,:);
ys=xys(2,:);

pd0=pathdistance(xs,ys);
pd=0:(pd0(end)/(np*n)):pd0(end);

xs2=interp1(pd0,xs,pd);
ys2=interp1(pd0,ys,pd);
