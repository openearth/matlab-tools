function sandmud_demo
%SANDMUD_DEMO Demonstration function for sand-mud interaction                                
%-------------------------------------------------------------------------------
%  $Id: sandmud_demo.m 7697 2012-11-16 14:10:17Z boer_aj $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/04_sandmud_demo/sandmud_demo.m $
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
%     %
%     implicit none
%     %
%     include 'sedparams.inc'
%     %
%     % Variables bed composition module
%     %  
%     type (bedcomp_data)             , pointer :: morlyr         % bed composition data
%     type (message_stack)            , pointer :: messages       % message stack
%     integer                         , pointer :: nmlb           % first cell number
%     integer                         , pointer :: nmub           % lastcell number
%     integer                         , pointer :: idiffusion     % switch for diffusion between layers
%     integer                         , pointer :: iunderlyr      % Underlayer mechanism
%     integer                         , pointer :: ndiff          % number of diffusion coefficients in vertical direction
%     integer                         , pointer :: neulyr         % number of eulerian underlayers
%     integer                         , pointer :: nfrac          % number of sediment fractions 
%     integer                         , pointer :: nlalyr         % number of lagrangian underlayers
%     integer                         , pointer :: nlyr           % total number of morphological layers (transport layer + nlalyr + neulyr + base layer)
%     integer                         , pointer :: updbaselyr     % switch for computing composition of base layer
%     real(fp)                        , pointer :: theulyr        % thickness eulerian layers [m]
%     real(fp)                        , pointer :: thlalyr        % thickness lagrangian layers [m]
%     real(fp)    , dimension(:)      , pointer :: thtrlyr        % thickness of transport layer [m]
%     real(fp)    , dimension(:)      , pointer :: zdiff          % depth below bed level for which diffusion coefficients are defined [m]
%     real(fp)    , dimension(:,:)    , pointer :: kdiff          % diffusion coefficients for mixing between layers [m2/s]
%     real(fp)    , dimension(:,:)    , pointer :: svfrac         % 1 - porosity coefficient [-]
%     real(fp)    , dimension(:,:)    , pointer :: thlyr          % thickness of morphological layers [m]
%     real(fp)    , dimension(:,:,:)  , pointer :: msed           % composition of morphological layers: mass of sediment fractions [kg/m2]
% FORTRAN
%%
% Constants
g       = 9.81;   % gravitational acceleration [m/s2]
rhow    = 1000.0; % density of water [kg/m3]
filesed = 'initsed_sandmud';
%
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
%     %
%     nmlb    = 1                 % first cell number
%     nmub    = 1                 % last cell number
%     %
%     nfrac       = 2             % number of sediment fractions 
%     iunderlyr   = 2             % Underlayer mechanism (default = 1)
%     exchlyr     = .false.       % Flag for exchange layer functionality (not implemented)
%     neulyr      = 0             % number of eulerian underlayers
%     nlalyr      = 0             % number of lagrangian underlayers
%     updbaselyr  = 1             % switch for computing composition of base layer 
%                                 %  1: base layer is an independent layer (default)
%                                 %  2: base layer composition is kept fixed
%                                 %  3: base layer composition is set equal to the
%                                 %     composition of layer above it
%                                 %  4: base layer composition and thickness constant
%     maxwarn     = 100           % maximum number of sediment shortage warnings remaining (default = 100)
%     minmass     = 0.0        % minimum erosion thickness for a sediment shortage warning [kg] (default = 0.0)
%     idiffusion  = 0             % switch for diffusion between layers
%                                 %  0: no diffusion (default)
%                                 %  1: diffusion based on mass fractions
%                                 %  2: diffusion based on volume fractions
%     ndiff       = 2             %  number of diffusion coefficients in vertical direction (default = 0)
%     flufflyr    = 0             % switch for fluff layer concept
%                                 %  0: no fluff layer (default)
%                                 %  1: all mud to fluff layer, burial to bed layers
%                                 %  2: part mud to fluff layer, other part to bed layers (no burial)
%     iporosity   = 0             % switch for porosity (simulate porosity if iporosity > 0)
%                                 %  0: porosity included in densities, set porosity to 0 (default)
%                                 %  1: ...
% FORTRAN
%
Obj.number_of_columns           = 1;
Obj.number_of_fractions         = 2;
Obj.bed_layering_type           = 2; 
Obj.base_layer_updating_type    = 1;
Obj.number_of_lagrangian_layers = 0;
Obj.number_of_eulerian_layers   = 3;
Obj.diffusion_model_type        = 0;
Obj.number_of_diffusion_values  = 5;
Obj.flufflayer_model_type       = 0;
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
%     theulyr     = 0.1        % thickness eulerian layers [m] (default = 0.0)
%     thlalyr     = 0.2        % thickness lagrangian layers [m] (default = 0.0)
% FORTRAN
%
Obj.thickness_of_lagrangian_layers  = 0.01;
Obj.thickness_of_eulerian_layers    = 0.01;
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
%         %
%         do i = 1, ndiff
%             zdiff(i) = i*0.1;        % depth below bed level for which diffusion coefficients are defined [m]
%             do nm = nmlb, nmub
%                 kdiff(i,nm) = 0.5    % diffusion coefficients for mixing between layers [m2/s]
%             enddo
%         enddo
%         %
%     endif
% FORTRAN
%
if Obj.diffusion_model_type>0
    zdiff = [0.1 0.2 0.3 0.4 0.5];
    kdiff = zeros(Obj.number_of_diffusion_values,Obj.number_of_columns)+0.1;
    Obj.diffusion_levels        = zdiff;
    Obj.diffusion_coefficients  = kdiff;
