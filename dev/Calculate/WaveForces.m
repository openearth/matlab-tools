%Class with to compute wave pressures and forces on submerged 
% and emerged structures. Written for project 12099, see report 
% I/RA/12099/15.164/NZI for a detailed description of the formulas.
%
% @author NZI
% @author VIK
% @version
%

classdef WaveForces


    properties
        rho=1023;   % water density [kg/m3]
        g=9.81;     % gravity [m/s2]
    end

    methods

        function [Fh,Rmax,surf,bAppl] = Camfield(obj,H0,L0,Hb,tanB,Rc,X1)
            % Camfield (1991) method for wave force due to broken waves in
            % run-up zone, on a vertical wall landward of the coastline. 
            % Source : CEM (2006). I/RA/12099/15164/NZI
            % 
            % INPUT:  H0 = (regular) wave height in deep water [m]  (for
            %            irregular waves, use Hmax = 1.86*Hs for max impact)
            %         L0 = wave length in deep water [m]
            %         Hb = (regular) breaking wave height [m]
            %         tanB = beach slope tan(beta) [-]
            %         X1 = (SCALAR OR VECTOR) horizontal distance between 
            %            the coastline (MWL) and the wall [m]
            %         Rc = freeboard [m] above which the force is kept constant
            %            since Camfield otherwise assumes an infinite slope
            %
            % OUTPUT: Fh = horizontal wave force on the wall [N/m]
            %         Rmax = max runup height (Schuttrumpf, 2001 according to 
            %            Eurotop manual) [m]
            %         surf = surf similarity parameter (Iribarren number) [-]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            %
            % last edited 22/07/2015, NZI
            
            % surf similarity parameter
            surf = tanB.*(H0./L0).^(-1/2);
            
            % % maximum run-up (Mase, 1989 ; from CEM, 2006)
            % Rmax=2.32.*surf.^(0.77).*H0;
            
            % Ru = Max. wave runup height for reg. waves (based on Schuttrumpf, 2001)
            % chosen to be comparable to Chen2012 and Chen2015
            Rmax = 2.25.*Hb.*tanh((0.5).*surf);
            
            % horizontal force on the wall
            Fh                = 0.18.*(obj.rho).*(obj.g).*Hb.^2*(1-X1.*tanB./Rmax).^2;
            Fh(X1>Rmax./tanB) = 0; % no force if no runup
            if Rc<Rmax; % if runup>freeboard, keep force constant after reaching freeboard
                Fh(X1>Rc./tanB) = max(0.18.*(obj.rho).*(obj.g).*Hb.^2*(1-Rc./Rmax).^2,Fh(X1>Rc./tanB));
            end;
            
            % applicability range
            bAppl = true(size(X1));
            % slope
            if tanB>1/10 || tanB<1/100;
                bAppl(:) = 0;
            end;
            % freeboard no applicability limit
            % berm width no applicability limit
        end
        
        function [Fh,R01pc,surf,bAppl] = Pedersen(obj,Hs,Lom,tanA,Ac,B,fc,h)
            % Pedersen (1997) method for wave force due to broken waves
            % on a crown wall of a breakwater. Most reliable formula for
            % crown wall according to Rock Manual (2009). 0.1% exceedance
            % probability.
            % Source : CEM (2006). I/RA/12099/15164/NZI
            % 
            % INPUT:  Hs = significant wave height at breakwater toe [m]
            %         Lom = deepwater wave length corresponding to the mean wave period [m]
            %         tanA = breakwater slope (steeper than 1:3.7 otherwise area A2 undefined = nan) [-]
            %         Ac = vertical distance between MWL and the crest of the armour berm [m]
            %         B = (SCALAR OR VECTOR) berm width of armour layer in front of the wall [m]
            %         fc = height of the wall not protected by the armour layer (above) [m]
            %         h = height of the wall protected by the armour layer (below)(<=Ac) [m]
            %
            % OUTPUT: Fh = horizontal wave force on the crown wall [N/m]
            %         R01pc = exceedance runup height [m] [suggested value = 0.1 m] 
            %         surf = surf similarity parameter (Iribarren number) [-]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            %
            % last edited 22/07/2015, NZI
            
            % surf similarity parameter
            surf = tanA.*(Hs./Lom).^(-1/2);
            
            % 0.1% exceedance run-up
            R01pc            = nan(length(surf));
            R01pc(surf<=1.5) = 1.12.*Hs.*surf; % if surf<=1.5
            R01pc(surf>1.5)  = 1.34.*Hs.*surf.^0.55; % if surf>1.5
            
            % pressure pm
            pm = (obj.rho).*(obj.g).*(R01pc-Ac);
            pm = max(pm,0);
            
            % yeff
            y    = (R01pc-Ac)./sind(atand(tanA)).*sind(15)./cosd(atand(tanA)-15);
            y    = max(y,0); % runup must be larger than freeboard
            yeff = min(y./2,fc);
            
            % area A
            A1 = Ac.*(B+Ac./(2.*tanA));
            A2 = (R01pc.^2./2).*(1./tand(atand(tanA)-15)-1./tanA);
            A2 = max(A2,0);
            A  = min(A2./A1,1);
            
            % horizontal force on the wall
            Fh = (0.21).*sqrt(Lom./B).*((1.6).*pm.*yeff+A.*pm./2.*h);
