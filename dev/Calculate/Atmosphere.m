%Class with atmosphere related functions
%
% @author SDO
% @version
%

classdef Atmosphere < handle
    %Public properties
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %Stactic methods
    methods (Static)
        
    function [ RH ] = RelativeHumidity( Tdry, Tdew )
        % computes relative humidity
        % Tdry  dry-bulb (regular) temperature [°C]
        % Tdew  dewpoint temperature [°C]
        % RH    relative humidity [%] [0-100]

        es = Atmosphere.VaporPressure( Tdry );
        e = Atmosphere.VaporPressure( Tdew );

        RH = (e./es)*100;
    end 
 
    function [ e, es ] = VaporPressure( T )
        % Computes varpor pressure (Dampspanning)
        % using the 2nd method on http://www.theweatherprediction.com/basic/equations/
         % Clausius-Clapeyron equation
        % http://www.theweatherprediction.com/habyhints/161/
        
        % T : dry-bulb (regular) temperature to compute saturated vapour pressures
        %        or
        % T : dewpoint temperature to compute actual vapour pressure

        macht = (7.5*T)./(237.3+T);
        e = 6.11*10.^macht; 

        L = 2.453*1e6; 
        Rv = 461; 
        TK  = T+273.15;

        arg = L/Rv.*(1/273-1./TK); 
        es = 6.11*exp(arg); 
    end
    
    function [ Tw ] = WetBulbTempApprox( T, RH )
        % Approximation of the wet-bulb temperature
        % Stull, 2011, Wet-Bulb Temperature from relative humidity and air
        % temperature
        % Approximation for 1013.25 hPa
        Tw = T.*atan(0.151977.*sqrt(RH+8.313659)) + atan(T+RH) - atan(RH-1.676331) ... 
                + 0.00391838.*RH.^(3/2).*atan(0.023101*RH) -4.686035;
        % To use the figure of approximation 
        % K:\PROJECTS\14\14215_P007294 - Frequentieanalyse Meteoparameters\05-Data\WetBulbTemp 
        % or perhaps it is moved to the L-dreive
        Tw = min(Tw, T,'includenan'); % You wont get large deviations, this is for the record
    end


    end
end