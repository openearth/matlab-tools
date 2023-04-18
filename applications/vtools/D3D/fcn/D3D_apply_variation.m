%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 09:11:11 +0100 (di, 01 feb 2022) $
%$Author: chavarri $
%$Id: elder.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/elder.m $
%
%

function allvari=D3D_apply_variation(allvari,variation_c)

allvari_add=allcomb(variation_c{:});
% allvari_add=allcomb(noise_seed_v,Tstop_v,MorFac_v,CFL_v);

allvari=cat(1,allvari,allvari_add);

% combStr2 = [a(m(1,:)); b(m(2,:)); c(m(3,:))]'

end