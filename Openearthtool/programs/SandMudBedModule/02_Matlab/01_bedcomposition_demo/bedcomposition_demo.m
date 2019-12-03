function bedcomposition_demo
%BEDCOMPOSITION_DEMO Demonstration function for the bedcomposition module

%
% Obtain bedcomposition version
% The bedcomposition_module.dll is automatically loaded on the first bedcomposition call
% Only tested with MATLAB 7.10.0 (R2010a)
% Need to run p:\delta\wlsettings\wlsettings for plotting 
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
%
% Create a bedcomposition object
%
Obj = bedcomposition;
%
% Set various properties
%
Obj.number_of_columns = 10;%numer of water-bed columns to be considered (by default settings are the same for each one)
Obj.number_of_fractions = 2;
Obj.bed_layering_type = 2;%switch for underlayer concept (keyword IUnderLyr in MOR-file)
                          %1: standard fully mixed concept (doesn't work yet!)
                          %2: graded sediment concept
Obj.base_layer_updating_type = 1;%switch for computing composition of base layer (keyword UpdBaseLyr in MOR-file)
                                 %1: base layer is an independent layer
                                 %2: base layer composition is kept fixed
                                 %3: base layer composition is set equal to the composition of layer above it
                                 %4: base layer composition and thickness constant
Obj.number_of_lagrangian_layers = 0;%max numer of Langrangian underlayers (Keword NLaLyr in MOR-file) 
Obj.number_of_eulerian_layers = 10;%max numer of Eulerian underlayers (Keword NEuLyr in MOR-file) 
Obj.diffusion_model_type = 0;%switch for vertical diffusion (keyword IDiffusion in MOR-file)
                             %0 no diffusion
                             %1 diffusion based on mass fractions
                             %2 diffusion based on volume fractions 
Obj.number_of_diffusion_values = 5;%number of diffusion coefficients in z-direction (keyword Ndiff in MOR-file)                                   
Obj.flufflayer_model_type = 0;%switch for fluff layer concept (keyword Flufflyr in MOR-file)
                              %0: no fluff layer
                              %1: all mud to fluff layer, burial to bed layers
                              %2: part mud to fluff layer, other part to bed layers (no burial)
%
% Initialize the object (allocate the memory based on preceding numbers)
%
Obj.initialize
%
% Set thickness of the layers
%
Obj.thickness_of_transport_layer = 0.1;%thickness transport layer [m] (keyword ThTrlyr in MOR-file)
Obj.thickness_of_lagrangian_layers = 0.1;%max. thickness Langrangian underlayers [m] (keyword ThLaLyr in MOR-file)
Obj.thickness_of_eulerian_layers = 0.3;%max. thickness Eulerian underlayers [m] (keyword ThEuLyr in MOR-file)
%
% Display current settings
%
Obj
%
% % Set the diffusion properties 
% %
% zdiff = [0.1 0.2 0.3 0.4 0.5];%depth below bedlevel for diffusion coefficients [m] (keyword Zdiff in IND-file)
% Obj.diffusion_levels = zdiff;
% kdiff = zeros(Obj.number_of_diffusion_values,Obj.number_of_columns)+1e-1;%diffusion coefficients at levels Zdiff [m2/s] (keyword Kdiff in IND-file)
% Obj.diffusion_coefficients = kdiff;
% 
% %
% % Set the fluff layer properties 
% %
% bf1 = zeros(Obj.number_of_fractions,Obj.number_of_columns) + 2e-4;%burial coefficient 1 (M0) [kg/m2/s] (keyword BurFluff0 in MOR-file, only if Flufflyr=1)                          
% bf2 = zeros(Obj.number_of_fractions,Obj.number_of_columns) + 0.1;%burial coefficient 2 (M1) [1/s] (keyword BurFluff1 in MOR-file, only if Flufflyr=1)                          
% Obj.burial_coeff_1 = bf1;
% Obj.burial_coeff_2 = bf2;
% %note: net sediment flux into fluf layer are not computed in the routine, but imposed
% %instead
%
% Set the properties of the sediment fractions
%
sedtyp = [1 2];%sediment type: sand (1) or mud (2)
d50 = [0.2 0.05]*1e-3;%median grain size [m]
logsigma = [1.34 1.34];%parameter in computation porosity, default is 1.34 [-]
rho = [1600 1600];%dry bed density [kg/m3]]
rhosol = [2650 2650];%bed density [kg/m3]
Obj.fractions(sedtyp,d50,logsigma,rho)
%
dt     = 1;%time step [s] (only relvant for vertical mixing process)
morfac = 1;%morphological upscale factor [-]
%
% Deposit sediment in 100 steps; sediment composition varies slowly
%
z = zeros(Obj.number_of_layers+1,101);
c = zeros(Obj.number_of_layers,101);
max1 = 100;
mscale = 32;
for i=1:max1
    %
    % Determine sediment to deposit
    %
    mass(:,i) = repmat(mscale*[0.25+(i-1)*(0.75-0.25)/(max1-1);0.75+(i-1)*(0.25-0.75)/(max1-1)],1,Obj.number_of_columns);%net sediment flux into transport layer per fraction [kg/m2/s]
    massfluff(:,i) = 0*mass(:,i)*1e-6;%net sediment flux into fluff layer [kg/m2/s]
    %
    % Deposit sediment and obtain bed level change [m]
    %
    dz = Obj.deposit(mass(:,i),dt,rhosol,massfluff(:,i),morfac);
    %
    % Determine new bed level [m]
    %
    z(1,i+1) = z(1,i)+dz(1);
    %
    % Obtain layer interfaces and bed composition
    %
    thick = Obj.layer_thickness(:,1);
    for j = 1:Obj.number_of_fractions
        c(:,i+1,j) = Obj.volume_fraction(j,:,1)';
    end
    z(2:end,i+1) = z(1,i+1)-cumsum(thick);
