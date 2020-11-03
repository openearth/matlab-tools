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
%160223
%   -V. Created for the first time.
%
%160429
%   -V. Introduction of periodic boundary conditions
%
%160623
%   -V. Cyclic boundary conditions.
%
%160803
%	-L. Merging; including cycled boundary conditions
%
%170126
%   -L. Added cases 13,14 (no new version)
%
%170516
%   -V. Erased upwind factor
%
%171005
%   -V. Added entrianment deposition formulation
%   -V. Add pmm to general update
%
%200715
%   -V. Solved bug with unsteady flow and mixed-size sediment

function etab_new=bed_level_update_combined(input,etab,Qb0,Qb,beta)

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
nx=input.mdv.nx; %number of cells
% nf=input.mdv.nf; 
% UpwFac=input.mdv.UpwFac;
% bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;

%%
%% CALC
%%

% UpwFac = 1-(Qb<0); %sets the UpwFac to 1 if flow comes from left, and to 0 if flow comes from right [1,nx] double

%upstream node always FTBS
if input.bcm.type==4
    etab_new(1,1)=etab(1,1);
else
    flux_BS=bed_flux_BS([Qb0,Qb(1)],B(1:2));
    etab_new(1,1)      = etab(1,1)      - MorFac * dt /cb /beta(1,1)/(dx/2) * flux_BS;
end
        
switch input.mor.scheme
    case 1 %FTBS
        flux_BS=bed_flux_BS(Qb,B);
        etab_new(1,2:nx)=etab(1,2:nx)-MorFac*dt./cb./beta(1,2:nx)./(dx).* flux_BS;
    case 3 %QUICK
        %second cell is BS
        flux_BS=bed_flux_BS(Qb(1:2),B(2:3));
        etab_new(1,2)      = etab(1,2)      - MorFac * dt /cb /beta(1,2)/(dx) * flux_BS;
        
        %rest is QUICK
        flux_QUICK=bed_flux_QUICK(Qb,B);
        etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_QUICK;
        
        %last cell is BS
        flux_BS=bed_flux_BS(Qb(end-1:end),B(end-1:end));
        etab_new(1,nx)      = etab(1,nx)      - MorFac * dt /cb /beta(1,nx)/(dx) * flux_BS;
    case 4
        %second cell is BS
        flux_BS=bed_flux_BS(Qb(1:2),B(2:3));
        etab_new(1,2)      = etab(1,2)      - MorFac * dt /cb /beta(1,2)/(dx) * flux_BS;
        
        %rest is flux limiter
        flux_limiter=bed_flux_limiter(input,Qb,B);
        etab_new(1,3:nx-1)=etab(1,3:nx-1)-MorFac*dt./cb./beta(1,3:nx-1)./(dx).* flux_limiter;
        
        %last cell is BS
        flux_BS=bed_flux_BS(Qb(end-1:end),B(end-1:end));
        etab_new(1,nx)      = etab(1,nx)      - MorFac * dt /cb /beta(1,nx)/(dx) * flux_BS;
end


end %function