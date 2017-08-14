function [m,n]=EHY_find_mn_location(x,y,grdFile)
% [m,n]=EHY_find_mn_location(x,y,grdFile)
%
% Find the m,n-location(s) of your x,y-location(s) in a structured
% Delft3D/SIMONA grid.
% 
% Example1: [m,n]=EHY_find_mn_location(70000,445000,'D:\Nederland.grd')
% Example2: [m,n]=EHY_find_mn_location([70000 80000],[445000 455000],'D:\Nederland.grd')
% 
% created by Julien Groenenboom, May 2017

grd=delft3d_io_grd('read',grdFile);

if length(x)~=length(y); error('x and y should have the same length'); end

for ixy=1:length(x)
dist=sqrt( (grd.cen.x-x(ixy)).^2 + (grd.cen.y-y(ixy)).^2 );
[mm,nn]=find(dist==min(min(dist)));
m(ixy)=mm(1)+1;
n(ixy)=nn(1)+1;
end