end
max2 = 100;
for i=1:max2
    %
    % Determine sediment to deposit
    %
    mass(:,i+max1) = -repmat(mscale*max1/max2*[0.75+(0.25-0.75)*(i-1)/(max2-1);0.25+(0.75-0.25)*(i-1)/(max2-1)],1,Obj.number_of_columns);%net sediment flux into transport layer per fraction [kg/m2/s]
    massfluff(:,i+max1) = 0*mass(:,i+max1)*1e-6;%net sediment flux into fluff layer [kg/m2/s]
    %
    % Deposit sediment and obtain bed level change
    %
    dz = Obj.deposit(mass(:,i+max1),dt,rhosol,massfluff(:,i+max1),morfac);
    %
    % Determine new bed level
    %
    z(1,i+1+max1) = z(1,i+max1)+dz(1);
    %
    % Obtain layer interfaces and bed composition
    %
    thick = Obj.layer_thickness(:,1);
    for j = 1:Obj.number_of_fractions
        c(:,i+1+max1,j) = Obj.volume_fraction(j,:,1)';
    end
    z(2:end,i+1+max1) = z(1,i+1+max1)-cumsum(thick);
end
% %
% Visualize the bed layers over time
%

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
print(gcf,'-dpng','-r300',['sed_flux'])

%total sediment mass
figure
plot(dt*cumsum(mass(1,:)),'b--','LineWidth',1.5)
hold on
grid on
plot(dt*cumsum(mass(2,:)),'b:','LineWidth',1.5)
plot(dt*cumsum(mass(1,:)+mass(2,:)),'b-','LineWidth',1.5)
plot([0:1:200],-sum(diff(z).*c(:,:,1)*rho(1)),'r--','LineWidth',1.5)
plot([0:1:200],-sum(diff(z).*c(:,:,2)*rho(2)),'r:','LineWidth',1.5)
plot([0:1:200],(-sum(diff(z).*c(:,:,1)*rho(1))-sum(diff(z).*c(:,:,2)*rho(2))),'r-','LineWidth',1.5,'LineWidth',1.5)
xlabel('time [s]')
ylabel('mass [kg/m^2]')
dum = get(gca,'ylim');
set(gca,'ylim',[0 dum(2)])
xlim([0 200])
title('total sediment mass')
legend('supplied sedfrac1 (cum)','supplied sedfrac2 (cum)','total supplied mass (cum)','sedfrac1 in bed','sedfrac2 in bed','total in bed',1)
print(gcf,'-dpng','-r300',['mass_total'])

%mass fraction different layers
c(c==0)=NaN;
for j = 1:Obj.number_of_fractions
figure
    columnpatch(0:[max1+max2]+1,z,c(:,:,j)*rho(j)./(c(:,:,1)*rho(1) + c(:,:,2)*rho(2)))
    set(gca,'clim',[0 0.75])
    colorbar
    xlim([0 [max1+max2]])
    ylim([0 2]);
    ylabel('bed level [m]')
    xlabel('time [s]')
    title(['Fraction mass of sediment ',num2str(j),' [-]'])
    print(gcf,'-dpng','-r300',['massfraction_',num2str(j)])
end

%sediment mass top layer
figure
plot([0:1:200],-diff(z(1:2,:)).*c(1,:,1)*rho(1),'b-','LineWidth',1.5)
hold on
grid on
plot([0:1:200],-diff(z(1:2,:)).*c(1,:,2)*rho(2),'r-','LineWidth',1.5)
plot([0:1:200],-diff(z(1:2,:)).*(c(1,:,1)*rho(1)+c(1,:,2)*rho(2)),'k-','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass [kg/m^2]')
legend('sedfrac1','sedfrac2','total',1)
title('sediment mass top layer')
xlim([0 200])
print(gcf,'-dpng','-r300',['mass_toplayer'])

