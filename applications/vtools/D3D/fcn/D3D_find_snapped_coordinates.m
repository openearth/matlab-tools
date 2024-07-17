%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19670 $
%$Date: 2024-06-13 15:26:01 +0200 (Thu, 13 Jun 2024) $
%$Author: chavarri $
%$Id: D3D_io_input.m 19670 2024-06-13 13:26:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
%Find the coordinates of the center of the cell-edges (i.e., coordinates of links) that cross a set 
%of polylines.

function int_all=D3D_find_snapped_coordinates(fpath_grd,fpath_pol)

%% READ

messageOut(NaN,'Start reading data')

ltw=D3D_io_input('read',fpath_pol);
% gridInfo=EHY_getGridInfo(fpath_grd,{'grid'});
edge_faces=ncread(fpath_grd,'mesh2d_edge_faces');
face_x=ncread(fpath_grd,'mesh2d_face_x');
face_y=ncread(fpath_grd,'mesh2d_face_y');

%%

% max(edge_faces(:))
% min(edge_faces(:))
% find(edge_faces==0)

%loop on mesh edges
nedg=size(edge_faces,2);
npol=numel(ltw);
int_all=cell(npol,1);

for kedg=1:nedg

%coordinates of mesh faces neighbouring a mesh edge
face_neigh=edge_faces(:,kedg);
if any(face_neigh==0)
    continue
end

%line joining neighbouring faces
face_lin=[face_x(face_neigh)';face_y(face_neigh)']; %two rows, first row x-coordinate, second row y-coordinate

%loop on polylines
for kpol=1:npol
    lin_pol=ltw(kpol).xy'; %two rows, first row x-coordinate, second row y-coordinate

    %cross line with polyline
    int=InterX(face_lin,lin_pol);

    %save coordinate
    if ~isempty(int)
        int_all{kpol}=cat(2,int_all{kpol},int);
    end

end %kpol

%display
fprintf('Done %4.2f %% \n',kedg/nedg*100);

end %kedg

end %function