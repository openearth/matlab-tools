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

function allvari=D3D_apply_variation(allvari,variation_c)

allvari_add=allcomb(variation_c{:});
% allvari_add=allcomb(noise_seed_v,Tstop_v,MorFac_v,CFL_v);

allvari=cat(1,allvari,allvari_add);

% combStr2 = [a(m(1,:)); b(m(2,:)); c(m(3,:))]'

end