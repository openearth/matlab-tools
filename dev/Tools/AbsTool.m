%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef AbsTool < handle
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
        function SCB = correctABS(sctAdcp, sctWater, sctOptions)
            % function sctProfiles = Script_Extract_Profiles(dataSet, sctOptions)
            % This job extracts profile data from data in timeseries format (such as
            % could have been read from an IMDC format)and returns a struct containing
            % all the individual profiles.
            %
            %#INPUTS: The input is a struct with the following fields
            %        -sctData.nColDepth: the kolom of the data with the depth in
            %        sctData.mData
            %        -sctData.strUpDown (optional): this string has either the value
            %        'up', 'down' or 'both', which refers to only upcasts, downcasts
            %        and both upcasts and downcasts in the data
            %        -sctData.mData: a matrix containing the data. the first two
            %        columns are expected to be date and time
            %        -sctData.nMinDepth: the threshold value for the depth. Only
            %        profiles are generated for depths higher than this value
            %#OUTPUTS: the output is a vector of structs, each value of which contains
            %an extracted profile. Such a profile has the fields
            %    sctProfiles(nI).mData: the profiles of the new data
            %    sctProfiles(nI).nDepth: the maximum depth
            %    sctProfiles(nI).nDate: the data
            %    sctProfiles(nI).nTime: the time
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: Okt 2009
            % Modified by:
            % Date:
            if ~isfield(sctOptions,'diaTransducer')
                sctOptions.diaTransducer = 20; % based on expert justment in Sediview (Note: Wageningen uses a radius value of 0.0505 or diameter if 0.1010)
            end
            if ~isfield(sctOptions,'soundVelAdcp')
                sctOptions.soundVelAdcp = 1500;
            end
            if ~isfield(sctOptions,'firmAdcp')
                sctOptions.firmAdcp = 'rdi';
            end
            
            if ~isfield(sctOptions,'depthAdcp')
                sctOptions.depthAdcp = 0;
            end
            
            if ~isfield(sctOptions,'method')
                sctOptions.method = 'gostiaux-vanharen';
            end
            
            if ~isfield(sctOptions,'particleSize')
                sctOptions.particleSize = 20;
            end
            if ~isfield(sctOptions,'pH')
                sctOptions.pH = 8;
            end
            if ~isfield(sctOptions,'bOnlyWaterAnnuation')
                sctOptions.bOnlyWaterAnnuation = false;
            end
            if ~isfield(sctOptions,'kc')
                sctOptions.kc = 0.43;
            end
            if ~isfield(sctOptions,'Er')
               sctOptions.Er = 40; % 0 is used in Sediview. Literature: 40
                if strcmpi(sctOptions.method,'sediview')
                    sctOptions.Er = 0;
                end
            end
             if ~isfield(sctOptions,'C')
                sctOptions.C = 0; 
             end
            if ~isfield(sctOptions,'powerSupply')
                sctOptions.powerSupply = 'external'; 
            end
              if ~isfield(sctOptions,'Ks')
                sctOptions.Ks = 50; 
              end
              if ~isfield(sctOptions,'S')
                sctOptions.S = 21; 
              end
             if ~isfield(sctOptions,'AlphaW_method')
                sctOptions.AlphaW_method = 'medwin';
                if strcmpi(sctOptions.method,'sediview')
                   sctOptions.AlphaW_method = 'schulkin';
                end
             end
            % define the input parameters
            intensities = double(sctAdcp.ECHO);                                  % echo intensity (counts)
            specs_adcp = AbsTool.adcpSpecs(sctOptions.firmAdcp, sctAdcp.sysconf);
            specs_adcp.blankingDistance = double(sctAdcp.blnk)./100;                  % blank after transmit (m)
            specs_adcp.pulseLength = double(sctAdcp.lngthtranspulse)/100;       % transmit pulse length (m)
            specs_adcp.binSize  = double(sctAdcp.binsize)./100; % binsize in metres
            specs_adcp.nBins = double(sctAdcp.nbins);
            specs_adcp.nEns = length(sctAdcp.temperature);

            temp_water = repmat(double(sctAdcp.temperature)./100,specs_adcp.nBins ,1);
            sal_water = repmat(double(sctAdcp.salinity),specs_adcp.nBins ,1);
            
            % calculation of some extra parameters
            if ~strcmpi(sctOptions.method, 'sediview')
                specs_adcp.currentAmp = specs_adcp.currentFact*double(sctAdcp.ADC(:,1))';          % current (A)
                specs_adcp.voltage = specs_adcp.voltFact*double(sctAdcp.ADC(:,2))';             % voltage (V) 
                specs_adcp.tempTrans = AbsTool.getTempTransducer(double(sctAdcp.ADC(:,6))', specs_adcp);  % real-time temperature of the transducer (C)
                
                LDBM = 10*log10(specs_adcp.pulseLength);
                power = specs_adcp.voltage.*specs_adcp.currentAmp; % Transmit power in Watts
                PDBW = 10*log10(power);
                if strcmpi(sctOptions.powerSupply, 'internal') % correction regarding Mullison 2017 if batteries are used.
                    PDBW = PDBW + 20.*log10(specs_adcp.voltage./specs_adcp.voltBattery);
                end
                if sctOptions.C == 0
                    sctOptions.C =  specs_adcp.tempConstant;
                end
                 Tx = repmat(specs_adcp.tempTrans, specs_adcp.nBins, 1);
                 PDBW = repmat(PDBW, specs_adcp.nBins, 1);
            else
                  % conversion from counts to dB
                 ABS = AbsTool.convert2dB(intensities, sctOptions);
            end
            
            % calculate depth of the bins (centre of the bins!)
            soundVel1 = Physics.calculateSoundVelocity(temp_water(:,1), sal_water(:,1), sctOptions.depthAdcp);
            depth = AbsTool.calculateBinDepth(specs_adcp, sctOptions.depthAdcp, soundVel1, sctOptions.soundVelAdcp);
            soundVel = Physics.calculateSoundVelocity(temp_water, sal_water, depth);
            depth = AbsTool.calculateBinDepth(specs_adcp, sctOptions.depthAdcp, soundVel(:,1), sctOptions.soundVelAdcp);
            depth = repmat(depth,1, specs_adcp.nEns);
            
            % calculates the slant range R
            distR = AbsTool.calculateRange(specs_adcp, soundVel, sctOptions.soundVelAdcp);
            distR = repmat(distR,1, specs_adcp.nEns);
            binsR = diff(distR);
                        
            % near-field correction
            nearField = AbsTool.calculateNearField(distR, soundVel, specs_adcp.freqActual, sctOptions.diaTransducer);
            
            % water annuation
            alpha_w = Physics.soundAttenuationWater(specs_adcp.freqActual, temp_water, sal_water, depth, sctOptions.pH, sctOptions.AlphaW_method);
            Ra_w(1,:) = alpha_w(1,:).*distR(1,:);
            Ra_w(2:specs_adcp.nBins,:) = alpha_w(1:end-1,:).*distR(1:end-1,:) + (alpha_w(1:end-1,:) + alpha_w(2:end,:)).*binsR.*0.5; % incl. annuation of the upper water layers
            
            % calculate the SCB without sediment concentration 
            switch lower(sctOptions.method)
                case 'sediview'
                    SCB = ABS + 20.*log10(nearField.*distR) + 2.*Ra_w;
                case 'trdi-fst'
                   SCB = sctOptions.C + 10*log10((Tx + 273.16).*distR.^2.*nearField.^2) - LDBM - PDBW + 2.*Ra_w +...
                        10.*log10(10.^(sctOptions.kc.*(intensities - sctOptions.Er)./10) - 1);
                case 'gostiaux-vanharen'
                    SCB = sctOptions.C + 10*log10((Tx + 273.16).*distR.^2.*nearField.^2) - LDBM - PDBW + 2.*Ra_w +...
                        10.*log10(10.^(sctOptions.kc.*intensities./10) - 10.^(sctOptions.kc.*sctOptions.Er./10));
                otherwise
                    error('The defined calculation method isnot available.')
            end
            
             % calculate SCB with sediment annuation         
             if ~sctOptions.bOnlyWaterAnnuation
                 % sediment annuation
                 alpha_s = Physics.soundAttenuationSediment(specs_adcp.freqActual, temp_water, sal_water, depth,  sctOptions.particleSize);
                 % implementation of attenuation on R according Thorne and
                 % Hanes (2002)
                 switch lower(sctOptions.method)
                     case 'sediview'
                         %error('to be checked');
                         %SSC_w = 1/1000.*10.^((-sctOptions.Ks + SCB)./sctOptions.S);% SSC in g/l
                         %SSC_w = 1/1000.*10.^((-54 + SCB)./10);% SSC in g/l
                         SSC_w = ones(size(ABS))./1000; % using 1 mg/L in stead
                         SSC = SSC_w;
                         Ra_s(1,:,:) = alpha_s(1,:).*distR(1,:).*SSC_w(1,:,:);
                         for iB = 1 : size(ABS, 3)
                             for i = 2 : specs_adcp.nBins
                                 Ra_s(i,:,iB) = alpha_s(i-1,:).*distR(i-1,:).*SSC(i-1,:,iB) + (alpha_s(i-1,:).*SSC(i-1,:,iB) + alpha_s(i,:).*SSC_w(i,:,iB)).*0.5.*binsR(i-1);
                                 
                                 SCB(i,:,iB) = ABS(i,:,iB) + 20.*log10(nearField(i,:).*distR(i,:)) + 2.*Ra_w(i,:) + 2.*Ra_s(i,:,iB);
                                 %SSC(i,:,iB) = 1/1000.*10.^((-sctOptions.Ks + SCB(i,:,iB))./sctOptions.S);
                             end
                         end   
                         SSC = 10.^((-sctOptions.Ks + SCB)./sctOptions.S);
                     case 'trdi-fst'
                         SSC_w = 10.^(SCB./10);
                         SSC(1,:,:) = SSC_w(1,:,:);
                         Ra_s(1,:,:) = alpha_s(1,:).*distR(1,:).*SSC_w(1,:,:);
                         for iB = 1 : size(SSC_w, 3)
                             for i = 2 : specs_adcp.nBins
                                 Ra_s(i,:,iB) = alpha_s(i-1,:).*distR(i-1,:).*SSC(i-1,:,iB) + (alpha_s(i-1,:).*SSC(i-1,:,iB) + alpha_s(i,:).*SSC_w(i,:,iB)).*0.5.*binsR(i-1);
                                 
                                 SCB(i,:,iB) = sctOptions.C + 10*log10((Tx(i,:) + 273.16).*distR(i,:).^2.*nearField(i,:).^2) - LDBM - PDBW(i,:) + 2.*Ra_w(i,:)...
                                     + Ra_s(i,:,iB) + 10.*log10(10.^(sctOptions.kc.*(intensities(i,:,iB) - sctOptions.Er)./10) - 1);
                                 SSC(i,:,iB) = 10.^(SCB(i,:,iB)./10);
                             end
                         end
                     case 'gostiaux-vanharen'
                         SSC_w = 10.^(SCB./10);
                         SSC(1,:,:) = SSC_w(1,:,:);
                         Ra_s(1,:,:) = alpha_s(1,:).*distR(1,:).*SSC_w(1,:,:);
                         for iB = 1 : size(SSC_w, 3)
                             for i = 2 : specs_adcp.nBins
                                 Ra_s(i,:,iB) = alpha_s(i-1,:).*distR(i-1,:).*SSC(i-1,:,iB) + (alpha_s(i-1,:).*SSC(i-1,:,iB) + alpha_s(i,:).*SSC_w(i,:,iB)).*0.5.*binsR(i-1);
                                 
                                 SCB(i,:,iB) = sctOptions.C + 10*log10((Tx(i,:) + 273.16).*distR(i,:).^2.*nearField(i,:).^2) - LDBM - PDBW(i,:) + 2.*Ra_w(i,:)...
                                     + Ra_s(i,:,iB) + 10*log10(10.^(sctOptions.kc.*intensities(i,:,iB)./10) - 10.^(sctOptions.kc.*sctOptions.Er./10));
                                 SSC(i,:,iB) = 10.^(SCB(i,:,iB)./10);
                             end
                         end
                 end
                 
             end 
        end
         function  depth = calculateBinDepth(specs_adcp, depthAdcp, soundVel, soundVelAdcp) 
            % this script calculates depth of each bin based on the centre
            % of each bin.
            %
            % depth = AbsTool.calculateBinDepth(specs_adcp, depthAdcp, soundVel, soundVelAdcp) 
            %
            %#INPUTS: 
            % specs_adcp = structure with follwing fields:
            %       blankingDistance = blanking after transmit in m
            %       pulseLength = pulse length transmit in m
            %       nBins = number of bins
            %
            % depthADCP = depth of ADCP below the water surface (m)
            %            (default = 0)
            % soundVel = observed sound velocity of the water (m/s)
            %            (default: 1500 m/s)
            % soundVelAdcp = sound velocity set by the ADCP  
            %             (default: 1500 m/s) 
            %
            %
            %#OUTPUTS: Nx1 matrix with depths in metres N = nBins
            %
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 03/2019
            % Modified by:
            % Date:
           
            % default;
           
            B = specs_adcp.blankingDistance;
            L = specs_adcp.pulseLength;
            binSize = specs_adcp.binSize;
            N = [1:specs_adcp.nBins]';
            
            if nargin < 4
               soundVelAdcp = 1500;
            end
            if nargin < 3
               soundVel = 1500;
            end
            if nargin < 2
                depthAdcp = 0;
            end
            
            distR1 = depthAdcp + B + (L + binSize).*0.5;
            depth = soundVel./soundVelAdcp.*(distR1 + ((N - 1).*binSize)) + depthAdcp;

        end
       
          function distR = calculateRange(specs_adcp, soundVel, soundVelAdcp)
            % this script calculates depth of each bin based on the centre
            % of each bin.
            %
            % depth = AbsTool.calculateBinDepth(specs_adcp, depthAdcp, soundVel, soundVelAdcp) 
            %
            %#INPUTS: 
            % specs_adcp = structure with follwing fields:
            %       blankingDistance = blanking after transmit in m
            %       pulseLength = pulse length transmit in m
            %       nBins = number of bins
            %       beamAngle = beam angle in degrees
            %       firm = string of the adcp manufacturer (default: 'rdi')
            %       type = string of adcp type (default: 'workhorse')
            %
            % depthADCP = depth of ADCP below the water surface (m)
            %            (default = 0)
            % soundVel = observed sound velocity of the water (m/s)
            %            (default: 1500 m/s)
            % soundVelAdcp = sound velocity set by the ADCP  
            %             (default: 1500 m/s) 
            %
            %
            %#OUTPUTS: Nx1 matrix with slant range in metres N = nBins
            %
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 03/2019
            % Modified by:
            % Date:
           
            % default;
            typeLastQuarter = {'rdi_workhorse','rdi_long ranger','rdi_quartermaster'};
                % those type, the last quarter of bin has taken to
                % calculate the slank distance. (see Mullison, 2017)
            posBin = 0;
             
            if ~isfield(specs_adcp, 'firm')
                specs_adcp.firm = 'rdi';
            end
            if ~isfield(specs_adcp, 'type')
               specs_adcp.type = 'workhorse'; 
            end
            
            N = [1:specs_adcp.nBins]';
            type = [specs_adcp.firm,'_',specs_adcp.type];                      
             
             if nargin < 3
               soundVelAdcp = 1500;
            end
            if nargin < 2
               soundVel = 1500;
            end
            
            if sum(strcmpi(type,  typeLastQuarter)) > 0 % workhorse, long ranger and quartermaster 
                posBin =  specs_adcp.binSize./4; % take the last quarter of each cell
            end
            
            distR1 = specs_adcp.blankingDistance + (specs_adcp.pulseLength + specs_adcp.binSize).*0.5;                      
            distR = soundVel(:,1)./(soundVelAdcp.*cosd(specs_adcp.beamAngle)).*(distR1 + ((N - 1).*specs_adcp.binSize + posBin));
            
          end          
            
       
          function ABS = convert2dB(intensities, sctOptions)
            % ABS = convert2dB(intensities, sctOptions)
            % This function converts the obtained intensities to acoustic
            % backscatter in decibels, based on scaling factors. 
            %
            %#INPUTS: The input is a struct with the following fields
            %        
            %#OUTPUTS: the output is a vector of structs, each value of which contains
            %
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: 
            %
            % Date: 
            % Modified by:
            % Date:
           
            if ~isfield(sctOptions,'kc')
                sctOptions.kc = 0.43;
            end
            if ~isfield(sctOptions,'Er')
                sctOptions.Er = 0; % 0 is used in Sediview. Literature: 40
            end
            
            % convert to decibels
            ABS = sctOptions.kc.*(intensities - sctOptions.Er);

          end
        
          function NF = calculateNearField(distR, velSound, frequency, diaTransducer)
            % calculateNearField(distR, velSound, frequency, diaTransducer)
            % This function calculates correction factor regarding near
            % field (as described by Downing et al, 1995). This method is
            % only suitbale for a piston transducer.
            
            %
            %#INPUTS: distR = distance along the beams (m)
            %         diaTransducer = "effective" diameter of transducer (mm) 
            %         velSound = sound of speed (m/s)
            %         frequency = ADCP in kHz
            %
            %#OUTPUTS: matrix
            %
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 03/2019
            % Modified by:
            % Date:
           
            % default;
            if nargin < 4
               diaTransducer = 20; % based on expert justment in Sediview (Note: Wageningen uses a radius value of 0.0505m or diameter if 0.1010)              
            end
            diaTransducer = diaTransducer.*0.95; % theoretically 95% of the physical diameter in mm
            
            % near-field correction coefficient;
            if nargin > 1
                A = (diaTransducer./(2*1000)).^2.*pi;
                Rn = A.*(frequency*1000)./velSound;
                z = distR./Rn;
                %NF = 1+1./((1.35.*Z) + (2.5.*Z).^3.2);
                NF = (1+1.32.*z+(2.5.*z).^3.2)./(1.32.*z+(2.5.*z).^3.2);
            else
                NF = ones(size(distR));
            end   
          end
        
          function  tempTrans = getTempTransducer(raw, specs_adcp, type)
              if nargin < 3
                  type = 'rdi_workhorse';
              end
              switch lower(type)
                  case 'rdi_workhorse'
                      t_cnts = raw.*256; % Temperature Counts (ADC value)
                      tempTrans = specs_adcp.tempTransOffset + polyval(specs_adcp.tempTransCoeff, t_cnts);
                  otherwise
                      error('incorrect adcp type.')
              end
              
          end
            
          
             function sctSpecs = adcpSpecs(firm, freq, type)
            % sctSpecs = adcpSpecs(firm, freq, type)
            % This function lists the adcp specs in a structure depending
            % of the adcp type.
            %
            %#INPUTS: firm  = string of the manufacturer (only: 'RDI')
            %         freq = frequency of the adcp or raw code of RDI adcps (string)
            %         type = to be defined (keep empty)
            %#OUTPUTS: a structure containing following fields
            %    * currentFact = current factor to convert the raw data to
            %                    ampere values
            %    * voltFact = volt factor to convert the raw data to
            %                    voltage values
            %    * tempConstant = constant to convert the raw data to temperature values 
            %    * beamAngle = designed angles of the beams
            %    * freqNom = frequency of adcp rounded on 100
            %    * freqActual = actual frequency of the adcp    
            %
            %#STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 02/12/2019
            % Modified by:
            % Date:
            sctSpecs.firm = firm;
            if nargin > 2
                type = '';
            end
            switch lower(firm)
                case {'rdi',''}
                    angle = '';
                    if length(freq) > 6
                       angle = freq(9:10);
                       freq = freq(1:3);
                    end
                    sctSpecs.type  =  'workhorse';
                    sctSpecs.currentFact= 11451/1e6;
                    sctSpecs.tempTransCoeff(1,1) =  -2.32924716883e-12;
                    sctSpecs.tempTransCoeff(1,2) =  1.60433886495e-7;
                    sctSpecs.tempTransCoeff(1,3) =  -5.86074151382e-3;
                    sctSpecs.tempTransCoeff(1,4) = 9.82697464e1; 
                    sctSpecs.tempTransOffset = -0.35;
                    sctSpecs.voltBattery  = 32; % average battery voltage for Worhorse (see Mullison, 2017) 
                    
                                       % % NOT IMPLEMENTED NEED?
                    % Table for getting the ADCP settings based on the paper
                    %
                    %---------------------------------------------
                    % ADCP                    C	     P	 Rayl. Dist
                    %----------------------------------------------
                    %  76.8	 WH Long Ranger	-159.1  24.0  1.30
                    % 307.2	 WH Sentinel    -143.5  14.0  0.98
                    %	     WH Monitor	    -143.0  14.0  0.98
                    % 614.4	 RioGrande	    -139.3	 9.0  1.96
                    %1228.8	 WH Sentine     -129.1   4.8  1.67
                    %	     WH Monitor	    -129.1	 4.8  1.67
                    %----------------------------------------------
                    %
                    %  George Voulgaris Oct 2004
                    %
                    %C=[-170 -159.1 -143.5 -139.3 -129.1];   % in dB
                    %P=[44  24.0   14.0   9.0     4.8]; % in dBW
                    %RD=[2 1.30 0.98 1.96 1.67]; % Rayleigh Distance (in m)
                    % 
                    switch freq
                        case {'000', '75', 75} 
                            sctSpecs.voltFact = 2092719/1e6; % in Volt
                            sctSpecs.currentFact = 43838/1e6; % in A
                            sctSpecs.tempConstant=-159.1;
                            sctSpecs.freqNom = 75;
                            sctSpecs.freqActual = 76.8;
                            
                        case {'100','150', 150}
                            sctSpecs.voltFact = 592157/1e6;
                            sctSpecs.tempConstant = -153.0;
                            sctSpecs.freqNom = 150;
                            sctSpecs.freqActual = 150;
                            
                        case {'010','300', 300}
                            sctSpecs.voltFact = 592157/1e6;
                            sctSpecs.tempConstant = -143;
                            sctSpecs.freqNom = 300;
                            sctSpecs.freqActual = 307.2;
                            
                        case {'110','600',600}
                            sctSpecs.voltFact = 380667/1e6;
                            sctSpecs.tempConstant = -139.3;
                            sctSpecs.freqNom = 600;
                            sctSpecs.freqActual = 614.4;
                             
                        case {'001', '1200', 1200}
                            sctSpecs.voltFact = 253765/1e6;
                            sctSpecs.tempConstant = -129.1;
                            sctSpecs.freqNom = 1200;
                            sctSpecs.freqActual = 1228.8;
                         case {'101', '2400', 2400} % streamPro
                            sctSpecs.voltFact = 253765/1e6;
                            sctSpecs.tempConstant = NaN;
                            sctSpecs.freqNom = 2400;
                            sctSpecs.freqActual = 2400;
                        otherwise
                            error('unhandled ADCP type');
                    end
                    switch angle
                        case '00'
                            sctSpecs.beamAngle = 15;% degrees
                        case '10'
                            sctSpecs.beamAngle = 20;% degrees
                        case '11'
                            sctSpecs.beamAngle = 30;% degrees
                        case {'01',''}
                            sctSpecs.beamAngle = nan;% degrees
                        otherwise
                            error('unhandled beam angle retrieval');
                    end
                otherwise
                    error('unhandled ADCP manufacturer');
            end
          end
          
    end
end