%             if isscalar(tanA) && tanA<(1/3.7); % force undefined if slope too mild
%                 Fh(:)=nan;
%             else
%                 Fh(tanA<1/3.7)=nan;
%             end;
            
            % applicability range, assuming model scale 1:20
            bAppl = true(size(B));
            
            % slope 1:1-1:3.7 (tested 1:1.5-1:3.5)
            if tanA<1/3.7 || tanA>1/1;
                bAppl(:) = 0;
            end;
            
            % freeboard 1.5-5m (tested 2.2-3.8m)
            if Ac<1.5 || Ac>5;
                bAppl(:) = 0;
            end;
            
            % berm length 2.5-7.5m (tested 3.6-7.2m)
            bAppl(B<2.5) = 0;
            bAppl(B>7.5) = 0;
        end

        function [Fh,Ru,surf,bAppl] = Chen2012(obj,Hm,Lom,tanA,Rc,B)
            % Chen et al. (2012) method for wave force due to overtopping
            % bore on a vertical wall landward of the coastline. 
            % CAUTION :
            % Instead of fixed coefficients depending on the distance to 
            % the coastline in the original formula, these coefficients
            % have been linearly interpolated between the case "dike" and
            % the case "inland", then set to the case "dike" seaward of the
            % crest and to the case "inland" beyond 15m berm length. This 
            % is done for project 12099 and allows to apply the formula for 
            % other distances than those tested in the flume (0m and 15m).
            % Source : Chen et al. (2012). I/RA/12099/15164/NZI
            %
            % INPUT:  Hm = (regular) wave height near toe of dike [m] (for
            %            irregular waves, use Hmax = 1.86*Hs for max impact)
            %         Lom = deepwater wave length corresponding to the mean wave period [m]
            %         tanA = beach slope tan(alpha) [-]
            %         Rc = crest freeboard [m]
            %         B = (SCALAR OR VECTOR) berm width [m]
            % 
            % OUTPUT: Fh = horizontal force on vertical wall [N/m]
            %         Ru = max runup height for regular waves (Schuttrumpf) [m]
            %         surf = surf similarity parameter (Iribarren number) [-]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            %
            % last edited 04/08/2015, VIK
            
            % So : Overtopping wave tongue thickness at beginning of crest
            % So equals Hm.* (1-(Rc./Ru) with c1 : 2.2 and c1star : 0.5
            % c2 = Coefficient related to dike crest width: 0.51 for inland case and 1.48 for dike case
            
            % coefficients c1 and c1star
            c1     = 2.25;
            c1star = 0.5;
            
            % surf similarity parameter
            surf = tanA.*(Hm./Lom).^(-1/2);
            
            % Ru = Max. wave runup height for reg. waves (based on Schuttrumpf, 2001)
            Ru = Hm.*c1.*(tanh(c1star.*surf));
            
            % coefficient c2 linearly interpolated between 1.48 at dike and
            % 0.51 at 15m inland wall, equal to 0.51 further landwards
            % NOTE : not in standard formula, added for project 12099
            a  = (0.51-1.48)/15;
            b  = 1.48;
            C2 = a.*B+b;
            C2 = max(C2,0.51);
            C2 = min(C2,1.48);
            
            % horizontal force on the wall, as function of distance
            Fh = C2 .*(obj.rho).*(obj.g).*((Hm).^2).*((1-(Rc./Ru)).^2);
            if isscalar(Rc) && isscalar(Ru) && Rc>Ru; % no force if runup does not reach the crest
                Fh(:)     = 0;
            else
                Fh(Rc>Ru) = 0;
            end;
            
%             % horizontal force on the wall, for the two distances tested
%             FhA = 1.48 .*(obj.rho).*(obj.g).*((Hm).^2).*((1-(Rc./Ru)).^2); % crest
%             FhB = 0.51 .*(obj.rho).*(obj.g).*((Hm).^2).*((1-(Rc./Ru)).^2); % 15m inland
%             FhA(Rc>Ru)=0; % no force if runup does not reach the crest
%             FhB(Rc>Ru)=0; % no force if runup does not reach the crest
            
            % applicability range, assuming model scale 1:30
            bAppl= true(size(B));
            % slope 1:2-1:3 (tested 1:2.35)
            if tanA<1/3 || tanA>1/2;
                bAppl(:) = 0;
            end;
            % freeboard 1.5-3m (tested UNKNOWN ! 1 configuration)
            if Rc<1.5 || Rc>3;
                bAppl(:) = 0;
            end;
            % berm length 0-15m (tested 0 and 15m)
            bAppl(B<0)  = 0;
            bAppl(B>15) = 0;
        end
        
        function [Fh,Ru,dA0,dB0,surf,bAppl] = Chen2015(obj,Hm,Lom,tanA,Rc,B)
            % Chen (2015) method for wave force due to broken waves in
            % run-up zone, on a vertical wall landward of the coastline. 
            % Source : Coastal Engineering (2015). I/RA/12099/15164/NZI
            % last edited 12/08/2015, FBR
            %
            % INPUT:  Hm = (regular) wave height near toe of dike [m] (for
            %            irregular waves, use Hmax = 1.86*Hs for max impact)
            %         Lom = deepwater wave length corresponding to the mean wave period [m]
            %         tanA = dike slope tan(Alpha) corresponds to beta in formula [-]
            %         Rc = crest freeboard [m]
            %         B = (SCALAR OR VECTOR) berm width [m]
            % 
            % OUTPUT: Fh = horizontal force on vertical wall [N/m]
            %         Ru = max runup height for regular waves (Schuttrumpf) [m]
            %         dA0 = unobstructed overtopping flow depth (no wall) [m]
            %         dB0 = obstructed overtopping flow depth (presence of a wall) [m]
            %         surf = surf similarity parameter (Iribarren number) [-]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            
            % Ru = fictious max runup height for regular waves (Schuttrumpf) [m]
            % Ctr = coeff. to correlate dA0 and dB0
            % (B/Lom) = relative location of the wall with L=Lom
            
            % surf similarity parameter
            surf = tanA.*(Hm./Lom).^(-1/2);
            
            % Ru = Max. wave runup height for reg. waves (based on Schuttrumpf, 2001)
            Ru = 2.25.*Hm.*tanh((0.5).*surf);
            
            % dA0 = unobstructed overtopping flow depth (no wall) [m]
            dA0         = 0.77.*Hm.*(1-(Rc./Ru));
            dA0(Rc>=Ru) = 0;
            
            % Ctr = coeff. to correlate dA0 and dB0
            Ctr         = 0.33.*log(B./Lom)+1.86;
            Ctr(Ctr<=0) = nan; % flow depth has to remain positive
            
            % dB0 = obstructed overtopping flow depth (presence of a wall) [m]
            dB0 = dA0.*Ctr;
            
            % horizontal force on the wall
            Fh = ((obj.rho).*(obj.g).*((dA0).^2)).*((1.7).*((Ctr).^2))...
                .*((1./tanA)).*(exp((-3.08.*(1./tanA).*(B./Lom))));
            
            % applicability range, assuming model scale 1:30
            bAppl= true(size(B));
            
            % slope 1:1.5-1:8 (tested 1:3-1:6)
            if tanA<1/8 || tanA>1/1.5;
                bAppl(:) = 0;
            end;
            
            % freeboard 0-2.5m (tested 0.4-1.5m)
            if Rc<0 || Rc>2.5;
                bAppl(:) = 0;
            end;
            
            % berm length 5-25m (tested 7.5-22.5m)
            bAppl(B<5)  = 0;
            bAppl(B>25) = 0;
        end
        
        function [Fh,etastar,p1,p2,p3,bAppl] = Goda(obj,Hdesign, beta_wave,L,d,hb,hs,hw,Bm,hc,hprime,tanB)
            % Goda (1974) method for wave force on a breakwater due to
            % quasi-static waves, amended by Takahashi (1994) for impact
            % waves.
            % Source : CEM (2006). I/RA/12099/15164/NZI
            %
            % INPUT:  see figure Goda for more details ; caisson on rubble mound
            %         Hdesign = highest wave height in the design sea state in front of breakwater :
            %            use 1.8 Hs(seaward of surf zone) or highest of random breaking waves at 
            %            distance 5Hs seaward of structure (within surf zone) [m]
            %         beta_wave = angle of incidence of waves (between wave crest and front of structure) [deg]
            %         L = Wavelength at water depth hb (toe of structure) 
            %            for a period 1.1*Tm where Tm is the average period [m]
            %         d = water depth at caisson foot [m]
            %         hb = water depth at distance 5Hs seaward of the caisson front wall [m]
            %         hs = water depth at toe of structure [m]
            %         hw = height of caisson (crest freeboard + bottom structure 
            %            to still water level (h'+ hc)) [m]
            %         Bm = (SCALAR OR VECTOR) horizontal berm width until caisson wall [m]
            %         hc = crest freeboard [m]
            %         hprime = bottom caisson to SWL (hw-hc) = submerged height of the caisson from the 
            %            toe to the still water level [m]
            %         tanB = dike slope (for applicability only, no impact on result !) [-]
            % 
            % OUTPUT: Fh = horizontal force on vertical wall of caisson [N/m]
            %         etastar = runup height [m]
            %         p1 = pressure at MSL [Pa]
            %         p2 = pressure at caisson top [Pa]
            %         p3 = pressure at caisson foot [Pa]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            %
            % last edited 04/08/2015, VIK
            
            % Ufh is a stochastic variable signifying the bias and uncertainty 
            % of horizontal moment (mean value of 0.9 to add 0.25)
            % lambda1 eq. lambda2 eq. Lambda3 eq. 1
            
            % structure coefficients set to 1
            lambda1 = 1;
            lambda2 = 1;
            
            % coefficients for Takahashi modification for impact load
            delta22      = -0.36.*(Bm./L-0.12)+0.93.*((hs-d)./hs-0.6);  
            delta2       = nan(size(delta22));
            idx          = delta22<=0;
            delta2(idx)  = 4.9.*delta22(idx);      % if delta22<=0
            delta2(~idx) = 3.*delta22(~idx);       % if delta22>0
            
            delta11      = 0.93.*(Bm./L-0.12)+0.36.*((hs-d)./hs-0.6);
            delta1       = nan(size(delta11)); 
            idx          = delta11<=0;
            delta1(idx)  = 20.* delta11(idx);      % if delta11<=0  
            delta1(~idx) = 15.* delta11(~idx);     % if delta11>0
            
            idx           = Hdesign./d<=2;
            alphai0       = nan(size(Hdesign));
            alphai0(idx)  = Hdesign(idx)./d(idx);  % if Hdesign/d <=2 
            alphai0(~idx) = 2;                     % if Hdesign/d > 2
            
            idx           = delta2<=0;
            alphai1       = nan(size(delta1));
            alphai1(idx)  = cos(delta2(idx))./(cosh(delta1(idx)));             % if delta2 <= 0  
            alphai1(~idx) = 1./(cosh(delta1(~idx)).*cosh(delta2(~idx)).^(1/2));   % if delta2 > 0
            
            alphai = alphai0.*alphai1;
            alpha2 = min((hb-d)/(3.*hb).*(Hdesign/d).^2, (2.*d./Hdesign)); % the smallest of: ((hb-d)/(3 hb))*(Hdesign/d)^2 and 2d/Hdesign
            
            alphastar = max(alphai,alpha2);       % largest of alphai and alpha2
            
            alpha1 = 0.6+0.5.*((4.*pi.*hs./L)/sinh(4.*pi.*hs/L)).^2;
           
            alpha3 = 1-((hw-hc)./hs).*(1-(1./cosh(2.*pi.*hs./L)));
            
            % overtopping height
            etastar = 0.75.*(1+cosd(beta_wave)).*lambda1.*Hdesign;
            
            % horizontal pressures p1 to p3 on the wall
            p1 = (1/2).*(1+cosd(beta_wave).*(lambda1.*alpha1+lambda2.*alphastar.*cosd(beta_wave).^2)...
                .*obj.rho.*obj.g.*Hdesign);
            p2 = (1-hc./etastar).*p1;             % if etastar > hc 
            
            if isscalar(etastar) && isscalar(hc) && etastar<=hc; % if etastar <= hc
                p2 = 0;
            else
                p2(etastar<=hc) = 0;
            end;
            p3 = alpha3.*p1;
             
            % horizontal force on the wall
            % height for integration of pressure above water is max(hc,etastar) !
            Fh = 0.9.*(1/2.*(p1+p2).*min(hc,etastar)+(1/2).*(p1+p3).*hprime);
            
            % applicability range, assuming model scale 1:10
            bAppl = true(size(Bm));
            
            % slope 1:0.5-1:4 (tested UNKNOWN !)
            if tanB<1/4 || tanB>1/0.5;
                bAppl(:) = 0;
            end;
            
            % (negative) freeboard -5 to -0.5m (tested -0.7 to -3.9m)
            if d<-5 || d>-0.5;
                bAppl(:) = 0;
            end;
            
            % berm length 0-25m (tested 0.25-20m)
            bAppl(Bm<0)  = 0;
            bAppl(Bm>25) = 0;           
        end
        
%         function Fh=Oumeraci(obj,Hb,d,dc)
%             % WORK IN PROGRESS
%             % 
%             % Oumeraci and Kortenhaus (1997) method for wave force on a
%             % breakwater for both quasi-static and impact waves.
%             % Source : XXX Kortenhaus - PROVERBS / MASTIII - Chapter 5-1-Paper34.b pdf pages 24-26 … 
%             % Calculate elevation of pressure distrib. eta_star; bottom
%             % pressure (p3); max. pressure (p1); and pressure at crest of
%             % structure (p4)
%             % 
%             % INPUT :
%             % Hb = breaking wave height
%             % d = profondeur structure
%             % dc = niveau de crete
%             % Rc = crest height 
%             %
%             % OUTPUT :
%             % Fh = horizontal force on vertical wall [N/m]
%             %
%             % last edited 04/08/2015,FBR
%
%             kprime = 0.086;
%             
%             
%             eta_star=(0.8).*Hb; % elevation distribution pression 
%             
%             p1= @(t)Fh(t)./(((0.4).*Hb))+((0.7).*(d+dc));
%             
%             p3 = (0.45).*p1;
%           
%             p4(eta_star>Rc)= ((eta_star-Rc)./eta_star).*p1 ;%if eta_star>Rc 
%             p4 (eta_star<=Rc)= 0;                           %if eta_star<=Rc
%             
%             % Fh = horizontal wave force on the wall [N]
%             Fh(t)=1/2.*p1(t).*(0.8).*Hb+(d+dc);
%             
%             
%             k = 0.086; % lognormal distr, mean 0.086 stdev 0.084
%             
%         end
        
        function [Fh,Ru2,h,v,surf,bAppl] = Eurotop(obj,Hmo,Lom, tanA,Rc,Bc,tanB,X1)
            % Theoretical estimate of pressure and force, derived from the
            % overtopping flow depth and flow velocity of the Eurotop
            % manual for the seaward slope, the dike crest and the landward slope.
            % CAUTION : Such an approach is wished for by many people but
            % reality is more complex. There is at this stage no
            % consolidated literature on the topic. See email to KB Waves
            % of 22/07/2015, by Corrado Altomare (Flanders Hydraulics).
            % Source : Eurotop (2007). I/RA/12099/15164/NZI
            % 
            % INPUT:  Hmo = significant wave height at dike toe [m]
            %         Lom = deepwater wave length corresponding to the mean wave period [m]
            %         tanA = seaward beach/dike slope tan(alpha) [-]
            %         Rc = crest freeboard [m]
            %         Bc = (SCALAR OR VECTOR) width of dike crest [m]
            %         tanB = landward dike slope tan(beta) [-]
            %         x = horizontal distance between the coastline (MWL) and the wall [m]
            % 
            % OUTPUT: Fh = horizontal force on vertical wall [N/m]
            %         Ru2 = exceedance runup height [m] [suggested value = 2 m]     
            %         h = overtopping flow depth [m]
            %         v = overtopping flow velocity [m/s]
            %         surf = surf similarity parameter (Iribarren number) [-]
            %         bAppl = applicability range (1 = applicable, 0 = non applicable)
            %
            % last edited 11/08/2015 NZI
            
            %% applicability range
            % IN EUROTOP MANUAL P 19, 23 ET 123
            bAppl = true(size(X1));
            
            % slope 1:1-1:10 (tested 1:1 to 1:8, up to 1:10, <1:12 not valid)
            if tanA<1/10 || tanA>1/1;
                bAppl(: )= 0;
            end;
            
            % freeboard 0 to 5m (tested UNKNOWN !)
            if Rc<0 || Rc>5;
                bAppl(:) = 0;
            end;
            % berm length no limitation      
            
            %% Initialisation
            % initialisation of results vectors
            v = nan(size(X1)); % overtopping velocity
            h = nan(size(X1)); % overtopping flow depth
            
            % coefficients in overtopping flow depth and velocity formulas
            c2     = 0.055;     % value for 2% exceedence prob. (TMA spectra)(0.028 for 50%, 0.042 for 10%)
            c3     = 0.89 ;     % dimensional coefficient c3=0.89 (TMA spectra) or 1.1 (natural wave spectra)
            a0star = 1.55;      % value for 2% exceedence prob. (1.03 for 50%, 1.37 for 10%)
            f      = 0.01;      % friction coefficient 0.01 for smooth straight slope (Eurotop p 106)
                                % (Schulz 1992 recommends f=0.02 for smooth straight slope)
            
            % coefficients in runup formula
            gamma_b    = 1;     % berm coefficient in run-up formula
            gamma_f    = 1;     % roughness coefficient in run-up formula 
            gamma_beta = 1;     % wave approach angle coefficient in run-up formula 
            
            % surf similarity parameter
            surf = tanA.*(Hmo./Lom).^(-1/2);
            
            % 2% exceedance wave run-up with 5% uncertainty interval (eq. 5.4 p 89 eurotop)
            Ru2 = Hmo .*1.75.*gamma_b.*gamma_f.*gamma_beta.*surf;
            Ru2 = min(Ru2,Hmo.*gamma_b.*gamma_f.*(4.3-1.6./sqrt(surf)));
            xz  = Ru2./tanA;    % xz = maximum horizontal runup distance
            
            %% Zone 1 - Seaward slope 
            % (no Breaking info. already in run up formula)
            
            % remaining run-up distance
            xstar = (xz-X1);
            
            % overtopping flow depth at distance x
            hA       = c2.*xstar;
            hA(hA<0) = nan;
            
            % height above MSL at distance x
            zA         = tanA.*X1;
            zA(Ru2<zA) = nan;
            
            % overtopping flow velocity at distance x
            vA = a0star.*sqrt((Ru2-zA)./Hmo).*sqrt(obj.g.*Hmo);
            
            % copy results to final vector
            v(X1<=xz) = vA(X1<=xz);
            h(X1<=xz) = hA(X1<=xz);
            
            % exit or boundary condition for zone 2
            if Rc>Ru2 || max(X1)<Rc./tanA; % run-up does not reach the crest or vector x too short
                Fh = (obj.rho).*v.^2.*h;
                return;
            end;
            hC0 = c2.*(Ru2-Rc)./tanA;
            vC0 = a0star.*sqrt((Ru2-Rc)./Hmo).*sqrt(obj.g.*Hmo);
                        
            %% Zone 2 - Dike crest
            % xc = 0 @ beginning of crest ;  xc = coordinate on the crest ;
            % hc = overtopping flow depth on dike crest 
            % hc (xc)/hc (xc = 0)= (exp(-c3.*(xc./Bc)))
            
            % coordinates on crest
            xC = X1-Rc./tanA;
            
            % overtopping flow depth at distance xC
            hC = hC0.*exp(-c3.*xC./Bc);
            
            % overtopping flow velocity at distance xC
            vC = vC0.*exp(-(xC.*f)./(2.*hC));
            
            % copy results to final vector
            v(X1>Rc./tanA) = vC(X1>Rc./tanA);
            h(X1>Rc./tanA) = hC(X1>Rc./tanA);

            % boundary condition for zone 2 (no exit needed for exponential function)
            % at distance xC=Bc
            if max(X1)<=Rc./tanA+Bc; % vector x too short
                Fh = (obj.rho).*v.^2.*h;
                return;
            end;
            hb0 = hC0.*exp(-c3.*Bc./Bc);
            vb0 = vC0.*exp(-(Bc.*f)./(2.*hb0));
            
            
            %% Zone 3 - Landward slope
            
            % overtopping flow depth (independent of distance)
            hb = (vb0.*hb0).^(2/3).*(f./(2.*obj.g.*sin(atan(tanB)))).^(1/3);
            
            % overtopping flow velocity (independent of distance)
            vb = vb0.*hb0./hb;
            
            % copy results to final vector
            v(X1>(Rc./tanA+Bc)) = vb(X1>(Rc./tanA+Bc));
            h(X1>(Rc./tanA+Bc)) = hb(X1>(Rc./tanA+Bc));            
            
            %% horizontal force on the wall
            Fh = (obj.rho).*v.^2.*h;            
        end       
    end % methods
end % class
