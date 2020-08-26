% %Class to declare the most common Physics
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Physics < handle
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
        
        function c = coriolisCoef(latitude, omega)
            % determines coriolis coefficient
            %
            % c = coriolisCoef(latitude, omega)
            %
            if nargin==1
                omega = 2*pi/86400;
            end
            c = 2*omega*sind(latitude);
        end
        
        
        function [tau,shields] = calculateCriticalShear(dp,delta,rho,nu,g,method)
            % Calculates the critical shear strtess using the shileds equations
            %
            % [tau, shields] = calculateCriticalShear(dp,delta,rho,nu,g,method)
            % INPUTS:
            % - dp : grain size {m]
            % - delta (optional): rhop/rhof - 1 [-]  ;default = 1.65
            % - rho (optional): water density; default = 1000
            % - nu (optional): kinematic viscosity[m2/s]  ;default = 1e-6
            % -  g (optional): gravitational acceleration[m/s2]
            %        ;default = 9.81
            % -  method: calculation method
            %   - 'soulsby',   Soulsby & Whitehouse (1997)
            %   - 'browlie'    Brownlie (1981) (default)
            %   - 'vanrijn'    Van Rijn (1993)
            %
            % OUTPUTS:
            % - tau: the critical shear stress  [pascal]
            % - shields: dimensionless shields parameter [-]
            %
            switch nargin
                case 1
                    delta = 1.65;
                    rho = 1000;
                    nu =1e-6;
                    g = 9.81;
                    method = 'brownlie';
                case 2
                    rho = 1000;
                    nu =1e-6;
                    g = 9.81;
                    method = 'brownlie';
                case 3
                    nu =1e-6;
                    g = 9.81;
                    method = 'brownlie';
                case 4
                    g = 9.81;
                    method = 'brownlie';
                case 5
                    method = 'brownlie';
            end
            %% code
            
            % van Rijn (1993)
            dStar = (delta.*g./(nu.^2))^(1/3)*dp;
            dgd = rho.*delta*g*dp;
            switch lower(method)
                case 'vanrijn'
                    tau = dgd.*0.24./dStar.*(dStar<=4) + ...
                        dgd.*0.14./(dStar.^0.64).*(dStar>4).*(dStar<=10) + ...
                        dgd.*0.04./(dStar.^0.1).*(dStar>10).*(dStar<=20) + ...
                        dgd.*0.013.*(dStar.^0.29).*(dStar>20).*(dStar<=150) + ...
                        dgd.*0.055.*(dStar>150);
                case 'brownlie'
                    %% Curve fit Brownlie (1981)
                    
                    Rep = dp.*sqrt(delta.*g.*dp)./nu;
                    tau = dgd.*(0.22.*Rep.^(-0.6) + 0.06.* 10.^(-7.7.*Rep.^(-0.6)));
                    
                    %% Soulsby & Whitehouse (1997)
                case 'soulsby'
                    theta = 0.30./(1+1.2.*dStar) + 0.055.*(1- exp(-0.020.*dStar));
                    tau = g.*(delta.*rho).*dp.*theta;
                otherwise
                    error('Unknown critical shear stress equation');
            end
            shields = tau/(rho*delta.*g*dp);
        end
        
        function density = calculateDensity(temperature, salinity, pressure, method)
            % This function calculates the water density based on  the
            % temperature and salinity
            %
            % density = calculateDensity(temperature,salinity)
            % The function is using the same equation of state as Delft3D
            % (Eckart 1958). Other methods are:
            %   - EOS80: based unesco-formula.
            %
            %
            % INPUTS:-temperature: vector with Temperature data (in degrees Centigrade)
            %        -salinity: vector with Salinity data (in ppy)
            %        - pressure in dbar (not needed for eckart)
            %        - method: string of method (default: Eckart)
            % OUTPUTS:-
            %        -density: density [kg/m3]
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %% Written by: Alexander Breugem
            %
            % Date: Nov 2009
            % Modified by: jca (adding eos80)
            % Date: 2019
            
            if nargin < 3
               depth = ones(size(temperature));
            end
            
            if nargin < 4
                method = 'eckart';
            end
            
            switch lower(method)
                case 'eckart'
                    p0      = 5890+38.*temperature-0.375.*temperature.^2+3.*salinity;
                    lambda  = 1779.5+11.25.*temperature-0.0745.*temperature.^2-(3.8+0.01.*temperature).*salinity;
                    alpha   = 0.698;
                    density = 1000.*p0./(lambda+alpha.*p0);
                    
                case 'eos80'
                    density = density_of_seawater(temperature, salinity, pressure);                  
                otherwise
                    error('incorrect method are defined');
            end
            
        end
        
        function [salinity] = calculateSalinity(conductivity, temperature, waterPressure)
            % Calculate salinity based on conductivity, temperature and pressure data.
            %
            % salinity = calculateSalinity(conductivity, temperature, waterPressure)
            %
            % The equations follows following the 1978 Practical Salinity Scale (PSS) that forms the basis of an internationally accepted method.
            % The equations generate a new vector containing a column with the computed salinity values.
            %
            %
            % @param[in] conductivity (in [mS/cm])
            % @param[in] temperature (in °C)
            % @param[in] waterPressure (in dbar)
            % @param[out] salinity (in psu)
            
            % use short names
            c = conductivity;
            t = temperature;
            p = waterPressure;
            
            % default parameters
            a0 = 0.0080;
            a1 = -0.1692;
            a2 = 25.3851;
            a3 = 14.0941;
            a4 = -7.0261;
            a5 = 2.7081;
            
            b0 = 0.0005;
            b1 = -0.0056;
            b2 = -0.0066;
            b3 = -0.0375;
            b4 = 0.0636;
            b5 = -0.0144;
            k  = 0.0162;
            
            c0 = 0.6766097;
            c1 = 0.0200564;
            c2 = 0.0001104259;
            c3 = -0.00000069698;
            c4 = 0.0000000010031;
            
            d1 = 0.03426;
            d2 = 0.000464;
            d3 = 0.4215;
            d4 = -0.003107;
            
            e1 = 0.0002070;
            e2 = -0.0000000637;
            e3 = -0.000000000003989;
            
            % calculation of salinity
            R1 = c/42.914;
            R2 = 1 + (p.*(e1+e2.*p+e3.*p.^2)./((1+d1.*t+d2.*t.^2+(d3+d4.*t).*R1)));
            r  = c0+c1.*t+c2.*t.^2+c3.*t.^3+c4.*t.^4;
            
            R = R1./(R2.*r);
            deltaS = ((t-15)./(1+k.*(t-15))).*(b0+b1.*R.^0.5+b2.*R+b3.*R.^1.5+b4.*R.^2+b5.*R.^2.5);
            
            salinity     = a0+a1.*R.^0.5+a2.*R+a3.*R.^1.5+a4.*R.^2+a5.*R.^2.5+deltaS ;
        end
        
        function SpecConductivity = calculateSpecificConductivity(conductivity, temperature, reference)
            %   calculateSpecificConductivity calculates the specific conductance based on conductivity, temperature and reference temperature.
            %
            %   The used equation follows the YSI manual and is an
            %   internationally accepted method: Specific cond = Cond./(1+TC*(Temp-Tempref))
            %   The equations generate a new vector containing a column with the computed values.
            %
            % SpecConductivity = calculateSpecificConductivity(conductivity,temperature, reference)
            %
            % INPUT:
            %
            %
            % conductivity, (in mS/cm or ...)
            % temperature (in °C)
            % ref temperature in °C (default: 25°C)
            %
            %
            % OUTPUT:
            % specific conductance
            %
            % Written 09/2017, JCA
            
            if nargin < 3
                reference = 25;
            end
            TC = 0.0191;
            
            SpecConductivity  = conductivity./(1 + TC.*(temperature - reference));
            
        end
        
        function velocity = calculateSoundVelocity(temperature,salinity, depth, method)
            %   SoundVelocity calculates sound speed in water based on conductivity, temperature and pressure data.
            %
            %   Thee equations follows following the Urick (1983) that forms the basis of an internationally accepted method.
            %   The equations generate a new vector containing a column with the computed sound velocity values.
            %
            %velocity = calculateSoundVelocity(temperature,salinity, depth,method)
            %
            % INPUT:
            %
            %
            % temperature, (in °C)
            % salinity is ppt or psu
            % water depth (in metres)
            % method (optional): default urick (other mackenzie, to be define)
            %
            % mackenzie (1981): salty ocean water
            %
            % OUTPUT:
            % sound velocity (in m/s)
            %
            % Written 05/2017, JCA
            
            %
            
            % default settings
            if nargin < 4
                method = 'urick';
            end
            
            % methods
            switch lower(method)
                case 'urick' % method based on urick 1983
                    velocity = 1449.2 + 4.6.*temperature - 0.055.*temperature.^2+...
                        0.00029.*temperature.^3 + (1.34 - 0.01.* temperature).*(salinity - 35) + ...
                        0.016.*depth;
                    
                case 'mackenzie'
                    a1 = 1448.96;
                    a2 = 4.591;
                    a3 = -5.304e-2;
                    a4 = 2.374e-4;
                    a5 = 1.340;
                    a6 = 1.63e-2;
                    a7 = 1.675e-7;
                    a8 = -1.025e-2;
                    a9 = -7.139e-13;
                    
                    velocity = a1 + a2.*temperature + a3.*temperature.^2 + ...
                        a4.*temperature.^3 + a5.*(salinity - 35) + ...
                        a6.*depth + a7.* depth.^2 + ...
                        a8.*temperature.*(salinity-35) + a9.*temperature.*depth.^3;
                otherwise
                    error('Unknown sound of speed equation');
                    
            end
            
        end
        
        function  chlorid = calculateChlorid(temperature, conductivity, pressure, method)
            %   ChloridContent calculates chlorid content in water based on measured conductivity and temperature data.
            %
            %   The equations follows NDB-standard and the CL10 of Rijkswaterstaat.
            % Other need to be implemented
            %
            %chlorid = chloridContent(temperature,conductivity,pressure, method)
            %
            % INPUT:
            %
            %
            % temperature, (in °C)
            % conductivity (mS/cm)
            % water depth (in metres or dbar)
            % method (optional): default NDB (if no pressure avalaible
            % otherwise CL10)
            %
            %
            % OUTPUT:
            % chlorid (in mg/l)
            %
            % Written 05/2017, JCA
            
            %
            if nargin < 3
                method = 'ndb';
                pressure = ones(size(temperature));
            end
            if nargin < 4
                method = 'cl10';
            end
            
            switch lower(method)
                case 'meetpaalijsselmeer'
                    % EC20
                    EC20 = conductivity./(1+(0.0191*(temperature-20)));
                    mask = EC20 < 3 | isnan(EC20);
                    chlorid(mask,:) = 7.1165+4.637*EC20(mask,:).*10+1.9396*(EC20(mask,:).*10).^2-0.0424*(EC20(mask,:).*10).^3;
                    
                    
                    chlorid(~mask,:) = Physics.calculateChlorid(temperature(~mask,:), conductivity(~mask,:), pressure(~mask,:), 'cl10');
                    
                case 'cl10'
                    if isempty(pressure)
                        pressure = ones(size(temperature));
                    end
                    % conductivity ratio Rt
                    c0 = 0.6766097;
                    c1 = 2.00564e-2;
                    c2 = 1.104259e-4;
                    c3 = -6.9698e-7;
                    c4 = 1.0031e-9;
                    
                    G15 = 42.914;%4.291 S/m convert to mS/cm
                    rT = c0 + c1.*temperature + c2.*temperature.^2 + c3.*temperature.^3 + c4.*temperature.^4;
                    RT = conductivity./(G15.*rT);
                    
                    % chlorid
                    chlorid = nan(size(RT));
                    mask = RT >= 0.1;
                    
                    chlorid(mask,:) = Physics.calculateChloridHighConc(temperature(mask,:), conductivity(mask,:), pressure(mask,:));
                    chlorid(~mask,:) = Physics.calculateChloridLowConc(RT(~mask,:));
                    
                    
                case 'ndb'
                    B3 =9.56460e-10;
                    B4 = 6.63405e-08;
                    B5 = 2.18091e-06;
                    B6 = 1.22700e-04;
                    B7 = 2.00402e-02;
                    B8 = 6.76518e-01;
                    const15 = 42.91; % mS/cm
                    const18 = 45.89;
                    conductivity = conductivity*1000;
                    const = const15.*(((((-B3.*temperature+B4).*temperature-B5).*...
                        temperature+B6).*temperature+B7).*temperature+B8);
                    
                    k18 = const18./const.*conductivity;
                    chlorid = zeros(size(k18));
                    
                    mask = 200 < k18 & k18 <=1200;
                    chlorid(mask) =  0.0000958.*k18(mask).^2 + 0.139.*k18(mask)-16;
                    
                    mask = 1200 < k18 & k18 <=2500;
                    chlorid(mask) = 0.0000051.*k18(mask).^2+0.345.*k18(mask)-137;
                    
                    mask = 2500 < k18 & k18 <=12500;
                    chlorid(mask) =  0.000003.*k18(mask).^2+0.345.*k18(mask)-140;
                    
                    mask = 12500 < k18 & k18 <=19000;
                    chlorid(mask) =  0.0000014.*k18(mask).^2+0.38.*k18(mask)-330;
                    
                    mask = 19000 < k18 & k18<=19275;
                    chlorid(mask) =  0.0000014.*k18(mask).^2+0.38.*k18(mask)-340;
                    
                    mask = 19275 < k18 & k18 <=33000;
                    chlorid(mask) =  0.0000014.*k18(mask).^2+0.38.*k18(mask)-350;
                    
                    mask = 33000 < k18;
                    chlorid(mask) = 0.475.*k18(mask) - 1960;
                    
                otherwise
                    error('Unknown chlorid calculation method');
            end
            mask = isnan(temperature) | isnan(conductivity);
            chlorid(mask) = nan;
        end
        
        function chlorid = calculateChloridLowConc(RT)
            G18 = 45.89;
            Gtmp = RT.*G18;
            
            mask = 0.2 > Gtmp;
            chlorid(mask) = nan;
            
            mask = 0.2 <= Gtmp & Gtmp <=1.2;
            H0 = -16;
            H1 = 139;
            H2 = 95.8;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 1.2 < Gtmp & Gtmp <=2.5;
            H0 = -137;
            H1 = 345;
            H2 = 5.1;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 2.5 < Gtmp & Gtmp <=12.5;
            H0 = -140;
            H1 = 345;
            H2 = 3;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 12.5 < Gtmp & Gtmp <=19;
            H0 = -330;
            H1 = 380;
            H2 = 1.4;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 19 < Gtmp & Gtmp <=19.97;
            H0 = -340;
            H1 = 380;
            H2 = 1.4;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 19.97 < Gtmp & Gtmp <=33;
            H0 = -350;
            H1 = 380;
            H2 = 1.4;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
            
            mask = 33 < Gtmp;
            H0 = -1960;
            H1 = 457;
            H2 = 0;
            chlorid(mask) = H0 + H1.*Gtmp(mask) + H2.*Gtmp(mask).^2;
        end
        function chlorid = calculateChloridHighConc(temperature, conductivity, pressure)
            a0 = 999.842594;
            a1 = 6.793952e-2;
            a2 = -9.095290e-3;
            a3 = 1.001685e-4;
            a4 = -1.120083e-6;
            a5 = 6.536332e-9;
            
            b0 = 8.24493e-1;
            b1 = -4.0899e-3;
            b2 = 7.6438e-5;
            b3 = -8.2467e-7;
            b4 = 5.3875e-9;
            
            c0 = -5.72466e-3;
            c1 = 1.0227e-4;
            c2 = -1.6546e-6;
            d0 = 4.8314e-4;
            
            ROw = a0 + a1.*temperature + a2.*temperature.^2 + a3.*temperature.^3 ...
                + a4.*temperature.^4 + a5.*temperature.^5;
            S  = Physics.calculateSalinity(conductivity, temperature, pressure);
            
            RO = ROw + (b0 + b1.*temperature + b2.*temperature.^2 + b3.*temperature.^3 + b4.*temperature.^4).*S ...
                + (c0 + c1.*temperature + c2.*temperature.^2).*S.^(1.5) ...
                + d0.*S.^2;
            
            chlorid = S.*RO./(1.80655);
            
        end
        
        
        function ws = calculateSettling(dp,delta,nu,g,method,df,nf)
            % Calculates the settling velocity
            %
            % ws = calculateSettling(dp,delta,nu,g,method,df, nf)
            % INPUT: dp : grane size [m]. in case of winterwerp equation
            %        the diameter of the primary particles.
            %        delta (optional): rhop/rhof - 1 [-]  ;default = 1.65
            %        nu (optional): kinematic viscosity[m2/s]  ;default = 1e-6
            %        g (optional): gravitational acceleration[m/s2]
            %        ;default = 9.81
            %       method: calculation method
            %       'stokes',   Stokes equation (Rep < 1)
            %       'stokes2'   Stokes equation, with non-linear correction
            %       'winterwerp'  winterwerp settling equation for flocs
            %       'vanrijn'    Van Rijn (1993)
            %       'camenensand' Camenen(2007) for sand [default]
            %       'camenenmud' Camenen(2007) for mud
            %       'cheng': Cheng equation
            %       'chang':  %Chang and Liou
            %       'zhang': %Zhang & Xie (1993)
            %       df (only for winterwerp eq): floc diameter [m] (note
            %       can be constant or vector with the size of dp)
            %       nf (only for winterwerp eq): fractal dimension [-] (note
            %       can be constant or vector with the size of dp)
            
            % OUTPUT: ws: settling velocity [m/s]
            %
            %
            switch nargin
                case 1
                    delta = 1.65;
                    method = 'camenensand';
                    g = 9.81;
                    nu =1e-6;
                    
                case 2
                    
                    g = 9.81;
                    nu =1e-6;
                    
                    method = 'camenensand';
                case 3
                    g = 9.81;
                    
                    
                    method = 'camenensand';
                case 4
                    method = 'camenensand';
            end
            %% code
            %d*
            dStar=dp.*(delta.*g./nu.^2).^(1/3);
            %Stokes
            switch lower(method)
                
                case 'winterwerp'
                    nrPoin = max(numel(df),numel(dp));
                    ws =nan(1,nrPoin);
                    if numel(df) == 1
                        df = df.*ones(size(ws));
                    end
                    if numel(nf) == 1
                        nf = nf.*ones(size(ws));
                    end
                    if numel(dp) == 1
                        dp = dp.*ones(size(ws));
                    end
                    for  dd=1:length(df)
                        wsini=1e-3; err=1;
                        while err>1e-6
                            Rep=df(dd)*wsini/nu;
                            fRe=1+0.15*Rep^0.687;
                            ws2=delta*g*(df(dd).^(nf(dd)-1))*(dp(dd).^(3-nf(dd)))/(18*nu*(fRe));
                            err=abs(ws2-wsini);
                            wsini=ws2;
                        end
                        ws(dd)=ws2;
                    end
                case 'stokes'
                    ws=delta*g*dp.^2/(18*nu);
                    %max for Rep=1
                    
                case 'stokes2'
                    % wsSt(iout)=NaN;
                    %Stokes, large particle Reynolds
                    ws=nan(1,length(dp));
                    for dd=1:length(dp)
                        wsini=1e-3; err=1;
                        while err>1e-6
                            Rep=dp(dd)*wsini/nu;
                            
                            fRe=1+0.15*Rep^0.687;
                            
                            ws2=delta*g*dp(dd).^2/(18*nu*(fRe));
                            err=abs(ws2-wsini);
                            wsini=ws2;
                        end
                        ws(dd)=ws2;
                        %    if Rep>935 , break , end
                    end
                    
                    
                    
                    %Van Rijn
                case 'vanrijn'
                    ws=nan(1,length(dp));
                    ws(dp<1e-4)=delta*g*dp(dp<1e-4).^2/(18*nu);
                    ws(dp>=1e-4 & dp<1e-3)=((10*nu)./dp(dp>=1e-4 & dp<1e-3)).*(sqrt(1+(0.01*delta*g.*(dp(dp>=1e-4 & dp<1e-3)).^3)/nu^2)-1);
                    ws(dp>=1e-3)=1.1*sqrt(delta*g*dp(dp>=1e-3));
                    
                    %Camenen
                    %sand
                case 'camenensand'
                    A=24.6; B=0.96; m=1.53;
                    ws=(nu./dp).*(sqrt(0.25*(A/B)^(2/m)+((4*dStar.^3/(3*B))).^(1/m))-0.5*(A/B)^(1/m)).^m;
                    %flocs
                case 'camenenmud'
                    A=26.8; B=2.11; m=1.19;
                    ws=(nu./dp).*(sqrt(0.25*(A/B)^(2/m)+((4*dStar.^3/(3*B))).^(1/m))-0.5*(A/B)^(1/m)).^m;
                    
                    %Cheng
                case 'cheng'
                    ws=(nu./dp).*(sqrt(25+1.2*dStar.^2)-5).^1.5;
                    
                    %Chang and Liou
                case 'chang'
                    AA=delta*g*dp.^3/nu^2; al=30.22; be=0.463; ch=18;
                    ws=(nu./dp).*((al*AA.^be)./(ch*(1+al*AA.^(be-1))));
                    
                    %Zhang & Xie (1993)
                case 'zhang'
                    ws = sqrt((13.95*nu./dp).^2+1.09*(2.65-1)*g.*dp) - 13.95*nu./dp;
                otherwise
                    error('Unknown settling velocity equation');
                    
            end
            
        end
        
        function k = internalWaveNumber(omega, rho1,rho2,g)
            % calculates the wave number of an internal wave at an
            % interface
            %
            % k = internalWaveNumber(omega, rho1,rho2,g)
            %
            % INPUT:
            %       - omega: wave frequency [1/s]
            %       - rho1, rho2: density of top and bottom layer [kg/m3]
            %       - g: acceleration due to grvity (option; default = 9.81 m/s2)
            %
            % OUTPUT:
            %       - k: wave number [1/m]
            if nargin ==3
                g = 9.81;
            end
            gAcc = (rho2-rho1)./(rho1+rho2).*g;
            k = (omega.^2)./gAcc;
        end
        
        function uX = internalWaveVel(k,z,A,zInt)
            % calculates the velocity amplitude due to internal waves at an
            % interface
            %
            % uX = internalWaveVel(k,z,A,zInt)
            %
            % INPUT:
            %         -k: wave number [1/m]
            %         -z: elevation of output [m]; downwards irection is
            %             negative
            %          A: amplitude of the internal wave [m]
            %          zInt: (optional). elevation of the internal wave
            %                [m]. default = 0
            %
            % OUTPUT:
            %         uX: velocity amplitude [m/s]
            %
            if nargin ==3
                zInt = 0;
            end
            z = z-zInt;
            mask = z>=0;
            uX = mask.*A.*k.*exp(-k.*z) + ~mask.*A.*k.*exp(k.*z);
        end
        
        function nu = kinematicViscosity(T)
            % calculates the kinematic viscosity of sea water (ITTC, 1978)
            %
            % nu = kinematicViscosity(T,S)
            %
            % INPUT:
            % - T: temperature (in degrees centigrade)
            %
            % OUTPUT:
            % - nu: kinematic viscosity (in m2/s)
            
            nu = 1E-6.*(1.7688 + (0.659E-3.*(T-1) - 0.05076).*(T-1));
        end
        
        function [xyzOut,bOut,Cout,tOut,uvwOut,rhoOut,rhoWPlumeOut,Dout]=lagrangianPlume(varargin)
            % Lagrangian plume model from Lee and Cheung
            %
            % [xyzOut,bOut,Cout,tOut,uvwOut,rhoOut,rhoWPlumeOut,Dout]=Lagrange_Model_function_sediment(u,v,w,b2,rho,C,Ua,W0,rhoa,Depth)
            %
            % Theoretical framework based on Lee & Cheung (1990)
            %
            % INPUT (all scalars):
            %     - u,v,w: initial condition for flow velocity. u and v are optional
            %       (default: u = 0, v=0, w=1), w = required. Remark: w = positive downward!
            %     - b2: initial width of the plume times 2 [m]. This can be the
            %       diameter of the pipe in a dredging study or the propellor diameter for a shipping study.
            %     - rhoWPlume: initial density of the water in the plume (not including sediment) [kg/m3]
            %     - C: initial sediment concentration (kg/m3). If no
            %       sediments are present in the plume C=0.
            %     - velProf: flow velocity profile (m/s)
            %     - rhoProf: density of the ambient fluid (kg/m3)
            %     - zProf: density of the ambient fluid (kg/m3)
            %     - sMax (optional): maximum plume distance (default = 500 m)
            %     - depth: (optional) water depth (m) (default = infinity))
            %     - g (optional): gravitational acceleration (default = 9.81060 m/s^2)
            %     - rhoS (optional) = sediment density (default = 2650);
            %     - initDepth (optional) = initial plume depth (default = 0)
            %     - wMin (optional): stopping criterium. Not used for the moment.
            %
            % OUTPUT:
            %     - xyzOut: [Nx3] matrix with x, y and z coordinates of the plume.
            %         Note that y should normally be zero with the current implementation.
            %     - bOut: [Nx1]    vector with the the width of the plume (m)
            %     - Cout: [Nx1] vector with the concentration of the plume (kg/m3)
            %     - tOut: [Nx1] vector with the time of the output data
            %     - uvwOut: [Nx1] vector with the velocity
            %     - rhoOut: [Nx1] vector with the density of the sediment
            %       plume (kg/m3) (is equal to rhoWPlumeOut in case of no
            %       sediments)
            %     - rhoWPlumeOut: [Nx1] vector with the density of the
            %       water in the plume
            %     - Dout: [Nx1] vector with the dilution coefficient (-).
            %       This output is to be used to determine the dilution of a
            %       scalar (delta temperature, delta salinity, count of bacteries, ...)
            %
            % ASSUMPTIONS: 
            %     - The ambient fluid density and velocity can change over the vertical, 
            %       but are constant in space and time.
            
            %% Input parsing
            p = inputParser;
            addParameter(p,'u',0);
            addParameter(p,'v',0);
            addParameter(p,'w',1);
            addParameter(p,'b2',1);
            addParameter(p,'rhoWPlume',1025);
            addParameter(p,'C',1);
            addParameter(p,'sMax',500);
            addParameter(p,'depth',inf);
            addParameter(p,'g',9.81);
            addParameter(p,'rhoS',2650);
            addParameter(p,'initDepth',0);
            addParameter(p,'zProf',[0;1]);
            addParameter(p,'rhoProf',[0;1]);
            addParameter(p,'velProf',[0;1]);
            addParameter(p,'wMin',-inf); % left in for now
            
            
            parse(p,varargin{:});
            u=p.Results.u;
            v=p.Results.v;
            w=p.Results.w;
            b2=p.Results.b2;
            rhoWPlume=p.Results.rhoWPlume;
            C=p.Results.C;
            sMax=p.Results.sMax;
            depth=p.Results.depth;
            g=p.Results.g;
            rhoS=p.Results.rhoS;
            initDepth=p.Results.initDepth;
            zProf=p.Results.zProf;
            rhoProf=p.Results.rhoProf;
            velProf=p.Results.velProf;
            wMin = p.Results.wMin; % left in for now
            %% Constants
            % output interval
            outputInterval = 10 ;
            alf=1; %proportionality constant in the expression for Froude number (Lee&Cheung, eq 11b)
            
            
            %% Initial Conditions
            k    = 1;
            kOut = 1;
            Ca  = 0;
            b =  b2/2;
            D = 1; % dillution coefficient (starts at 1)
            
            % if w<=0
            %   error('w must be positive');
            % end
            
            % preallocate
            VERY_SMALL = 1e-16;
            MAXARR = 10000000;
            nrIter = 2;
            xyzOut  = zeros(MAXARR,3);
            bOut    = zeros(MAXARR,1);
            Cout    = zeros(MAXARR,1);
            tOut    = zeros(MAXARR,1);
            uvwOut  = zeros(MAXARR,3);
            rhoOut  = zeros(MAXARR,1);
            rhoWPlumeOut  = zeros(MAXARR,1);
            Dout    = zeros(MAXARR,1);
            
            %% Initialisation
            rho = rhoWPlume*(1-C/rhoS) + C;
            Vh = sqrt(u^2+v^2);  % initial horizontal velocity
            V  = sqrt(u^2+v^2+w^2);  % initial velocity
            if V==0
                error('No exit velocity for the jet defined: at least one of the initial velocities (u,v,w) should be positive.')
            end
            dt = 0.1*b/V;
            h = V*dt;
            ds  = V*dt;
            M  = pi*b^2*h*rho;
            sinphi  = w/V;
            cosphi  = Vh/V;
            if Vh>0
                sintheta = v(k)/Vh(k);
                costheta = u(k)/Vh(k);
            else % if no horizontal velocity present average initial angle
                sintheta = 0.5;
                costheta = 0.5;
            end
            xyz=[0 0 initDepth];
            s=0;
            dBdZ = 0;
            bold = 0;
            % store intial condition in memory
            xyzOut(1,:) = xyz;
            bOut(1)   = b;
            
            Cout(1)   = C;
            rhoOut(1)   = rho;
            rhoWPlumeOut(1) = rhoWPlume;
            rhoWPlumeZero = rhoWPlume; % UPDATE
            Dout(1) = 1;
            
            fprintf('M start = %.3f\n',M);
            
            update = false;
            %             fprintf('K S X Z M RHO C U W VH VTOT H B RHOWPLUME K\n');
            %             fprintf([repmat('%.3f ',1,15) '\n'],k,s,xyzOut(end,1),xyzOut(end,3),M,rho,C,u,w,Vh,V,h,b,rhoWPlume,k);
            %
            
            %% Loop
            % while (s<sMax && xyz(3)<depth && kOut< MAXARR && w>0.001 && dBdZ <= 10)
            while (s<sMax && xyz(3)<depth && kOut< MAXARR && w>wMin && dBdZ <= inf)
