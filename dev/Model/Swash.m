%Class to declare the most common in SWASH
%
% @author THL
% @version 0.1, 10/02/2014
%

classdef Swash < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties(Dependent = true, SetAccess = private)
        
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
        function [] = createRunFromProtofile(strfilexls, strtabblad,opt)
            %               [] = createRunFromProtofile(strfilexls, strtabblad);
            %               %Create a set of SWASH runs from an input Excel sheet and a proto
            %               file (template).
            % INPUTS
            %   - strfilexls    excel bestand dat de karakteristie van de runs bevat
            %   optional
            %   - strtabblad    tabblad van de excel met de karakteristieken,
            %                   default: "SWASH"
            %   - opt           optional parameters, including:
            %       opt.makeBatch: Whether to also make batch files
            %       (default: true)
            % OUTPUTS
            %   - inputfiles van swash
            %   - batchfiles
            %   - bestanden met de opgevraagde resultaten van SWASH
            %   - resultaten van verwerkte gegevens
            %
            % THL, May 2015, based on similar code by SDO for SWAN.
            
            % Set defaults
            if nargin<2;
                strtabblad= 'SWASH' ;
            end
            
            if nargin<3;
                opt = struct;
            end
            opt = Util.setDefault(opt,'makeBatch',true);
            opt = Util.setDefault(opt,'fileField',{'bathyfile';'wvgfile'});
            
            
            % Read input
            sctSwash = Swash.readInputXls(strfilexls, strtabblad);
            
            % Make SWASH files
            Swash.shellWriteInput(sctSwash, sctSwash(1).author); % De shell laat toe te groeperen per protofile
            if opt.makeBatch;
                % Make Batch files
                cBF = Swash.shellWriteBatch(sctSwash); % De shell laat toe te groeperen per batchfile
            end
            
            for i = 1:numel(opt.fileField);
                if isfield(sctSwash,opt.fileField{i});
                    for j = 1:numel(sctSwash);
                        copyfile(sctSwash(j).(opt.fileField{i}),sctSwash(j).directory);
                    end
                end
            end
        end
        
        
        function [P,F,dof]=crosgk(X,Y,N,M,DT,DW,stats)
            % CROSGK   Power cross-spectrum computation, with smoothing in the
            %          frequency domain
            %
            % Usage: [P,F]=CROSGK(X,Y,N,M,DT,DW,stats)
            %
            % Input:
            % X  contains the data of series 1
            % Y  contains the data of series 2
            % N  is the number of samples per data segment (power of 2)
            % M  is the number of frequency bins over which is smoothed (optional),
            %    no smoothing for M=1 (default)
            % DT is the time step (optional), default DT=1
            % DW is the data window type (optional): DW = 1 for Hann window (default)
            %                                        DW = 2 for rectangular window
            % stats : display resolution, degrees of freedom (optimal, YES=1, NO=0)
            %
            % Output:
            % P contains the (cross-)spectral estimates: column 1 = Pxx, 2 = Pyy, 3 = Pxy
            % F contains the frequencies at which P is given
            %
            
            %
            % Gert Klopman, Delft Hydraulics, 1995
            %
            
            if nargin < 4,
                M = 1;
            end;
            
            if nargin < 5,
                DT = 1;
            end;
            
            if nargin < 6,
                DW = 1;
            end;
            
            if nargin < 7,
                stats = 1;
            end;
            
            df = 1 / (N * DT) ;
            
            % data window
            
            w = [];
            if DW == 1,
                % Hann
                w  = .5*(1 - cos(2*pi*(1:N)'/(N+1)));
                dj = N/2;
            else
                % rectangle
                w  = ones(N,1);
                dj = N;
            end;
            varw = sum (w.^2) / N ;
            
            
            % summation over segments
            
            nx    = max(size(X));
            ny    = max(size(Y));
            avgx  = sum(X) / nx;
            avgy  = sum(Y) / ny;
            px    = zeros(size(w));
            py    = zeros(size(w));
            Pxx   = zeros(size(w));
            Pxy   = zeros(size(w));
            Pyy   = zeros(size(w));
            ns    = 0;
            
            for j=[1:dj:nx-N+1],
                
                ns = ns + 1;
                
                %   compute FFT of signals
                
                px = X([j:j+N-1]') - avgx;
                
                px = w .* px ;
                px = fft(px) ;
                
                py = Y([j:j+N-1]') - avgy;
                py = w .* py ;
                py = fft(py) ;
                
                % compute periodogram
                
                Pxx = Pxx + px .* conj(px) ;
                Pyy = Pyy + py .* conj(py) ;
                Pxy = Pxy + py .* conj(px) ;
                
            end;
            
            Pxx = (2 / (ns * (N^2) * varw * df)) * Pxx ;
            Pyy = (2 / (ns * (N^2) * varw * df)) * Pyy ;
            Pxy = (2 / (ns * (N^2) * varw * df)) * Pxy ;
            
            % smoothing
            
            if M>1,
                w = [];
                w = .54 - .46*cos(2*pi*(0:M-1)'/(M-1));
                w = w / sum(w);
                w = [w(ceil((M+1)/2):M); zeros(N-M,1); w(1:ceil((M+1)/2)-1)];
                w = fft(w);
                Pxx = fft(Pxx);
                Pyy = fft(Pyy);
                Pxy = fft(Pxy);
                Pxx = ifft(w .* Pxx);
                Pyy = ifft(w .* Pyy);
                Pxy = ifft(w .* Pxy);
            end;
            
            Pxx = Pxx(1:N/2);
            Pyy = Pyy(1:N/2);
            Pxy = Pxy(1:N/2);
            
            % frequencies
            
            F = [];
            F = ([1:1:N/2]' - 1) * df;
            
            % signal variance
            
            if DW == 1,
                nn = (ns + 1) * N / 2;
            else
                nn = ns * N;
            end;
            avgx  = sum (X(1:nn)) / nn;
            varx  = sum ((X(1:nn) - avgx).^2) / (nn - 1);
            avgy  = sum (Y(1:nn)) / nn;
            vary  = sum ((Y(1:nn) - avgy).^2) / (nn - 1);
            covxy = sum ((X(1:nn) - avgx) .* (Y(1:nn) - avgy)) / (nn - 1);
            
            m0xx    = (0.5 * Pxx(1) + sum(Pxx(2:N/2-1)) + 0.5 * Pxx(N/2)) * df;
            m0yy    = (0.5 * Pyy(1) + sum(Pyy(2:N/2-1)) + 0.5 * Pyy(N/2)) * df;
            m0xy    = (0.5 * Pxy(1) + sum(Pxy(2:N/2-1)) + 0.5 * Pxy(N/2)) * df;
            
            %disp(['m0x / varx = ' num2str(m0xx./varx) '  ;  m0y / vary = ' num2str(m0yy./vary) '  ; m0xy / varxy = ' num2str(real(m0xy)./covxy) '  '])
            
            
            Pxx = Pxx * (varx  / m0xx);
            Pyy = Pyy * (vary  / m0yy);
            Pxy = Pxy * (covxy / real(m0xy));
            
            P = [Pxx, Pyy, Pxy];
            
            % output spectrum characteristics
            dof = floor(2*ns*(M+1)/2/(3-DW));
            if stats == 1
                fprintf('number of samples used : %8.0f\n', nn);
                fprintf('degrees of freedom     : %8.0f\n', floor(2*ns*(M+1)/2/(3-DW)));
                fprintf('resolution             : %13.5f\n', (3-DW)*df*(M+1)/2);
            end
            %
        end
        
        
        
        function specData = gaugeSpectral(gaugeSeries,vargin)
            % specData = gaugeSpectral(gaugeSeries,opt);
            % Calculate spectral characteristics at each wave gauge
            % Inputs:
            %   gaugeSeries: Water level series at wave gauge points,
            %   generated by Swash.readTableData.
            %   opt: structure with optional parametes:
            %   opt.analysisDur: Only the last opt.analysisDur of the
            %   timeseries are taken into account. Default = 1200
            %   opt.smooth: Smoothing parameter for the spectra. Default =
            %   15.
            %   opt.fCutoff: Frequency cut-off value for calculating
            %   Tm-1,0. Default = 0.005
            % Outputs:
            % specData: structure that contains for each gauge the fields
            %   x and y, the location of the gauge
            %   f and Sf, the free surface elevation spectrum
            %   Hm0, the spectral significant wave height
            %   Tmm10, a wave period
            %   setup, the mean water level (incl wave setup)
            if nargin == 1;
                opt = struct;
            else
                opt = vargin;
            end
            %Set default options
            opt = Util.setDefault(opt,'analysisDur',1200);
            opt = Util.setDefault(opt,'smooth',15);
            opt = Util.setDefault(opt,'fCutoff',[0.005 0.5]);
            opt = Util.setDefault(opt,'nSamp',Inf);
            opt = Util.setDefault(opt,'spectralMethod','crosgk');
            
            if numel(opt.fCutoff)==1; %If only lower cutoff limit was specified
                opt.fCutoff = [opt.fCutoff inf];
            end
            
            
            numGauge = numel(gaugeSeries.X.data);
            
            for i = [1:numGauge];
                
                
                mask = gaugeSeries.Time.data >= max(gaugeSeries.Time.data) - opt.analysisDur;
                
                specData(i).setup = mean(gaugeSeries.Watlev.data(mask,i));
                
                
                dt = median(diff(gaugeSeries.Time.data(mask)));
                
                
                nlen=length(gaugeSeries.Watlev.data(mask,i));
                if mod(nlen,2) == 1
                    nlen=nlen-1;
                end
                if isinf(opt.nSamp)
                    opt.nSamp = nlen;
                end
                
                % First, calculate spectrum with no smoothing - for Hm0 and
                % Tmm-10 calculation
                TT = gaugeSeries.Time.data(mask);
                XT = gaugeSeries.Watlev.data(mask,i);
                if rem(numel(XT),2)==1;
                    TT = TT(1:end-1);
                    XT = XT(1:end-1);
                end
                
                [P,F,dof]=Swash.crosgk(XT,XT,...
                    numel(XT),1,dt,0,0);
                specData(i).Sf = real(P(:,1));
                specData(i).f = F;
                
                df = specData(i).f(2)-specData(i).f(1);
                
                % Calculate Hm0
                m0=trapz(specData(i).f,specData(i).Sf);
                specData(i).Hm0=[4*sqrt(m0)];
                
                %Calculate Tm-1,0
                mask = specData(i).f >= opt.fCutoff(1) & specData(i).f <= opt.fCutoff(2);
                m0p = df * sum(specData(i).Sf(mask));
                
                mm1 = trapz(specData(i).f(mask),specData(i).Sf(mask)./specData(i).f(mask));
                specData(i).Tmm10=[mm1/m0p];
                
                % Now, calculate spectrum including smoothing - for Tp and
                % visualization
                
                switch opt.spectralMethod;
                    case 'crosgk';
                        [P,F,dof]=Swash.crosgk(XT,XT,opt.nSamp,opt.smooth,dt,1,0);
                        specData(i).Sf = real(P(:,1));
                        specData(i).f = F;
                    case 'wafo'
                        %Add wafo to path if not already in path
                        if ~exist('dat2spec','file')
                            warning('Adding WAFO to path from S-drive');
                            run('S:\in-house\MATLAB\ExternalLibraries\wafo_2017\wafo\initwafo.m');
                        end
                        SS = dat2spec([TT XT],opt.nSamp,'f');
                        specData(i).Sf = SS.S;
                        specData(i).f = SS.f;
                end
                
                df = specData(i).f(2)-specData(i).f(1);
                fp = specData(i).f(specData(i).Sf==max(specData(i).Sf));
                specData(i).Tp = 1/fp;
                
                specData(i).x = gaugeSeries.X.data(i);
                specData(i).y = gaugeSeries.Y.data(i);
            end
            
        end
        
        function [sctSwash] = readInputXls(strFile,strtabblad)
            % sctSwash = readInputXls(strFile,strtabblad));
            % Reads the input for to create SWASH files.
            %
            % INPUTS
            %   - strFile       Name of the excel file
            %   - strtabblad    Name of the sheet in the excel file
            % OUTPUS
            %   - sctSwash       Data from the excel file
            %   - bPT           true; when they all use the same prototype
            %                   false; if they use a different prototype
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: sdo
            % Date: Feb 2007
            % Adaptated by sdo
            % Date : Juli 2007
            %   Verwijderen van lege rijen
            % Adapted by THL
            % Date: May 2015
            %   Adapted to SWASH
            
            % inlezen
            if nargin < 2;
                strtabblad = 'SWASH';
            end % default tabblad is SWASH, maar kan ook voor andere dingen worden gebruikt
            
            [~,~,cRaw] = xlsread(strFile, strtabblad);
            
            % tweede rij logische variabele, moet een bestand eerst worden ingelezen of
            mbReadFile = cell2mat(cRaw(2,:));
            
            % alles omzetten naar strings
            indnum = find(cellfun('prodofsize', cRaw)==1);
            strTemp = num2str(cell2mat(cRaw(indnum)));
            [m, n]=size(strTemp);
            cRaw(indnum) = mat2cell(strTemp, ones(m,1), n);
            clear m indnum strTemp
            
            % eertse rij veldnamen
            cFields = cRaw(1,:);
            cRaw(1:2,:) = [];
            
            % Soms worden lege kolommen ingelezen
            indnum = find(cellfun('prodofsize', cFields)==1); % [NaN], the strings should be longer
            cRaw(:,indnum)= []; cFields(indnum) = [];
            
            % Soms worden lege rijen ingelezen
            % strNaN = [IMDC_Tools_RepeatRowChar(' ', n-3, 'hor') 'NaN'];
            strNaN = [repmat(' ',1,n-3) 'NaN'];
            indNaR = all(strcmp(cRaw, strNaN),2);
            cRaw(indNaR,:) = [];
            clear indNaR
            
            % default waarden
            %strNaN = [IMDC_Tools_RepeatRowChar(' ', n-3, 'hor') 'NaN'];
            indNaN = strcmp(cRaw, strNaN);
            cAllDefault = cRaw(ones(size(cRaw,1),1),:);
            cRaw(indNaN) = cAllDefault(indNaN); % 3de rij bevat default waarden
            
            indnum = find(strcmp(cFields, 'filename'));
            indrow = find(strcmp(lower(cRaw(:,indnum)), 'default'));
            cRaw(indrow,:)=[];
            
            if numel(cRaw)==0
                sctSwash=[];
                bPTF = 0;
            else
                % In te lezen bestanden.
                for iCol = 1:numel(mbReadFile)
                    if ~mbReadFile(iCol);
                        continue
                    end
                    for iRun=1:size(cRaw,1)
                        cRaw{iRun, iCol};
                        sct = load(cRaw{iRun, iCol});
                        cstr = fieldnames(sct);
                        cRaw{iRun, iCol} = getfield(sct, cstr{1});
                    end
                end
                sctSwash = cell2struct(cRaw, cFields, 2);
                
                if isfield(sctSwash, 'protofile')
                    indptf = find(strcmp(cFields, 'protofile')); % protofile is niet noodzakelijk een veldnaam wanneer het geen SWASH invoer moet zijn
                    bPTF = all(strcmp(cRaw(:,indptf), cRaw(1,indptf)));
                else bPTF = 0;
                end
                
                
            end
        end
        
        function data = readTableData(tableFile)
            % data = readTableData(tableFile);
            % Read ASCII output data from SWASH from the file tableFile and
            % return it as a datastructure data. Note, the table file
            % should have the output SWASH (not HEAD or NOHEAD)
            
            
            txt=fileread(fullfile(tableFile));
            numLines = sum(txt==10)+1;
            
            clear txt;
            
            %% Now open the file for real reading
            fid = fopen(tableFile,'r');
            
            %Start reading through the file
            while ~feof(fid)
                line = fgetl(fid);%Read the next line
                switch line
                    case 'TIME                                    time-dependent data';%Time-independent data
                        line = fgetl(fid);%Read the next line
                        if ~strcmp(line,'     7                                  time coding option');
                            error('Time coding option should be set to 7 for proper postprocessing. See "tbegblk" in the SWASH manual.');
                        end
                        
                        
                    case 'LOCATIONS                               locations in x-y-space';
                        line = fgetl(fid);%Read the next line
                        data.numLoc = textscan(line,'%d %*[^\n]');
                        data.numLoc = data.numLoc{1};%This is the number of locations in the table file
                        for i = 1:data.numLoc;
                            line = fgetl(fid);%Read the next line
                            xy = textscan(line,'%f %f %*[^\n]');
                            data.X.data(i) = xy{1}';
                            data.Y.data(i) = xy{2}';
                        end
                        
                        %Now we know the approximate number of output steps in the file (for
                        %pre-allocation)
                        numSteps = round(numLines)/(data.numLoc+1);
                        data.Time.data = nan(numSteps,1);
                        data.Time.unit = 's';
                        
                        
                        
                        
                    case 'QUANT                                   description of quantities';
                        line = fgetl(fid);%Read the next line
                        numQuant = textscan(line,'%d %*[^\n]');%Number of output quantities
                        numQuant = numQuant{1};
                        %Read description of each output quantity
                        for i = 1:numQuant;
                            line = fgetl(fid);%Read the next line
                            par = textscan(line,'%s %*[^\n]');%Parameter name
                            par = par{1}{1};
                            quants{i}=par;
                            line = fgetl(fid);%Read the next line
                            data.(par).unit = textscan(line,'%s %*[^\n]');%Parameter unit
                            
                            line = fgetl(fid);%Read the next line
                            line = fgetl(fid);%Read the next line
                            data.(par).exclusion_value = textscan(line,'%f %*[^\n]');%Parameter unit
                            
                            data.(par).dim = {'T','XY'};
                            data.(par).data = nan(numSteps,numel(data.X.data));
                            
                            
                        end
                        %After reading all the QUANT input parameters, we should have
                        %reached the end of the headers
                        break
                        
                        
                        
                end
            end
            lineString = repmat('%f ',1,numQuant);
            
            j = 0;
            while ~feof(fid)%This loop reads one timestep at a time
                j = j + 1;
                line = fgetl(fid);%Read the next line
                timeRaw = textscan(line,'%s %*[^\n]');%Parameter name
                timeRaw = timeRaw{1};
                mtime = datenum(timeRaw,'HHMMSS.FFF');
                if j ==1;%If this is the first time steps
                    initTime = mtime;%Initial time
                end
                data.Time.data(j)=(mtime-initTime)*24*3600;
                for i = 1:numel(data.X.data);
                    line = fgetl(fid);
                    outRaw = textscan(line,lineString);
                    for k = 1:numQuant;
                        data.(quants{k}).data(j,i) = outRaw{k};
                    end
                end
            end
            
            %% Remove extra lines
            data.Time.data=data.Time.data(1:j);
            for k = 1:numQuant;
                data.(quants{k}).data=data.(quants{k}).data(1:j,:);
            end
            
            fclose(fid);
            
        end
        
        function cBatchfiles = shellWriteBatch(sctSwash)
            % Laat een opsplisting in de batchfiles voor SWAN toe
            % Swash.shellWriteBatch(sctSwash)
            % Roept voor veschillende protofiles de routine meerdere keren aan.
            % Based on IMDC_SWAN_Shell_Write_Batch
            %
            % INPUTS
            %   - sctSwash
            %       ° protofile
            %       ° protofile
            % OUTPUTS
            %   - protofile(s)
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: sdo
            % Date: March 2007
            % Modified by: THL
            % Date: May 2015
            cFields = fieldnames(sctSwash);
            cSWAN   = struct2cell(sctSwash)';
            
            indbf = find(strcmp(cFields, 'batchfile'));
            
            binbat = zeros(size(cSWAN,1),1); % no run in batch file
            nbf = 0;
            
            while any(~binbat)
                nbf = nbf+1;
                indbat = find(~binbat, 1, 'first');
                strbatchfile = sctSwash(indbat).batchfile;
                bindsbf = strcmp(cSWAN(:,indbf), strbatchfile); % weet niet zeker of niet zelfde grootte moet zijn
                sctSAMEBAT = sctSwash(bindsbf);
                Swash.writeBatch(sctSAMEBAT(1).protodos, sctSAMEBAT, strbatchfile); % eigenlijk nog controleren of zelfde protodos geeft, anders foutmelding geven
                binbat = binbat | bindsbf;
                cBatchfiles{nbf} = strbatchfile;
            end
        end
        
        function shellWriteInput(sctSwash, struser)
            % Laat een opsplisting in de protofiles voor SWASH toe
            % IMDC_SWASH_Shell_Write_INPUT(sctSwash)
            % Roept voor veschillende protofiles de routine meerdere keren aan.
            % Based on IMDC_SWAN_Shell_Write_INPUT
            %
            % INPUTS
            %   - sctSwash
            %       ° protofile
            %       ° protofile
            % OUTPUTS
            %   - protofile(s)
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: sdo
            % Date: March 2007
            % Modified by: THL
            % Date: May 2015
            
            cFields = fieldnames(sctSwash);
            cSWAN   = struct2cell(sctSwash)';
            
            indpf = find(strcmp(cFields, 'protofile'));
            
            bininp = zeros(size(cSWAN,1),1); % no run in batch file
            
            while any(~bininp)
                indbat = find(~bininp, 1, 'first');
                strprotofile = sctSwash(indbat).protofile;
                bindsbf = strcmp(cSWAN(:,indpf), strprotofile); % weet niet zeker of niet zelfde grootte moet zijn
                sctSAMEP = sctSwash(bindsbf);
                Swash.writeInput(sctSAMEP(1).protofile, sctSAMEP, struser, 'IMDC');
                bininp = bininp | bindsbf;
            end
        end
        
        function bceof = writeBatch(strProtoDos, sctAdap, strBatchfile)
            % IMDC_SWAN_AutoInput generates a batchhfile casted to a prototype-batchfile.
            % bceof = writeBatch(strProtoDos, sctAdap, strBatchfile);
            %
            % INPUTS
            %   - strProtoDos : string; filename of the file which contains the prototype dos-commands
            %   - sctAdap   : structure, for which the fieldnames are the variables
            %               that will be replaced in the prototype batchfile, by the content of the field.
            %               (variables in the batch file between brackets, for example: fieldname filename in Prototype DOS: {filename}
            %   - strBatchfile: name of the output batchfile
            % OUTPUTS
            %   - bceof       : boolean; correct ending of function
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % written by: sdo
            % date:  monday, June 12th 2006
            % Modified by: THL
            % Date: May 2015
            
            bceof = 0;                      % boolean correct ending of function
            cAdap = fieldnames(sctAdap);  % Obtaines the variables that will be replaced
            
            % read dos commands for batchfile
            fid = fopen(strProtoDos, 'rt');
            indLine = 0;
            while feof(fid) == 0
                indLine = indLine+1;
                cDOScom{indLine} = fgetl(fid);
            end
            fclose(fid);
            
            % write dos commands for subsequently each requested run
            fid = fopen(strBatchfile, 'w');
            for indFile=1:length(sctAdap)
                cBatchFile = cDOScom;
                for indVar = 1:size(cAdap,1)
                    cBatchFile = strrep(cBatchFile, ['{',char(cAdap{indVar}),'}'], getfield(sctAdap,{indFile}, cAdap{indVar}));
                end
                %Find the end of header line
                strEndHeader = '### END HEADER ###';
                endHeaderInd = find(strcmp(cBatchFile,strEndHeader));
                
                % Copy the header of the batch file only for the first run
                if indFile == 1;
                    for indLine=1:length(cBatchFile)
                        fprintf(fid, '%s\n', char(cBatchFile{indLine}));
                    end
                else
                    for indLine=endHeaderInd+1:length(cBatchFile);
                        fprintf(fid, '%s\n', char(cBatchFile{indLine}));
                    end
                end
                %     if indFile==1
                %         fidtest = fopen(strrep(strBatchfile, '.bat', '_test.bat'), 'w');
                %         for indLine=1:length(cBatchFile)
                %             fprintf(fidtest, '%s\r\n', char(cBatchFile{indLine}));
                %         end
                %         fclose(fidtest);
                %     end
                clear cBatchFile
            end % for indFile=1:length(sctAdap)
            fclose(fid);
            fprintf('Created job/batch file %s.\n',strBatchfile);
            
            clear
            
            bceof = 1; % function reached proper ending.
        end
        
        function bCeof = writeInput(strProtoFile, sctAdap, author, company)
            % Write SWASH input files
            % bCeof = writeInput(strProtoFile, sctAdap, author, company);
            % Swash.writeInput generates swash inputfiles casted to a prototype-file.
            % Based on IMDC_SWAN_Write_INPUT.m
            %
            % INPUTS
            %   strProtoFile: string, which contains the filename of the prototype-swanfile
            %   sctAdap   : structure, for which the fieldnames are the variables
            %               that will be replaced in the prototype swan-file, by the content of the field.
            %               (variables in the SWAN file between brackets, for example: fieldname Hsig in Prototype SWAN: {Hsig}
            %             a) it should also contain the fields 'directory' and
            %                'filename' under which the swashfile will be saved.
            %                (NO extension!!!!)
            %   author      : string;
            % OUTPUTS
            %   bCeof       : boolean; correct ending of function
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: sdo
            % Date:  monday, June 12th 2006
            % Modified by: sdo
            % Date: january 24th, 2007
            % Modification:- added matrices.
            %              - removed automatic .swn, so maybe usefull for other
            %                routines.
            
            % strProtoFile should contain the filename of the prototype file.
            % sctAdap
            
            %Author and company are not necessary:
            if nargin ==2
                author = '';
            end
            if nargin<=3
                company = 'IMDC';
            end
            
            bCeof = 0;                      % boolean correct ending of function
            cAdap = fieldnames(sctAdap);  % Obtaines the variables that will be replaced
            
            for indVar = 1:size(cAdap,1) %Divide cAdap list in a list with strings and a list with numbers
                indchar(indVar) = ischar(getfield(sctAdap,{1}, cAdap{indVar}));
            end
            cAdapStr = cAdap(indchar);
            cAdapNum = cAdap(~indchar);
            
            % read the entire prototype swanfile, line by line into a cell array.
            %             fid = fopen(strProtoFile, 'rt');
            %             indLine = 0;
            %             while feof(fid) == 0
            %                 indLine = indLine+1;
            %                 cellProtoFile{indLine,1} = fgetl(fid);
            %             end
            %             fclose(fid);
            cellProtoFile = strsplit(fileread(strProtoFile),'\n');
            
            % date and author are the same for each file
            
            cellProtoFile = strrep(cellProtoFile, '{date}', [datestr(now, 'ddd '), date]);
            cellProtoFile = strrep(cellProtoFile, '{author}', author);
            cellProtoFile = strrep(cellProtoFile, '{company}', company);
            
            % for each set of variables adapt the cell array and write swan file.
            for indFile=1:length(sctAdap)
                cellFile = cellProtoFile;
                % strings
                for indVar = 1:size(cAdapStr,1)
                    cellFile = strrep(cellFile, ['{',cAdapStr{indVar},'}'], getfield(sctAdap,{indFile}, cAdapStr{indVar}));
                end
                % matrices
                for indVar = 1:size(cAdapNum,1)
                    indmatr = find(~cellfun('isempty', strfind(cellFile, ['{',cAdapNum{indVar},'}'])));
                    if isempty(indmatr)
                        continue
                    end
                    matr = getfield(sctAdap,{indFile}, cAdapNum{indVar});
                    if numel(matr)==1
                       try
                            if abs(rem(matr,1))>1e-6 %If it's pretty much a whole number, write it as such
                                cellFile = strrep(cellFile,['{',cAdapNum{indVar},'}'],sprintf('%.5f',getfield(sctAdap,{indFile}, cAdapNum{indVar})));
                            else
                                cellFile = strrep(cellFile,['{',cAdapNum{indVar},'}'],sprintf('%.0f',getfield(sctAdap,{indFile}, cAdapNum{indVar})));
                            end
                       catch
                                 cellFile = strrep(cellFile,['{',cAdapNum{indVar},'}'],sprintf(getfield(sctAdap,{indFile}, cAdapNum{indVar})));
                       end
                    else
                        warning('Replacing matrices or arrays in steering files is not yet implemented. Errors may follow.');
                        strform = [IMDC_Tools_RepeatRowChar('%10.4f', size(matr,2), 'hor'), '\n'];
                        for i = 1:numel(indmatr)
                            cellFile{indmatr(i)} = sprintf(strform, matr');
                            cellFile{indmatr(i)} = strrep(cellFile{indmatr(i)}, '-Inf', '    ');
                            cellFile{indmatr(i)}(end-1:end) = [];
                        end
                    end
                end
                % eventueel nog directories aanmaken indien ze nog niet bestaan.
                if ~exist(sctAdap(indFile).directory,'dir')>0
                    mkdir(sctAdap(indFile).directory);
                end
                fid = fopen(fullfile(sctAdap(indFile).directory, sctAdap(indFile).filename), 'w');
                for indLine=1:length(cellFile)
                    nn = size(cellFile{indLine},2);
                    strform = ['%', num2str(nn), 's\n'];
                    fprintf(fid, strform, char(cellFile{indLine}));
                end
                fclose(fid);
                fprintf('Created run file in directory %s.\n',sctAdap(indFile).directory);
                clear cellFile
            end
            
            clear cellProtoFile
            
            bCeof = 1; % function performed satisfactory
        end
        
    end
end