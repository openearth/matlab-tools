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
        mat_out=mat(:,:,:,:,idx_get(idx_get<=size(mat,5))); %?? Willem, did you do this?
    otherwise
        error('add')
end

end %function