end
%%
%
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
%     allocate (d90       (nfrac))
%     allocate (sedtyp    (nfrac))
%
%     sedtyp(1)   = SEDTYP_NONCOHESIVE_SUSPENDED  % non-cohesive suspended sediment (sand)
%     sedtyp(2)   = SEDTYP_COHESIVE               % cohesive sediment (mud)
%     cdryb       = 1650.0                     % dry bed density [kg/m3]
%     rhosol      = 2650.0                     % specific density [kg/m3]
%     d50         = 0.0001                     % 50% diameter sediment fraction [m]
%     d90         = 0.0002                     % 90% diameter sediment fraction [m]
%     logsedsig   = log(1.34)                  % standard deviation on log scale (log of geometric std.) [-]
%
%    call setbedfracprop(morlyr, sedtyp, sedd50, logsedsig, cdryb)
%
% FORTRAN
%
sedtyp      = [1 2];
d50         = [0.2 0.05]*1e-3;
d90         = 1.5*d50;
logsigma    = [1.34 1.34];
rho         = [1600 1600];
rhosol      = [2650 2650];
%
Obj.fractions(sedtyp,d50,logsigma,rho)
%%
% 
%   Initial bed composition
% 
% FORTRAN
%     if (iunderlyr==2) then
%         thtrlyr = 0.1        % thickness of transport layer [m]
%         thlyr   = 0.1        % thickness of morphological layers [m]
%         svfrac  = 1.0        % 1 - porosity coefficient [-]
%         if (flufflyr>0) then
%             mfluff  = 0.0        % composition of fluff layer: mass of mud fractions [kg/m2]
%         endif
%         msed = 0.0           % composition of morphological layers: mass of sediment fractions [kg/m2]
%         do l = 1, nfrac
%             msed(l,:,:) = thlyr*cdryb(l)/nfrac 
%         enddo
%     endif
% FORTRAN

if (Obj.bed_layering_type==2)
    thlyr = zeros(Obj.number_of_layers,Obj.number_of_columns)+0.01;
    svfrac = zeros(Obj.number_of_layers,Obj.number_of_columns)+ 1.0;
    Obj.thickness_of_transport_layer = 0.01;     % thickness of transport layer [m]
    Obj.init_layer_thickness(thlyr);            % thickness of morphological layers [m] 
    Obj.init_porosity(svfrac);                  % 1 - porosity coefficient [-]
    if (Obj.flufflayer_model_type>0)
        mfluff = zeros(Obj.number_of_fractions,Obj.number_of_columns);
        Obj.init_fluff_mass(mfluff);        % composition of fluff layer: mass of mud fractions [kg/m2]
    end
    msed = zeros(Obj.number_of_fractions,Obj.number_of_layers,Obj.number_of_columns);           % composition of morphological layers: mass of sediment fractions [kg/m2]
    for l = 1: Obj.number_of_fractions
        msed(l,:,:) = Obj.layer_thickness*rho(l)/Obj.number_of_fractions;
    end
    Obj.init_layer_mass(msed);
end


