function diffusion_demo
%DIFFUSION_DEMO Demonstration function for diffusion in bed module                         
%-------------------------------------------------------------------------------
%  $Id: diffusion_demo.m 8431 2013-04-11 12:55:29Z boer_aj $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/02_diffusion_demo/diffusion_demo.m $
%-------------------------------------------------------------------------------
%
% Obtain bedcomposition version
% The bedcomposition_module.dll is automatically loaded on the first bedcomposition call
%
close all
addpath('..')
addpath('../matlab')
%
[id,url,prec] = bedcomposition.version;
fprintf('BEDCOMPOSITION MODULE\nID        = %s\nURL       = %s\nPRECISION = %i\n\n',id,url,prec)
if prec~=8
   error('Matlab interface requires bedcomposition module to be compiled in double precision')
end
% FORTRAN
%     use precision
%     use bedcomposition_module
%     use message_module
%     !
%     implicit none
%     !
%     include 'sedparams.inc'
%     !
%     ! Variables bed composition module
%     !  
%     type (bedcomp_data)             , pointer :: morlyr         ! bed composition data
%     type (message_stack)            , pointer :: messages       ! message stack
%     integer                         , pointer :: nmlb           ! first cell number
%     integer                         , pointer :: nmub           ! lastcell number
%     integer                         , pointer :: idiffusion     ! switch for diffusion between layers
%     integer                         , pointer :: iunderlyr      ! Underlayer mechanism
%     integer                         , pointer :: ndiff          ! number of diffusion coefficients in vertical direction
%     integer                         , pointer :: neulyr         ! number of eulerian underlayers
%     integer                         , pointer :: nfrac          ! number of sediment fractions 
%     integer                         , pointer :: nlalyr         ! number of lagrangian underlayers
%     integer                         , pointer :: nlyr           ! total number of morphological layers (transport layer + nlalyr + neulyr + base layer)
%     integer                         , pointer :: updbaselyr     ! switch for computing composition of base layer
%     real(fp)                        , pointer :: theulyr        ! thickness eulerian layers [m]
%     real(fp)                        , pointer :: thlalyr        ! thickness lagrangian layers [m]
%     real(fp)    , dimension(:)      , pointer :: thtrlyr        ! thickness of transport layer [m]
%     real(fp)    , dimension(:)      , pointer :: zdiff          ! depth below bed level for which diffusion coefficients are defined [m]
%     real(fp)    , dimension(:,:)    , pointer :: kdiff          ! diffusion coefficients for mixing between layers [m2/s]
%     real(fp)    , dimension(:,:)    , pointer :: svfrac         ! 1 - porosity coefficient [-]
%     real(fp)    , dimension(:,:)    , pointer :: thlyr          ! thickness of morphological layers [m]
%     real(fp)    , dimension(:,:,:)  , pointer :: msed           ! composition of morphological layers: mass of sediment fractions [kg/m2]
% FORTRAN
%%
% Create a bedcomposition object
%
% FORTRAN
%     allocate (morlyr)
%     allocate (messages)
%     call initstack(messages)
% FORTRAN
%
Obj = bedcomposition;
%%
% Set various properties
%
% FORTRAN
%     message = 'initializing logical and scalar values'
%     call addmessage(messages, message)
%     if (istat == 0) istat = bedcomp_getpointer_logical(morlyr, 'exchange_layer'                 , exchlyr)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'flufflayer_model_type'          , flufflyr)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'diffusion_model_type'           , idiffusion)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'porosity_model_type'            , iporosity)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'bed_layering_type'              , iunderlyr)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'number_of_fractions'            , nfrac)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'first_column_number'            , nmlb)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'last_column_number'             , nmub)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'MaxNumShortWarning'             , maxwarn)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'number_of_diffusion_values'     , ndiff)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'number_of_eulerian_layers'      , neulyr)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'number_of_lagrangian_layers'    , nlalyr)
%     if (istat == 0) istat = bedcomp_getpointer_integer(morlyr, 'base_layer_updating_type'       , updbaselyr)
%     if (istat == 0) istat = bedcomp_getpointer_realfp (morlyr, 'MinMassShortWarning'            , minmass)
%     if (istat == 0) istat = bedcomp_getpointer_realfp (morlyr, 'thickness_of_eulerian_layers'   , theulyr)
%     if (istat == 0) istat = bedcomp_getpointer_realfp (morlyr, 'thickness_of_lagrangian_layers' , thlalyr)
%     if (istat /= 0) call adderror(messages, message)
%     !
%     nmlb    = 1                 ! first cell number
%     nmub    = 1                 ! last cell number
%     !
%     nfrac       = 2             ! number of sediment fractions 
%     iunderlyr   = 2             ! Underlayer mechanism (default = 1)
%     exchlyr     = .false.       ! Flag for exchange layer functionality (not implemented)
%     neulyr      = 0             ! maximum number of eulerian underlayers
%     nlalyr      = 0             ! maximum number of lagrangian underlayers
%     updbaselyr  = 1             ! switch for computing composition of base layer 
%                                 !  1: base layer is an independent layer (default)
%                                 !  2: base layer composition is kept fixed
%                                 !  3: base layer composition is set equal to the
%                                 !     composition of layer above it
%                                 !  4: base layer composition and thickness constant
%     maxwarn     = 100           ! maximum number of sediment shortage warnings remaining (default = 100)
%     minmass     = 0.0_fp        ! minimum erosion thickness for a sediment shortage warning [kg] (default = 0.0)
%     idiffusion  = 0             ! switch for diffusion between layers
%                                 !  0: no diffusion (default)
%                                 !  1: diffusion based on mass fractions
%                                 !  2: diffusion based on volume fractions
%     ndiff       = 2             !  number of diffusion coefficients in vertical direction (default = 0)
%     flufflyr    = 0             ! switch for fluff layer concept
%                                 !  0: no fluff layer (default)
%                                 !  1: all mud to fluff layer, burial to bed layers
%                                 !  2: part mud to fluff layer, other part to bed layers (no burial)
%     iporosity   = 0             ! switch for porosity (simulate porosity if iporosity > 0)
%                                 !  0: porosity included in densities, set porosity to 0 (default)
%                                 !  1: ...
% FORTRAN
%
Obj.number_of_columns           = 1;    % number of cells
Obj.number_of_fractions         = 2;    % number of sediment fractions
Obj.bed_layering_type           = 2;    % Underlayer mechanism (1: one well mixed layer, 2: multiple layers) 
Obj.base_layer_updating_type    = 1;    % switch for computing composition of base layer (see above)
Obj.number_of_lagrangian_layers = 0;    % maximum number of lagrangian underlayers
Obj.number_of_eulerian_layers   = 12;   % maximum number of eulerian underlayers
Obj.diffusion_model_type        = 2;    % switch for diffusion between layers (see above)
Obj.number_of_diffusion_values  = 5;    % number of diffusion coefficients in vertical direction (default = 0)                            
Obj.flufflayer_model_type       = 0;    % switch for fluff layer concept (see above)
%%
% Initialize the object (allocate the memory based on preceding numbers)
%
% FORTRAN
%     message = 'allocating bed composition module'
%     call addmessage(messages, message)
%     if (allocmorlyr(morlyr) /=0 ) call adderror(messages, message)
% FORTRAN
%        
Obj.initialize
%%
% Set thickness of the layers
%
% FORTRAN
%     theulyr     = 0.1_fp        ! thickness eulerian layers [m] (default = 0.0)
%     thlalyr     = 0.2_fp        ! thickness lagrangian layers [m] (default = 0.0)
% FORTRAN
%
Obj.thickness_of_transport_layer    = 0.2;  % thickness of transport layer [m]
Obj.thickness_of_lagrangian_layers  = 0.2;  % max thickness Langrangian underlayers [m]
Obj.thickness_of_eulerian_layers    = 0.4;  % max thickness Eulerian underlayers [m]
%%
% Set the diffusion properties 
%
% FORTRAN
%     if (idiffusion>0) then
%         message = 'initializing diffusion'
%         call addmessage(messages, message)
%         if (istat == 0) istat = bedcomp_getpointer_realfp(morlyr, 'diffusion_coefficients'  , kdiff)
%         if (istat == 0) istat = bedcomp_getpointer_realfp(morlyr, 'diffusion_levels'        , zdiff)
%         if (istat /= 0) call adderror(messages, message)
%         !
%         do i = 1, ndiff
%             zdiff(i) = i*0.1_fp;        ! depth below bed level for which diffusion coefficients are defined [m]
%             do nm = nmlb, nmub
%                 kdiff(i,nm) = 0.5_fp    ! diffusion coefficients for mixing between layers [m2/s]
%             enddo
%         enddo
%         !
%     endif
% FORTRAN
%
if Obj.diffusion_model_type>0
    zdiff = [0.5 1.0 1.5 2.0 2.5];                                              % depth below bedlevel for diffusion coefficients [m]
    kdiff = zeros(Obj.number_of_diffusion_values,Obj.number_of_columns)+0.02;   % diffusion coefficients for mixing between layers [m2/s]
