function [OUT,OPT,IN] = getSignal(input,lat,varargin)
% Main function of morfacTide

%% Settings

% Default
OPT.type        = 'springneap';
OPT.nCycles     = 2;
OPT.morTime     = [];
OPT.morFac      = [];
OPT.tStart      = datenum(2000,1,1);
OPT.ampFac      = 1;
OPT.histScaling = 0;
OPT.plot        = 0;

% User defined
OPTflds = fieldnames(OPT);
if nargin > 2
    for i = 1:length(varargin)
        if any(strcmpi(OPTflds,varargin{i}))
            fld = OPTflds{strcmpi(OPTflds,varargin{i})};
            OPT.(fld) = varargin{i+1};
        end
    end
end



%% Define and rewrite variables

% Set-up output struct
OUT = struct;
IN = struct;

% M2 periods for time calculations
fM2 = 0.080511400670213; % M2 tidal frequency (cyc/hr)
TM2 = 1/fM2; % M2 tidal period (hr)
TdoubleTide = 2 *(TM2/24); % Period doubletide (days)
TspringNeap = 28*(TM2/24); % Period springneap (days)

% Check the input
if ~mod(OPT.nCycles,1) == 0 % Integer number provided?
    fprintf('\tWarning: number of cycles should be an integer number to correctly \n\t simulate a representative signal!\n')
    fprintf('\tFunction stopped\n')
    return
end


% Input morphological time
if ~isempty(OPT.morTime) || ~isempty(OPT.morFac)
    if ~isempty(OPT.morTime) && isempty(OPT.morFac)
        fprintf('\tValue for ''morFac'' required if ''morTime'' is specified!\n')
        fprintf('\tFunction stopped\n')
        return
    elseif isempty(OPT.morTime) && ~isempty(OPT.morFac)
        fprintf('\tValue for ''morTime'' required if ''morFac'' is specified!\n')
        fprintf('\tFunction stopped\n')
        return
    end
    
    if ~isempty(OPT.nCycles)
        fprintf('\tIf ''morTime'' and ''morFac'' are specified the number of \n\t cycles are calculated\n')
    end
    
    fprintf('\tA calculated value for morFac is provided in the output\n')
end

% % Combination 'doubletide' and 'ampfac'
% if OPT.ampFac && strcmp(OPT.type,'springneap')
%     fprintf('\tampFac not used when type is ''springneap''\n')
% end
% % Combination 'springneap' and 'histScaling'
% if OPT.histScaling && strcmp(OPT.type,'doubletide')
%     fprintf('\thistScaling not used when type is ''doubletide''\n')
% end


% Determine simulation time
if ~isempty(OPT.morTime) && ~isempty(OPT.morFac)
    hydroTime = OPT.morTime/OPT.morFac;
    tStop = OPT.tStart + hydroTime;
    
    tDur = tStop-OPT.tStart;
    if strcmp(OPT.type,'doubletide')
        OPT.nCycles     = round(tDur/TdoubleTide);
        OUT.morTime     = OPT.morTime;
        OUT.morFac      = OPT.morTime/(OPT.nCycles*TdoubleTide);
    elseif strcmp(OPT.type,'springneap')
        OPT.nCycles = round(tDur/TspringNeap);
        OUT.morTime = OPT.morTime;
        OUT.morFac  = OPT.morTime/(OPT.nCycles*TspringNeap);
    end  
end

% Time vector for representative signal (days, hours, and seconds)
if strcmp(OPT.type,'doubletide')
    tStop = OPT.tStart + OPT.nCycles * TdoubleTide;
elseif strcmp(OPT.type,'springneap')
    tStop = OPT.tStart + OPT.nCycles * TspringNeap;
end
OUT.hydroTime    = tStop-OPT.tStart;
OUT.datenum      = (OPT.tStart:datenum(0,0,0,0,10,0):tStop)';
OUT.timeDays     = OUT.datenum-OUT.datenum(1);
OUT.timeHours    = OUT.timeDays*24;
OUT.timeSeconds  = OUT.timeDays*24*60*60;







