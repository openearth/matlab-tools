function output = springNeap(const,OPT,IN)
% Function used in morfacTide.getSignal
% Inputfields are defined in morfacTide.getSignal()
% Function returns a timeseries of a single repetition of a 
% repr. spring-neap cycle.

% Rewrite the relevant constituents
idO1 = strcmp(const.name,'O1');
idK1 = strcmp(const.name,'K1');
idM2 = strcmp(const.name,'M2');
idS2 = strcmp(const.name,'S2');
idM4 = strcmp(const.name,'M4');
idM6 = strcmp(const.name,'M6');
idM8 = strcmp(const.name,'M8');

SN = struct;

SN.D1.amp(1,1) = const.amp(idO1); % Amplitude (Unit of input, e.g. m)
SN.D1.amp(2,1) = const.amp(idK1);
SN.D2.amp(1,1) = const.amp(idM2);
SN.D2.amp(2,1) = const.amp(idS2);
SN.D4.amp(1,1) = const.amp(idM4);
SN.D6.amp(1,1) = const.amp(idM6);
SN.D8.amp(1,1) = const.amp(idM8);

SN.D1.phi(1,1) = (pi/180).*const.pha(idO1); % Phase (radians)
SN.D1.phi(2,1) = (pi/180).*const.pha(idK1);
SN.D2.phi(1,1) = (pi/180).*const.pha(idM2);
SN.D2.phi(2,1) = (pi/180).*const.pha(idS2);
SN.D4.phi(1,1) = (pi/180).*const.pha(idM4);
SN.D6.phi(1,1) = (pi/180).*const.pha(idM6);
SN.D8.phi(1,1) = (pi/180).*const.pha(idM8);

SN.D1.T(1,1) = (1/const.freq(idO1))*60*60; % Period (s)
SN.D1.T(2,1) = (1/const.freq(idK1))*60*60;
SN.D2.T(1,1) = (1/const.freq(idM2))*60*60;
SN.D2.T(2,1) = (1/const.freq(idS2))*60*60;
SN.D4.T(1,1) = (1/const.freq(idM4))*60*60;
SN.D6.T(1,1) = (1/const.freq(idM6))*60*60;
SN.D8.T(1,1) = (1/const.freq(idM8))*60*60;

SN.D1.omega(1,1) = (2*pi)/SN.D1.T(1,1); % Angular frequency (rad/s)
SN.D1.omega(2,1) = (2*pi)/SN.D1.T(2,1);
SN.D2.omega(1,1) = (2*pi)/SN.D2.T(1,1);
SN.D2.omega(2,1) = (2*pi)/SN.D2.T(2,1);
SN.D4.omega(1,1) = (2*pi)/SN.D4.T(1,1);
SN.D6.omega(1,1) = (2*pi)/SN.D6.T(1,1);
SN.D8.omega(1,1) = (2*pi)/SN.D8.T(1,1);
    

%% Build-up of the constituents of the representative periodic spring-neap cycle

% 1. Determine duration of a spring-neap cycle exactly in seconds
% 2. Limit the length to an integer and even number of D2 cycles 
%   (duration of the synthetic spring-neap cycle)
% 3. Create a time vector for a single synthetic spring-neap cycle (with second increments)
% 4. Calculate the other constituents (Dsn and C1). Phase of Dsn is neglected (0 deg).
% Optional: Scaling on the amplitudes and phases 
% 5. Create a single repetition of the synthetic spring-neap cycle

% 1. Duration spring-neap cycle (M2-S2 or M2-N2)
SNduration_s = ((2*pi) / (SN.D2.omega(2) - SN.D2.omega(1)));
SNduration_d = SNduration_s/60/60/24;

% 2. Limit the length
nD2cycles   = floor(SNduration_s/SN.D2.T(1)/2)*2;
TreprCycle  = nD2cycles*SN.D2.T(1);

% 3. Create time vector
SN.repr.ts = (0:TreprCycle)';
SN.repr.th = SN.repr.ts/60/60;
SN.repr.td = SN.repr.ts/60/60/24;

