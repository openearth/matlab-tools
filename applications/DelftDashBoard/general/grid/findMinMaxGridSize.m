function [dmin,dmax]=findMinMaxGridSize(xg,yg,varargin)

cstype='projected';

dmin=1e9;
dmax=0;

xg1=xg(1:end-1,1:end);
xg2=xg(2:end,1:end);
xg3=xg(1:end,1:end-1);
xg4=xg(1:end,2:end);

yg1=yg(1:end-1,1:end);
yg2=yg(2:end,1:end);
yg3=yg(1:end,1:end-1);
yg4=yg(1:end,2:end);

dstn=sqrt((xg2-xg1).^2+(yg2-yg1).^2);
dmin=min(dmin,min(min(dstn)));
dmax=max(dmax,max(max(dstn)));

dstn=sqrt((xg4-xg3).^2+(yg4-yg3).^2);
dmin=min(dmin,min(min(dstn)));
dmax=max(dmax,max(max(dstn)));
