
clc
clear

%%
%2585 = n cell corners
%5011 = n cell edges
%2426 = n cells

path_grd='p:\11205950-001-pumarejo\05_data\05_grd\UGg04_03_full_net.nc';
nci=ncinfo(path_grd);
edg_node=ncread(path_grd,'mesh2d_edge_nodes'); %{'Start and end nodes of mesh edges'}
node_x=ncread(path_grd,'mesh2d_node_x'); 
edge_x=ncread(path_grd,'mesh2d_edge_x'); 
edge_y=ncread(path_grd,'mesh2d_edge_y'); 
face_x=ncread(path_grd,'mesh2d_face_x'); 
face_y=ncread(path_grd,'mesh2d_face_y'); 
net_elem_node=double(ncread(path_grd,'NetElemNode')); %which cell corners connect each cell max=2585
net_elem_link=double(ncread(path_grd,'NetElemLink')); %which 
net_elem_link(abs(net_elem_link)>1e5)=NaN;
NetLinkContour_x=ncread(path_grd,'mesh2d_NetLinkContour_x'); %{'list of x-contour points of momentum control volume surrounding each net/flow link'}
NetLinkContour_y=ncread(path_grd,'mesh2d_NetLinkContour_y');
% The orthogonality is defined as the cosine of the angle ? between a flowlink and a netlink.
% The smoothness of a mesh is defined as the ratio of the areas of two adjacent cells
%%
p0=[node_x(edg_node(1,:)),node_y(edg_node(1,:))];
pf=[node_x(edg_node(2,:)),node_y(edg_node(2,:))];

%%
% CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);

%%
figure
hold on
plot([p0(:,1),pf(:,1)]',[p0(:,2),pf(:,2)]')
axis equal
%%
x1=NetLinkContour_x([1,3],:); %initial and final x of v
x2=NetLinkContour_x([2,4],:); %initial and final x of u
y1=NetLinkContour_y([1,3],:);
y2=NetLinkContour_y([2,4],:);

v=[x1(2,:)-x1(1,:);y1(2,:)-y1(1,:)];
u=[x2(2,:)-x2(1,:);y2(2,:)-y2(1,:)];

CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
CosTheta = dot(u,v)/(norm(u)*norm(v));

%%
close all
figure
hold on
plot(NetLinkContour_x(:,1),NetLinkContour_y(:,1))
scatter(face_x,face_y,10,'g','filled')
% plot(NetLinkContour_x([1,2],1),NetLinkContour_y([1,2],1),'b')
% plot(NetLinkContour_x([3,4],1),NetLinkContour_y([3,4],1),'r')
scatter(edge_x,edge_y,10,'b','filled')
scatter(node_x,node_y,10,'r','filled')
edg_node
axis equal
%%
figure
hold on
% plot([x1,x2],[y1,y2])
plot(x1,y1,'r');
plot(x2,y2,'b');
%%
figure
scatter(edge_x,edge_y,10,CosTheta,'filled')
axis equal
colorbar

