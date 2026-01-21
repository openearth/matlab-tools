function [faceEdges,faceEdgeSign] = D3D_build_face_edge_connectivity(mesh2d_edge_faces)

%BUILD_FACE_EDGE_CONNECTIVITY Geometry + sign prep for vorticity
%
% Inputs:
%   mesh2d_node_x, mesh2d_node_y : node coordinates
%   mesh2d_edge_nodes : [2 x nEdges]
%   mesh2d_edge_faces : [2 x nEdges] (face1 -> face2 defines +u1)
%

nFaces = max(mesh2d_edge_faces(:));
nEdges = size(mesh2d_edge_faces,2);

% --- Face-edge lists
faceEdges     = cell(nFaces,1);
faceEdgeSign  = cell(nFaces,1);

for e = 1:nEdges
    f1 = mesh2d_edge_faces(1,e);
    f2 = mesh2d_edge_faces(2,e);

    if f1 > 0
        faceEdges{f1}(end+1)    = e;
        faceEdgeSign{f1}(end+1) = -1;  % outward = -u1
    end

    if f2 > 0
        faceEdges{f2}(end+1)    = e;
        faceEdgeSign{f2}(end+1) = +1;  % outward = +u1
    end
end

end %function
