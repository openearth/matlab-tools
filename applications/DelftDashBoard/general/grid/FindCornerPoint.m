function [m,n]=FindCornerPoint(posx,posy,x,y,varargin)

if ~isempty(varargin)
    maxdist=varargin{1};
else
    maxdist=1e12;
end
dist=sqrt((posx-x).^2+(posy-y).^2);
[m,n]=find(dist<=min(min(dist)));

for i=1:length(m)
    dist2(i)=sqrt((posx-x(m(i),n(i))).^2+(posy-y(m(i),n(i))).^2);
end
dist3=max(dist2);
if dist3>maxdist
    m=[];
    n=[];
end
