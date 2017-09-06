function [m,n]=EHY_xy2mn(x,y,grdFile)
% [m,n]=EHY_xy2mn(x,y,grdFile)
%
% Find the m,n-location(s) of your x,y-location(s) in a structured
% Delft3D/SIMONA grid.
%
% Example1: [m,n]=EHY_xy2mn(70000,445000,'D:\Nederland.grd')
% Example2: [m,n]=EHY_xy2mn([70000 80000],[445000 455000],'D:\Nederland.grd')
%
% created by Julien Groenenboom, May 2017

tempGrdFile=[tempdir 'tmp.grd'];
copyfile(grdFile,tempGrdFile);
grd=wlgrid('read',tempGrdFile);
delete(tempGrdFile);

grd.Xcen=corner2centernan(grd.X);
grd.Ycen=corner2centernan(grd.Y);

if length(x)~=length(y); error('x and y should have the same length'); end

for ixy=1:length(x)
    dist=sqrt( (grd.Xcen-x(ixy)).^2 + (grd.Ycen-y(ixy)).^2 );
    [mm,nn]=find(dist==min(min(dist)));
    m(ixy,1)=mm(1)+1;
    n(ixy,1)=nn(1)+1;
end