% 4. Calculate the other constituents
% Constituent Dsn, that mimics the spring-neap variation
% Equation (2) in Schrijvershof et al. (2023)
SN.Dsn.omega    = (2*pi)/TreprCycle;
SN.Dsn.amp        = SN.D2.amp(2);
SN.Dsn.ampvar     = SN.D2.amp(2) * cos(SN.Dsn.omega.*SN.repr.ts - pi); % -pi to start with neap tide

% To check: Very small rounding differences can cause the end of
% the signal not to coincide with the beginning of the signal, so that
% SN.Dsn.ampvar(1)~=SN.Dsn.ampvar(end). This is solved by making Avar exactly symmetric
SN.Dsn.ampvar  = round(SN.Dsn.ampvar,4);

% Constituent C1 from O1 & K1 (amplitude and phase)
SN.C1.amp     = sqrt(2*SN.D1.amp(1)*SN.D1.amp(2));
O1x             = cos(SN.D1.phi(1,1));
O1y             = sin(SN.D1.phi(1,1));
K1x             = cos(SN.D1.phi(2,1));
K1y             = sin(SN.D1.phi(2,1));
SN.C1.phi       = atan2(mean([O1y,K1y]),mean([O1x,K1x])); % Mean of angles
SN.C1.phi(SN.C1.phi<0) = SN.C1.phi + (SN.C1.phi<0)*2*pi; % Convert to 0-2pi
SN.C1.omega     = 0.5*SN.D2.omega(1);

%% Scaling procedure
if OPT.histScaling
    tic
    % 1. Rewrite the signal as a linear combination of sines and cosines
    %    (to get rid of phases in the equation)
    % 2. Calculate dz/dt and binning intervals
    % 3. Scale the amplitudes of Dsn, D2, D4, and C1 to fit histograms of Z and
    %    dZ/dt of the full astronomical tidal signal
    
    
    % 1. Rewrite the signal as a linear combination of sines and cosinse
    % to get rid of the phases. This
    SN.C1.a = SN.C1.amp*cos(SN.C1.phi);
    SN.C1.b = SN.C1.amp*sin(SN.C1.phi);
%     SN.D2.a = (SN.D2.amp(1) + SN.Dsn.ampvar).*cos(SN.D2.phi(1)); % NOT A CONSTANT!
%     SN.D2.b = (SN.D2.amp(1) + SN.Dsn.ampvar).*sin(SN.D2.phi(1));
    SN.D4.a = SN.D4.amp(1)*cos(SN.D4.phi(1));
    SN.D4.b = SN.D4.amp(1)*sin(SN.D4.phi(1));
    SN.D6.a = SN.D6.amp(1)*cos(SN.D6.phi(1));
    SN.D6.b = SN.D6.amp(1)*sin(SN.D6.phi(1));
    SN.D8.a = SN.D8.amp(1)*cos(SN.D8.phi(1));
    SN.D8.b = SN.D8.amp(1)*sin(SN.D8.phi(1));
    
    % 2. Rewrite and calculate dzdt
    Z1       = IN.valFullTide;
    dZdt1    = diff(Z1)/(diff(IN.datenum(1:2))*24);
    dZdt1(end+1) = NaN; % Equal array as Z1 required
    Zdx      = 0.2; % Bin interval, unit of z (e.g. m)
    dZdtdx   = 1/6; % Bin interval, unitof dz/dt (e.g. m/hr)
    
    % Set-up the binning intervals (exactly symmetric around 0)
    Zlim    = max(abs([floor(min(Z1)/Zdx),ceil(max(Z1)/Zdx)]));
    Zlim    = Zlim+1;
    Zedges  = Zlim*-Zdx:Zdx:Zlim*Zdx;
    Zbins   = Zedges(1:end-1)+(diff(Zedges)./2);
    
    dZdtlim    = max(abs([floor(min(dZdt1)/dZdtdx),ceil(max(dZdt1)/dZdtdx)]));
    dZdtlim    = dZdtlim+1;
    dZdtedges  = dZdtlim*-dZdtdx:dZdtdx:dZdtlim*dZdtdx;
    dZdtbins   = dZdtedges(1:end-1)+(diff(dZdtedges)./2);
    
    % Bivariate histogram of full tidal signal
    data1 = histcounts2(Z1,dZdt1,Zedges,dZdtedges,'Normalization','probability');
    
    % Scaling factors
    dfac = 0.1;
    fac = 0.5:dfac:1.5; % Range of scaling factors
    
    % 3. Scale the amplitudes
    %%% Scaling of the amplitude of the spring-neap variation (Dsn)
    
    
