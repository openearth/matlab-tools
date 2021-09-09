%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17460 $
%$Date: 2021-08-19 15:11:09 +0200 (Thu, 19 Aug 2021) $
%$Author: chavarri $
%$Id: D3D_io_input.m 17460 2021-08-19 13:11:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%

function piles=polnan2cell(piles_nan)

nan_p=isnan(piles_nan(:,1));
nx=size(piles_nan,1);
idx_n=[0;find(nan_p);nx+1];
np=sum(nan_p)+1;
piles=cell(np,1);
for kp=1:np
    piles{kp,1}=piles_nan(idx_n(kp)+1:idx_n(kp+1)-1,:);
end