%% Tidal analysis and rewrite tidal constituents
const = [];

if iscell(input)    
    const.name  = input(:,1);
    const.amp   = cell2mat(input(:,2));
    const.pha   = cell2mat(input(:,3));
    const.freq  = t_tide_name2freq(const.name,'unit','cyc/hr')'; % frequency (cyc/hr)
    const.cel   = const.freq.*360; % celerity (deg/hr)
    const.omega = 2*pi.*const.freq; % angular frequency (rad/hr)

    % Create one-year time-series to evaulate tidal constituents
    tStartDate      = datevec(OPT.tStart);
    tStopDate       = tStartDate; tStopDate(1) = tStopDate(1)+1;
    IN.datenum      = (OPT.tStart:datenum(0,0,0,0,10,0):datenum(tStopDate))';
    IN.valMeteoTide = NaN(size(IN.datenum));
    tidecon         = eps*ones(length(const.name),4);
    tidecon(:,1)    = vertcat(const.amp);
    tidecon(:,3)    = vertcat(const.pha);
    IN.valFullTide  = t_predic(IN.datenum,const.name,const.freq,tidecon,'latitude',lat);
elseif isnumeric(input)
    
    IN.datenum = input(:,1);
    IN.valMeteoTide  = input(:,2);
    
    % Tidal analysis (requires t_tide toolbox)
    if ~exist('t_tide.m','file')
        fprintf('\tThe morphoTide toolbox requires the t_tide toolbox version 1.4,\n\tdownload it at https://www.eoas.ubc.ca/~rich/\n');
        return
    end
    
    IN.T = struct;
    % Harmonic analysis analysis (t_tide)
    % Version 1.4: Use constant value for time interval
    [IN.T,IN.valFullTide] = t_tide(input(:,2),...
        'int',diff(input(1:2,1)).*24,...
        'start',input(1,1),...
        'latitude',lat,...
        'diary','none',...
        'output','none');
    IN.T.names = cellstr(IN.T.name);
    IN.T.per   = 1./IN.T.freq;  % period (hr)
    IN.T.cel   = IN.T.freq.*360; % celerity (deg/hr)
    % Significant peaks
    IN.T.fsig  = IN.T.tidecon(:,1) > IN.T.tidecon(:,2);
    
    const.name = cellstr(IN.T.name(IN.T.fsig,:));
    const.amp  = IN.T.tidecon(IN.T.fsig,1);
    const.pha  = IN.T.tidecon(IN.T.fsig,3);
    const.freq = IN.T.freq(IN.T.fsig); % cycles/h
    const.cel  = const.freq.*360; % celerity (deg/hr)
end


%% Create representative signal

switch OPT.type
    case 'springneap'
        % Output consist of timeseries of a single spring-neap cycle 
        output = morfacTide.springNeap(const,OPT,IN);
        
        % Temporary
        IN.output = output;
    case 'doubletide'
        % Output consist of Mx3 array with [velocty,amplitude,phase]
        output = morfacTide.doubleTide(const,OPT);  
end

%% Create the signal on the defined time-axis that consist of nCycles of repetitions

switch OPT.type
    case 'springneap'
        
        % Create n repetitions
        clear val;
        if ~OPT.histScaling
            val         = repmat(output.timeseries,OPT.nCycles,1);
            OUT.val     = val(1:600:end);
            
            n = ceil((IN.datenum(end)-IN.datenum(1))/TspringNeap);
            val             = repmat(output.timeseries,n,1);
            IN.valReprTide  = val(1:600:end);
            IN.valReprTide = IN.valReprTide(1:length(IN.datenum));
        elseif OPT.histScaling
            val         = repmat(output.timeseriesScaled,OPT.nCycles,1);
            OUT.val     = val(1:600:end);
            
            n = ceil((IN.datenum(end)-IN.datenum(1))/TspringNeap);
            val             = repmat(output.timeseriesScaled,n,1);
            IN.valReprTide  = val(1:600:end);
            IN.valReprTide = IN.valReprTide(1:length(IN.datenum));
        end
        

        
        
        
        % Method below not possible with scaled amplitudes because
        % amplitude of D2 is not a constant but a timeseries
