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