%%
%   Initial flow conditions
%
% FORTRAN
%     allocate (chezy     (nmlb:nmub))
%     allocate (h0        (nmlb:nmub))
%     allocate (h1        (nmlb:nmub))
%     allocate (umod      (nmlb:nmub))
%     allocate (taub      (nmlb:nmub))
%     allocate (r0        (nfrac,nmlb:nmub))
%     allocate (r1        (nfrac,nmlb:nmub))
%     allocate (rn        (nfrac,nmlb:nmub))
%     allocate (ws        (nfrac,nmlb:nmub))
% 
%     chezy   = 60.0       % Chezy coefficient for hydraulic roughness [m(1/2)/s]
%     h1      = 3.0        % water depth [m]
%     umod    = 0.0        % depth averaged flow magnitude [m/s]
%     ws      = 0.01       % Settling velocity [m/s]
%     r1(1,:) = 1.0e-3     % sediment concentration [kg/m3]
%     r1(2,:) = 1.0e-3     % sediment concentration [kg/m3]
%     z       = 0.0        % bed level [m]
%
%     do nm = nmlb, nmub
%         taub(nm) = umod(nm)*umod(nm)*rhow*g/(chezy(nm)*chezy(nm)) % bottom shear stress [N/m2]
%     enddo
% FORTRAN
%
for nm=1:Obj.number_of_columns
    chezy(nm)    = 50.0;       % Chezy coefficient for hydraulic roughness [m(1/2)/s]
    h1(nm)       = 3.0;        % water depth [m]
    umod(nm)     = 0.0;        % depth averaged flow magnitude [m/s]
    ws(1,nm)     = 0.02;       % Settling velocity [m/s]
    ws(2,nm)     = 0.001;       % Settling velocity [m/s]
    r1(1,nm)     = 1.0e-2;     % sediment concentration [kg/m3]
    r1(2,nm)     = 1.0e-2;     % sediment concentration [kg/m3]
end
%
for nm = 1: Obj.number_of_columns
    taub(nm) = umod(nm)*umod(nm)*rhow*g/(chezy(nm)*chezy(nm)); % bottom shear stress [N/m2]
end
%
% FORTRAN
%     tstart  = 0.0          % start time of computation [s] 
%     tend    = 5000.0       % end time of computation [s] 
%     dt      = 100.0        % time step [s]    
%     morfac  = 1.0          % morphological scale factor [-]
% FORTRAN
%
tstart = 0;
tend   = 100;
dt     = 0.5;
morfac = 1;
nstep  = (tend-tstart)/dt;
%%
% Deposit sediment in 100 steps; sediment composition varies slowly
%
% FORTRAN
%     allocate (mass    (nfrac,nmlb:nmub))
%     allocate (frac    (nfrac,nmlb:nmub))
%     allocate (z       (nmlb:nmub))
%     allocate (dz      (nmlb:nmub))
%
%     z      = 0.0        % bed level [m]
% FORTRAN
z    = zeros(Obj.number_of_layers+1,nstep+1); % bed level [m]
frac = zeros(Obj.number_of_layers,nstep+1,Obj.number_of_fractions);
thick = Obj.layer_thickness(:,1);
frac(:,1,:) = Obj.mass_fraction(:,:,1)';
z(2:end,1) = z(1,1)-cumsum(thick);

if (Obj.flufflayer_model_type>0)
    mf(:,1)=Obj.fluff_mass(:,1);
end
r(:,1) = r1(:,1);
tau(1) = taub(1);
for i=1:nstep
    %
    r0 = r1;
    h0 = h1;
    %
    %   Computing erosion fluxes
    %
    % FORTRAN
    %         call erosed(morlyr    , nmlb      , nmub  , dt    , morfac          , & 
    %                   & ws        , umod      , h0    , chezy , taub  , r0      , &
    %                   & nfrac     , rhosol    , sedd50, sedd90, sedtyp          , &
    %                   & sink      , sinkf     , sour  , sourf , messages   )
    % FORTRAN
    %
    [sink, sinkf, sour, sourf] = erosed(Obj    , filesed,  1      , Obj.number_of_columns  ,  ...
                                         ws        , umod      , h1    , chezy , taub  , r1    , ...
                                        Obj.number_of_fractions     , rhosol    , d50, d90, sedtyp );
    %
    %   Compute flow
    %
    h1      = h0;
    umod    = abs(1.0*sin(2*pi*i/nstep));
    %
    for nm = 1: Obj.number_of_columns
        taub(nm) = umod(nm)*umod(nm)*rhow*g/(chezy(nm)*chezy(nm)); % bottom shear stress [N/m2]
    end      
    tau(i+1)=taub(1);
    for l = 1: Obj.number_of_fractions
        for nm = 1 : Obj.number_of_columns
            rn(l,nm) = r0(l,nm); % explicit
%             r1(l,nm) = r0(l,nm) + dt*(sour(l,nm) + sourf(l,nm))/h0(nm) - dt*(sink(l,nm) + sinkf(l,nm))*rn(l,nm)/h1(nm);
        end
    end
    %
    %   Compute change in sediment composition of top layer and fluff layer
    %
    mass       = zeros(Obj.number_of_fractions,Obj.number_of_columns);    % change in sediment composition of top layer, [kg/m2]
    massfluff  = zeros(Obj.number_of_fractions,Obj.number_of_columns);   % change in sediment composition of fluff layer [kg/m2]
    %
    for l = 1: Obj.number_of_fractions
        for nm = 1 : Obj.number_of_columns
            %
            % Update dbodsd value at nm
            %
