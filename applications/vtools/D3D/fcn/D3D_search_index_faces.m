%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18945 $
%$Date: 2023-05-15 14:17:04 +0200 (Mon, 15 May 2023) $
%$Author: chavarri $
%$Id: D3D_search_index_layer.m 18945 2023-05-15 12:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_search_index_layer.m $
%
%

function idx_f=D3D_search_index_faces(data)
idx_f=D3D_search_index_in_dimension(data,'mesh2d_nFaces');
end