%     clear ERR
%     ERR = NaN(length(fac),1);
%     for k = 1:length(fac)
%         clear Z2 dZdt2 Avar D2a D2b
%         ampvar = fac(k) * SN.Dsn.amp * cos(SN.Dsn.omega.*SN.repr.ts - pi); % -pi to start with neap tide
%         ampvar = round(ampvar,4);        
%         D2a  = (SN.D2.amp(1) + ampvar).*cos(SN.D2.phi(1));
%         D2b  = (SN.D2.amp(1) + ampvar).*sin(SN.D2.phi(1));
%         Z2 = ...
%             SN.C1.a .* cos(SN.C1.omega   .* SN.repr.ts) + SN.C1.b .* sin(SN.C1.omega.*SN.repr.ts) + ...
%             D2a .* cos(SN.D2.omega(1)   .* SN.repr.ts) + D2b .* sin(SN.D2.omega(1).*SN.repr.ts) + ...
%             SN.D4.a .* cos(SN.D4.omega(1).* SN.repr.ts) + SN.D4.b .* sin(SN.D4.omega(1).*SN.repr.ts) + ...
%             SN.D6.a .* cos(SN.D6.omega(1).* SN.repr.ts) + SN.D6.b .* sin(SN.D6.omega(1).*SN.repr.ts) + ...
%             SN.D8.a .* cos(SN.D8.omega(1).* SN.repr.ts) + SN.D8.b .* sin(SN.D8.omega(1).*SN.repr.ts);  
%         dZdt2 = diff(Z2)/(diff(SN.repr.th(1:2)));
%         dZdt2(end+1) = NaN;
%         % Bivariate histogram of synthetic cycle
%         data2 = histcounts2(Z2,dZdt2,Zedges,dZdtedges,'Normalization','probability');
%         % RMSE
%         ERR(k) = sqrt( sum((data2(:)-data1(:)).^2) / length(data1(:)));
%     end
%     % Get the best factor
%     [~,id] = min(ERR(:));
%     fDsn = fac(id);
%     % Apply the best factor
%     SN.Dsn.ampScaled    = fDsn * SN.Dsn.amp;
%     SN.Dsn.ampvarScaled = fDsn * SN.Dsn.amp * cos(SN.Dsn.omega.*SN.repr.ts - pi); % -pi to start with neap tide
%     SN.Dsn.ampvarScaled = round(ampvar,4);
    
    
    SN.Dsn.ampvarScaled = SN.Dsn.ampvar; % Scaling on amplitude of Dsn destroys the fit, to check...
    
    % Calculate D2a and D2b
    SN.D2.a = (SN.D2.amp(1) + SN.Dsn.ampvarScaled).*cos(SN.D2.phi(1)); % NOT A CONSTANT!
    SN.D2.b = (SN.D2.amp(1) + SN.Dsn.ampvarScaled).*sin(SN.D2.phi(1));
    
    % Scaling on the semi-diurnal (D2) amplitudes
    ERR = NaN(length(fac),length(fac));
    for k = 1:length(fac)
        for m = 1:length(fac)
            clear Z2 dZdt2
            Z2 = ...
                SN.C1.a .* cos(SN.C1.omega.*SN.repr.ts) + SN.C1.b .* sin(SN.C1.omega.*SN.repr.ts) + ...
                fac(k) .* SN.D2.a .* cos(SN.D2.omega(1).*SN.repr.ts) + fac(m) .* SN.D2.b .* sin(SN.D2.omega(1).*SN.repr.ts) + ...
                SN.D4.a .* cos(SN.D4.omega(1).*SN.repr.ts) + SN.D4.b .* sin(SN.D4.omega(1).*SN.repr.ts) + ...
                SN.D6.a .* cos(SN.D6.omega(1).*SN.repr.ts) + SN.D6.b .* sin(SN.D6.omega(1).*SN.repr.ts) + ...
                SN.D8.a .* cos(SN.D8.omega(1).*SN.repr.ts) + SN.D8.b .* sin(SN.D8.omega(1).*SN.repr.ts);
            dZdt2 = diff(Z2)/(diff(SN.repr.th(1:2)));
            dZdt2(end+1) = NaN;
            % Bivariate histogram of synthetic cycle
            data2 = histcounts2(Z2,dZdt2,Zedges,dZdtedges,'Normalization','probability');
            % RMSE
            ERR(k,m) = sqrt( sum((data2(:)-data1(:)).^2) / length(data1(:)));
        end
    end
    % Get the best factor
    [~,id] = min(ERR(:));
    [idr,idc] = ind2sub(size(ERR),id);
    fD2a = fac(idr);
    fD2b = fac(idc);
    
    % Scaling of quarter-diurnal (D4) amplitudes
    ERR = NaN(length(fac),length(fac));
    for k = 1:length(fac)
        for m = 1:length(fac)
            clear Z2 dZdt2
            Z2 = ...
                SN.C1.a .* cos(SN.C1.omega.*SN.repr.ts) + SN.C1.b .* sin(SN.C1.omega.*SN.repr.ts) + ...
                fD2a .* SN.D2.a .* cos(SN.D2.omega(1).*SN.repr.ts) + fD2b .* SN.D2.b .* sin(SN.D2.omega(1).*SN.repr.ts) + ...
                fac(k) .* SN.D4.a .* cos(SN.D4.omega(1).*SN.repr.ts) + fac(m) .* SN.D4.b .* sin(SN.D4.omega(1).*SN.repr.ts) + ...
                SN.D6.a .* cos(SN.D6.omega(1).*SN.repr.ts) + SN.D6.b .* sin(SN.D6.omega(1).*SN.repr.ts) + ...
                SN.D8.a .* cos(SN.D8.omega(1).*SN.repr.ts) + SN.D8.b .* sin(SN.D8.omega(1).*SN.repr.ts);
            dZdt2 = diff(Z2)/(diff(SN.repr.th(1:2)));
            dZdt2(end+1) = NaN;
            % Bivariate histogram of synthetic cycle
            data2 = histcounts2(Z2,dZdt2,Zedges,dZdtedges,'Normalization','probability');
            % RMSE
            ERR(k,m) = sqrt( sum((data2(:)-data1(:)).^2) / length(data1(:)));
        end
    end
    % Get the best factor
    [~,id] = min(ERR(:));
    [idr,idc] = ind2sub(size(ERR),id);
    fD4a = fac(idr);
    fD4b = fac(idc);
    
    % Scaling on the diurnal (C1) amplitudes
    ERR = NaN(length(fac),length(fac));
    for k = 1:length(fac)
        for m = 1:length(fac)
            clear Z2 dZdt2
            Z2 = ...
                fac(k) * SN.C1.a .* cos(SN.C1.omega.*SN.repr.ts) + fac(m) * SN.C1.b .* sin(SN.C1.omega.*SN.repr.ts) + ...
                fD2a .* SN.D2.a .* cos(SN.D2.omega(1).*SN.repr.ts) + fD2b .* SN.D2.b .* sin(SN.D2.omega(1).*SN.repr.ts) + ...
                fD4a .* SN.D4.a .* cos(SN.D4.omega(1).*SN.repr.ts) + fD4b .* SN.D4.b .* sin(SN.D4.omega(1).*SN.repr.ts) + ...
                SN.D6.a .* cos(SN.D6.omega(1).*SN.repr.ts) + SN.D6.b .* sin(SN.D6.omega(1).*SN.repr.ts) + ...
                SN.D8.a .* cos(SN.D8.omega(1).*SN.repr.ts) + SN.D8.b .* sin(SN.D8.omega(1).*SN.repr.ts);
            dZdt2 = diff(Z2)/(diff(SN.repr.th(1:2)));
            dZdt2(end+1) = NaN;
            % Bivariate histogram of synthetic cycle
            data2 = histcounts2(Z2,dZdt2,Zedges,dZdtedges,'Normalization','probability');
            % RMSE
            ERR(k,m) = sqrt( sum((data2(:)-data1(:)).^2) / length(data1(:)));
        end
    end
    % Get the best factor
    [~,id] = min(ERR(:));
    [idr,idc] = ind2sub(size(ERR),id);
    fC1a = fac(idr);
    fC1b = fac(idc);
    
    % Rewrite back to include a phase. Otherwise the artifical spring-neap
    % modulation needs to be applied on two amplitudes and the phase is
    % scaled as well. We assume the spring-neap variation has phase=0