%         % Create the signal, equation (1) in Schrijvershof et al. (2023)
%         % (this way there is a (insignificant) small offset in time because of rounding error in Dsn constituent)
%        OUT.val = ...
%             (output.constituents.C1.amp) .* cos(output.constituents.C1.omega.*OUT.timeSeconds - output.constituents.C1.phi) + ...
%             (output.constituents.D2.amp(1) + ...
%             (output.constituents.Dsn.amp * cos(output.constituents.Dsn.omega.*OUT.timeSeconds - pi)) ) ...
%             .* cos(output.constituents.D2.omega(1).*OUT.timeSeconds - output.constituents.D2.phi(1)) + ...
%             (output.constituents.D4.amp(1)) .* cos(output.constituents.D4.omega(1).*OUT.timeSeconds - output.constituents.D4.phi(1)) + ...
%             (output.constituents.D6.amp(1)) .* cos(output.constituents.D6.omega(1).*OUT.timeSeconds - output.constituents.D6.phi(1)) + ...
%             (output.constituents.D8.amp(1)) .* cos(output.constituents.D8.omega(1).*OUT.timeSeconds - output.constituents.D8.phi(1));
%         
%         datenumS = IN.datenum*24*60*60;
%         IN.valReprTide = ...
%         (output.constituents.C1.amp) .* cos(output.constituents.C1.omega.*datenumS - output.constituents.C1.phi) + ...
%             (output.constituents.D2.amp(1) + ...
%             (output.constituents.Dsn.amp * cos(output.constituents.Dsn.omega.*datenumS - pi)) ) ...
%             .* cos(output.constituents.D2.omega(1).*datenumS - output.constituents.D2.phi(1)) + ...
%             (output.constituents.D4.amp(1)) .* cos(output.constituents.D4.omega(1).*datenumS - output.constituents.D4.phi(1)) + ...
%             (output.constituents.D6.amp(1)) .* cos(output.constituents.D6.omega(1).*datenumS - output.constituents.D6.phi(1)) + ...
%             (output.constituents.D8.amp(1)) .* cos(output.constituents.D8.omega(1).*datenumS - output.constituents.D8.phi(1));
        
    case 'doubletide'

        % Harmonic boundary conditions in FM GUI is:
        % Freq (deg/h), amplitude (m), phase (deg)
        % But input files are
        % Length (minutes/cycle), amplitude (m), phase(deg)
        
        dur     = 1./output(:,1)*60; % 1/(deg/hr)*60 = min/cycle
        amp     = output(:,2);
        pha     = output(:,3);
        pha_rad = pha.*(pi/180);
        omega   = 2*pi.*output(:,1);
        
        
        % #    name    deg/hr        hr/cyc        cyc/hr        cyc/day
        % 48   M2      28.9841       12.4206       0.080511      1.9323
        
         val = amp' .* cos(omega' .* (OUT.datenum.*24) - pha_rad');
         OUT.val = sum(val,2);
         
         % For visualization next to full timeseries
         valRep = amp' .* cos(omega' .* (IN.datenum.*24) - pha_rad');
         IN.valReprTide = sum(valRep,2);
        
end

%% Make figure of time-series and histograms


