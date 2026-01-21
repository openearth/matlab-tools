%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%
function L = D3D_compute_streamfunction_Laplacian(mesh2d_edge_faces,mesh2d_face_x,mesh2d_face_y,edge_length)

%% DIMENSIONS, RENAME

nFaces = numel(mesh2d_face_x);
nEdges = numel(edge_length);

fcx=mesh2d_face_x;
fcy=mesh2d_face_y;

%% ---- Sparse Laplacian assembly
I = [];
J = [];
V = [];

for e = 1:nEdges
    fL = mesh2d_edge_faces(1,e);
    fR = mesh2d_edge_faces(2,e);

    Le = edge_length(e);

    if fL > 0 && fR > 0
        % distance between face centres
        dx = fcx(fR) - fcx(fL);
        dy = fcy(fR) - fcy(fL);
        d  = hypot(dx,dy);

        w = Le / d;

        % Laplacian entries
        I = [I fL fL fR fR];
        J = [J fL fR fR fL];
        V = [V -w  w -w  w];

    else
        % Boundary edge → Neumann ψ (no-flux)
        % nothing to add to matrix
    end
end

L = sparse(I,J,V,nFaces,nFaces);

%% ---- Fix gauge (ψ defined up to constant)
L(1,:) = 0;
L(1,1) = 1;

end