%     SN.C1.ampScaled     = sqrt(fC1a.*SN.C1.a.^2 + fC1b.*SN.C1.b.^2);
%     SN.C1.phiScaled     = atan((fC1a.*SN.C1.b(1)) / (fC1b.*SN.C1.a(1)));
%     SN.D2.ampScaled     = sqrt(fD2a.*SN.D2.a.^2 + fD2b.*SN.D2.b.^2);
%     SN.D2.phiScaled     = atan((fD2a .* SN.D2.b) ./ (fD2b .* SN.D2.a));
%     SN.D4.ampScaled     = sqrt(fD4a.*SN.D4.a.^2 + fD4b.*SN.D4.b.^2);
%     SN.D4.phiScaled     = atan((fD4a.*SN.D4.b(1)) / (fD4b.*SN.D4.a(1)));
    toc
    
    % Figure of error matrix
%     if 0
%         % 1x1
%         close all;
%         fig = figure; fig.Units = 'centimeters'; fig.Position = [5 5 9 7];
%         axs = tight_subplot(1,1,0.5,[0.15,0.1],[0.15,0.1]);
%         set(fig,'CurrentAxes',axs(1)); ax = gca; hold on; box on;
%         pcolor(fac,fac,ERR);
%         ht = text(fac(idc)+dfac/2,fac(idr)+dfac/2,'x','VerticalAlignment','middle','HorizontalAlignment','center');
%         hc = colorbar; colormap(flip(parula));
%         xlabel('a factor (-)');
%         ylabel('b factor (-)');
%         ylabel(hc,'RMSE (m, m/hr)')
%         xlim([fac(1),fac(end)])
%         ylim([fac(1),fac(end)])
%         
%         % Write to file
%         figName = sprintf('ExampleErrorMatrix');
%         print(fig,'-dpng','-r300',['./figs/',figName  '.png'])
%     end
end

