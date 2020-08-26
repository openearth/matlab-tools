%Class with wave related functions
%
% @author ABR
% @author SEO
% @version
%

classdef Waves < handle
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
        
        
        function [Hs,thetaM,fM,m0] =  specPar2D(f,theta,E)
            % calculates parameters from a 2D spectrum
            %
            %[Hs,thetaM,fM,m0] =  specPar2D(f,theta,E)
            %
            % INPUT
            % -f:     frequency [1/s]      
            % -theta: direction [radians] 
            % -E: energy density
            
%             error('gives wrong results somehow')
            [f,theta]  = Waves.make2dcoor(f,theta);
            
            % increasing order for theta
            theta = mod(theta,2*pi);
            [~, indsort] = sortrows(theta,1);
            theta = theta(indsort,:);
            E = E(indsort,:);
            
            
            % increasing order for frequency
            [~, indsort] = sortrows(f',1);
            f = f(:,indsort); 
            E = E(:,indsort);
            
            % add extra theta bin for symmetry
            % sdo : I changed the dimensions, because it was actually copying the first frequency.
            theta(end+1,:) = theta(1,:)+2*pi; % add 2pi, otherwise diff(theta) has a large negative value.
            f(end+1,:)     = f(1,:);
            E(end+1,:)     = E(1,:);
            
            
            % calculation of the moments
            m0x = Integrate.trapeziumRule2dMG(f,theta,cos(theta).*E);
            m0y = Integrate.trapeziumRule2dMG(f,theta,sin(theta).*E);
            m0 = Integrate.trapeziumRule2dMG(f,theta,E);
            m1 = Integrate.trapeziumRule2dMG(f,theta,f.*E);

            % calculate parameters
            Hs = 4.*sqrt(m0);
            fM = m1./m0; 
            thetaM = atan2(m0y,m0x);
        end
        
        function [pwd1, pwd2, pwd3, pf] = PeakWaveDir(f,theta,E)
            % pwd3 : the peak of the 2D spectrum which is a silly definition
            % pwd2 : the peak direction of the 2D spectrum integrated over
            %        the frequencies
            % pwd1 : the mean wave direction corresponding with the peak frequency
            % pf   : peak frequency ter controle
            
            % pwd1 : the mean wave direction corresponding to the peak frequency.
            Ef = Integrate.trapeziumRule(theta, E); 
            [mx, indmx] = max(Ef); 
            pf = f(indmx); 
            Epf = E(:,indmx); 
            m0x = Integrate.trapeziumRule(theta,cos(theta).*Epf);
            m0y = Integrate.trapeziumRule(theta,sin(theta).*Epf);
            pwd1 = atan2(m0y,m0x);

            
            % pwd2 : the peak direction of the 2D spectrum integrated over
            %        the frequencies           
            Ed = Integrate.trapeziumRule(f, E'); 
            [~, indmx] = max(Ed); 
            pwd2 = theta(indmx); 
            
            % 
            mx = max(max(E)); 
            indmx = find(E==mx,1); 
            [II,JJ] = ind2sub(size(E),indmx);
%             check = E(II,JJ)==mx
            pwd3 = theta(II);
            
            
        end
        function [f,theta]  = make2dcoor(f,theta)             
            %make sure data are 2D
            %
            % [f,theta]  = make2dcoor(f,theta)       
            %
            
            if min(size(f))==1 && min(size(theta))==1
                [f,theta] = meshgrid(f,theta);
            elseif min(size(f))>1 && min(size(theta))>1
                % nothing to do;
            else
                error('f and theta must be either 1d or 2d');
            end
        end
        
        function Eout = spectInterp2D(fIn,thetaIn,Ein,fOut,thetaOut)
            % interpolates a 2D spectrum to one with a different frequency
            % and direction distribution
            %
            % Eout = spectInterp2D(fIn,thetaIn,Ein,fOut,thetaOut)
            
            [fIn,thetaIn]     =  Waves.make2dcoor(fIn,thetaIn);
            [fOut,thetaOut]   = Waves.make2dcoor(fOut,thetaOut);
            
            % calculate parameters
            [~,thetaM,~,m0] =  Waves.specPar2D(fIn,thetaIn,Ein);
            % scale spectrum
            
            thetaIn  = thetaIn-thetaM;
            thetaOut = thetaOut-thetaM;
            
            %orthogonalize
            fxIn = fIn.*cos(thetaIn);
            fyIn = fIn.*sin(thetaIn);
            fxOut = fOut.*cos(thetaOut);
            fyOut = fOut.*sin(thetaOut);
            
            
            % interpolate
            Fint = scatteredInterpolant(fxIn(:),fyIn(:),Ein(:));
            Eout = Fint(fxOut,fyOut);
            
            %scale such that energy is conserved
            thetaOut = thetaOut+thetaM;
            [~,~,~,m0Out] =  Waves.specPar2D(fOut,thetaOut,Eout);
            
            % scale back
            Eout = Eout.*m0./max(m0Out,1e-16);
            
        end
        function Ef = jonswap(freq, Hs, Tp, pef)
            % compute Jonswap spectrum given wave characteristics
            % code modified from SWAN Fortran code
            % INPUT
            %   freq : frequency mesh
            %   Hs   : significant wave height.
            %   Tp   : peak period
            %   pef  : peak enhancement factor
            % OUTPUT
            %   Ef   : variance density [m²/Hz]

            %     spcsig = 2*pi*freq; 

            fpeak  = (1./Tp);                                               
            FPK4 = fpeak.^4;
            SALPHA = (Hs.^2 .* FPK4) ./((0.06533.*(pef.^0.8015)+0.13467).*16.);

            SF4 = freq.^4;
            SF5 = freq.^5;
            CPSHAP = 1.25.*FPK4./SF4;
                ind10 = CPSHAP>10;
            RA = (SALPHA./SF5).*exp(-CPSHAP);
            RA(ind10) = 0; 
                indfpk = freq<fpeak; 
            coeff = 0.09*ones(size(freq)); 
            coeff(indfpk) = 0.07;
            APSHAP =  0.5 .* ((freq-fpeak) ./ (coeff*fpeak)) .^2;
            SYF = ones(size(APSHAP)); 
                ind = APSHAP<+10.;
            PPSHAP = exp(-APSHAP(ind));
            SYF(ind) = pef.^PPSHAP;

            Ef = SYF.*RA;%./(spcsig*2*pi);

            % scale to Hs
                m0_s = Integrate.trapeziumRule(freq, Ef);
                m0_g = Hs^2/16;
            factor = m0_g/m0_s;
            
            Ef = factor*Ef;
        end
        function VaDens = spectralShape(freq, spcdir, SPPARM, LOGPM, DSHAPL)
            %
            % freq : frequency mesh [Hz]
            % dirmesh : directional mesh [NAUT]
            % SPPARM : wave characteristics
            %    (1) : Hs
            %    (2) : wave period
            %          Tp   (LOGPM = true)
            %          Tm01 (LOGPM = false)         
            %    (3) : peak enhancement factor
            %    (4) : mean direction
            %    (5) : directional spreading
            %           - MS (DSHAPL = <other>)
            %           - 1D directional spreading (DSHAPL='degrees')     
            % VaDens : Variance Density(d,f) [m2/Hz/rad]

            freq = reshape(freq, [],1);

            if SPPARM(1)<=0
              errordlg('negative wave height')
              return
            end

            % -------------------------------------------------------------------------
            %   compute spectral shape using peak period PKPER                      
            % -------------------------------------------------------------------------

            Hs  = SPPARM(1); 
            Tp  = SPPARM(2); % let's assume wave period is Tp for initial 
            pef = SPPARM(3); % peak enhancement factor
            Ef = Waves.jonswap(freq, Hs, Tp, pef); 

            % -------------------------------------------------------------------------
            %   if mean frequency was given recalculate PKPER and restart
            % -------------------------------------------------------------------------
            if ~LOGPM
                for ITPER=1:10
                    m0 = Integrate.trapeziumRule(freq,Ef);
                    m1 = Integrate.trapeziumRule(freq,freq.*Ef);
                    Tm01 = m0/m1; 
                    if ~isfinite(Tm01)                                                            
                        errordlg('First moment is zero in calculating the spectrum at boundary using param. bc.')
                    end                    
                    if (abs(Tm01-SPPARM(2)) > 0.01*SPPARM(2))
                        Tp = (SPPARM(2) / Tm01) * Tp;
                        Ef = Waves.jonswap(freq, Hs, Tp, pef);   
                    else
                        break
                    end
                    if ITPER==10
                        errordlg('No convergence')
                    end
                end
            end


            % m0 = Integrate.trapeziumRule(freq, Ef);
            % Hm0 = 4*sqrt(m0)
            % -------------------------------------------------------------------------
            % 	now introduce distribution over directions
            % -------------------------------------------------------------------------
                   % Mean direction
                  NAUT = SPPARM(4); %MDIR in nautical degrees
%                   % convert to cartesian
%                   CART = mod(270-NAUT,360); 
%                   ADIR = CART*pi/180; % degrees to radians 
                  ADIR = NAUT*pi/180;
                  % 
                  if strcmpi(DSHAPL, 'degrees') % Directional spreading in degrees
                    DSPR = pi * SPPARM(5) / 180.;
                    MS = max (DSPR^(-2) - 2., 1.); % convert to factor.
                  else
                    MS = SPPARM(5);
                  end

                  if (MS<12.)
                    CTOT = (2.^MS) * (gamma(0.5*MS+1.))^2 / (pi * gamma(MS+1.));
                  else
                    CTOT =  sqrt (0.5*MS/pi) / (1. - 0.25/MS);
                  end

                  ACOS = cos(spcdir - ADIR)';
                    indacos = ACOS<=0;
                  CDIR = CTOT.*max(ACOS.^MS, 1.E-10);
                  CDIR(indacos) = 0;
            %             CDIR = CDIR/M;
                  VaDens =  CDIR*Ef';

                    m0_s = abs(Integrate.trapeziumRule2dMG(freq',spcdir',VaDens)); % negative when direction decreasing.
                    m0_g = Hs^2/16;

                    factor = m0_g/m0_s;
                    VaDens = factor*VaDens;
        end
        
        function create_2dspectra_4c_from_era5(tblERA5, freq, dirmesh, fullfileOut, starttime, endtime)
            % create a 2d spectra of 4 components from ERA5 time series
            
            % tblERA5   : table with ERA5 wave characteristics (ERA5.extractTimeSeriesWaves)
            % freq      : frequency mesh
            % dirmesh   : directional mesh (nautical convention)
            % fullfileOut : filename of output file 
            % starttime : time to start spectral output
            % endtime : time to end spectral output
            % fcal : (calibration term) maximum frequency to compute Tm01
            %         of swell components when computing Jonswap with Tm01 
            %         rather than Tp 
            
            
            %% Initialise DAT structure
                                    nfreq = numel(freq);
                                     ndir = numel(dirmesh); 
                %% Initialise DAT structure
                  DAT.number_of_locations = 1;
                             DAT.timecode = 1;
                             %DAT.timefmt = 'yyyymmdd.HHMMSS';
                        DAT.date_and_time = datenum(starttime);
                                  DAT.mxc = 0;
                                  DAT.myc = 0;
                                    DAT.x = 0;
                                    DAT.y = 0;
                                  DAT.lon = 0;
                                  DAT.lat = 0;
                       DAT.frequency_type = 'absolute';

                            DAT.frequency = freq;
                DAT.number_of_frequencies = nfreq;

                DAT.dimension_of_spectrum = 2;
                 DAT.number_of_quantities = 1;
            DAT.quantity_exception_values = -99;
                       DAT.quantity_names = {'VaDens'};
                  DAT.quantity_names_long = {'variance densities in m2/Hz/degr'};
                       DAT.quantity_units = {'m2/Hz/degr'};
                                 DAT.NDIR = dirmesh; % nautical
                               DAT.VaDens = [];
            % write to outputfile
            swan_io_2Dspectrum_writeTS(fullfileOut, DAT);
            
            % append spectra
            indtime = find(tblERA5.Time>=starttime & tblERA5.Time<=endtime);
            indtime = indtime'; 
            tblERA5.Time.Format = 'yyyyMMdd.HHmmss';
            
            fmt = [repmat('% 5i ', 1, ndir) '\r\n'];
            spcdir = dirmesh*pi/180; 
            
            fid = fopen(fullfileOut, 'a');
            for itime = indtime
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                % first swell component
                SPPARM = [tblERA5.p140121(itime), tblERA5.p140123(itime), 3.3, tblERA5.p140122(itime), 10];                    
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell1 = zeros(ndir,nfreq);
                else
                    swell1 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS');
                end
                % second swell component
                SPPARM = [tblERA5.p140124(itime), tblERA5.p140126(itime), 3.3, tblERA5.p140125(itime), 10];                  
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell2 = zeros(ndir,nfreq);
                else
                    swell2 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS');
                end
                % third swell component
                SPPARM = [tblERA5.p140127(itime), tblERA5.p140129(itime), 3.3, tblERA5.p140128(itime), 10];                  
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell3 = zeros(ndir,nfreq);
                else
                    swell3 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS');
                end
                % wind waves
                SPPARM = [tblERA5.shww(itime), tblERA5.p1ww(itime), 3.3,tblERA5.mdww(itime), 180/pi*tblERA5.dwww(itime)]; 
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    windsea = zeros(ndir,nfreq);
                else
                    windsea = Waves.spectralShape(freq, spcdir, SPPARM, false, 'degrees');
                end
                spec = swell1+ swell2 + swell3 + windsea; 
                spec = spec*pi/180;
                % scale wave height
                    Hs =  Waves.specPar2D(freq,dirmesh*pi/180,spec*180/pi);
                    Hm0 = tblERA5.swh(itime); 
                    fac = (Hm0/Hs)^2;
                spec = spec*fac;    
                % rescale spectrum : maximum number 9901 
                    mx1 = max(spec); 
                    mx2 = max(mx1); 
                    FACTOR = mx2/9901;
                    scaled_spec = round(spec./FACTOR);
                
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                T = sprintf('%s                         date and time', tblERA5.Time(itime)); 
                fprintf  (fid,'%s\r\n',T);
                
                fprintf  (fid,'%s \r\n','FACTOR ');
                fprintf  (fid,'%g \r\n',FACTOR);
                
                fprintf(fid, fmt, scaled_spec);
            end
            
            fclose(fid);
        end
        
        function create_2dspectra_4c_from_era5_test(tblERA5, freq, dirmesh, fullfileOut, starttime, endtime)
            % create a 2d spectra of 4 components from ERA5 time series
            
            % tblERA5   : table with ERA5 wave characteristics (ERA5.extractTimeSeriesWaves)
            % freq      : frequency mesh
            % dirmesh   : directional mesh (nautical convention)
            % fullfileOut : filename of output file 
            % starttime : time to start spectral output
            % endtime : time to end spectral output
            % TEST in stead of individual Tm01, which are wrong, Tm01 of
            % total swell component
            
            %% Initialise DAT structure
                                    nfreq = numel(freq);
                                     ndir = numel(dirmesh); 
                %% Initialise DAT structure
                  DAT.number_of_locations = 1;
                             DAT.timecode = 1;
                             %DAT.timefmt = 'yyyymmdd.HHMMSS';
                        DAT.date_and_time = datenum(starttime);
                                  DAT.mxc = 0;
                                  DAT.myc = 0;
                                    DAT.x = 0;
                                    DAT.y = 0;
                                  DAT.lon = 0;
                                  DAT.lat = 0;
                       DAT.frequency_type = 'absolute';

                            DAT.frequency = freq;
                DAT.number_of_frequencies = nfreq;

                DAT.dimension_of_spectrum = 2;
                 DAT.number_of_quantities = 1;
            DAT.quantity_exception_values = -99;
                       DAT.quantity_names = {'VaDens'};
                  DAT.quantity_names_long = {'variance densities in m2/Hz/degr'};
                       DAT.quantity_units = {'m2/Hz/degr'};
                                 DAT.NDIR = dirmesh; % nautical
                               DAT.VaDens = [];
            % write to outputfile
            swan_io_2Dspectrum_writeTS(fullfileOut, DAT);
            
            % append spectra
            indtime = find(tblERA5.Time>=starttime & tblERA5.Time<=endtime);
            indtime = indtime'; 
            tblERA5.Time.Format = 'yyyyMMdd.HHmmss';
            
            fmt = [repmat('% 5i ', 1, ndir) '\r\n'];
            spcdir = dirmesh*pi/180; 
            
            fid = fopen(fullfileOut, 'a');
            for itime = indtime
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                % first swell component
                SPPARM = [tblERA5.p140121(itime), tblERA5.p1ps(itime), 3.3, tblERA5.p140122(itime), 10];                    
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell1 = zeros(ndir,nfreq);
                else
                    swell1 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS'); % false should be true
                end
                % second swell component
                SPPARM = [tblERA5.p140124(itime), tblERA5.p1ps(itime), 3.3, tblERA5.p140125(itime), 10];                  
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell2 = zeros(ndir,nfreq);
                else
                    swell2 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS'); % false should be true
                end
                % third swell component
                SPPARM = [tblERA5.p140127(itime), tblERA5.p1ps(itime), 3.3, tblERA5.p140128(itime), 10];                  
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    swell3 = zeros(ndir,nfreq);
                else
                    swell3 = Waves.spectralShape(freq, spcdir, SPPARM, false, 'MS'); % last false should be true
                end
                % wind waves
                SPPARM = [tblERA5.shww(itime), tblERA5.p1ww(itime), 3.3,tblERA5.mdww(itime), 180/pi*tblERA5.dwww(itime)]; 
                if SPPARM(1)<0.01 || isinf(SPPARM(1))
                    windsea = zeros(ndir,nfreq);
                else
                    windsea = Waves.spectralShape(freq, spcdir, SPPARM, false, 'degrees');
                end
                spec = swell1+ swell2 + swell3 + windsea; 
                spec = spec*pi/180;
                % scale wave height
                    Hs =  Waves.specPar2D(freq,dirmesh*pi/180,spec*180/pi);
                    Hm0 = tblERA5.swh(itime); 
                    fac = (Hm0/Hs)^2;
                spec = spec*fac;    
                % rescale spectrum : maximum number 9901 
                    mx1 = max(spec); 
                    mx2 = max(mx1); 
                    FACTOR = mx2/9901;
                    scaled_spec = round(spec./FACTOR);
                
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                T = sprintf('%s                         date and time', tblERA5.Time(itime)); 
                fprintf  (fid,'%s\r\n',T);
                
                fprintf  (fid,'%s \r\n','FACTOR ');
                fprintf  (fid,'%g \r\n',FACTOR);
                
                fprintf(fid, fmt, scaled_spec);
            end
            
            fclose(fid);
        end
       function create_2dspectra_2c_from_era5(tblERA5, freq, dirmesh, fullfileOut, starttime, endtime)
            % create a 2d spectra of 4 components from ERA5 time series
            
            % tblERA5   : table with ERA5 wave characteristics (ERA5.extractTimeSeriesWaves)
            % freq      : frequency mesh
            % dirmesh   : directional mesh (nautical convention)
            % fullfileOut : filename of output file 
            % starttime : time to start spectral output
            % endtime : time to end spectral output
            
            
            %% Initialise DAT structure
                                    nfreq = numel(freq);
                                     ndir = numel(dirmesh); 
                %% Initialise DAT structure
                  DAT.number_of_locations = 1;
                             DAT.timecode = 1;
                             %DAT.timefmt = 'yyyymmdd.HHMMSS';
                        DAT.date_and_time = datenum(starttime);
                                  DAT.mxc = 0;
                                  DAT.myc = 0;
                                    DAT.x = 0;
                                    DAT.y = 0;
                                  DAT.lon = 0;
                                  DAT.lat = 0;
                       DAT.frequency_type = 'absolute';

                            DAT.frequency = freq;
                DAT.number_of_frequencies = nfreq;

                DAT.dimension_of_spectrum = 2;
                 DAT.number_of_quantities = 1;
            DAT.quantity_exception_values = -99;
                       DAT.quantity_names = {'VaDens'};
                  DAT.quantity_names_long = {'variance densities in m2/Hz/degr'};
                       DAT.quantity_units = {'m2/Hz/degr'};
                                 DAT.NDIR = dirmesh; % nautical
                               DAT.VaDens = [];
            % write to outputfile
            swan_io_2Dspectrum_writeTS(fullfileOut, DAT);
            
            % append spectra
            indtime = find(tblERA5.Time>=starttime & tblERA5.Time<=endtime);
            indtime = indtime'; 
            tblERA5.Time.Format = 'yyyyMMdd.HHmmss';
            
            fmt = [repmat('% 5i ', 1, ndir) '\r\n'];
            spcdir = dirmesh*pi/180; 
            
            fid = fopen(fullfileOut, 'a');
            for itime = indtime
%                 if tblERA5.Time(itime)==datetime(2015,11,5,6,0,0)
%                     help = 'me'; 
%                 end
                % total swell component
                SPPARM = [tblERA5.shts(itime), tblERA5.p1ps(itime), 3.3, tblERA5.mdts(itime), 180/pi*tblERA5.dwps(itime)];                    
                if SPPARM(1)<0.01 || ~isfinite(SPPARM(1))
                    swelltot = zeros(ndir,nfreq);
                else
                    swelltot= Waves.spectralShape(freq, spcdir, SPPARM, false, 'degrees');
                end
                % wind waves
                SPPARM = [tblERA5.shww(itime), tblERA5.p1ww(itime), 3.3,tblERA5.mdww(itime), 180/pi*tblERA5.dwww(itime)]; 
                if SPPARM(1)<0.01 || ~isfinite(SPPARM(1))
                    windsea = zeros(ndir,nfreq);
                else
                    windsea = Waves.spectralShape(freq, spcdir, SPPARM, false, 'degrees');
                end
                spec = swelltot + windsea; 
                spec = spec*pi/180;
                % scale with wave height
                    Hs =  Waves.specPar2D(freq,dirmesh*pi/180,spec*180/pi);
                    Hm0 = tblERA5.swh(itime); 
                    fac = (Hm0/Hs)^2;
                spec = spec*fac;    
                % rescale spectrum : maximum number 9901 
                    mx1 = max(spec); 
                    mx2 = max(mx1); 
                    FACTOR = mx2/9901;
                    scaled_spec = round(spec./FACTOR);
                
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                T = sprintf('%s                         date and time', tblERA5.Time(itime)); 
                fprintf  (fid,'%s\r\n',T);
                
                fprintf  (fid,'%s \r\n','FACTOR ');
                fprintf  (fid,'%g \r\n',FACTOR);
                
                fprintf(fid, fmt, scaled_spec);
            end
            
            fclose(fid);
       end
        
       
       function create_2dspectra_2c_from_era5_test(tblERA5, freq, dirmesh, fullfileOut, starttime, endtime)
            % create a 2d spectra of 4 components from ERA5 time series
            
            % tblERA5   : table with ERA5 wave characteristics (ERA5.extractTimeSeriesWaves)
            % freq      : frequency mesh
            % dirmesh   : directional mesh (nautical convention)
            % fullfileOut : filename of output file 
            % starttime : time to start spectral output
            % endtime : time to end spectral output
            
            
            %% Initialise DAT structure
                                    nfreq = numel(freq);
                                     ndir = numel(dirmesh); 
                %% Initialise DAT structure
                  DAT.number_of_locations = 1;
                             DAT.timecode = 1;
                             %DAT.timefmt = 'yyyymmdd.HHMMSS';
                        DAT.date_and_time = datenum(starttime);
                                  DAT.mxc = 0;
                                  DAT.myc = 0;
                                    DAT.x = 0;
                                    DAT.y = 0;
                                  DAT.lon = 0;
                                  DAT.lat = 0;
                       DAT.frequency_type = 'absolute';

                            DAT.frequency = freq;
                DAT.number_of_frequencies = nfreq;

                DAT.dimension_of_spectrum = 2;
                 DAT.number_of_quantities = 1;
            DAT.quantity_exception_values = -99;
                       DAT.quantity_names = {'VaDens'};
                  DAT.quantity_names_long = {'variance densities in m2/Hz/degr'};
                       DAT.quantity_units = {'m2/Hz/degr'};
                                 DAT.NDIR = dirmesh; % nautical
                               DAT.VaDens = [];
            % write to outputfile
            swan_io_2Dspectrum_writeTS(fullfileOut, DAT);
            
            % append spectra
            indtime = find(tblERA5.Time>=starttime & tblERA5.Time<=endtime);
            indtime = indtime'; 
            tblERA5.Time.Format = 'yyyyMMdd.HHmmss';
            
            fmt = [repmat('% 5i ', 1, ndir) '\r\n'];
            spcdir = dirmesh*pi/180; 
            
            fid = fopen(fullfileOut, 'a');
            for itime = indtime
%                 if tblERA5.Time(itime)==datetime(2015,11,5,6,0,0)
%                     help = 'me'; 
%                 end
                % total swell component
                SPPARM = [tblERA5.shts(itime), tblERA5.p1ps(itime), 3.3, tblERA5.mdts(itime), 180/pi*tblERA5.dwps(itime)];                    
                if SPPARM(1)<0.01 || ~isfinite(SPPARM(1))
                    swelltot = zeros(ndir,nfreq);
                else
                    swelltot= Waves.spectralShape(freq, spcdir, SPPARM, true, 'degrees');
                end
                % wind waves
                SPPARM = [tblERA5.shww(itime), tblERA5.p1ww(itime), 3.3,tblERA5.mdww(itime), 180/pi*tblERA5.dwww(itime)]; 
                if SPPARM(1)<0.01 || ~isfinite(SPPARM(1))
                    windsea = zeros(ndir,nfreq);
                else
                    windsea = Waves.spectralShape(freq, spcdir, SPPARM, false, 'degrees');
                end
                spec = swelltot + windsea; 
                spec = spec*pi/180;
                % scale with wave height
                    Hs =  Waves.specPar2D(freq,dirmesh*pi/180,spec*180/pi);
                    Hm0 = tblERA5.swh(itime); 
                    fac = (Hm0/Hs)^2;
                spec = spec*fac;    
                % rescale spectrum : maximum number 9901 
                    mx1 = max(spec); 
                    mx2 = max(mx1); 
                    FACTOR = mx2/9901;
                    scaled_spec = round(spec./FACTOR);
                
                if tblERA5.Time(itime)==datetime(2011,1,26,6,0,0)
                    help = 'me'; 
                end
                T = sprintf('%s                         date and time', tblERA5.Time(itime)); 
                fprintf  (fid,'%s\r\n',T);
                
                fprintf  (fid,'%s \r\n','FACTOR ');
                fprintf  (fid,'%g \r\n',FACTOR);
                
                fprintf(fid, fmt, scaled_spec);
            end
            
            fclose(fid);
       end
       
        function transform_spectra_era5_to_swan(fullfileIn, fullfileOut, lon, lat, starttime, endtime)
            % create a 2d spectra of 4 components from ERA5 time series
            
            % fullfileIn : filename of input file 
            % fullfileOut : filename of output file 
            % lon : longitude
            % lat : latitude
            % starttime : time to start spectral output
            % endtime : time to end spectral output
            
            dim = Tomawac.dimensionsERA5(fullfileIn);
            dirmesh = flipud(mod((dim.dir+pi)*180/pi,360)); % goingto/coming from
                ind = find(dirmesh(2:end)>dirmesh(1:end-1))+1; 
                dirmesh(ind:end) = dirmesh(ind:end)-360; % SWAN
            freq = dim.freq;
            time0 = datenum('01-Jan-1900');  % reference time
            Time = double(ncread(fullfileIn, 'time'))/24+time0; 
            Time = datetime(Time, 'convertFrom', 'datenum'); 
            latitude = ncread(fullfileIn, 'latitude');
            longitude = ncread(fullfileIn, 'longitude');
                [~, indlon] = min(abs(longitude-lon)); 
                [~, indlat] = min(abs(latitude-lat)); 
            %% Initialise DAT structure
                                    nfreq = numel(freq);
                                     ndir = numel(dirmesh); 
                %% Initialise DAT structure
                  DAT.number_of_locations = 1;
                             DAT.timecode = 1;
                             %DAT.timefmt = 'yyyymmdd.HHMMSS';
                        DAT.date_and_time = datenum(starttime);
                                  DAT.mxc = 0;
                                  DAT.myc = 0;
                                    DAT.x = 0;
                                    DAT.y = 0;
                                  DAT.lon = 0;
                                  DAT.lat = 0;
                       DAT.frequency_type = 'absolute';

                            DAT.frequency = freq;
                DAT.number_of_frequencies = nfreq;

                DAT.dimension_of_spectrum = 2;
                 DAT.number_of_quantities = 1;
            DAT.quantity_exception_values = -99;
                       DAT.quantity_names = {'VaDens'};
                  DAT.quantity_names_long = {'variance densities in m2/Hz/degr'};
                       DAT.quantity_units = {'m2/Hz/degr'};
                                 DAT.NDIR = dirmesh; % nautical
                               DAT.VaDens = [];
            % write to outputfile
            swan_io_2Dspectrum_writeTS(fullfileOut, DAT);
            
            % append spectra
            indtime = find(Time>=starttime & Time<=endtime);
            indtime = indtime'; 
            Time.Format = 'yyyyMMdd.HHmmss';
            
            fmt = [repmat('% 5i ', 1, ndir) '\r\n'];
            spcdir = dirmesh*pi/180; 
            
            fid = fopen(fullfileOut, 'a');
            for itime = indtime
                spec = squeeze(Tomawac.spectraERA5(fullfileIn, indlon, indlat, itime,1));
                spec = spec*pi/180;
                spec = flipud(spec); % both dirmesh and spec are flipped! (order SWAN)
                % rescale spectrum : maximum number 9901 
                    mx1 = max(spec); 
                    mx2 = max(mx1); 
                    FACTOR = mx2/9901;
                    scaled_spec = round(spec./FACTOR);

                T = sprintf('%s                         date and time', Time(itime)); 
                fprintf  (fid,'%s\r\n',T);
                
                fprintf  (fid,'%s \r\n','FACTOR ');
                fprintf  (fid,'%g \r\n',FACTOR);
                
                fprintf(fid, fmt, scaled_spec);
            end
            
            fclose(fid);
        end
    end
end