function x2 = convertUnits(x1,sourceUoM,targetUoM,STD)
% CONVERTUNITS converts between different unit of measures
%   Detailed explanation goes here

if strcmpi(sourceUoM,targetUoM)
    x2 = x1;
else
    ind1 = find(strcmpi(STD.unit_of_measure.unit_of_meas_name,sourceUoM));
    ind2 = find(strcmpi(STD.unit_of_measure.unit_of_meas_name,targetUoM));

    % check if both are both same type:
    if ~strcmp(STD.unit_of_measure.unit_of_meas_type(ind1),STD.unit_of_measure.unit_of_meas_type(ind2))
        error('different types')
    end

    %convert source to SI
    if ismember(sourceUoM, {'metre','radian','unity'})
        xSI = x1;
    else
        % check if conversion parameters are defined
        fact_b = STD.unit_of_measure.factor_b(ind1);
        fact_c = STD.unit_of_measure.factor_c(ind1);
        if ~isnan(fact_b+fact_c)
            % check if the parameter closely resembles pi. If so, replace by pi
            if abs(abs(fact_b)-pi)<0.001, fact_b=pi()*sign(fact_b); end
            if abs(abs(fact_c)-pi)<0.001, fact_c=pi()*sign(fact_c); end
            xSI = x1*fact_b/fact_c;
        else %do something special for every predetermined case
            switch sourceUoM
                case 'sexagesimal DMS'
                    % Pseudo unit. Format: signed degrees - period - minutes (2
                    % digits) - integer seconds (2 digits) - fraction of seconds
                    % (any precision). Must include leading zero in minutes and
                    % seconds and exclude decimal point for seconds. Convert to
                    % degree using formula.
                    degs =floor(abs(x1));
                    mins = floor(100*(abs(x1)-degs)+1000*eps); %correct for numerical error
                    secs = 10000*(abs(x1)-degs-mins/100);
                    xSI = sign(x1).*(degs+mins/60+secs/3600)/180*pi;
                case 'sexagesimal DM'
                    % Pseudo unit. Format: sign - degrees - decimal point - integer
                    % minutes (two digits) - fraction of minutes (any precision).
                    % Must include leading zero in integer minutes.  Must exclude
                    % decimal point for minutes.  Convert to deg using algorithm.
                    degs =floor(abs(x1));
                    mins = 100*(abs(x1)-degs);
                    xSI = sign(x1).*(degs+mins/60)/180*pi;
                otherwise
                    error(['unable to convert to ''' sourceUoM ''' to an SI unit'])
            end
        end
    end

    %convert SI to target
    if ismember(targetUoM, {'metre','radian','unity'})
        x2 = xSI;
    else
        % check if conversion parameters are defined
        fact_b = STD.unit_of_measure.factor_b(ind2);
        fact_c = STD.unit_of_measure.factor_c(ind2);

        % check if conversion parameters are defined
        if ~isnan(fact_b+fact_c)

            % check if the parameter closely resembles pi. If so, replace by pi
            if abs(abs(fact_b)-pi)<0.001, fact_b=pi()*sign(fact_b); end
            if abs(abs(fact_c)-pi)<0.001, fact_c=pi()*sign(fact_c); end

            x2 = xSI*fact_c/fact_b;
        else %do something special for every predetermined case
            switch targetUoM
                case 'sexagesimal DMS'
                    % Pseudo unit. Format: signed degrees - period - minutes (2
                    % digits) - integer seconds (2 digits) - fraction of seconds
                    % (any precision). Must include leading zero in minutes and
                    % seconds and exclude decimal point for seconds. Convert to
                    % degree using formula.
                    xSI     = (xSI+100*eps)*180/pi; % eps is added to deal 
                                                    % with numerical precision
                    degs    = floor(abs(xSI));
                    mins    = floor((abs(xSI)-degs)*60);
                    secs    = ((abs(xSI)-degs)*60 - mins)*60;
                    x2      = sign(xSI).*(degs+mins/100+secs/10000);
                otherwise
                    error(['unable to convert ''' sourceUoM ''' to ''' targetUoM ''''])
            end
        end
    end
end
end