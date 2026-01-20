function omega = vorticity_from_u1(mesh2d_u1,edgeLength,faceEdges,faceEdgeSign,mesh2d_flowelem_ba)
%VORTICITY_FROM_U1 Cell-centered vorticity from edge-normal velocities
%
% Inputs:
%   mesh2d_u1 : [nEdges x 1] edge-normal velocity
%   edgeLength : [nEdges x 1] edge lengths
%   faceEdges : cell array of edges for each face
%   faceEdgeSign : cell array of edge signs for each face
%   mesh2d_flowelem_ba : [nFaces x 1] face areas
%
% Output:
%   omega : [nFaces x 1] vertical vorticity (CCW positive)

nFaces = numel(faceEdges);
omega  = zeros(nFaces,1);

for f = 1:nFaces
    edges = faceEdges{f};
    sgn   = faceEdgeSign{f};

    circ = sum( sgn .* mesh2d_u1(edges).' .* edgeLength(edges).' );
    omega(f) = circ / mesh2d_flowelem_ba(f);
end
end