if OPT.plot
    

    clr(1,:)    = [0,0,0];
    clr(2:3,:)  = lines(2);
    legStr = {'Observed','Full tidal prediction','Representative signal'};
    
    
    clear axs
    % Set-up figure
    fig = figure; fig.Units = 'centimeters'; fig.Position = [0 0 34 19];
    axs(1) = axes; axs(1).Units = 'centimeters'; axs(1).Position = [1.5 10 22 8.5];
    axs(2) = axes; axs(2).Units = 'centimeters'; axs(2).Position = [25 10 8 8.5];
    axs(3) = axes; axs(3).Units = 'centimeters'; axs(3).Position = [1.5 1.5 9 7];
    axs(4) = axes; axs(4).Units = 'centimeters'; axs(4).Position = [12.5 1.5 9 7];
    
    
    % Plot 1: Time-series
    set(fig,'CurrentAxes',axs(1)); hold on; box on; ax = gca;
    plot(IN.datenum,IN.valMeteoTide,'--','Color',clr(1,:));
    plot(IN.datenum,IN.valFullTide,'Color',clr(2,:));
    plot(IN.datenum,IN.valReprTide,'Color',clr(3,:));
    
    axis tight;
    datetick('x','mmm-yyyy','keeplimits','keepticks')
    hl = legend(legStr,'Location','NE');
    ylabel('y (unit of amplitude)')
    
    set(fig,'CurrentAxes',axs(2)); hold on; box on; ax = gca;
    plot(IN.datenum,IN.valMeteoTide,'--','Color',clr(1,:));
    plot(IN.datenum,IN.valFullTide,'Color',clr(2,:));
    plot(IN.datenum,IN.valReprTide,'Color',clr(3,:));
    
    axis tight;
    xlim([IN.datenum(1),IN.datenum(1)+2])
    datetick('x','HH:mm','keeplimits','keepticks')
    
    set(fig,'CurrentAxes',axs(3)); hold on; box on; ax = gca;
    dx      = 0.2; % Bin interval
    edges   = round(min([IN.valMeteoTide;IN.valFullTide;IN.valReprTide]),1,'decimals')-2*dx:dx:round(max([IN.valMeteoTide;IN.valFullTide;IN.valReprTide]),1,'decimals')+2*dx;
    bins    = edges(1:end-1)+diff(edges);
    
    data0 = histcounts(IN.valMeteoTide,edges,'Normalization','probability');
    data1 = histcounts(IN.valFullTide,edges,'Normalization','probability');
    data2 = histcounts(IN.valReprTide,edges,'Normalization','probability');
    
    plot(bins,data0,'--','Color',clr(1,:));
    area(bins,data1,'LineStyle','-','EdgeColor','n',...
        'LineWidth',1,'FaceColor',clr(2,:),'FaceAlpha',0.5);
    plot(bins,data2,'Color',clr(3,:));
    
    xlabel('y (unit of amplitude)')
    
    
    set(fig,'CurrentAxes',axs(4)); hold on; box on; ax = gca;
    dZdt0 = diff(IN.valMeteoTide)./(diff(IN.datenum)*24);
    dZdt1 = diff(IN.valFullTide)./(diff(IN.datenum)*24);
    dzdt2 = diff(IN.valReprTide)./(diff(IN.datenum)*24);
    
    dx      = 1/6; % Bin interval
    edges   = round(min([dZdt0;dZdt1;dzdt2]),1,'decimals')-2*dx:dx:round(max([dZdt0;dZdt1;dzdt2]),1,'decimals')+2*dx;
    bins    = edges(1:end-1)+diff(edges);
    
    data0 = histcounts(dZdt0,edges,'Normalization','probability');
    data1 = histcounts(dZdt1,edges,'Normalization','probability');
    data2 = histcounts(dzdt2,edges,'Normalization','probability');
    
    plot(bins,data0,'--','Color',clr(1,:));
    area(bins,data1,'LineStyle','-','EdgeColor','n',...
        'LineWidth',1,'FaceColor',clr(2,:),'FaceAlpha',0.5);
    plot(bins,data2,'Color',clr(3,:));
    
    xlabel('dy/dt (unit of amplitude/hr)');
    
    
end

return