%             mass(l, nm) = mass(l, nm) + dt*morfac*( sink(l,nm)*rn(l,nm) - sour(l,nm) );
            %
            % Update dfluff value at nm
            %
            if (Obj.flufflayer_model_type>0)
                massfluff(l, nm) = massfluff(l, nm) + dt*( sinkf(l,nm)*rn(l,nm) - sourf(l,nm) );
            end
        end
    end
    %
    % Deposit sediment and obtain bed level change
    %
    % FORTRAN
    %         message = 'updating bed composition'
    %         if (updmorlyr(morlyr, mass, massfluff, rhosol, dt, morfac, dz, messages) /= 0) call adderror(messages, message)
    % FORTRAN
    %
    dz = Obj.deposit(mass,dt,rhosol,massfluff,morfac);
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
    %                 if (thlyr(k,nm)>0.0) then
    %                    frac(l,k,nm) = msed(l, k, nm)/(rhosol(l)*svfrac(k, nm)*thlyr(k, nm))
    %                 else
    %                    frac(l,k,nm) = 0.0
    %                 endif
    %              enddo
    %           enddo
    %        enddo
    % FORTRAN
    %
    thick = Obj.layer_thickness(:,1);
    frac(:,i+1,:) = Obj.mass_fraction(:,:,1)';
    z(2:end,i+1) = z(1,i+1)-cumsum(thick);
    if (Obj.flufflayer_model_type>0)
        mf(:,i+1)=Obj.fluff_mass(:,1);
    end
    r(:,i+1) = r1(:,1);
    psour(:,i+1) = sour(:,1);
    psink(:,i+1) = sink(:,1).*rn(:,1);
end
%%

%sink and source terms sand fraction
figure
subplot(2,1,1)
plot([0:dt:tend],psour(1,:),'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
plot([0:dt:tend],psink(1,:),'r','LineWidth',1.5)
ylabel('sand flux (kg/m^2/s)')
legend('source','sink')

subplot(2,1,2)
plot([0:dt:tend],tau,'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
xlabel('time (s)')
ylabel('bed shear stress (N/m^2)')
print(gcf,'-dpng','-r300','sand_flux') 

%sink and source terms mud fraction
figure
subplot(2,1,1)
plot([0:dt:tend],psour(2,:),'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
plot([0:dt:tend],psink(2,:),'r','LineWidth',1.5)
ylabel('mud flux (kg/m^2/s)')
legend('source','sink')

subplot(2,1,2)
plot([0:dt:tend],tau,'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
xlabel('time (s)')
ylabel('bed shear stress (N/m^2)')
print(gcf,'-dpng','-r300','mud_flux') 

%erosion velocity
figure
subplot(2,1,1)
plot([0:dt:tend],psour(1,:)./(frac(1,:,1)*rhosol(1)),'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
plot([0:dt:tend],psour(2,:)./(frac(1,:,2)*rhosol(2)),'r','LineWidth',1.5)
ylabel('erosion velocity (m/s)')
legend('sand','mud')

subplot(2,1,2)
plot([0:dt:tend],tau,'LineWidth',1.5)
hold on
grid on
xlim([0 tend])
xlabel('time (s)')
ylabel('bed shear stress (N/m^2)')
print(gcf,'-dpng','-r300','erosion_velocity') 
    

% % Visualize the bed layers over time
% %
% frac(frac==0)=NaN;
% figure
% columnpatch(0:nstep+1,z,frac(:,:,1))
% colorbar
% title('sand')
% figure
% columnpatch(0:nstep+1,z,frac(:,:,2))
% colorbar
% title('mud')
% figure
% plot(tau)
% title('bed shear stress')
% figure
% plot(r(1,:))
% hold on
% plot(r(2,:),'r')
% title('concentration')
%     legend('sand','mud')
% figure
% hold on
% plot(psour(1,:))
% plot(psink(1,:),'r')
% title('sour/sink sand')
%     legend('sour','sink')
% figure
% hold on
% plot(psour(2,:))
% plot(psink(2,:),'r')
% title('sour/sink mud')
%     legend('sour','sink')
%     

%%
% Delete the bedcomposition object and release fortran memory
%
% FORTRAN 
%     message = 'cleaning up variables'
%     call addmessage(messages, message)
%     if (clrmorlyr(morlyr) /= 0) call adderror(messages, message)
%     %
%     %   Write messages to terminal
%     %
%     call writemessages(messages,6)
%     %
%     deallocate (morlyr)
%     deallocate (messages)
%     deallocate (cdryb)
%     deallocate (logsedsig)
%     deallocate (rhosol)
%     deallocate (d50)
%     deallocate (d90)
%     %
%     deallocate (mass)
%     deallocate (z)
%     deallocate (dz)
% FORTRAN
%
clear Obj
%
% Unload the fortran dll from MATLAB memory
%
bedcomposition.unload