%% Create the signal (a single repetition)

% 5. Equation (1) in Schrijvershof et al. (2023)
SN.repr.cycle = ...
     SN.C1.amp .* cos(SN.C1.omega .* SN.repr.ts - SN.C1.phi) + ...
     (SN.D2.amp(1) + SN.Dsn.ampvar) .* cos(SN.D2.omega(1).*SN.repr.ts - SN.D2.phi(1)) + ...
     SN.D4.amp .* cos(SN.D4.omega .* SN.repr.ts - SN.D4.phi) + ...
     SN.D6.amp .* cos(SN.D6.omega .* SN.repr.ts - SN.D6.phi) + ...
     SN.D8.amp .* cos(SN.D8.omega .* SN.repr.ts - SN.D8.phi);
if OPT.histScaling
    SN.repr.cycleScaled = ...
        fC1a * SN.C1.a .* cos(SN.C1.omega.*SN.repr.ts) + fC1b * SN.C1.b .* sin(SN.C1.omega.*SN.repr.ts) + ...
        fD2a .* SN.D2.a .* cos(SN.D2.omega(1).*SN.repr.ts) + fD2b .* SN.D2.b .* sin(SN.D2.omega(1).*SN.repr.ts) + ...
        fD4a * SN.D4.a .* cos(SN.D4.omega(1).*SN.repr.ts)  + fD4b *  SN.D4.b .* sin(SN.D4.omega(1).*SN.repr.ts) + ...
        SN.D6.a .* cos(SN.D6.omega(1).*SN.repr.ts) + SN.D6.b .* sin(SN.D6.omega(1).*SN.repr.ts) + ...
        SN.D8.a .* cos(SN.D8.omega(1).*SN.repr.ts) + SN.D8.b .* sin(SN.D8.omega(1).*SN.repr.ts);
    
