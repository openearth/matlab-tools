%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19428 $
%$Date: 2024-02-10 10:41:10 +0100 (Sat, 10 Feb 2024) $
%$Author: chavarri $
%$Id: D3D_sediment_parameters.m 19428 2024-02-10 09:41:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/eqtran/matlab/fcn/D3D_sediment_parameters.m $
%
%Computation of sediment parameters as done in Delft3D.

function [drho,tetacr,dstar,taucr]=D3D_sediment_parameters(rhosol,rhow,vicmol,sedd50,ag,factcr)

% drho      = (sedpar%rhosol(ll)-rhow) / rhow
drho=rhosol-rhow/rhow;
% dstar(ll) = sedd50(ll) * (drho*ag/vicmol**2)**0.3333_fp
dstar=sedd50*(drho*ag/vicmol^2)^0.3333;
% if (dstar(ll) < 1.0_fp) then
if dstar<1
    %  if (iform(ll) == -2) then
    if iform==2
    %     tetacr(ll) = 0.115_fp / (dstar(ll)**0.5_fp)
    tetacr=0.115/(dstar^0.5);
    %  else
    else
    %     tetacr(ll) = 0.24_fp / dstar(ll)
    tetacr=0.24/dstar;
    %  endif
    end
% elseif (dstar(ll) <= 4.0_fp) then
elseif dstar <= 4.0
%  if (iform(ll) == -2) then
    if iform==-2
    %     tetacr(ll) = 0.115_fp / (dstar(ll)**0.5_fp)
    tetacr=0.115/(dstar^0.5);
    %  else
    else
    %     tetacr(ll) = 0.24_fp / dstar(ll)
    tetacr=0.24/dstar;
    %  endif
    end
% elseif (dstar(ll)>4.0_fp .and. dstar(ll)<=10.0_fp) then
elseif dstar>4.0 && dstar<=10.0
%  tetacr(ll) = 0.14_fp  / (dstar(ll)**0.64_fp)
tetacr=0.14/(dstar^0.64);
% elseif (dstar(ll)>10.0_fp .and. dstar(ll)<=20.0_fp) then
elseif dstar>10.0 && dstar<=20.0
%  tetacr(ll) = 0.04_fp  / (dstar(ll)**0.1_fp)
tetacr=0.04/(dstar^0.1);
% elseif (dstar(ll)>20.0_fp .and. dstar(ll)<=150.0_fp) then
elseif dstar>20.0 && dstar<=150.0
%  tetacr(ll) = 0.013_fp * (dstar(ll)**0.29_fp)
tetacr=0.013*(dstar^0.29);
% else
else
%  tetacr(ll) = 0.055_fp
tetacr=0.055;
% endif
end
% taucr(ll) = factcr * (rhosol(ll)-rhow) * ag * sedd50(ll) * tetacr(ll)
taucr=factcr*(rhosol-rhow)*ag*sedd50*tetacr;

end %function