%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef Flocculation < handle
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
        
        
       

        function [prFloc, prIni] = modelParameters(prFloc, prIni)
            % set default flocculations parameters
            %
            %
            if nargin <2
                prIni = struct;
            end
            if nargin <1
                prFloc = struct;
            end
            
            
            % ------------------------------------------------------------------------
            % Set constants and arrays required for DPBE
            % Floc/Particle propertiflocParam.es
            % Aggregation/Break-up Kinetic Constants
            prFloc = Util.setDefault(prFloc,'alpha_pbe1',0.20);
            prFloc = Util.setDefault(prFloc,'alpha_pbe2',0.20);
            prFloc = Util.setDefault(prFloc,'alpha_pbe3',0.20);
            % Correction Coefficient for Diff Settling-Mediated Flocculation
            prFloc = Util.setDefault(prFloc,'es',1.0D-4);
            prFloc = Util.setDefault(prFloc,'ffy',1.0D+10);
            prFloc = Util.setDefault(prFloc,'brk_f',0.1);
            
            % ------------------------------------------------------------------------
            % Constant for Fractal Theory - Check FlprFloc.esch et al (AICHE, 1999)
            prFloc = Util.setDefault(prFloc,'frac_df',2.0);
            
            % ------------------------------------------------------------------------
            % Physicochemical PropertiprFloc.es of Solid and Liquid
            prFloc = Util.setDefault(prFloc,'par_den',1.6D3);
            prFloc = Util.setDefault(prFloc,'wat_den',1.05D3);
            prFloc = Util.setDefault(prFloc,'g',9.81);
            prFloc = Util.setDefault(prFloc,'vmu',1.002D-3);
            prFloc = Util.setDefault(prFloc,'bolz',1.38D-23);
            prFloc = Util.setDefault(prFloc,'temp',2.93D2);
            
            
            % ------------------------------------------------------------------------
            % Constants (make 'MKS' units)- Check Spicer & Pratsinis (AICHE, 1996)
            prFloc = Util.setDefault(prFloc,'pdia',5.0D-6);
            prFloc = Util.setDefault(prFloc,'ffdia',100.0D-6);
            prFloc = Util.setDefault(prFloc,'pri_vol',1.0D0/6.0D0*pi*prFloc.pdia^3);
            
            % ------------------------------------------------------------------------
            % Initial Concentration
            prIni = Util.setDefault(prIni,'pconc',1.0);
            prIni = Util.setDefault(prIni,'pnconc',prIni.pconc/prFloc.par_den/prFloc.pri_vol);
            
            
        end
        
        function  [xn1,xn2,xn3,xnt,conc,fdia]= initialCondition(prIni,prFloc)
            % sets initial conditions
                xn1  = prIni.pnconc*0.999d0;
                xn3  = prIni.pnconc*0.001d0;
                fdia = prFloc.ffdia;
                xnc  = (fdia./prFloc.pdia).^prFloc.frac_df;
                xn2  = xn3./xnc;
                xnt  = xn1 + xn3;
                conc = xnt .* prFloc.par_den .*prFloc.pri_vol;
        end
        
        function [wsf,wsp] = settlingFloc(prFloc,wsf0,fdia)
               % calculate sthe settling velocity of the flocs
               %
               % [wsf,wsp] = settlingFloc(prFloc,wsf,fdia)
               %
               % INPUT:
               % -prFloc: floc parameter structure
               % -wsf0: initial settling velocity of the flocs
               % -fdia: floc diameter
               %
               % OUTPUT:
               % - wsp: settling velocity of the primary particles
               % - wsf: settling velocity of the flocs
               %
            
                VERY_SMALL = 1e-16;
                
                
                % Stokes
                rhoDeltaG = (prFloc.par_den-prFloc.wat_den).*prFloc.g;
                wsp   = (prFloc.pdia.^2).*rhoDeltaG./(18.0d0.*prFloc.vmu);
                
                % Winterwerp  with iteration
                err = 1;
                while any(err>1e-5)
                    reP   = abs(fdia.*wsf0.*prFloc.wat_den./prFloc.vmu);
                    wsf   = rhoDeltaG.*prFloc.pdia.^(3-prFloc.frac_df)...
                        .*fdia.^(prFloc.frac_df-1)./(18.0d0.*prFloc.vmu)...
                        ./(1+0.15.*reP.^0.687);
                    err   = abs(wsf./max(abs(wsf0),VERY_SMALL) - 1);
                    wsf0  = wsf;
                end
                
        end
        
        function flocDen = flocDensity(prFloc,fdia)
            % calculates the density of the flocs
            %
            % flocDen = flocDensity(prFloc,fdia)
            %
            % INPUT:
            %      - prFloc: floc parameter structure
            %      - fdia:  floc diameter
            %
            % OUTPUT:
            %      -flocden: the density of the flocs
            %
                      flocDen = prFloc.wat_den + (prFloc.par_den-prFloc.wat_den)...
                    .* (prFloc.pdia./fdia).^(3.0d0-prFloc.frac_df);
        end
        
        function fDia = flocDiameter(xn3,xn2,prFloc)
            % floc diameter calculation
            %
            % fDia = flocDiameter(xn3,xn2,prFloc)
            %
            % INPUT:
            %     - prFloc: floc parameter structure
            %     - xn2,xn3: number concentratations of fraction 2 and 3
            %
            % OUTPUT: 
            %     - fDia: the floc diameter
            %
           
            xnc   = xn3./xn2;
            fDia  = xnc.^(1.0./prFloc.frac_df).*prFloc.pdia;
        end
        
        
        function [dxndt] = ...
                implicitTCPBE(t,xn,prFloc,shearTs,concTs,timeTs)
            % ------------------------------------------------------------------------

            DT  = 1e-3;
            
            % time interpolation of input
            conc    = interp1(timeTs,concTs,t);
            concDt  = interp1(timeTs,concTs,t+DT);
            dcdt    = (concDt-conc)/DT;
            shear = interp1(timeTs,shearTs,t);
            
            % adapt number concentration to match total concentration
            % volume conc
            cVol = conc./prFloc.par_den;
            % total number conc
            xnTot = cVol./prFloc.pri_vol;

            % Previous Scalar Concentration
            
            xn1 = xn(1)*xnTot;
            xn2 = xn(2)*xnTot;
            xn3 = xn(3)*xnTot;
            xnc = xn3./xn2;

            % parameters
            fdia = Flocculation.flocDiameter(xn3,xn2,prFloc);
            
            % brownian motion
            tmp       = 2.0.*prFloc.bolz.*prFloc.temp./(3.0.*prFloc.vmu);
            beta.bm1  = 4.0.*tmp;
            beta.bm2  = tmp.*(1.0./prFloc.pdia + 1.0./fdia).*(prFloc.pdia+fdia);
            beta.bm3  = 4.0.*tmp;
            
            % differential settling
            [wsf,wsp] = Flocculation.settlingFloc(prFloc,0,fdia);            
            beta.ds2  = pi./4.0 .* (fdia+prFloc.pdia).^2.0...
                *abs(wsf-wsp);
            
            % shear
            beta.sh1  = 1.0./6.0  .*shear .*(2.0.*prFloc.pdia).^3.0;
            beta.sh2  = 1.0./6.0  .*shear.*(prFloc.pdia+fdia).^3.0;
            beta.sh3  = 1.0./6.0  .*shear.*(fdia+fdia).^3.0;
            % combined
            beta.pbe1 = prFloc.alpha_pbe1.*(beta.bm1+beta.sh1);
            beta.pbe2 = prFloc.alpha_pbe2.*(beta.bm2+beta.ds2+beta.sh2);
            beta.pbe3 = prFloc.alpha_pbe3.*(beta.bm3+beta.sh3);
            
            % breakage
            brk_s     = prFloc.es*shear*(fdia/prFloc.pdia-1.0d0)^(3.0D0-prFloc.frac_df)...
                *(prFloc.vmu*shear*fdia^2.0D0*prFloc.ffy)^1.00d0;
            
            dxdt = dcdt./conc;
            
            % differential term (including correction for changes in
            % concentration)
            dx1dt = -0.5D0*beta.pbe1*xn1^2*...
                (xnc/(xnc-1.0d0))-beta.pbe2*xn1*xn2+...
                prFloc.brk_f*xnc*brk_s*xn2;
            dx2dt = (0.5D0*beta.pbe1*xn1^2*...
                (1.0d0/(xnc-1.0d0))-0.5D0*beta.pbe3*xn2^2+...
                brk_s*xn2 );            
            dxndt(1) = (dx1dt + xn1.*dxdt)./xnTot;
            dxndt(2) = (dx2dt + xn2.*dxdt)./xnTot;
            dxndt(3) = (-dx1dt + xn3.*dxdt)./xnTot;
            dxndt = dxndt';
            
        end
        
        function [xn1,xn2,xn3] = ...
                explicitTCPBE(prFloc,dt,xn1,xn2,xn3,shear,wsp,wsf)
            % ------------------------------------------------------------------------
            % Previous Scalar Concentration
            ppxn1 = xn1;
            ppxn2 = xn2;
            ppxn3 = xn3;
            
            % parameters
            xnc   = xn3./xn2;
            fdia  = xnc.^(1.0./prFloc.frac_df).*prFloc.pdia;

            % brownian motion
            tmp       = 2.0.*prFloc.bolz.*prFloc.temp./(3.0.*prFloc.vmu);
            beta.bm1  = 4.0.*tmp;
            beta.bm2  = tmp.*(1.0./prFloc.pdia + 1.0./fdia).*(prFloc.pdia+fdia);
            beta.bm3  = 4.0.*tmp;
            % differential settling
            beta.ds2  = pi./4.0 .* (fdia+prFloc.pdia).^2.0...
                *abs(wsf-wsp);
            % TODO: check if correct
            beta.ds3  = zeros(size(beta.ds2));
            
            % shear
            beta.sh1  = 1.0./6.0  .*shear .*(2.0.*prFloc.pdia).^3.0;
            beta.sh2  = 1.0./6.0  .*shear.*(prFloc.pdia+fdia).^3.0;
            beta.sh3  = 1.0./6.0  .*shear.*(fdia+fdia).^3.0;
            % combined
            beta.pbe1 = prFloc.alpha_pbe1.*(beta.bm1+beta.sh1);
            beta.pbe2 = prFloc.alpha_pbe2*(beta.bm2+beta.ds2+beta.sh2);
            beta.pbe3 = prFloc.alpha_pbe3*(beta.bm3+beta.ds3+beta.sh3);
            
            % breakage
            brk_s     = prFloc.es*shear*(fdia/prFloc.pdia-1.0d0)^(3.0D0-prFloc.frac_df)...
                *(prFloc.vmu*shear*fdia^2.0D0*prFloc.ffy)^1.00d0;
            
            % Euler explicit integration of breakage terms
            xn1 = ppxn1+ dt*(-0.5D0*beta.pbe1*ppxn1^2*...
                (xnc/(xnc-1.0d0))-beta.pbe2*ppxn1*ppxn2+...
                prFloc.brk_f*xnc*brk_s*ppxn2);
            xn2 = ppxn2+ dt*(0.5D0*beta.pbe1*ppxn1^2*...
                (1.0d0/(xnc-1.0d0))-0.5D0*beta.pbe3*ppxn2^2+...
                brk_s*ppxn2);
            xn3 = -xn1+ppxn1+ppxn3;

            
        end
        function [xnOut,tOut,dfOut,wsOut] = bimodalFloc(concIn, shearIn, timeCs, timeIn,  prFloc, prIni)
        % bimodal flocculation model in a lagrangian frame
            %
            % [xnOut,dfOut,wsOut] = bimodalFloc(concIn, shearIn, timeCs, timeIn, timeOut, prFloc, prIni)
            %
            % INPUT: 
            %   -  concIn: time  series of concentration [g/l]
            %   - shearIn: time series of turbulent shear rate [1/s]
            %   - timeCs: time of concIn and shearIn [s]
            %   - timeIn: 3x1 vector with start time, end time and time
            %   step [s]
            %   - timeOut: [nx1] vector with output intervals [s]
            %   - prFloc: structure with flocculation parameters. see
            %   Flocculation.modelParameters for definition
            %   - prIni: structure with initial condition parameters CAN BE
            %   DELETED?
            %  
            %
            % OUTPUT:
            %   - xnOut: [nx3] vector with number concentrations of: primary
            %   particles, flocs and nt (number of flocs time
            %   - dfOut: [nx1] vector floc diameter [m]
            %   - wsOut: [nx3] vector with settling velocity of: primary
            %   particles, flocs and average settling velocity (used to
            %   get the correct mass settling flux)
            %
            % REFERENCES:
            % Lee, B. J., Toorman, E., Molz, F. J., & Wang, J. (2011). A two-class population balance equation yielding bimodal flocculation of marine or estuarine sediments. Water research, 45(5), 2131-2145.
            
 %% ------------------------------------------------------------------------
            % Load All the model parameters
            if nargin <= 4
                prFloc = struct;
            end
            if nargin <= 5
                prIni = struct;
            end
            
            [prFloc, prIni] = Flocculation.modelParameters(prFloc, prIni);
            
            
            
            %% ------------------------------------------------------------------------
            % initial condition (intial seeding)
            
            % Initial Concentration
            prIni.pconc  = interp1(timeCs,concIn,timeIn(1));
            prIni.pnconc = prIni.pconc/prFloc.par_den/prFloc.pri_vol;
            [xn1,xn2,xn3,xnt] = Flocculation.initialCondition(prIni,prFloc);
            xn1 = xn1./xnt;
            xn2 = xn2./xnt;
            xn3 = xn3./xnt;
            % ------------------------------------------------------------------------
            % Time Increase
            
            % solve ode
            
             odeOptions = odeset('NonNegative',[1 1 1]);
             [tOut,xnOut] = ode15s( ...
             @(tOut,xnOut) Flocculation.implicitTCPBE(tOut,xnOut,prFloc,shearIn,concIn,timeCs),...
               timeIn([1 2]),[xn1,xn2,xn3]',odeOptions);
             % prepare output
             conc   = interp1(timeCs,concIn,tOut);
             xnTot  = conc./(prFloc.par_den.*prFloc.pri_vol);
             xnOut  = xnOut.*xnTot;
             xn1 = xnOut(:,1);
             xn2 = xnOut(:,2);
             xn3 = xnOut(:,3);
             dfOut = Flocculation.flocDiameter(xn3,xn2,prFloc);
             [wsf,wsp]  = Flocculation.settlingFloc(prFloc,zeros(size(dfOut)),dfOut);
             wsmean     = (wsp.*xn1 + wsf.*xn3)./(xn1+xn3);
             wsOut      = [wsp*ones(size(wsf)),wsf,wsmean];

            
            
        end
        function [xnOut,dfOut,wsOut] = bimodalFlocOld(concIn, shearIn, timeCs, timeIn, timeOut, prFloc, prIni)
            % bimodal flocculation model in a lagrangian frame
            %
            % [xnOut,dfOut,wsOut] = bimodalFloc(concIn, shearIn, timeCs, timeIn, timeOut, prFloc, prIni)
            %
            % INPUT: 
            %   -  concIn: time  series of concentration [g/l]
            %   - shearIn: time series of turbulent shear rate [1/s]
            %   - timeCs: time of concIn and shearIn [s]
            %   - timeIn: 3x1 vector with start time, end time and time
            %   step [s]
            %   - timeOut: [nx1] vector with output intervals [s]
            %   - prFloc: structure with flocculation parameters. see
            %   Flocculation.modelParameters for definition
            %   - prIni: structure with initial condition parameters CAN BE
            %   DELETED?
            %  
            %
            % OUTPUT:
            %   - xnOut: [nx3] vector with number concentrations of: primary
            %   particles, flocs and nt (number of flocs time
            %   - dfOut: [nx1] vector floc diameter [m]
            %   - wsOut: [nx3] vector with settling velocity of: primary
            %   particles, flocs and average settling velocity (used to
            %   get the correct mass settling flux)
            %
            % REFERENCES:
            % Lee, B. J., Toorman, E., Molz, F. J., & Wang, J. (2011). A two-class population balance equation yielding bimodal flocculation of marine or estuarine sediments. Water research, 45(5), 2131-2145.
            
            
            %% ------------------------------------------------------------------------
            % Load All the model parameters
            if nargin <= 5
                prFloc = struct;
            end
            if nargin <= 6
                prIni = struct;
            end
            
            [prFloc, prIni] = Flocculation.modelParameters(prFloc, prIni);
            
            
            
            %% ------------------------------------------------------------------------
            % initial condition (intial seeding)
            [xn1,xn2,xn3] = Flocculation.initialCondition(prIni,prFloc);
            
            % ------------------------------------------------------------------------
            % Time Increase
            
            dt      = timeIn(3);
            time    = timeIn(1);
            timeEnd = timeIn(2);
            nrStep  = floor((timeEnd-time)/dt);
            
            % preallocate output
            nrOut = length(timeOut);
            xnOut = zeros(nrOut,3);
            wsOut = zeros(nrOut,3);
            dfOut = zeros(nrOut,1);
            n     = 1;
            
            % primary floc diameter
            
            % initial guess for wsf
            wsf = 1e-6;
            for itm=1:nrStep
                time = time + dt;
                
                % ------------------------------------------------------------------------
                
                
                % interpolate data
                conc  = interp1(timeCs,concIn,time);
                shear = interp1(timeCs,shearIn,time);
                
                % floc size and settling velocity
                fDia       = Flocculation.flocDiameter(xn3,xn2,prFloc);
                [wsf,wsp]  = Flocculation.settlingFloc(prFloc,wsf,fDia);

                % adapt number concentration to match total concentration
                % volunme conc
                cVol = conc./prFloc.par_den;
                % total number conc
                xnOld = xn1 + xn3;
                xnNew = cVol./prFloc.pri_vol;
                afac = xnNew/xnOld;
                % divide over the fractions
                xn1 = afac.*xn1;
                xn2 = afac.*xn2;
                xn3 = afac.*xn3; % This means that the total numer of micrflocs per macroflocs does not change
                
                % explicit solver for tcpbe
                [xn1,xn2,xn3] = ...
                Flocculation.explicitTCPBE(prFloc,dt,xn1,xn2,xn3,shear,wsp,wsf);
            
                
                % save data if needed
                if any (abs((time-timeOut))<1e-6)
                   xnOut(n,:) = [xn1,xn2,xn3];
                   fDia       = Flocculation.flocDiameter(xn3,xn2,prFloc);
                   [wsf,wsp]  = Flocculation.settlingFloc(prFloc,wsf,fDia);
                   wsmean     = (wsp.*xn1 + wsf.*xn3)./(xn1+xn3);
                   wsOut(n,:) = [wsp,wsf,wsmean];
                   dfOut(n)   = fDia;
                   n          = n+1;
                end
                
                
                % end of the time loop
            end



        end
        
        function lagrangianFloc
            % TODO
            
        end
        
        function popBalance
            % TODO
        end
        
    end
end