%             while (s<sMax && xyz(3)<depth && kOut< MAXARR && dBdZ <= inf) 
                
                % copy variablers
                M_i = M;
                rho_i = rho;
                C_i = C;
                u_i = u;
                v_i = v;
                w_i = w;
                Vh_i = Vh;
                V_i = V;
                h_i = h;
                b_i = b;
                sinphi_i = sinphi;
                cosphi_i = cosphi;
                sintheta_i = sintheta;
                costheta_i = costheta;
                xyz_i = xyz;
                ds_i = ds;
                rhoWPlume_i=rhoWPlume;
                D_i = D;
                
                % interate
                for i=1:nrIter
                    
                    rhoa = interp1q(zProf,rhoProf,xyz_i(end,3));
                    Ua = interp1q(zProf,velProf,xyz_i(end,3));
                    % shear entrainment
                    uacoscos = abs(Ua)*cosphi_i*costheta_i;
                    % Froude number
                    Fr = alf*abs(V_i-uacoscos)/sqrt(g*abs(rho_i-rhoa)*b_i/rhoa);
                    % Entrainment coefficient
                    E = sqrt(2)*(0.057+(0.554*sinphi_i)/Fr^2)/(1+5*uacoscos/abs(V_i-uacoscos));
                    % Mass increase due to entrainment
                    dMs = rhoa*2*pi*b_i*h_i*E*abs(V_i-uacoscos)*dt;
                    % Forced entrainment (correction)
                    if update
                        if i>1
                            dMf = rhoa*abs(Ua)*(2*b_i*sqrt(1-(cosphi_i*costheta_i)^2)*h_i + pi*b_i*(b_i-b)*cosphi_i*costheta_i + ...
                                0.5*pi*b_i^2*(cosphi_i*costheta_i-cosphi*costheta))*dt;
                        else
                            dMf= rhoa*abs(Ua)*h*b*( 2*sqrt(sinphi^2 + sintheta^2 - (sinphi*sintheta)^2) + ...
                                pi*(b-bold)*cosphi*costheta/ds + ...
                                0.5*pi*b*(cosphi*costheta-cosphiold*costhetaold)/ds)*dt;
                        end
                    else
                        dMf = 0.0;
                        update = true;
                    end
                    %         dMs,dMf
                    % Total entrainment
                    % 1/ max hypothesis
                    dM = max(dMs,dMf);
                    
                    if dM==0;
                        1;
                    end
                    
                    % intermediate value dependent variables
                    
                    % Mass
                    M_i = M + dM;
                    % state variables
                    C_i = (M*C + dM*Ca)/M_i;
