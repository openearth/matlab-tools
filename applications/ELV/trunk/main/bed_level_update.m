%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
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

function etab_new=bed_level_update(etab,qbk,Dk,Ek,bc,input,~,kt,time_l,pmm)

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
nx=input.mdv.nx; %number of cells
nf=input.mdv.nf; 
UpwFac=input.mdv.UpwFac;
bc_interp_type=input.mdv.bc_interp_type;
B=input.grd.B;
beta=pmm(2,:); 

%%
%% EXNER
%%

%% FLUX FORM
if input.mor.particle_activity==0
    
%% boundary condition

%%upstream bed load
switch bc_interp_type
    case 1 %interpolate at the beggining
        switch input.bcm.type
            case {1,3,11,12,13,14,'set1'}
                Qbkt = mod(kt,bc.repQbkT(2))+(mod(kt,bc.repQbkT(2))==0)*bc.repQbkT(2);
                Qbk0=B(1)*bc.qbk0(Qbkt,:); %total load [m^3/s]; [1xnf double]
                Qb0=sum(Qbk0,2); %[1x1 double]
            case 2
                Qbk0=B(end)*qbk(:,end);
                Qb0=sum(Qbk0,1); %[1x1 double]       
            case 4
                %nothing to do
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
    case 2 %interpolate here
        switch input.bcm.type
            case 1
                Qbk0=NaN(nf,1);
                for kf=1:nf
                    Qbk0(kf,1)=interp1(input.bcm.timeQbk0,input.bcm.Qbk0(:,kf),time_l,'linear'); 
                end
                Qb0=sum(Qbk0,1); %total load [m^3/s]; [1x1 double] 
            case 2
                Qbk0=B(end)*qbk(:,end);
                Qb0=sum(Qbk0,1); %[1x1 double]   
            case 4
                %nothing to do
            otherwise
                error('Kapot! check input.bcm.type')
        end %input.bcm.type
end %bc_interp_type

%% update

%total load
Qb=B.*sum(qbk,1); %[1,nx] double
etab_new=NaN(1,nx);                
switch input.mor.bedupdate
    case 0
        etab_new=etab;
    case 1
        switch input.mdv.flowtype
            case {0,1,6}
                if input.bcm.type==4
                    etab_new(1,1)=etab(1,1);
                else
                    etab_new(1,1)      = etab(1,1)      - MorFac * dt /cb /beta(1,1     ) * ((UpwFac * ((Qb(1)     -Qb0       ) /(dx/2)) + (1-UpwFac) * ((Qb(2)   -Qb(1)     ) /(dx/2))) /B(2   ));
                end
                etab_new(1,2:nx-1) = etab(1,2:nx-1) - MorFac * dt./cb./beta(1,2:nx-1).* ((UpwFac * ((Qb(2:nx-1)-Qb(1:nx-2))./(dx  )) + (1-UpwFac) * ((Qb(3:nx)-Qb(2:nx-1))./(dx  )))./B(3:nx));
                etab_new(1,nx)     = etab(1,nx)     - MorFac * dt /cb /beta(1,nx    ) * (           (Qb(nx)    -Qb(nx-1)  ) /(dx  ))/B(end);  
            case {2,3,4}
                UpwFac = 1-(Qb<0); %sets the UpwFac to 1 if flow comes from left, and to 0 if flow comes from right [1,nx] double
                if input.bcm.type==4
                    etab_new(1,1)=etab(1,1);
                else
                    etab_new(1,1) = etab(1,1) - MorFac * dt./cb/beta(1,1).* ((UpwFac(1) * ((Qb(1)-Qb0)./(dx/2)) + (1-UpwFac(1)) * ((Qb(2)-Qb(1))./(dx/2)))./B(1));
                end
                %!ATTENTION! there seems to be an inconsistency between the
                %case above and this one regarding the width in the last
                %fraction. Above it is B(3:nx) and below it is B(2:end-1)
                etab_new(1,2:nx-1) = etab(1,2:nx-1) - MorFac * dt./cb./beta(1,2:nx-1).* (UpwFac(2:nx-1).* ((Qb(2:nx-1)-Qb(1:nx-2))./(dx)) + (1-UpwFac(2:nx-1)).* ((Qb(3:nx)-Qb(2:nx-1))./(dx)))./B(2:end-1);  
                if Qb(nx)>0              
                    etab_new(1,nx) = etab(1,nx) - MorFac * dt/cb/beta(1,nx) * ((Qb(nx)-Qb(nx-1))/(dx))/B(end);
                else
                    etab_new(1,nx) = etab(1,nx);
                end
                          
            otherwise
                error('Supposedly you do not end up here');
        end
    otherwise
       error(':( I thought you wanted to use Exner... :(')
        
end


%% ENTRAINMENT DEPOSITION FORM
else
    
switch input.mor.bedupdate
    case 0
        etab_new=etab;
    case 1
        D=sum(Dk,1); %[(1)x(nx)]
        E=sum(Ek,1); %[(1)x(nx)]
        etab_new=etab+MorFac*dt/cb*(D-E); %[(1)x(nx)]
    otherwise
       error(':( I thought you wanted to use Exner... :(')
end %input.mor.bedupdate

end %input.mor.particle_activity

end %function