%     kdiff=[0.11;0.22;0.33;0.44;0.55];
    kdiff(5) = 0;
    Obj.diffusion_levels        = zdiff;
    Obj.diffusion_coefficients  = kdiff;
    Obj.diffusion_coefficients
end
%%
% Display current settings
%
Obj
%%
% Set the properties of the sediment fracions
%
% FORTRAN
%     allocate (cdryb     (nfrac))
%     allocate (logsedsig (nfrac))
%     allocate (rhosol    (nfrac))
%     allocate (d50       (nfrac))
%     allocate (sedtyp    (nfrac))
%
%     sedtyp(1)   = SEDTYP_NONCOHESIVE_SUSPENDED  ! non-cohesive suspended sediment (sand)
%     sedtyp(2)   = SEDTYP_COHESIVE               ! cohesive sediment (mud)
%     cdryb       = 1650.0_fp                     ! dry bed density [kg/m3]
%     rhosol      = 2650.0_fp                     ! specific density [kg/m3]
%     sedd50      = 0.001_fp                      ! 50% diameter sediment fraction [m]
%     logsedsig   = log(1.34_fp)                  ! standard deviation on log scale (log of geometric std.) [-]
%
%    call setbedfracprop(morlyr, sedtyp, sedd50, logsedsig, cdryb)
%
% FORTRAN
%
sedtyp      = [1 2];%sediment type: sand (1) or mud (2)
d50         = [0.2 0.05]*1e-3;%median grain size [m]
logsigma    = [1.34 1.34];%parameter in computation porosity, default is 1.34 [-]
rho         = [1600 1600];%dry bed density [kg/m3]
rhosol      = [2650 2650];%bed density [kg/m3]
%
Obj.fractions(sedtyp,d50,logsigma,rho)
%%
% FORTRAN
%     tstart  = 0.0_fp          ! start time of computation [s] 
%     tend    = 400.0_fp        ! end time of computation [s] 
%     dt      = 1.0_fp          ! time step [s]    
% FORTRAN
%
tstart = 0;
tend   = 200;
dt     = 1.0;
nstep  = (tend-tstart)/dt;