%                     C_i = (M/rhoWPlume*C + dM/rhoa*Ca)/( M/rhoWPlume + dM/rhoa); % To be checked if more appriopriate
                    D_i = (M*D + dM*0)/M_i;
                    
                    rhoWPlume_i1 = (M+dM)/(M./rhoWPlume_i+dM/rhoa); % TO BE CHECKED WHAT IS MOST APPRIOPRIATE
%                     rhoWPlume_i2 = rhoa*(1-D_i)+D_i*rhoWPlumeZero; % TO BE CHECKED WHAT IS MOST APPRIOPRIATE

                    rhoWPlume = rhoWPlume_i1;
                    
                    rho_i = rhoWPlume_i*(1-C_i/rhoS) + C_i; % same to rhoWPlume_i in case of thermal and salinity plume with Csed=0
                    
                    % Momentum
                    % Horizontal
                    u_i = (M*u + dM*Ua)/M_i;
                    v_i = M*v/M_i;
                    % Vertical
                    gr = 9.8066*(rho_i-rhoa)/rho_i;
                    w_i = (M*w + M_i*gr*dt)/M_i;
                    Vh_i = max(sqrt(u_i^2 + v_i^2),VERY_SMALL);
                    V_i = sqrt(Vh_i^2 + w_i^2);
                    
                    % Thickness/radius
                    h_i = h*(V_i/V);
                    b_i = sqrt(M_i/(rho_i*pi*h_i));
                    
                    % orientationV
                    sinphi_i   = w_i/V_i;
                    cosphi_i   = Vh_i/V_i;
                    sintheta_i = v_i/Vh_i;
                    costheta_i = u_i/Vh_i;
                    
                    % Location
                    xyz_i = xyz + [u_i v_i w_i]*dt;
                    ds_i = V_i*dt;
                    
                    
                end
                if k>3
                    dBdZ = (b-bold)/(xyz_i(3)-xyz(3));
                end
                % copy data back
                M      = M_i;
                rho    = rho_i;
                C      = C_i;
                u      = u_i;
                v      = v_i;
                w      = w_i;
                Vh     = Vh_i;
                V      = V_i;
                h      = h_i;
                bold   = b;
                cosphiold = cosphi;
                costhetaold = costheta;
                b      = b_i;
                sinphi = sinphi_i;
                cosphi = cosphi_i;
                sintheta = sintheta_i;
                costheta = costheta_i;
                xyz = xyz_i;
                ds = ds_i;
                rhoWPlume = rhoWPlume_i;
                D = D_i;
                
                
                
                % time increment
                k = k+1;
                s = s + ds;
                % store in memory
                if mod(k-1,outputInterval)==0
                    xyzOut(kOut,:) = xyz;
                    bOut(kOut)   = b;
                    Cout(kOut)   = C;
                    tOut(kOut)   = k*dt;
                    uvwOut(kOut,:)  = [u v w];
                    rhoOut(kOut) = rho;
                    rhoWPlumeOut(kOut)=rhoWPlume;
                    Dout(kOut) = D;
                    kOut = kOut + 1;
                end
                
                %                 fprintf([repmat('%.3f ',1,15) '\n'],k,s,xyzOut(end,1),xyzOut(end,3),M,rho,C,u,w,Vh,V,h,b,rhoWPlume,k);
                %                 return;
                
                
            end
            % delete unused variables
            if kOut<=MAXARR
                xyzOut(kOut:end,:) = [];
                bOut(kOut:end) = [];
                Cout(kOut:end) = [];
                tOut(kOut:end) = [];
                rhoOut(kOut:end) = [];
                rhoWPlumeOut(kOut:end) = [];
                uvwOut(kOut:end,:) = [];
                Dout(kOut:end) = [];
            end
            fprintf('M end = %.3f\n',M);
            
        end
        
        
        function nusselt = nusseltPipe(u,D,nu,kw,rho,cp,method,isCooling)
            % calculates the nusselt number in a smooth turbulent pipe flow
            %
            % nusselt = nusseltPipe(u,D,nu,kw,rho,cp,method,isCooling)
            %
            % INPUT:
            %  - u: velocity in the pipe
            %  - D: pipe diameter
            %  - nu, kw, rho, cp: (optional): viscosity (m2/s), thermal
            %  conduictivity (W/mK), density (kg/m3), specific heat capacity (J/kg/K) . default values are
            %  for seawater
            %  - method: options are 'gnielinksy' (default) and 'dittus-boelter'
            %  - isCooling: (optional))
            % OUTPUT:
            %
            %
            % REFERENCES:
            % - https://en.wikipedia.org/wiki/Nusselt_number
            
            
            % default options
            if nargin < 7
                method = 'gnielinsky';
            end
            if strcmpi(method,'dittus-boelter') && nargin < 8
                error('Cooling data needed for the dittus-boelter relation');
            end
            if nargin < 6
                cp = 4185.5;
            end
            if nargin < 5
                rho = 1025;
            end
            if nargin < 4
                kw =  0.6;
            end
            if nargin < 3
                nu = 1e-6;
            end
            
            % Reynolds and Prandtl number
            Re = u.*D./nu;
            Pr = nu.*cp.*rho./kw;
            
            %
            switch lower(method)
                case 'gnielinsky'
                    f = (0.79.*log(Re)-1.64).^-2;
                    f8 = f./8;
                    nusselt = f8.*(Re-1000.0).*Pr./(1+12.7.*sqrt(f8).*(Pr.^(2/3)-1));
                    % check applicability
                    outOfRange = Pr < 0.5 | Pr > 2000 | Re<3000 | Re >5e6;
                    if any(outOfRange)
                        warning([num2str(sum(outOfRange)),' have values that are out of range']);
                    end
                case 'dittus-boelter'
                    n = isCooling.*0.3  + (1-isCooling).*0.4;
                    nusselt  =0.023.*Re.^0.8.*Pr.^n;
                    outOfRange = Pr < 0.6 | Pr > 160 | Re<10000;
                    if any(outOfRange)
                        warning([num2str(sum(outOfRange)),' have values that are out of range']);
                    end
                    
                otherwise
                    error('Unknown method');
            end
        end
        
        
        function C = plumeConc(x,y,z,t,D,U,m,k,xyz0,H,tEnd,nrReflec)
            % 3D analytical solution of the plume concentration with time
            %
            % C = plumeConc(x,y,z,t,D,U,m,xyz0,H,tEnd,nrReflec)
            %
            % INPUT:
            %      - x, y, z: scalar, vector, matrix, 3d or 4d array with coordinate
            %      points. The flow is assumed to be in the x direction. The bed is at
            %      z = 0.
            %      - t      : scalar or vector, matrix, 3d or 4d array with the time at which output is wanted
            %      - D: diffusion coeffcient [m2/s].  Either a scalar or or vector containing
            %      (Dxx, Dyy and Dzz)
            %      - U : flow velocity in the X direction [m/s]. Scalar or
            %      2x1 vector (with x component and z component (for
            %      settling). In that case, there is no reflections
            %      (nrReflxc must be 0).
            %      - m:  tracer flux []. Scalar.
            %      - k: reaction term (default = 0)
            %      - xyz: 1x3 vector containing the coordinates of the source
            %      - H:  water depth.
            %      - tEnd; the end time of simulatation. 0 means not taken
            %      into account (default = 0).
            %      - nrReflec: nr  of reflections on the bed and the free surface(default = 0)
            % OUTPUT:
            %      - C: Concentration
            %
            % REFERENCES:
            %      - Sokolofsky and Jirka (2005).
            %        CVEN 489-501: Special Topics in Mixing and Transport Processes in the Environment
            % "K:\DATA\bibliotheek\D Technical Information\D08_algemeen_civiele techniek_milieu\D.8.1_Hydraulica\D.8.1.3_Sedimentatie-erosie\D.8.1.3.1_Sediment Transport\morphology\analytical cases - validation\BookMixing_Socolofsky_Jirka.pdf"
            
            % code
            
            
            
            % preprocess parameters
            if nargin < 12
                nrReflec = 0;
            end
            if nargin < 12
                tEnd = 0;
            end
            
            if nargin < 8
                k = 0;
            end
            if nargin <10
                H = max(z);
            end
            if nargin >9
                x0 = xyz0(1);
                y0 = xyz0(2);
                z0 = xyz0(3);
            else
                x0 = 0;
                y0 = 0;
                z0 = 0;
            end
            % transform coordinates
            x = x-x0;
            y = y-y0;
            z = z-z0;
            % Diffusion coefficients
            if numel(D)==3
                Dxx = D(1);
                Dyy = D(2);
                Dzz = D(3);
            elseif numel(D)==1
                Dxx = D;
                Dyy = D;
                Dzz = D;
            else
                error('Wrong size for D');
            end
            if numel (U) ==2
                settling = true;
                theta = atan2(U(2),U(1));
                % change coordinates in order to include settling velocity
                [xTmp,zTmp] = Calculate.rotateVector(x,z,-theta,'radians');
                U = sqrt(sum(U.^2));
                if nrReflec~=0
                    error('No reflections are allowed');
                end
            elseif numel(U)~=1
                error('Wrong dimension for U. Must be 1 or 2.');
            else
                settling = false;
            end
            
            C = Physics.plumeLowLevel(x,y,z,t,U,k,Dxx,Dyy,Dzz,m,tEnd);
            
            % reflections
            zT = H-z0;
            for i=1:nrReflec
                isEven = mod(i,2)==0;
                for j=1:2
                    if j ==1
                        % reflection on the bed
                        zTmp  = z0 + isEven.*(zT-z) + ~isEven.*(z-z0) + (i-1)*H;
                    else
                        % reflection on the free surface
                        zTmp  = zT + ~isEven.*(zT-z) + isEven.*(z-z0) + (i-1)*H;
                    end
                    Ctmp = Physics.plumeLowLevel(x,y,zTmp,t,U,k,Dxx,Dyy,Dzz,m,tEnd);
                    C    = C +  Ctmp;
                end
            end
            
            
            % use coordinate transform to calculate settling
            if settling
                interpC = scatteredInterpolant(xTmp(:),y(:),zTmp(:),C(:),'linear','none');
                C = interpC(x,y,z);
                % cut off the bed.
                C(z+z0<0) = nan;
                % cut off the surface.
                C(z+z0>H) = nan;
            end
            
            % interpolate back to originial coordinates
            
        end
        
        function C = plumeLowLevel(x,y,z,t,U,k,Dxx,Dyy,Dzz,m,tEnd)
            % low level plume concentrartion function
            %
            % No documentation needed, bevcause you are now supposed to
            % call it directly
            
            useEnd = tEnd>0;
            VERY_HIGH = realmax;
            alpha = x.^2 ./ (4.*Dxx) + ...
                y.^2 ./ (4.*Dyy) + ...
                z.^2 ./ (4.*Dzz);
            
            beta       =  U^2/(4.*Dxx) + k;
            xT         =  x.*U./(2.*Dxx);
            gammaV     =   m.*exp(xT)./(4.*pi.*sqrt(4.*pi.*Dxx.*Dyy.*Dzz));
            gammaV     =   min(gammaV,VERY_HIGH);
            sqrtBT     =   sqrt(beta .*t);
            
            
            % without reflections
            sqrt2AB    = 2.*sqrt(alpha.*beta);
            const      = min(gammaV.*sqrt(pi)./(2.*sqrt(alpha)),VERY_HIGH);
            sqrtAT     =  sqrt(alpha./t);
            
            if useEnd
                dt       =  t-tEnd;
                if numel(t)>1
                    sqrtADT  =  inf*ones(size(sqrtAT));
                    sqrtBDT  =  ones(size(sqrtBT));
                    mask     =  t>tEnd;
                    sqrtADT(mask)  =  sqrt(alpha(mask)./dt(mask));
                    sqrtBDT(mask)  =  sqrt(beta .*dt(mask));
                elseif t > tEnd
                    sqrtADT  =  sqrt(alpha./dt);
                    sqrtBDT  =  sqrt(beta .*dt);
                else
                    sqrtADT  =  inf*ones(size(sqrtAT));
                    sqrtBDT  =  ones(size(sqrtBT));
                end
                firstTimeTerm    =  erf(sqrtADT+sqrtBDT);
                secondTimeTerm   =  erf(sqrtADT-sqrtBDT);
            else
                firstTimeTerm  = 1;
                secondTimeTerm = 1;
            end
            firstTerm  =  min(exp(sqrt2AB),VERY_HIGH).*(firstTimeTerm-erf(sqrtAT+sqrtBT));
            secondTerm =  exp(-sqrt2AB).*(secondTimeTerm-erf(sqrtAT-sqrtBT));
            % concentration
            C          = const.*(firstTerm + secondTerm);
            
        end
        
        function C = plumeStat(x,y,z,U,k,Dxx,Dyy,Dzz,m)
            % stationary plume
            %
            % No documentation needed, because you are now supposed to
            % call it directly
            
            VERY_HIGH = realmax;
            alpha = x.^2 ./ (4.*Dxx) + ...
                y.^2 ./ (4.*Dyy) + ...
                z.^2 ./ (4.*Dzz);
            
            beta       =  U^2/(4.*Dxx) + k;
            xT         =  x.*U./(2.*Dxx);
            gammaV     =   m.*exp(xT)./(4.*pi.*sqrt(4.*pi.*Dxx.*Dyy.*Dzz));
            gammaV     =   min(gammaV,VERY_HIGH);
            sqrt2AB    = 2.*sqrt(alpha.*beta);
            const      = min(gammaV.*sqrt(pi)./(sqrt(alpha)),VERY_HIGH);
            % concentration
            C          = const.*exp(-sqrt2AB);
            
        end
        
        function tempSitu = potential2situTemp(tempPot,sal,zLev)
            % Convert potential to in-situ temperature
            %
            % tSitu = potential2situTemp(tempPot,sal,zLev);
            
            % Constants
            rho0 = 1025; % Initial guess for rho
            g = 9.81; %McGee's constant
            
            if median(diff(zLev(:,1)))>0;
                flipped = true;
                tempPot = flipud(tempPot);
                sal = flipud(sal);
                zLev = flipud(zLev);
            else
                flipped = false;
            end
            
            %Initialize
            dens = rho0*ones(size(tempPot));
            pres = zeros(size(tempPot));
            iter = 0;
            dfr = 1e6;
            nZ = size(tempPot,1);
            
            % Calculate density iteratively
            while dfr > 1e-3 && iter <10
                densOld = dens;
                
                for iZ = 2:nZ
                    pres(iZ,:) = pres(iZ-1,:) + 1e-4 * mean(dens(iZ+[-1 0],:)) .* g .* diff(zLev(iZ+[0 -1],:));
                end
                
                dens = rho_from_theta(sal,tempPot,pres);
                dfr = max(abs(dens(:)./densOld(:)-1));
                iter = iter+1;
            end
            
            ct = ct_from_theta(sal,tempPot);
            tempSitu = t_from_ct(sal,ct,pres);
            
            if flipped
                tempSitu = flipud(tempSitu);
            end
        end
        
        function c = rouseProf(z,z0,H,c0,uStar,ws)
            % calculates the rouse profile for sediment
            %
            % c = rouseProf(z,z0,H,c0,uStar,ws)
            %
            % INPUT:
            % - z: elevation above bottom
            % - z0: reference level
            % - H:water depth
            % - c0: reference concentration at z = z0
            % -suStar: friction velocity
            % - ws: settling velocity 
            % OUTPUT:
            %
            kappa =0.41;
            R = ws./(kappa.*uStar);
            cProf = (1-H./z)./(1-H./z0);
            cProf = cProf.^R;
            c =c0.*cProf;
            
        end
        
        function cf = cd2rough(law,cd,H,g)
            % determines a friction coeffcient from a cd value
            %
            % cf = cd2rough(law,cd,H,g)
            %
            % INPUT:
            % - H: water depth or hydaulic radius
            % - law: friction law: options are 'chezy','strickler',
            % 'manning', 'nikuradse,'z0'
            % - cd value (cd = u*^2/U^2)
            % - g: acceleration due to gravity
            %
            % OUTPUT:
            % - cf: friction coefficient
            switch lower(law)
                case 'chezy'
                    cf = sqrt(g./cd);
                case 'strickler'
                    cf = sqrt(cd.*(H.^(1/3)./g));
                    cf = 1./cf;
                case 'manning'
                    cf = sqrt(cd.*(H.^(1/3)./g));
                case 'nikuradse'
                    cf = H./(exp(1+0.4./sqrt(cd)));
                    cf = cf.*30;
                case 'z0'
                    cf = H./(exp(1+0.4./sqrt(cd)));
                otherwise
                    error('Unknown friction law');
            end
        end
        
        function cf = rough2rough(lawOrig,lawNew,cf,H,g)
            % convert roughness between different equations
            %
            % cf = rough2rough(lawOrig,lawNew,cf,H,g)
            %
            % INPUT:
            % - H: water depth or hydaulic radius
            % - lawOld, lawNew: friction law: options are 'chezy','strickler',
            % 'manning', 'nikuradse,'z0'
            % lawOrig is the law you are converting from. lawnew isn the
            % new friction law
            % - cf: friction coefficient
            % - g: acceleration due to gravity
            %
            % OUTPUT:
            % - cf: converted friction coefficient
            cd = Physics.rough2cd(lawOrig,cf,H,g);
            cf = Physics.cd2rough(lawNew,cd,H,g);
        end
        
        function cd = rough2cd(law,cf,H,g)
            % gets cd coeffcient from a friction law
            %
            % cd = rough2cd(law,cf,H,g)
            %
            % INPUT:
            % - H: water depth or hydaulic radius
            % - law: friction law: options are 'chezy','strickler',
            % 'manning', 'nikuradse,'z0'
            % - cf: friction coefficient
            % - g: acceleration due to gravity
            %
            % OUTPUT:
            % - cd value (cd = u*^2/U^2)
            switch lower(law)
                case 'chezy'
                    cd = g./cf.^2;
                case 'strickler'
                    cf = 1./cf;
                    cd = g.*cf.^2./(H.^(1/3));
                case 'manning'
                    cd = g.*cf.^2./(H.^(1/3));
                case 'nikuradse'
                    cf = cf./30;
                    cd = (0.4./(log(H./(exp(1).*cf)))).^2;
                case 'z0'
                    cd = (0.4./(log(H./(exp(1).*cf)))).^2;
                otherwise
                    error('Unknown friction law');
            end
            
        end
        
        function tc  = shearCurrent(u,k,H,rho)
            % shear stress due to currents (using Nikuradse)
            %
            % tc  = shearCurrent(u,k,H)
            %
            % INPUT: u: mean flow velocity [m/s]
            %        k: Nikuradse roughness length[m]
            %        H: water depth [m]
            %        rho: water density (optional; default = 1025kg/m3) [kg/m3]
            % OUTPUT: tc: kinematic shear stress due to currents [m2/s];
            % This still needs to be multiplied by rho!!!!
            if nargin ==3
                rho = 1025;
            end
            kappa = 0.41;
            z0    = k./30;
            cd    = (kappa./log(H./(z0.*exp(1)))).^2;
            tc = rho.*cd.*u.^2;
        end
        
        function tw = shearWave(Hs,tp,h,ks,rho,method)
            %shear stress due to waves waves (using Swart 1974)
            %
            %tw = shearWave(hs,tp,H,k)
            %
            % INPUT: Hs: wave height [m]
            %        tp: wave period [s]
            %         h: water depth [m]
            %       rho: water density (optional, default = 1025) [kg/m3]
            %       ks: Nikuradse roughness length[m]
            %
            % OUTPUT: tw: shear stress amplitude due to currents [N/m^2];
            
            if nargin<5;
                rho =1025;
            end
            if nargin<6;
                method = 'swart';
            end
            % convert parameters
            g = 9.81;
            sigma = 2.*pi./tp;
            a = Hs./2;
            
            switch method
                case 'roulund'
                    % See paper of Roulund 2016
                    uOrb = Hs/(2*sqrt(2)) * sqrt(g/h) * ...
                        exp(-(3.65/tp * sqrt(h/g))^(2.1));
                otherwise
                    % dispersion
                    kWav = Physics.waveDispersion(sigma,h,g);
                    % near bed velocities
                    kH = kWav.*h;
                    uOrb = sigma.*a./sinh(kH);
                    
            end
            % orbital excursion
            aOrb =  uOrb.*tp./(2*pi);
            % friction
            z0 = ks/30;
            
            r = (aOrb./ks);
            
            switch method
                case 'swart'
                    fWr = exp(-5.977+5.213.*r.^(-0.194));
                    fWr(r<1.59) = 0.3;
                case 'soulsby'
                    % using Souslby
                    fWr = 1.39.*(aOrb/z0).^-0.52;
                case 'roulund'
                    fWr(r<2.92) = 0.32 *r.^(-0.8);
                    fWr(r>=2.92&r<727) = 0.237 *r.^(-0.52);
                    fWr(r>=727) = 0.04 *r.^(-0.25);
                    
            end
            tw  = 0.5.*rho.*fWr.*uOrb.^2;
            
        end
        
        
        function vR = propellorFlow(xIn,yIn,zIn,zProp,dProp,pw,yPropellor,alpha,rhof,method)
            % calculate the flow due to propellorwash
            %
            % vR = propellorFlow(xIn,yIn,zIn,zProp,dProp,pw,yPropellor,alpha,rhof,method,draught)
            %
            %INPUT
            %
            % -xIn, yIn, zIn: coordinate arrays with the location where the
            % propellor wash is calculated in [m]
            %       Note: x is the direction of the jet
            %             y is perpendicular to the jet. y = 0 is assumed to be
            
            %z = 0 is assumed to be the bed and z is positive upward
            % -zProp: the elevation of the propellor
            % -dProp: diameter of the propellor [m]
            % -pw: the effective power of the propellor [W]; so multiply with 1000 if you
            % have it in kw and multiply with the percentane of force applied (so fp*pw)
            % -yPropellor (optional): array with the y-coordinates of each propellor
            % -alpha (optional): direction of the propellor jet (in degrees); default = 0
            % -rhof (optional): the water density (default 1025 kg/m3)
            % -method (optional): calculation method. options are 'dutch ducted', 'dutch unducted'
            % (default) and 'german'
            % OUTPUT: vR: the velocity due to the propellor wash
            %
            
            
            % default parameters
            if nargin <7
                yPropellor = 0;
            end
            if nargin <8
                alpha = 0;
            end
            if nargin <9
                rhof = 1025;
            end
            if nargin <10
                method = 'dutch ducted';
            end
            method = lower(method);
            
            
            % define z to be relative to the sjip axis
            % define new mesh
            zIn = zProp - zIn;
            [x,z] = Calculate.rotateVector(xIn,zIn,alpha);
            
            % define input velocity (v0
            v0 = 1.48.*(pw./(rhof.*dProp.^2)).^0.33;
            [method,ducted] = strtok(method);
            ducted = strtrim(ducted);
            % add each propellor separately
            vR = zeros(size(x));
            nrPropellor  = length(yPropellor);
            for i=1:nrPropellor
                y = yIn-yPropellor(i);
                r = sqrt(y.^2+z.^2);
                switch method
                    case 'dutch'
                        if strcmpi(ducted,'ducted')
                            A = 2.8;
                        else
                            A = 2.0;
                        end
                        vX = A.*v0.*dProp./x;
                        vX = min(vX,v0);
                        vTmp = vX.*exp(-15.4.*(r./x).^2);
                    case 'german'
                        A     = 1.88.*exp(-0.161.*zProp./dProp);
                        vX    = A.*v0.* (dProp./x).^0.6;
                        vX    = min(vX,v0);
                        vTmp    = vX.*exp(-22.2.*(r./x).^2);
                    otherwise
                        error('Invalid method');
                end
                vR = vR + vTmp.^2;
                
            end
            vR = sqrt(vR);
        end
        
        
        
        function [tm,tmax] = shearWaveCurrent(tc,tw,phi)
            % combined mean wave current bed shear stress using Soulsby (1995)
            %
            % [tm,tmax] = shearWaveCurrent(tc,tw,phi)
            %
            % INPUT: tc: shear stress due to currents
            %        tw: shear stress due to waves
            %       phi (optional): direction between waves and currents
            %       (in radians). It mus be between 0 and 0.5 pi. It is
            %       only needed when tmax is calculated
            %
            %OUTPUT   tm: average shear stress (during a wave period) due to waves and currents
            %combined
            %         tmax(optional): maximum shear stress (during a wave
            %         period) due to waves and currents combined.
            %         Directions are needed to calculate this.
            
            x  = tw./(tc+tw);
            tm = tc.*(1+1.2.*x.^3.2);
            if nargout ==2
                if nargin==3
                    tmax = sqrt((tm + tw.*cos(phi)).^2 + (tw.*sin(phi)).^2);
                else
                    error('The direction is necessary to calculate the maximum wave shear stress');
                end
            end
        end
        
        function rh = relativeHumidity(sh,p,t)
            % calculates relative humidity form the specific humidity
            %
            % rh = relativeHumidity(sh,p,t)
            %
            % INPUT:
            % - sh: specific humidity [-]
            % - t:  air temperature [deg C]
            % - p:  air pressure [Pa]
            % OUTPUT:
            % - rh: relative humidity [%]
            % NOTE: This function uses degrees Centigreed
            
            T0 = 273.16;
            % conversion to kelvin
            T = t +T0;
            tmp = 17.67.*(T-T0)./(T-29.65);
            rh = 0.263.*p.*sh./exp(tmp);
        end
        
        function rh = relativeHumidityDew(tDew,t)
            % calculates relative humidity from dewpoint temperature
            %
            % rh = relativeHumidityDew(tDew,t)
            %
            % INPUT:
            % - tDew: dewpoint temperature [K]
            % - t:  air temperature [K]
            % OUTPUT:
            % - rh: relative humidity [%]
            %
            % NOTE: This function uses degrees Kelvin
            
            eSat = 611.21 .* exp(17.502 * (tDew-273.16)./(tDew+0.7));
            e = 611.21 .* exp(17.502 * (t-273.16)./(t+0.7));
            rh = 100*eSat./e;
            
        end
        
        function q = sedTrans(method,u,delta,g,dp,cd)
            % calculates sediment transport rates
            %
            %  q = sedTrans(method,u,delta,g,dp,cd)
            %
            %
            
            switch lower(method)
                case 'engelundhansen'
                     uStar = sqrt(cd).*u;
                     q = 0.05/cd.*delta.^(-2).*g.^0.5.*dp.^(-1)*uStar.^5;
                case 'vanrijn2007'
                    % todo
                case 'mpm'
                    %todo
                otherwise
                    error('Method not implemented');
            end
        end
        
        function u = velProf(uMean,z,z0,kappa)
            % calculates logarithmic velocirty profile
            %
            % u = velProf(uMean,z,z0,kappa)
            %
            h = max(z);
            cd = Physics.rough2cd('z0',z0,h,9.81);
            uStar = sqrt(cd).*uMean;
            u = uStar./kappa.*log(z./z0);
            
        end
        
        function [c,cg,L,E,F,Ub,Dm]=waveAnalyze(H,T,h)
            %
            %
            %Input parameters:
            %-H, wave height in m
            %-T, wave period in s
            %-h, water depth in m
            %
            %Output:
            %-c, wave celerity in m/s
            %-cg, group velocity in m/s
            %-L, wave length in m
            %-E, wave energy density in J/m
            %-F, energy flux in J/s
            %-Ub, maximum orbital velocity at the bed in m/s
            %-Dm, maximum wave orbital diameter at the bed in m  (according to linear
            %wave theory)
            
            %Define constants
            g=9.81;
            rho=1025;
            om=2*pi/T;%omega, wave radial frequency
            
            %Solve wave dispersion relation iteratively
            
            %Initial value using Eckart (1951)
            kInit=om^2/(g*sqrt(tanh(om^2*h/g)));
            kNew=kInit;
            kOld=kNew*1000;
            i=0;
            
            %Iterate using Newton-Raphson scheme
            while abs((kNew-kOld)/kOld)>10^-5
                if i>100 break; end
                kOld=kNew;
                i;
                fk=(om^2-g*kOld*tanh(kOld*h));
                fkDeriv=(-g*tanh(h*kOld)-g*kOld*h/cosh(kOld*h)^2);
                kNew=kOld-fk/fkDeriv;
                i=i+1;
                %    fprintf('i=%3.0g; k=%3.6g delta=%3.3g \n',i,kNew,abs((kNew-kOld)/kOld));
            end
            %disp(['Newton-Raphson solving of dispersion relation took ' num2str(i) ' iterations.']);
            k=kNew;
            
            %Find some more parameters based on the found k
            L=2*pi/k;
            c=om/k;
            cg=c*1/2*(1+2*k*h/sinh(2*k*h));
            E=1/8*rho*g*H^2;
            F=E*cg;
            Ub=H*om/(2*sinh(k*h));
            Dm=H/sinh(k*h);
        end
        
        function [c,cg,n] = waveCelerity(sigma,H,k)
            %calculates wave phase and group velocity
            %
            %[c,cg,n] = waveCelerity(sigma,H,k)
            %
            % INPUT:
            % sigma: The wave frequency (2pi/T)
            % H:     The water depth
            % k : The wave number (2pi/L); calculate with waveDispersion
            % (optional); if not given calculated automatically assuming
            % g = 9.81 m/s^2
            %
            % OUTPUT:
            % c: phase velocity
            % cg: group velocity
            % n: group velocity devided by phase velocity
            
            if nargin==2
                g = 9.81;
                k = Physics.waveDispersion(sigma,H,g);
            end
            c = sigma./k;
            kH = k.*H;
            n = 0.5.*(1+2.*kH./sinh(2.*kH));
            cg = n.*c;
            
        end
        
        
        function k = waveDispersion(sigma,H,g) 	
            % calculates the wave number from the wave frequency (using the
            % approximate relation from 
            %
            % Hunt, John N. "Direct solution of wave dispersion equation." Journal of the Waterway, Port, Coastal and Ocean Division 105.4 (1979): 457-459.
            %
            % k = waveDispersion(sigma,H,g)
            %
            % INPUT:
            % sigma: The wave frequency (2pi/T)
            % H:     The water depth
            % g:     The acceleration due to gravity
            % OUTPUT:
            % k : The wave number (2pi/L)
            
            tmp = sigma.^2 .*H./g;
            tmp = tmp + (1.0 + 0.6522.*tmp + 0.4622.*tmp.^2 + 0.0864.*tmp.^4 + 0.0675.*tmp.^5).^(-1);
            k   = sigma.*(sqrt(tmp./(g.*H)));
            
        end
        
        function [u,w,dudt,dwdt] = waveVelocity(Hs,sigma,z, k, H)
            % calculates vertical profiles of orbital velocity amplitude
            %
            % [u,w] = waveVelocity(Hs,sigma,z, k, H)
            %
            % INPUT:
            % -sigma: The wave frequency (2pi/T)
            % -k: wave number (2pi/L)
            % -H:     The water depth.
            % -Hs:    Wave height
            % -z: vertical elevation. 0 at fgree surface -H at the bed
            % OUTPUT:
            % -u: horizontal velocity amplitude
            % -w: vertical velocity amplitude
            % -dudt: horizontal velocity acceleration amplitude
            % -dwdt: vertical velocity acceleration amplitude
            vertProfU = cosh(k.*(z+H))./sinh(k.*H);
            vertProfW = sinh(k.*(z+H))./sinh(k.*H);
            T   = 2*pi./sigma;
            tmp = pi.*Hs./T;
            u  =  tmp.*vertProfU;
            w  =  tmp.*vertProfW;
            tmp = 2.*pi.^2.*Hs./T.^2;
            dudt  =  tmp.*vertProfU;
            dwdt  =  tmp.*vertProfW;
        end
        
        function u  = windFromBeaufort(uBf)
            %converts wind in Beaufort to m/s
            %
            % u  = windFromBeaufort(uBf)
            u = 0.836.*uBf.^1.5;
        end
        
        function uBf  = windToBeaufort(u)
            %converts wind in m/s to Beaufort
            %
            % uBf  = windToBeaufort(u)
            uBf = (u./0.836).^(2/3);
            uBf = round(uBf);
            uBf = min(uBf,12);
        end
        
        
        function [z0,uStar] = windDrag(u10,method,sctOpt)
            % calculates wind drag using charnock's relation.
            %
            %  [z0,uStar] =  windDrag(u10,method,sctOpt)
            %
            % INPUT
            %  - u10: wind velocities [m/s] at a reference height (default =
            %  10 m)
            %  - method (optional): method to use. Currently only 'charnock'
            %  is implemented
            %  - sctOpt(optional): structure with optional parameters
            %
            % OUTPUT
            % - z0 : roughness length [m]
            % - uStar : friction velocity [m/s]
            if nargin ==1
                method = 'charnock';
            end
            if nargin < 3
                sctOpt = struct;
            end
            
            % default parameters
            sctOpt = Util.setDefault(sctOpt,'g',9.81);
            sctOpt = Util.setDefault(sctOpt,'alpha_c',0.015);
            sctOpt = Util.setDefault(sctOpt,'kappa',0.41);
            sctOpt = Util.setDefault(sctOpt,'h',10);
            sctOpt = Util.setDefault(sctOpt,'threshold',1e-5); % relative accuracy
            
            g = sctOpt.g;
            k = sctOpt.kappa;
            h = sctOpt.h;
            a = sctOpt.alpha_c;
            
            switch lower(method)
                case 'charnock'
                    % start conditions for iteration
                    dz = inf;
                    z0  = ones(size(u10));
                    % iterate charnock relation
                    n = 1;
                    while max(abs(dz))>sctOpt.threshold
                        zOld   = z0;
                        uStar = k.*u10./log(h./z0);
                        z0     = a.*uStar.^2./g;
                        dz     = z0./zOld-1;
                        n      = n + 1;
                    end
                    
                otherwise
                    error('Method not implemented');
            end
        end
        
        function S = windSpectrum(U10,f,method,L,kappa)
            % calculates harris wind gustiness spectrum
            %
            % windSpectrum(U10,f,method,L)
            %
            % INPUT
            %    - U10   : wind velocioty at 10 m elevation
            %    -   f   : frequency at which to calculate the spectrum
            %    - method: (optional) string with the method. Default is 'harris'
            %    - L     : (optional) length scale in Harris equation. default = 1800 m
            %    - kappa : (optional)  drag coeffcient.default = 0.003
            % OUTPUT;
            %    - S     : wind gust spectrum in m^2/s
            % NOTE:
            %    - Not recommanded for frequencies lower than 0.01 Hz
            
            
            % default variables
            if nargin <3
                method = 'harris';
            end
            if nargin < 4
                L = 1800;
            end
            if nargin < 5
                kappa = 0.003;
            end
            switch lower(method)
                case 'harris'
                    fT = L.*f./U10;
                    Snondim = 4.*kappa.*fT./(2+fT.^2).^(5/6);
                otherwise
                    error('Unknown method');
            end
            S = Snondim.*U10.^2./f;
            
        end
        
        function alpha_w = soundAttenuationWater(freq, temp, sal, depth,  pH, method)
            %
            %    function  alpha_w = Physics.soundAttenuationWater(Temp, Sal, Depth, freq, pH)
            %
            %    INPUT: Temp = temperature of water (degs C)
            %           Sal = salinity (ppt)
            %           Depth = depth (m)
            %           Freq = frequency of sound wave in kHz
            %           pH= alkalinity of sea water,optional (default =8)
            %           method = string of the method (default: Medwin)
            %
            %    OUTPUT alpha_w= sound attenuation coefficient in dB/m
            %
            % The estimation of the sound attenuation are based on:
            %  1. Medwin: Medwin and Clay, 1998  Fundamentals of Acoustical Oceanography. 
            %     based on the equations from page 109 of the book by
            %     Medwin and Clay, 1998, Fundamentals of Acoustical Oceanography.
            %
            %  2. Schulkin and Marsch, 1963 (used in Sedview)
            % 
            % Written by : JCA
            % Date: 12/2019
            %
            
            % 1. define parameters
            if nargin < 5
                pH=8;
            end
            if nargin < 4
               depth = ones(size(temp)); 
            end
            if nargin < 6
               method = 'medwin'; 
            end
            
            switch lower(method)
                case 'medwin' %Medwin and Clay, 1998, Fundamentals of Acoustical Oceanography.
                    c = Physics.calculateSoundVelocity(temp, sal, depth);
                                        
                    % temperature term
                    power1 = 4 - (1245./(temp + 273));
                    f1     = 2.8.*sqrt(sal./35).*10.^power1;             % Relaxation frequency for magnesium sulfate (in Khz)
                    power2 = 8 - 1990./(temp + 273);
                    f2    =(8.17.*10.^power2)./(1 + 0.0018.*(sal-35));   %  Relaxation frequency for boric acid (in Khz)
                    %
                    % Pressure Terms
                    P1 = 1;
                    P2 = 1 - 1.37e-4.*depth + 6.2e-9.*depth.^2;
                    P3 = 1 - 3.83e-5.*depth + 4.9e-10.*depth.^2;
                    %
                    % A parameters
                    A1 = (8.68./c).*10.^(0.78.*pH-5);
                    A2 = 21.44.*(sal./c).*(1 + 0.025.*temp);
                    
                    A3 = 3.964e-4 - 1.146e-5.*temp + 1.45e-7.*temp.^2 - 6.50e-10.*temp.^3;
                    mask = temp <= 20;
                    A3(mask) = 4.937e-4 - 2.59e-5.*temp(mask) + 9.11e-7.*temp(mask).^2 - 1.50e-8.*temp(mask).^3;
                    
                    %
                    TERM1 = (A1.*P1.*f1.*freq.^2)./(f1.^2 + freq.^2);  % Atten. due to Magnesium sulfate (dB/m)
                    TERM2 = (A2.*P2.*f2.*freq.^2)./(f2.^2 + freq.^2);  % Atten. due to Boric Acid (dB/m)
                    TERM3 = A3.*P3.*freq.^2;                    % Atten. due to pure sea water (dB/m)
                    
                    alpha_w = (TERM1 + TERM2 + TERM3)./1000;         % Total attenuation in sea (in dB/m)
                    
                case 'schulkin_sediview' % schulkin and March 1963 (used in Sediview)
                    % relaxation frequancy
                    fT = 21.9.*10.^(6 - 1520./(273 + temp)); % in kHz
                    alpha_w = (freq./91500).*(1.86.*fT.*freq./(fT.^2 + ...
                    freq.^2) + 2.86.*freq./fT); %described in sediview
                    %manual
                    
                case 'schulkin' %schulkin and March 1963 (as described in Landers et al.,2016)
                    fT = 21.9.*10.^(6 - 1520./(273 + temp)); % in kHz 
                    % described in landers et al. (2016)
                    Aw = 2.34e-6; % constant for ionic relaxtion process seawater
                    Bw = 3.38e-6; % constant for viscosity characteristics of pure water
                    pressure  = depth.*0.0986923266716013; % pressure in atmosphere
                    alpha_w = 8.89.*((sal.*Aw.*fT.*freq.^2)./(fT.^2 + freq.^2) + Bw.*freq.^2./fT) .*(1 - 6.54e-4.*pressure); 
                 
                otherwise
                    error('The estimation method is not programmed.')
            end
        end
        
        function alpha_s = soundAttenuationSediment(freq, temp, sal, depth,  particleSize, method)
            %
            %    function  alpha_w = Physics.soundAttenuationWater(Temp, Sal, Depth, freq, pH)
            %
            %    INPUT: Temp = temperature of water (degs C)
            %           Sal = salinity (ppt)
            %           Depth = depth (m)
            %           Freq = frequency of sound wave in kHz
            %           particleSize = particle diameter (in µm) - it can be a vector too (default = 20µm)
            %           method = string of the method (default: richards)
            %
            %    OUTPUT alpha_s = sound attenuation coefficient for sediment (absorption and scattering) in dB/m
            %
            % The estimation of the sound attenuation are based on:
            %  1. Equations from: Richards, S.D, A.D. Heathershaw and P.D Thorne, 1996.
            %  The efffect of suspended particulate matter on sound attnuation. J.
            %  Acoust. Soc. Am. 100(3): 1447-1450.
            %
            %  2. xxx (used in Sedview)
            %
            % Written by : JCA
            % Date: 12/2019
            %
            
            % 1. define parameters
            if nargin < 5
                particleSize = 20; % default as defined in Sediview
            end
            if nargin < 4
                depth = ones(size(temp));
            end
            if nargin < 6
                method = 'richards';
            end
            
            switch lower(method)
                case 'richards'
                    particleSize = particleSize./2.*10^-6; % particle size from µm to m and diameter to radius
                    particleDens = 2670; % density of sediment (kg/m3)
                    waterDens = Physics.calculateDensity(temp, sal, depth, 'eos80');  % density of salt water (kg/m3)
                    [muv, mus] = Physics.waterViscosity(temp); % viscosity water
                    velSound = Physics.calculateSoundVelocity(temp, sal, depth);
                    nu = mus./waterDens; % coefficient of kinematic viscosity (m2/s)
                    omega = 2.*pi.*freq.*1000; % angular frequency (rad/s)
                    k = omega./velSound; % wavenumber (1/m)
                    
                    sedrad = particleSize;%(i);
                    ka = k.*sedrad;      % dimensionless constant - k*sediment size
                    AlphaS = 0.18.*k.*(ka.^3)./(particleDens.*(1 + ka.^2 + 0.24.*ka.^4)); % Attenuation due to rigid particle scattering
                   
                    beta = (omega./(2.*nu)).^0.5;   % Changed by G. Voulgaris based on the Holdway paper using the kinematic viscocity
                    % Also see Richards et al, 2003. Visco-inertial absorption in dilute
                    % suspensions of irregular particles. Proc. R. Soc. Lond. A  459: 2153-2167.
                    tor = 1/2 + (9./(4.*beta.*sedrad));
                    s0 = (9./(4.*beta.*sedrad)).*(1 + 1./(beta.*sedrad));
                    densig = particleDens./waterDens;
                    AlphaV = (k.*((densig - 1).^2)./(2.*particleDens)).*(s0./(s0.^2 + (densig + tor).^2));  % Attenuation due to viscous absorption
                    % as given by Urick (1948) cited in Holdaway et al.
                    % Continental Shelf Research, 1, 1999, 421-441.
                    as = AlphaV + AlphaS;
                    alpha_s = as.*10.*log10(exp(2));                    
                    
                otherwise
                    error('The estimation method is not programmed.')
            end
        end
        
        function [VV, SV] = waterViscosity(temp)
            %
            %   function [VV, SV] = waterViscosity(temp)
            %
            %   INPUT:
            %         temp  = Water Temperature (in degs C)
            %
            %   OUTPUT:
            %
            %        VV = Volume Viscocity (in N sec m^(-2))
            %        SV = Shear Viscocity (in N sec m^(-2))
            %
            %  Function to estimate the coefficients of shear vsicocity (mu_f)
            %  and volume viscocity (mu'_f) as function of sea water temperature
            %  This is an interplolation from the Clay and Medwin , 1977, Acoustical
            %  Oceanography, Pricipals and Applications, John Wiley and Sons, book.
            %
            %
            % SV = -3.09e-8*T.^3 + 4.019e-6*T.^2 - 0.0002038*T + 0.005543;
            % VV = -7.773e-9*T.^3 + 1.018e-6*T.^2 - 5.547e-5*T + 0.001813;
            %
            %
            
            Temp = [0 10 20 30 40 50]';
            Volume_Viscocity = [1.82 1.330 1.071 0.8571 0.7143 0.619].*1e-3';
            Shear_Viscocity = [5.55 3.857 2.837 2.233  1.820 1.5476].*1e-3';
            %
            VV = interp1(Temp, Volume_Viscocity, temp, 'spline', 'extrap');
            SV = interp1(Temp, Shear_Viscocity, temp, 'spline', 'extrap');
            
        end
       
        function pressure = convertDepth2Pressure(depth, density, latitude, unit)
            % This function converts depth (m) to pressure (dbar) 
            %
            % pressure = convertDepth2Pressure(depth, density, latitude, unit)
            %
            %INPUTS: depth: in metres
            %        density: water density (default: 1000 kg/m³)
            %        latitude: degrees (default: 51)
            %        unit: output unit (default: dbar)
            %OUTPUTS:-
            %        - pressure in [dbar]
            % 
            % written: JCA
            % date : 2019 
            if nargin < 4
                unit = 'dbar';
            end
            if nargin < 3
                latitude = 51;
            end
            if nargin < 2
                density = 1000;
            end
            g = Physics.calculateGravity(latitude); % m/s²
            
            pressure = depth.*density.*g; %pa = 1 kg/(m/s2)
            
            switch lower(unit)
                case 'bar'
                    factor = 10^-5;
                case 'dbar'
                    factor = 10^-4;
                case 'pa'
                    factor = 1;
                case 'mbar'
                    factor = 10^-2;
            end
            pressure  = factor.*pressure;
        end
        
        
        function depth = convertPressure2Depth(pressure, density, latitude)
            % This function converts pressure (dbar) to depth 
            %
            %depth = convertPressure2Depth(pressure, density, latitude)
            %
            %INPUTS: depth: in metres
            %        density: water density (default: 1000 kg/m³)
            %        latitude: degrees (default: 51)
            %  
            %OUTPUTS:-
            %        - depth in metres
            % 
            % written: JCA
            % date : 2019 
           
            if nargin < 3
                latitude = 51;
            end
            if nargin < 2
                density = 1000;
            end
            g = Physics.calculateGravity(latitude); % m/s²
            pressure = pressure.*10^-4; %dbar => pascal
            depth = pressure./(density.*g); %m
        end
        
        function gravity = calculateGravity(latitude, height, method)
            % This function calculates the local gravity.
            %
            % gravity = calculateGravity(latitude, height, method)
            %
            %INPUTS: latitude: in degrees (default: 51)
            %        height: in metres (default: 0)
            %        method: IGF80 (default)
            %OUTPUTS:-
            %        - gravity in g m/s²
            % 
            % written: JCA
            % date : 2019
            
            if nargin < 1
                latitude = 51;
            end
            if nargin < 2
                height = 0;
            end
            if nargin < 3
                method = 'IGF80';
            end
            switch lower(method)
                case 'igf80'
                    IGF = 9.780327.*(1 + 0.0053024.*(sind(latitude)).^2 - 0.0000058.*(sind(2*latitude)).^2);
                    FAC = -3.086.*10^-6.*height;
                    gravity = IGF + FAC;
            end
        end
        
        function densityOUT = conversionSedimentDensities(sSwitch,densityIN,densitywater,densitygrain)
            % This function calculates the dry density of a sediment
            % mixture based on the wet density of the mixture, the density
            % of the water and the density of the composing grains
            %
            % densityOUT = conversionSedimentDensities(sSwitch,densityIN,densitywater,densitygrain)
            %
            %INPUTS: -sSwitch: type of conversion 'WET': conversion to a wet
            %        (in situ) density, 'DRY': conversion to a dry density.
            %        -densityIN: input density [kg/m3]
            %        -options:
            %           'densitywater': density water [kg/m3], default:  1025 kg/m3
            %           'densitygrain': density grains [kg/m3], default: 2650 kg/m3
            %OUTPUTS:-
            %        -densityOUT: wet or dry density [kg/m3]
            %
            
            % default parameters
            if nargin <3
                densitywater = 1025;
                densitygrain = 2650;
            end
            
            sSwitch = lower(sSwitch);
            
            switch sSwitch
                case 'wet'
                    densityOUT = (densityIN./densitygrain).*...
                        (densitygrain-densitywater)+densitywater;
                case 'dry'
                    densityOUT = (densityIN-densitywater)./...
                        (densitygrain-densitywater).*densitygrain;
                otherwise
                    error('wrong conversion specified');
            end
            
        end
        
        
    end
    
    
    
end