%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18516 $
%$Date: 2022-11-04 16:20:34 +0100 (Fri, 04 Nov 2022) $
%$Author: chavarri $
%$Id: gdm_order_dimensions.m 18516 2022-11-04 15:20:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_order_dimensions.m $
%
%

function mat_out=submatrix(mat,idx_dim,idx_get)

switch idx_dim
    case 1
        mat_out=mat(idx_get,:,:,:,:);
    case 2
        mat_out=mat(:,idx_get,:,:,:);
    case 3
        mat_out=mat(:,:,idx_get,:,:);
    case 4
        mat_out=mat(:,:,:,idx_get,:);
    case 5
        mat_out=mat(:,:,:,:,idx_get(idx_get<=size(mat,5)));
    otherwise
        error('add')
end

end %function