Obj.porosity
%%
% Deposit sediment in 100 steps; sediment composition varies slowly
%
% FORTRAN
%     allocate (mass    (nfrac,nmlb:nmub))
%     allocate (frac    (nfrac,nmlb:nmub))
%     allocate (z       (nmlb:nmub))
%     allocate (dz      (nmlb:nmub))
%
%     z      = 0.0_fp        ! bed level [m]
% FORTRAN
z    = zeros(Obj.number_of_layers+1,nstep+1);
frac = zeros(Obj.number_of_layers,nstep+1);
mscale = 80;
for i=1:nstep/2
    %
    % Determine sediment to deposit
    %
    mass(:,i) = repmat([mscale*(i-1)/(nstep/2-1);mscale*(nstep/2-i)/(nstep/2-1)],1,Obj.number_of_columns);
    %
    % Deposit sediment and obtain bed level change
    %
    % FORTRAN
    %         message = 'updating bed composition'
    %         if (updmorlyr(morlyr, mass, massfluff, rhosol, dt, morfac, dz, messages) /= 0) call adderror(messages, message)
    % FORTRAN
    %
    dz = Obj.deposit(mass(:,i),dt,rhosol);
    %
    % Determine new bed level
    %
    % FORTRAN
    %   z = z + dz
    % FORTAN
    %
    z(1,i+1) = z(1,i)+dz(1);
    %
    % Obtain layer interfaces and bed composition
    %
    % FORTRAN
    %        if (istat==0) istat = bedcomp_getpointer_integer(morlyr, 'number_of_layers'     , nlyr)
    %        if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'layer_mass'           , msed)
    %        if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'layer_thickness'      , thlyr)
    %        if (istat==0) istat = bedcomp_getpointer_realfp (morlyr, 'solid_volume_fraction', svfrac)
    %
    %        do nm = nmlb:nmub
    %           do k = 1,nlyr
    %              do l = 1,nfrac
    %                 if (thlyr(k,nm)>0.0_fp) then
    %                    frac(l,k,nm) = msed(l, k, nm)/(rhosol(l)*svfrac(k, nm)*thlyr(k, nm))
    %                 else
    %                    frac(l,k,nm) = 0.0_fp
    %                 endif
    %              enddo
    %           enddo
    %        enddo
    % FORTRAN
    %
    thick = Obj.layer_thickness(:,1);
    for j = 1:Obj.number_of_fractions
        frac(:,i+1,j) = Obj.mass_fraction(j,:,1)';
    end
