function output = doubleTide(const,OPT)
% Function used in morfacTide.getSignal
% Inputfields are defined in morfacTide.getSignal()
% Function returns a Mx3 array with fields [frequency,amplitude,phase]
%                                          [(cyc/hr) ,(m)      ,(degree)]
% NOTE: harmonic boundary conditions in FM are specified in minutes/cycle:
% 1/(cyc/hr)*60 = min/cyc


        clear D
        % Constituents potentially used for analysis
        D.name  = {'M2','M4','M6','M8','M10','O1','K1'};

        % Find constituents and rewrite parameters to separate fields
        n = 0;
        for i = 1:length(D.name)
            c = D.name{i};
            if any(strcmp(const.name,c))
                n = n+1;
                D.name_used{n} = c;
                id = strcmp(const.name,c);
                D.(c).amp     = const.amp(id);  % m
                D.(c).pha     = const.pha(id);  % degree
                D.(c).freq    = const.freq(id); % h-1
                D.(c).cel     = const.cel(id);  % deg/hr
                D.(c).vel     = 1/D.(c).cel*360*60;  % Velocity
            end
        end
        
        % Calculate C1 component from O1 & K1 (amplitude and phase)
        if ~isfield(D,'O1')
            fprintf('\tO1 constituent could not be determined!\n');
        elseif ~isfield(D,'K1')
            fprintf('\tK1 constituent could not be determined!\n');
        end
        D.C1.amp    = sqrt(2*D.O1.amp*D.K1.amp);
        O1x             = cosd(D.O1.pha);
        O1y             = sind(D.O1.pha);
        K1x             = cosd(D.K1.pha);
        K1y             = sind(D.K1.pha);
        D.C1.pha    = atan2d(mean([O1y,K1y]),mean([O1x,K1x])); % Mean of angles
        D.C1.pha(D.C1.pha<0) = D.C1.pha + (D.C1.pha<0)*360; % Convert to 0-360
        D.C1.pha    = mod(D.C1.pha,180); % To make sure we always start with the same diurnal in-equality (to conserve the relative phasing between multiple point in space)
        D.C1.freq   = 0.5*D.M2.freq;
        D.C1.cel    = 0.5*D.M2.cel;
        D.C1.vel    = 1/D.C1.cel*360*60;
        
        if OPT.ampFac
            % Amplification for M2, following Lesser (2009) equation 5.16
            % sqrt((sum(Aconst^2) - Ac1^2) / Am2^2)
            D.ampfac = sqrt((sum(const.amp.^2)-D.C1.amp.^2)/D.M2.amp.^2);
            D.M2.amp = D.M2.amp*D.ampfac;
        end
        
        
        % Rewrite
        flds = fieldnames(D);
        id = startsWith(flds,'M');
        
        D.mor.name = [flds(id);{'C1'}];
        for i = 1:length(D.mor.name)
            c = D.mor.name{i};
            D.mor.amp(i,1)  = D.(c).amp;
            D.mor.pha(i,1)  = D.(c).pha;
            D.mor.freq(i,1) = D.(c).freq;
        end
        
        %  Write to output variable (Mx3 array)
        output  = [D.mor.freq,D.mor.amp,D.mor.pha];
return