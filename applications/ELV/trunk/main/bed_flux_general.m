%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16757 $
%$Date: 2020-11-02 07:34:08 +0100 (Mon, 02 Nov 2020) $
%$Author: chavarri $
%$Id: bed_level_update.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_level_update.m $
%
%bed_level_update updates the bed elevation
%
%etab_new=bed_level_update(etab,qbk,bc,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%201106
%   -V. Created for the first time.
%

function bed_flux=bed_flux_general(input,Qb,B,c,etab,dt)

switch input.mor.scheme
    case 2 %Boorsboom
        vm=3:numel(Qb)-1;
end

fp05_p=f_flux_p(input,vm  ,Qb./B,c,etab,dt); %f_(m+0.5) when upwind positive
fm05_p=f_flux_p(input,vm-1,Qb./B,c,etab,dt); %f_(m-0.5) when upwind positive

bed_flux=fp05_p-fm05_p;

end %function

%%
%% FUNCTIONS
%%

function r=f_r(vm,v)
r=(v(vm+1)-v(vm))./(v(vm)-v(vm-1)); %epsilon to prevent NaN when flat
% r=(v(vm+1)-v(vm)+1e-10)./(v(vm)-v(vm-1)+1e-10); %epsilon to prevent NaN when flat
% r=(v(vm)-v(vm-1)+1e-10)./(v(vm+1)-v(vm)+1e-10); %epsilon to prevent NaN when flat
end

function sigma_b=f_sigma_b(input,c,dt)
sigma_b=input.mor.MorFac.*c.*dt./(1-input.mor.porosity)./input.grd.dx;
end

function f_flux_p=f_flux_p(input,vm,Qb,c,etab,dt)

input.mdv.fluxtype=input.mor.fluxtype; %we use the same function as for flow

switch input.mor.scheme
    case 2 %Boorsboom
        r=f_r(vm,etab);
        sigma_b=f_sigma_b(input,c(vm),dt);
        f_flux_p=Qb(vm)+c(vm).*0.5.*((1-sigma_b).*phi_func(r,input)-1).*(etab(vm+1)-etab(vm));
end %switch

end %function
