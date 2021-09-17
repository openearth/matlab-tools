
clc
clear

%%
%2585 = n cell corners
%5011 = n cell edges
%2426 = n cells

path_grd='';
nci=ncinfo(path_grd);
edge_node=ncread(path_grd,'mesh2d_edge_nodes'); %{'Start and end nodes of mesh edges'}
edge_type=ncread(path_grd,'mesh2d_edge_type');
node_x=ncread(path_grd,'mesh2d_node_x'); 
node_y=ncread(path_grd,'mesh2d_node_y'); 
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
p0=[node_x(edge_node(1,:)),node_y(edge_node(1,:))];
pf=[node_x(edge_node(2,:)),node_y(edge_node(2,:))];

%%
internal_edges = find(edge_type==2); 
for e = internal_edges(:).'; 
    [ii,jj] = find(net_elem_link == e);
    if length(jj) == 2; 
        A.x1 = face_x(jj(1));
        A.x2 = face_x(jj(2));
        A.y1 = face_y(jj(1));
        A.y2 = face_y(jj(2));
        B.x1 = node_x(edge_node(1,e)); 
        B.x2 = node_x(edge_node(2,e)); 
        B.y1 = node_y(edge_node(1,e)); 
        B.y2 = node_y(edge_node(2,e)); 
        C = dflowfm.intersect_lines(A, B); 
        v=[A.x2-A.x1;A.y2-A.y1;];
        u=[B.x2-B.x1;B.y2-B.y1;];
        CosTheta(e) = dot(u,v)/(norm(u)*norm(v));
        Smoothness(e) = max(C.alpha/(1-C.alpha),(1-C.alpha)/C.alpha); 
        edge_mid_x(e) = C.x; 
        edge_mid_y(e) = C.y; 
    else
        CosTheta(e) = NaN; 
        Smoothness(e) = NaN; 
        edge_mid_x(e) = NaN; 
        edge_mid_y(e) = NaN; 
    end 
end

%%
scatter(edge_mid_x,edge_mid_y,100, abs(Smoothness),'.')
axis equal