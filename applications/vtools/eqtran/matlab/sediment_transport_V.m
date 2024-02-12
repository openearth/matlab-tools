%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19428 $
%$Date: 2024-02-10 10:41:10 +0100 (Sat, 10 Feb 2024) $
%$Author: chavarri $
%$Id: D3D_erosed.m 19428 2024-02-10 09:41:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/eqtran/matlab/fcn/D3D_erosed.m $
%
%Compare sediment transport from `eqtran` with V's implementation.

function [qbk]=sediment_transport_V(rhosol,rhowat,ag,iform,hiding,rmu,vicmol,u,chezy,h,dk,A,B,thetac)

switch iform
    case 4
        flg.sed_trans=1;
    otherwise
        error('add');
end
flg.friction_closure=1;
if hiding~=1
    error('add');
end
flg.hiding=0;
flg.Dm=1;
flg.vp=0;
flg.E=0;
if rmu~=1
    error('add')
end
flg.mu=0;
flg.particle_activity=0;
flg.extra=1;
cnt.g=ag;
cnt.rho_s=rhosol;
cnt.rho_w=rhowat;
cnt.p=0.0;
cnt.R=(rhosol-rhowat)/rhowat;
cnt.nu=vicmol;

% u=1.00;
% h=h1;
cf=ag/chezy^2;

% dk=1e-3;
Fak=[1]';
La=1;
Mak=Fak.*La;

sed_trans_param=[A,B,thetac]; %MPM

E_param=[0.0199,1.5]; %FLvB
vp_param=[11.5,0.7]; %FLvB

hiding_param=-0.8;
mor_fac=1;

Gammak=zeros(1,numel(dk));

[qbk,Qbk]=sediment_transport(flg,cnt,h,u*h,cf,La,Mak,dk,sed_trans_param,hiding_param,1,NaN,NaN);

end %function