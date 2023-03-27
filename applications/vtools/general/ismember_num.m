%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18819 $
%$Date: 2023-03-13 16:40:14 +0100 (Mon, 13 Mar 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18819 2023-03-13 15:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Check if query values `q` are members of vector `v` considering a tolerance `tol`.

function bol_v=ismember_num(v,q,tol)

v=reshape(v,[],1);
q=reshape(q,[],1);

bol_l=v>q'-tol;
bol_h=v<q'+tol;
bol_m=bol_l & bol_h;
bol_v=any(bol_m,2);

end %function