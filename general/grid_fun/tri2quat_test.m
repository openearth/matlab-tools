%TRI2QUAT_TEST   test for tri2quat
%
%See also: tri2quat

[cor.x,cor.y] = meshgrid(1:3,1:4);

%tri    = delaunay(x,y);
%qua    = quat(x,y);
%mapper = tri2quat(tri,qua);

map   = triquat(cor.x,cor.y);

tri   = map.tri;
qua   = map.quat;

ntri  = size(tri,1);
nqua  = size(qua,1);

color = 'rgbcmyk';

[xctri,yctri] = tri_corner2center(tri,cor.x,cor.y);

plot(x(qua),y(qua),'bo')

hold on

for iqua=1:nqua

   patch(    cor.x(qua(iqua,:)),...
             cor.y(qua(iqua,:)),color(iqua),'facealpha',.5)
   text(mean(cor.x(qua(iqua,:))),...
        mean(cor.y(qua(iqua,:))),...
        num2str(iqua),'color',color(iqua),'BackgroundColor','w');

end

plot(cor.x(tri),cor.y(tri),'r.')
tm = trimesh(tri,cor.x,cor.y,'Color','r');
text(xctri,yctri,num2str([1:ntri]'),'color','r')

axis equal