%     SN.repr.cycleScaled = ...
%         SN.C1.ampScaled .* cos(SN.C1.omega .* SN.repr.ts - SN.C1.phiScaled) + ...
%         (SN.D2.ampScaled + SN.Dsn.ampvarScaled) .* cos(SN.D2.omega(1).*SN.repr.ts - SN.D2.phiScaled) + ...
%         SN.D4.ampScaled .* cos(SN.D4.omega .* SN.repr.ts - SN.D4.phiScaled) + ...
%         SN.D6.amp .* cos(SN.D6.omega .* SN.repr.ts - SN.D6.phi) + ...
%         SN.D8.amp .* cos(SN.D8.omega .* SN.repr.ts - SN.D8.phi);
end

%% Write the output

output = struct;
% Legend
output.constituents.legend = {'Dx = diurnal, semi-diurnal, quarter, etc.';...
    'Dsn = constituents that mimic spring-neap variation';...
    'amp = amplitude (unit of input signal)';...
    'omega = angular frequency (rad/s)';...
    'phi = phase (degrees)'};

output.timeseries = SN.repr.cycle;
% C1
output.constituents.C1.amp      = SN.C1.amp;
output.constituents.C1.omega    = SN.C1.omega;
output.constituents.C1.phi      = SN.C1.phi;
% D2
output.constituents.D2.amp      = SN.D2.amp;
output.constituents.D2.omega    = SN.D2.omega;
output.constituents.D2.phi      = SN.D2.phi;
% Dsn
output.constituents.Dsn.amp     = SN.Dsn.amp;
output.constituents.Dsn.ampvar  = SN.Dsn.ampvar;
output.constituents.Dsn.omega   = SN.Dsn.omega;
% D4
output.constituents.D4.amp      = SN.D4.amp;
output.constituents.D4.omega    = SN.D4.omega;
output.constituents.D4.phi      = SN.D4.phi;
% D6
output.constituents.D6.amp      = SN.D6.amp;
output.constituents.D6.omega    = SN.D6.omega;
output.constituents.D6.phi      = SN.D6.phi;
% D8
output.constituents.D8.amp      = SN.D8.amp;
output.constituents.D8.omega    = SN.D8.omega;
output.constituents.D8.phi      = SN.D8.phi;

if OPT.histScaling
    output.timeseriesScaled               = SN.repr.cycleScaled;
%     % C1
%     output.constituents.C1.ampScaled      = SN.C1.ampScaled;
%     output.constituents.C1.phiScaled      = SN.C1.phiScaled;
%     % D2
%     output.constituents.D2.ampScaled      = SN.D2.ampScaled;
%     output.constituents.D2.phiScaled      = SN.D2.phiScaled;
%     % Dsn
%     output.constituents.Dsn.ampScaled     = SN.Dsn.ampScaled;
%     output.constituents.Dsn.ampvarScaled  = SN.Dsn.ampvarScaled;
%     output.constituents.Dsn.omega         = SN.Dsn.omega;
%     % D4
%     output.constituents.D4.ampScaled      = SN.D4.ampScaled;
%     output.constituents.D4.omega          = SN.D4.omega;
%     output.constituents.D4.phiScaled      = SN.D4.phiScaled;
end