%     frac(:,i+1,1) = Obj.volume_fraction(1,:,1)';
    z(2:end,i+1) = z(1,i+1)-cumsum(thick);
end
for i=nstep/2+1:nstep
    %
    % Determine sediment to deposit
    %
    mass(:,i) = zeros(Obj.number_of_fractions, Obj.number_of_columns);
    %
    % Deposit sediment and obtain bed level change
    %
    % FORTRAN
    %         message = 'updating bed composition'
    %         if (updmorlyr(morlyr, mass, massfluff, rhosol, dt, morfac, dz, messages) /= 0) call adderror(messages, message)
    % FORTRAN
    %
    dz = Obj.deposit(mass(:,i),dt,rhosol);
    %
    % Determine new bed level
    %
    % FORTRAN
    %   z = z + dz
    % FORTAN
    %
    z(1,i+1) = z(1,i)+dz(1);
    %
    % Obtain layer interfaces and bed composition
    %
    thick = Obj.layer_thickness(:,1);
    for j = 1:Obj.number_of_fractions
        frac(:,i+1,j) = Obj.mass_fraction(j,:,1)';
    end
    %frac(:,i+1,1) = Obj.volume_fraction(1,:,1)';
    z(2:end,i+1) = z(1,i+1)-cumsum(thick);
end
%%

%net sediment fluxes into bed
figure
plot(mass(1,:),'b-','LineWidth',1.5)
hold on
grid on
plot(mass(2,:),'r-','LineWidth',1.5)
plot(sum(mass(:,:)),'k-','LineWidth',1.5)
xlabel('time [s]')
ylabel('net sediment flux [kg/m^2/s]')
legend('sedfrac 1','sedfrac 2','total',1)
ylim([0 100])
print(gcf,'-dpng','-r300',['sed_flux'])

%total sediment mass
figure
plot(dt*cumsum(mass(1,:)),'b--','LineWidth',1.5)
hold on
grid on
plot(dt*cumsum(mass(2,:)),'b:','LineWidth',1.5)
plot(dt*cumsum(mass(1,:)+mass(2,:)),'b-','LineWidth',1.5)
plot([0:1:nstep],-sum(diff(z).*frac(:,:,1)*rho(1)),'r--','LineWidth',1.5)
plot([0:1:nstep],-sum(diff(z).*frac(:,:,2)*rho(2)),'r:','LineWidth',1.5)
plot([0:1:nstep],(-sum(diff(z).*frac(:,:,1)*rho(1))-sum(diff(z).*frac(:,:,2)*rho(2))),'r-','LineWidth',1.5,'LineWidth',1.5)
xlabel('time [s]')
ylabel('mass [kg/m^2]')
dum = get(gca,'ylim');
set(gca,'ylim',[0 dum(2)])
xlim([0 nstep])
title('total sediment mass')
legend('supplied sedfrac1 (cum)','supplied sedfrac2 (cum)','total supplied mass (cum)','sedfrac1 in bed','sedfrac2 in bed','total in bed',4)
print(gcf,'-dpng','-r300',['mass_total'])

%mass fraction different layers
% frac(frac==0)=NaN;
for j = 1:Obj.number_of_fractions
    figure
    columnpatch(0:nstep+1,z,frac(:,:,j))
    set(gca,'clim',[0 1])
    colorbar
    xlim([0 nstep])
    ylim([0 5]);
    ylabel('bed level [m]')
    xlabel('time [s]')
    title(['Fraction mass of sediment ',num2str(j),' [-]'])
    print(gcf,'-dpng','-r300',['massfraction_',num2str(j)])
end

%sediment mass top layer
figure
plot([0:1:nstep],-diff(z(1:2,:)).*frac(1,:,1)*rho(1),'b-','LineWidth',1.5)
hold on
grid on
plot([0:1:nstep],-diff(z(1:2,:)).*frac(1,:,2)*rho(2),'r-','LineWidth',1.5)
plot([0:1:nstep],-diff(z(1:2,:)).*(frac(1,:,1)*rho(1)+frac(1,:,2)*rho(2)),'k-','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass [kg/m^2]')
legend('sedfrac1','sedfrac2','total',4)
title('sediment mass top layer')
xlim([0 nstep])
print(gcf,'-dpng','-r300',['mass_toplayer'])

%mass fractions transport layer
figure
plot([0:1:200],frac(1,:,1)*rho(1)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'b-','LineWidth',1.5)
hold on
grid on
plot([0:1:200],frac(1,:,2)*rho(2)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'r-','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass fraction [-]')
legend('sedfrac1 top layer','sedfrac1 top layer',1)
xlim([0 200])
ylim([0 1])
print(gcf,'-dpng','-r300',['massfractions_trlyr'])



