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
function psi = D3D_compute_streamfunction(L,edge_length,mesh2d_edge_faces,mesh2d_u1)

%% DIMENSIONS, RENAME

nFaces = max(mesh2d_edge_faces(:));
nEdges = size(mesh2d_edge_faces,2);

%% ---- Sparse Laplacian assembly
rhs = zeros(nFaces,1);

for e = 1:nEdges
    fL = mesh2d_edge_faces(1,e);
    fR = mesh2d_edge_faces(2,e);

    Le = edge_length(e);

    if fL > 0 && fR > 0
        % RHS from circulation
        flux = mesh2d_u1(e) * Le;
        rhs(fL) = rhs(fL) - flux;
        rhs(fR) = rhs(fR) + flux;

    else
        % Boundary edge → Neumann ψ (no-flux)
        % nothing to add to matrix
    end
end

%% ---- Fix gauge (ψ defined up to constant)
rhs(1) = 0;

%% ---- Solve
psi = L \ rhs;

end
