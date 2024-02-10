%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19299 $
%$Date: 2023-12-12 17:03:24 +0100 (Tue, 12 Dec 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19299 2023-12-12 16:03:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Parses input to call `eqtran`.
%
%not necessary to convert Matlab double to real integer. The C interface already takes the integer. 

function par=D3D_par(ag,rhowat,rhosol,sedd50,acal,b,cc,rmu,thcr,acals,bs,ccs,rmus,thcrs)

%real(fp)     , dimension(npar)      , intent(inout) :: par !<Sediment transport formula parameters

par( 1) = ag    ;
par( 2) = rhowat;
par( 3) = rhosol;
par( 4) = (rhosol-rhowat)/rhowat;
par( 5) = 1e-6  ; %!< laminar viscosity of water It is harcoded in `fm_erosed`
par( 6) = sedd50; %di50
par(11) = acal  ;
par(12) = b     ;
par(13) = cc    ;
par(14) = rmu   ;
par(15) = thcr  ;
par(16) = acals ;
par(17) = bs    ;
par(18) = ccs   ;
par(19) = rmus  ;
par(20) = thcrs ;

end %function