%mass fractions sediment flux and top layer
figure
plot(mass(1,:)./sum(mass),'b-','LineWidth',1.5)
hold on
grid on
plot(mass(2,:)./sum(mass),'r-','LineWidth',1.5)
plot([0:1:nstep],frac(1,:,1)*rho(1)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'b--','LineWidth',1.5)
plot([0:1:nstep],frac(1,:,2)*rho(2)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'r--','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass fraction [-]')
legend('supplied sedfrac1','supplied sedfrac2','sedfrac1 top layer','sedfrac1 top layer',1)
xlim([0 nstep])
ylim([0 1])
print(gcf,'-dpng','-r300',['massfractions_flux_toplayer'])

%sediment mass in underlayers
figure
plot([0:1:nstep],-sum(diff(z(2:end,:)).*frac(2:end,:,1)*rho(1)),'b-','LineWidth',1.5)
hold on
grid on
plot([0:1:nstep],-sum(diff(z(2:end,:)).*frac(2:end,:,2)*rho(2)),'r-','LineWidth',1.5)
plot([0:1:nstep],-sum(diff(z(2:end,:)).*(frac(2:end,:,1)*rho(1) + frac(2:end,:,2)*rho(2))),'k-','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass [kg/m^2]')
legend('sedfrac1','sedfrac2','total',4)
title('sediment mass under layers')
xlim([0 nstep])
print(gcf,'-dpng','-r300',['mass_underlayers'])


% if Obj.number_of_lagrangian_layers == 1
%     %sediment mass 1st Lagrangian layer
%     figure
%     plot([0:1:nstep],-diff(z(2:3,:)).*frac(2,:,1)*rho(1),'b-','LineWidth',1.5)
%     hold on
%     grid on
%     plot([0:1:nstep],-diff(z(2:3,:)).*frac(2,:,2)*rho(2),'r-','LineWidth',1.5)
%     plot([0:1:nstep],-diff(z(2:3,:)).*(frac(2,:,1)*rho(1) + frac(2,:,2)*rho(2)),'k-','LineWidth',1.5)
%     xlabel('time [s]')
%     ylabel('mass [kg/m^2]')
%     legend('sedfrac1','sedfrac2','total',1)
%     title('sediment mass 1st Langrangian layer')
%     xlim([0 nstep])
%     print(gcf,'-dpng','-r300',['mass_lalayer'])    
% 
%     %mass fractions in transport and 1st lagrangian layer
%     figure
%     plot([0:1:nstep],frac(1,:,1)*rho(1)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'b-','LineWidth',1.5)
%     hold on
%     grid on
%     plot([0:1:nstep],frac(1,:,2)*rho(1)./(frac(1,:,1)*rho(1) + frac(1,:,2)*rho(2)),'r-','LineWidth',1.5)
%     plot([0:1:nstep],frac(2,:,1)*rho(1)./(frac(2,:,1)*rho(1) + frac(2,:,2)*rho(2)),'b--','LineWidth',1.5)
%     plot([0:1:nstep],frac(2,:,2)*rho(1)./(frac(2,:,1)*rho(1) + frac(2,:,2)*rho(2)),'r--','LineWidth',1.5)    
%     xlabel('time [s]')
%     ylabel('mass fraction [-]')
%     legend('sedfrac1 top layer','sedfrac2 top layer','sedfrac1 Lagrangian layer','sedfrac2 Lagrangian layer',2)
%     xlim([0 nstep])
%     print(gcf,'-dpng','-r300',['mass_toplayer_lalayer'])    
% end
% 

% 
% 
% %%
% % Delete the bedcomposition object and release fortran memory
% %
% % FORTRAN 
% %     message = 'cleaning up variables'
% %     call addmessage(messages, message)
% %     if (clrmorlyr(morlyr) /= 0) call adderror(messages, message)
% %     !
% %     !   Write messages to terminal
% %     !
% %     call writemessages(messages,6)
% %     !
% %     deallocate (morlyr)
% %     deallocate (messages)
% %     deallocate (cdryb)
% %     deallocate (logsedsig)
% %     deallocate (rhosol)
% %     deallocate (d50)
% %     deallocate (d90)
% %     !
% %     deallocate (mass)
% %     deallocate (z)
% %     deallocate (dz)
% FORTRAN


Obj.messages

clear Obj
%
% Unload the fortran dll from MATLAB memory
%
bedcomposition.unload