%mass fractions transport layer
figure
plot([0:1:200],c(1,:,1)*rho(1)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'b-','LineWidth',1.5)
hold on
grid on
plot([0:1:200],c(1,:,2)*rho(2)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'r-','LineWidth',1.5)
xlabel('time [s]')
ylabel('mass fraction [-]')
legend('sedfrac1 top layer','sedfrac1 top layer',1)
xlim([0 200])
ylim([0 1])
print(gcf,'-dpng','-r300',['massfractions_trlyr'])


% 
% %mass fractions sediment flux and top layer
% figure
% plot(mass(1,:)./sum(mass),'b-','LineWidth',1.5)
% hold on
% grid on
% plot(mass(2,:)./sum(mass),'r-','LineWidth',1.5)
% plot([0:1:200],c(1,:,1)*rho(1)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'b--','LineWidth',1.5)
% plot([0:1:200],c(1,:,2)*rho(2)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'r--','LineWidth',1.5)
% xlabel('time [s]')
% ylabel('mass fraction [-]')
% legend('supplied sedfrac1','supplied sedfrac2','sedfrac1 top layer','sedfrac1 top layer',1)
% xlim([0 200])
% ylim([0 1])
% print(gcf,'-dpng','-r300',['massfractions_flux_toplayer'])
% 
% %sediment mass in underlayers
% figure
% plot([0:1:200],-sum(diff(z(2:end,:)).*c(2:end,:,1)*rho(1)),'b-','LineWidth',1.5)
% hold on
% grid on
% plot([0:1:200],-sum(diff(z(2:end,:)).*c(2:end,:,2)*rho(2)),'r-','LineWidth',1.5)
% plot([0:1:200],-sum(diff(z(2:end,:)).*(c(2:end,:,1)*rho(1) + c(2:end,:,2)*rho(2))),'k-','LineWidth',1.5)
% xlabel('time [s]')
% ylabel('mass [kg/m^2]')
% legend('sedfrac1','sedfrac2','total',1)
% title('sediment mass under layers')
% xlim([0 200])
% print(gcf,'-dpng','-r300',['mass_underlayers'])
% 
% 
% if Obj.number_of_lagrangian_layers == 1
%     %sediment mass 1st Lagrangian layer
%     figure
%     plot([0:1:200],-diff(z(2:3,:)).*c(2,:,1)*rho(1),'b-','LineWidth',1.5)
%     hold on
%     grid on
%     plot([0:1:200],-diff(z(2:3,:)).*c(2,:,2)*rho(2),'r-','LineWidth',1.5)
%     plot([0:1:200],-diff(z(2:3,:)).*(c(2,:,1)*rho(1) + c(2,:,2)*rho(2)),'k-','LineWidth',1.5)
%     xlabel('time [s]')
%     ylabel('mass [kg/m^2]')
%     legend('sedfrac1','sedfrac2','total',1)
%     title('sediment mass 1st Langrangian layer')
%     xlim([0 200])
%     print(gcf,'-dpng','-r300',['mass_lalayer'])    
% 
%     %mass fractions in transport and 1st lagrangian layer
%     figure
%     plot([0:1:200],c(1,:,1)*rho(1)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'b-','LineWidth',1.5)
%     hold on
%     grid on
%     plot([0:1:200],c(1,:,2)*rho(1)./(c(1,:,1)*rho(1) + c(1,:,2)*rho(2)),'r-','LineWidth',1.5)
%     plot([0:1:200],c(2,:,1)*rho(1)./(c(2,:,1)*rho(1) + c(2,:,2)*rho(2)),'b--','LineWidth',1.5)
%     plot([0:1:200],c(2,:,2)*rho(1)./(c(2,:,1)*rho(1) + c(2,:,2)*rho(2)),'r--','LineWidth',1.5)    
%     xlabel('time [s]')
%     ylabel('mass fraction [-]')
%     legend('sedfrac1 top layer','sedfrac2 top layer','sedfrac1 Lagrangian layer','sedfrac2 Lagrangian layer',2)
%     xlim([0 200])
%     print(gcf,'-dpng','-r300',['mass_toplayer_lalayer'])    
% end
% 
% %
% % Obtain the thickness of all layers and points
% %
% % thick = Obj.layer_thickness
% % %
% % mass = Obj.layer_mass
% % %
% % % Determine total sediment thickness
% % %
% % total_thickness = sum(thick)
% % %
% % % Remove the top half of the sediment column
% % %
% % mass = Obj.remove_thickness(total_thickness/2);
% %
% % Extract the new layer thicknesses after erosion
% %
% % thick = Obj.layer_thickness(:,1)
% %
% % Delete the bedcomposition object and release fortran memory
% %
% clear Obj
% %
% % Unload the fortran dll from MATLAB memory
% %
% bedcomposition.unload
