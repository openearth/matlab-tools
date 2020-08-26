%Class with functions to do overflow modeling according to:
%Jensen, Jacob Hjelmager, and Sina Saremi.
% "Overflow concentration and sedimentation in hoppers."
% Journal of Waterway, Port, Coastal, and Ocean Engineering (2014).
%
% @author ABR
% @author SEO
% @version
%

classdef Overflow < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependent properties
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
    
    %Static methods
    methods (Static)
        
        
        function [c,h,hb,t,dp,c0,q] = calcOverflow(physOptions)
            % Calculation of the overflow equation of Hjelmager jensen and
            % Saremi (2014)
            %
            % [c,h,hb,t,dp,c0,q] = Overflow.calcOverflow(physOptions)
            %
            % INPUT:  physOptions: a structure with input parameters with
            %               the following fields:
            %            conc: total concentration of the flow into the hopper
            %            discharge: discharge in the hopper [m3/s]
            %            area: area of the hopper [m2]
            %            depth: hopper depth [m]
            %            tEnd: end time of the simulation [seconds]
            %
            %         The particle size distribution can be specified in
            %         two ways:
            %          1.)  d16, d50, d84: particle diameter of the
            %          distribution [mu]. In this case a lognormal distribution
            %          will be used with nrFrac fractions
            %          2.)   specifying a psd directly using (nr Fraction
            %          is determined (automaticaly)
            %              psd: particle size distribution
            %               dp: particle size [mu]
            %
            %         Optional parameters:
            %            g: acceleration due to gravity optional [default = 9.81 m/s2]
            %            nu: kinematic viscosity optional [default = 1e-6 m2/s]
            %            dMin: min diameter in particle size distribution [default
            %               = 0.5*d50].
            %            dMax: max diameter in particle size distribution [default
            %               = 2*d50]. This may need to be addapted in order to avoid
            %               upward settling of large particles.
            %            nrFrac: nr of fractions [default = 100]
            %            deltaR: relative density [default = 1.59]
            %            initialDepth: initial water depth in the hopper [default
            %               = 0.1 m]. Main use is to prevent division by zero.
            %            porosity: porosity of the settled sediment in the hopper.
            %              [default = 0.4].
            %            hBedMax: fraction of the hopper that is to be
            %            filled when the calculation is stopped [default = 0.9]
            %            dt: the non-dimensional time step [default =
            %            0.005]; You should decrease this in case you have
            %            water depths larger than 1 (which may occur in
            %            case you have very small particle sizes).
            %
            % OUTPUT: c: volume concentration
            %         h: depth in the hopper
            %        hb: bed elevation in the hopper
            %         t: time [s]
            %         dp: particel size distribution
            %         c0: initial concentration
            %          q: discharge through overflow
            
            % default options sediment
            physOptions = Util.setDefault(physOptions,'g', 9.81);
            physOptions = Util.setDefault(physOptions,'nu',1e-6);
            physOptions = Util.setDefault(physOptions,'nrFrac',100);
            physOptions = Util.setDefault(physOptions,'deltaR',1.59);
            physOptions = Util.setDefault(physOptions,'hBedMax',0.9);
            physOptions = Util.setDefault(physOptions,'dt',0.005);
            
            
            % extract parameters
            conc   = physOptions.conc;
            Q      = physOptions.discharge;
            A      = physOptions.area;
            g      = physOptions.g;
            nu     = physOptions.nu;
            nrFrac = physOptions.nrFrac;
            deltaR = physOptions.deltaR;
            
            % select between automatic psd or user defined one
            if isfield(physOptions, 'dp') && isfield(physOptions, 'psd')
                % psd is given as input
                Util.checkColVec(physOptions.dp);
                Util.checkColVec(physOptions.psd);
                dp =  physOptions.dp;
                psd =  physOptions.psd;
                nrFrac = length(dp);
                physOptions.nrFrac = nrFrac;
                cVol = psd.*conc;
            else
                physOptions = Util.setDefault(physOptions,'dMin',0.5*physOptions.d50);
                physOptions = Util.setDefault(physOptions,'dMax',2*physOptions.d50);
                d16    = physOptions.d16;
                d50    = physOptions.d50;
                d84    = physOptions.d84;
                dMin   = physOptions.dMin;
                dMax   = physOptions.dMax;
                % generate PSD of settling distribution
                sigmaD = sqrt(d84/d16);
                dp = logspace(log10(dMin),log10(dMax),nrFrac+1)';
                [psd,dp] = Overflow.logDist(dp,d50,sigmaD);
                cVol = psd.*conc;
            end
            
            % clear water settling velocity
            [wFall,maxErr] = Overflow.termVel(1e-6.*dp, deltaR,g, nu);
            % calculate reference velocities
            physOptions.beta = wFall.*A./Q;
            physOptions.dp   = dp;
            
            %%overflow simulations
            physOptions.conc  = cVol;
            [c,h,hb,t,q] = Overflow.simOverflow(physOptions);
            c0 = cVol;
        end
        
        function hc = concOverflow(t,hcIn,sctOptions)
            % rhs of equation from Hjelmsage Jensen (used in simOverFlow)
            %
            % hc = Overflow.concOverflow(t,hcIn,sctOptions)
            %
            % INPUT:  t [1x1]: the non dimensionalized time
            %         hcIn: [N+1x1] vector. First value is the normalized water depth h~.
            %            The second value up to to the last value are the concentrations per fraction
            %         sctOptions: a structure with the fields:
            %            c0: [Nx1] vector with concentration. Note N is the number of
            %               fractions
            %            betaU, [Nx1] vector with beta_i Uci/UTi
            %            porosity: [1x1] porosity
            %            tOverFlow: [1x1] the nondimensional time with the start of overflowing
            %
            % OUTPUT: hc: [N+1x1] vector. First value is the normalized water depth h~.
            %           The second value up to to the last value are the concentrations per fraction
            
            % get variables
            HMIN      = 0.01;
            c0        = sctOptions.conc;
            porosity  = sctOptions.porosity;
            tOverflow = sctOptions.tOverflow;
            dp        = sctOptions.dp;
            Q         = sctOptions.discharge;
            A         = sctOptions.area;
            wFall     = sctOptions.beta.*Q./A;
            
            c    = hcIn(3:end);
            h    = hcIn(1);
            cTot = sum(c);
            
            % calculate the settling velocities
            wRel   = Overflow.hinderedSettling(dp,c);
            wFin   = Overflow.completeSettling(wRel,c,wFall);
            betaU  = wFin.*A/Q;            
            
            % check whether overflow occurs
            preOverFlow = double(t<=tOverflow && h<1.0);
            
            % equation for normalized water depth
            hc = preOverFlow - sum(betaU.*c)./(1-porosity-cTot);
            hb = preOverFlow - hc;
            
            % equation for the concentration
            hc = [hc;hb;(c0 - c.*(1+betaU))./max(h,HMIN)];
        end
        
        function [c,h,hb,t,q] = simOverflow(physOptions)
            % Simulation of the sediment in the overflow
            %
            % [c,h,hb,t,q] = simOverflow(physOptions)
            %
            % INPUT:  physOptions: a structure with physical options. See
            %            calcOverflow
            %
            % OUTPUT: c: concentration in the hopper (per fraction)
            %         h: depth in the hopper
            %         hb: bed elevation in the hopper
            %         t: time
            %         q: discharge
            
            % default parameters
            physOptions = Util.setDefault(physOptions,'initialDepth',0.1);
            physOptions = Util.setDefault(physOptions,'porosity',0.4);
            
            % extract patrameters
            Q    = physOptions.discharge;
            A    = physOptions.area;
            hBrg = physOptions.depth;
            h0   = physOptions.initialDepth;
            tEnd = physOptions.tEnd;
            
            % calculation time
            tStart = 0;
            tFill  = A.*hBrg./Q;
            tSpan  = [tStart tEnd]./tFill;
            physOptions.tOverflow = (hBrg-h0).*A/(Q*tFill);
            
            % initial conditions
            hc0 = h0./hBrg;
            hc0 = [hc0;0;zeros(size(physOptions.conc))];
            
            % numerical parameters
            solverOptions.Stats = 'off';
            solverOptions.MaxStep = physOptions.dt;
            
            % solve equation
            [tOut,hcOut] = ode23s(@(t,hc)Overflow.concOverflow(t,hc,physOptions),tSpan,hc0,solverOptions);
            
            % cut off too high concentrations
            mask = hcOut(:,1)>1-physOptions.hBedMax;
            % transform back
            tOverFlow = physOptions.tOverflow*tFill;
            t = tOut(mask).*tFill;
            h = hcOut(mask,1).*hBrg;
            hb = hcOut(mask,2).*hBrg;
            c = hcOut(mask,3:end);
            q = Q.*(t>tOverFlow);
        end
        
        function [wFin, vReturn] = completeSettling(hCorr,cVol,uTerm)
            % Calculation of the settling velocity for each fraction, taking retour current
            % into account
            %
            % [wFin, vReturn] = Overflow.completeSettling(hCorr,cVol,uTerm)
            %
            % INPUT:  hCorr: correction for hindered settling
            %            function hindereredSettling.
            %         cVol: volume concentration per section
            %         uTerm: terminal velocity
            % OUTPUT: wFin: Settling velocity for each fraction (including
            %            return currents. Positive means downward)
            %         vReturn: velocity of the return current
            %
            
            % check if beta is a column vector
            Util.checkColVec(uTerm,'beta');
            Util.checkColVec(cVol,'cVol');
            Util.checkColVec(hCorr,'wRel');
            
            nrFrac = length(uTerm);
            c      = sum(cVol);
            
            % right hand side
            rhs = uTerm.*hCorr;
            
            
            % matrix (non-diag terms)
            cVol = repmat(cVol,1,nrFrac);
            A = cVol'./(1-c);
            
            %add diagonal term
            A = A+eye(nrFrac);
            
            % Solve the equation
            wFin = A\rhs;
            
            % calculate the return current
            vReturn = hCorr.*uTerm - wFin;
        end
        
        function wRel = hinderedSettling(dp,cVol,method,rhop,rhow)
            % Calculation of the hindered settling of a polydisperse mixture
            %
            % wRel = Overflow.hinderedSettling(dp,cVol,method)
            %
            % Davis & Gecol (1994) as quoted in Hjelmager Jensen & Saremi (2013)
            %
            % INPUT:  dp: particle diametr for each size class
            %         cVol: volume
            %         method (optional: a string with the method:
            %               'davis1994': Davis & Gecol (1994) 
            %               'ha2002': Ha and Lui (2002)
            %               'masliyah1979'(default)
            %
            % OUTPUT: wRel: settling velocity devied by terminal velocity
            %
            % NOTES: negative velocities are sometimes found for very large
            % diameters. This is an artifact of the method, for which a
            % warning is given. In this case, the particle size
            % distribution should be changed.
            %

            % default method
            if nargin==2
                method =  'masliyah1979';
            end
            
            nrFrac = size(dp,1);
            c      = sum(cVol);

            % masliyah method
            if strcmpi(method,'masliyah1979')
                N    = 4.65;
                wRel = ones(nrFrac,1).*(1-c).^N;
                return
            end
                
            
            % check if dp is a column vector
            Util.checkColVec(dp,'dp');
            
            % make matrices
            dp     = repmat(dp,1,nrFrac);
            lambda = dp./dp';
            
            
            switch lower(method)
                case 'davis1994'
                    % Davis and Gecol
                    mij  = 3.5 +1.1.*lambda +1.02.*lambda.^2 +0.002.*lambda.^3;
                    % Ha and Lui (2002) (constant density of the material)
                case 'ha2002'
                    if nargin==5
                        Util.checkColVec(rhop,'rhop');
                        rhop   = repmat(rhop,1,nrFrac);
                        gamma = (rhop-rhow)./(rhop'-rhow);
                    else
                        gamma = 1;
                    end
                    mij = 2.5 + (lambda.^2 +3.*lambda + 1 - 1.87.*lambda./(1+0.0024.*lambda.^2)).*gamma;
                otherwise
                    error('Unknown method');
            end
            % mask
            dMat = ones(nrFrac);
            dMat((1:nrFrac)+(nrFrac*(0:nrFrac-1))) = 0;
            
            
            % constant term
            m   = 5.622;
            cst = (1-c).^(m-1);
            % term  is changed, becauyse it seems to be wrong in the paper
            % from Hjelmager
            mij = (mij-m).*dMat;
            % matrix multiplication (for settling velocity divided by terminal velocity)
            wRel = cst + cst*mij*cVol;
            

        end
        
        function [wFall,maxErr] = termVel(dp, deltaR,g, nu, sctOptions)
            % Calculation of the settling velocity using the Schiller-Naumann
            % correlation
            %
            % [wFall,maxErr] = Overflow.termVel(dp, deltaR,g, nu, sctOptions)
            %
            % INPUT:  dp: particle size diamater
            %         deltaR: relative density
            %         g: acceleration due to gravity
            %         nu: kinematic viscosity
            %         sctOptions: with the following fields:
            %         psi: [default = 1]: shape factor
            %         maxIter: [default = 500] maximum number of iterations
            %         maxErr: [default = 1e-6] maximum relative error
            %
            % OUTPUT: wFall: settling velocity
            %         maxErr: maximum error in the calculation
            
            if nargin==4
                sctOptions = struct;
            end
            
            sctOptions = Util.setDefault(sctOptions,'psi',1);% shapefactor
            sctOptions = Util.setDefault(sctOptions,'maxIter',500);% maximum number of iteration
            sctOptions = Util.setDefault(sctOptions,'maxErr',1e-6);% max error
            psi        = sctOptions.psi;
            
            % stokes velocity
            wFall0 = dp.^2.*deltaR.*g./(18.*nu);
            
            % Schiller Naumann (1933)
            ReP    = wFall0.*dp./nu;
            cd     = 0.15.*ReP.^0.687;
            wFall  = psi.*wFall0./(1+cd);
            maxErr = max(abs(wFall -wFall0));
            n      = 1;
            
            % iteration loop
            while  n<sctOptions.maxIter && maxErr>sctOptions.maxErr;
                wFallOld  = wFall;
                ReP       = wFall.*dp./nu;
                cd        = 0.15.*ReP.^0.687;
                wFall     = psi.*wFall0./(1+cd);
                maxErr    = max(abs(wFall -wFallOld));
                n         = n+1;
            end
        end
    end
end