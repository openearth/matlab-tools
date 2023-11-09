%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (di, 08 sep 2020) $
%$Author: chavarri $
%$Id: S3_get_branch_order.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/S3_get_branch_order.m $
%

function branch_length=branch_length_sobek3(offset,branch)

branch_2p_idx=unique(branch);
nb=numel(branch_2p_idx);

branch_length=NaN(nb,1);

for kb=1:nb
    idx_br=branch==branch_2p_idx(kb); %logical indexes of intraloop branch
    off_br=offset(idx_br);
    branch_length(kb,1)=off_br(end);
end

end %function
