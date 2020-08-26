classdef GlobalModel < handle
    %GLOBALMODEL Utilities to deal with global models
    %   Such as ERA, IOWAGA, NCEP, HYCOM, ...
    
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
    
    
    methods (Static)
        
        function [] = init()
            % Initiate the NetCDF toolbox. Needed for all further
            % processing
            if  ~contains(path,'nctoolbox-master\java')
                thePath = pwd;
                setupNcToolboxLocation = 'S:\in-house\MATLAB\ExternalLibraries\nctoolbox';
                cd(setupNcToolboxLocation);
                setup_nctoolbox;
                cd(thePath);
            else
                disp('NcToolBox is already in the path');
            end
            
        end
        
        function sct = navgemNames(thePath)
            % gets Navgem file names from a path
            allFields = {'navgem*mslprs.D','pres',1;
                'navgem*uv-10m.D','wind',2;
                'navgem*TaqaQlQg.D','temp',4;
                };
            for i =1:size(allFields,1)
                tmp = dir(fullfile(thePath,allFields{i,1}));
                sct.(allFields{i,2}).path  = fullfile(thePath,tmp.name);
                sct.(allFields{i,2}).nrVar =  allFields{i,3};
                sct.(allFields{i,2}).varNames = allFields{i,2};
                
            end
        end
        
        function [dataFile,nrVar,varIndex] = navgemNamesPerVar(thePath,theVar)
            % Get the NAVGEM file name and variable number for a TELEMAC variable
            switch theVar
                case 'WIND VELOCITY U '
                    dataFile = dir(fullfile(thePath,'navgem*uv-10m.D'));
                    nrVar = 2;
                    varIndex = 1;
                case 'WIND VELOCITY V '
                    dataFile = dir(fullfile(thePath,'navgem*uv-10m.D'));
                    nrVar = 2;
                    varIndex = 2;
                case 'PRESSURE        '
                    dataFile = dir(fullfile(thePath,'navgem*mslprs.D'));
                    nrVar = 1;
                    varIndex = 1;
                case 'AIR TEMPERATURE '
                    dataFile = dir(fullfile(thePath,'navgem*TaqaQlQg.D'));
                    nrVar = 4;
                    varIndex = 1;
                case     'RELATIVEHUMIDITY'
                    dataFile = dir(fullfile(thePath,'navgem*TaqaQlQg.D'));
                    nrVar = 4;
                    varIndex = 2;
                case     'SHORT-WAVE RAD  '
                    dataFile = dir(fullfile(thePath,'navgem*_03hr_solrad.D'));
                    nrVar = 1;
                    varIndex = 1;
                case     'LONG-WAVE RAD   '
                    dataFile = dir(fullfile(thePath,'navgem*_03hr_longwv.D'));
                    nrVar = 1;
                    varIndex = 1;
                otherwise
                    error('Unsupported variable');
            end
            
            
            
            
            % gets Navgem file names from a path
            allFields = {'navgem*mslprs.D','pres',1;
                'navgem*uv-10m.D','wind',2;
                'navgem*TaqaQlQg.D','temp',4;
                };
            for i =1:size(allFields,1)
                tmp = dir(fullfile(thePath,allFields{i,1}));
                sct.(allFields{i,2}).path  = fullfile(thePath,tmp.name);
                sct.(allFields{i,2}).nrVar =  allFields{i,3};
                sct.(allFields{i,2}).varNames = allFields{i,2};
                
            end
        end
        
        
        function ds = HycomDataLoad(opt)
            % ds = GlobalModel.HycomDataLoad(opt);
            % Load data from the global HYCOM dataset
            %
            % INPUT (all optional):
            %  - x: vector with x values
            %  - coef: coefficients determined from exponential fit
            %  - opt: structure containing the following optional inputs.
            %  - opt.dapLink: Link to openDAP file. Default: 'http://tds.hycom.org/thredds/dodsC/GLBu0.08/expt_19.1/3hrly'
            %  - opt.lon, opt.lat: Longitude and latitude range. Can either  be 1 value (single point) or 2 values (2D window).
            %  - opt.time: Time range (in datenum format). Can either be 1 value (single instance) or 2 values (time series).
            %  - opt.z: z value where data is requested (e.g. opt.z = -1000 for values at 1000 m depth). If left empty, then the full vertical profile is returned
            %  - opt.vars: Requested variables (in IMDC naming). Options are:     'VelX'    'VelY'    'Temp'    'Sal'
            %
            % OUTPUT:
            %  - ds: Requested data in IMDC standard format.
            
            
            % Inputs & defaults
            opt = Util.setDefault(opt,'dapLink','http://tds.hycom.org/thredds/dodsC/GLBu0.08/expt_19.1/3hrly');
            opt = Util.setDefault(opt,'lon',0);
            opt = Util.setDefault(opt,'lat',0);
            opt = Util.setDefault(opt,'h_stride',[1 1]);
            opt = Util.setDefault(opt,'vars','Temp');
            opt = Util.setDefault(opt,'imdcDataMap',{
                'VelX' 'water_u'
                'VelY' 'water_v'
                'Temp' 'water_temp'
                'Sal'  'salinity'
                'Lat'  'lat'
                'Lon'  'lon'
                'Time' 'time'
                'Z' 'z'
                'Watlev' 'surf_el'
                'BulkStressX' 'tauewd'
                'BulkStressY' 'taunwd'
                'AirTemp' 'airtmp'
                'SpecHumid' 'vapmix'
                'RadFlx' 'radflx'
                'ShwFlx' 'shwflx'
                'WindVel' 'wndspd'
                });
            %Put requested variables in a cell array
            if ~iscell(opt.vars);
                opt.vars = {opt.vars};
            end
            
            
            imdc2Hycom = containers.Map(opt.imdcDataMap(:,1),opt.imdcDataMap(:,2));
            hycom2Imdc = containers.Map(opt.imdcDataMap(:,2),opt.imdcDataMap(:,1));
            
            % Initiate NetCDF Toolbox
            GlobalModel.init;
            
            
            %             if isfield(opt,'z');
            %                 s.z_index = nan(size(opt.z));
            %                 for iZ = 1:numel(opt.z);
            %                 s.z_index(iZ) = find(opt.z(iZ) == allDepth);
            %                 end
            %                 if isempty(s.z_index);
            %                     fprintf('Couldn''t find data at requested depth %.1f.',opt.z);
            %                     fprintf('Available depths are: \n');
            %                     fprintf('%.1f \t',allDepth);
            %                     error('Stopped because couldn''t find data');
            %                 end
            %             end
            %             fprintf('Subset structure:\n');
            %             disp(s);
            
            for iv = 1:numel(opt.vars);%Loop over all requested variables
                fprintf('##################################################\nVariable %s\n',opt.vars{iv});
                
                % Access data file via openDAP
                fprintf('Opening geodataset...\t');
                maxTry = 5;
                tries = 1;
                
                
                
                for tries = 1:maxTry;%Try 3 times. Get a timeout sometimes.
                    try
                        suc = false;
                        if ~iscell(opt.dapLink)
                            nc = ncgeodataset(opt.dapLink);
                        else
                            nc = ncgeodataset(opt.dapLink{iv});
                        end
                        suc = true;
                        break;
                    catch
                        warning('Attempt %u of %u failed.',tries,maxTry);
                    end
                end
                if ~suc
                    error('Didn''t work after %u tries. Giving up.',maxTry);
                end
                
                fprintf('Opened.\n');
                
                
                %             Subset according to the ncToolbox syntax
                %             Subset can't handle 1 lat and 2 lon or vice versa -> fix
                if (numel(opt.lat)==1 && numel(opt.lon)==2);
                    opt.lat = opt.lat+0.001*[-1 1];
                end
                if (numel(opt.lat)==2 && numel(opt.lon)==1);
                    opt.lon = opt.lon+0.001*[-1 1];
                end
                
                s.lat = opt.lat;
                s.lon = opt.lon;
                if isfield(opt,'time')
                    s.time= opt.time;
                end
                s.h_stride = opt.h_stride;
                if isfield(opt,'v_stride')
                    s.v_stride = opt.v_stride;
                end
                
                
                hycomVar = imdc2Hycom(opt.vars{iv});%Find the HYCOM variable for this requested variable
                
                
                ncVar = nc.geovariable(hycomVar);
                
                fprintf('Loading variable %s...',opt.vars{iv});
                t1 = now;
                maxTry = 5;
                tries = 1;
                for tries = 1:maxTry;%Try 3 times. Get a timeout sometimes.
                    try
                        suc = false;
                        ncSub = ncVar.geosubset(s); %This is where the data is actually loaded
                        suc = true;
                        break;
                    catch
                        warning('Attempt %u of %u failed due to timeout.',tries,maxTry);
                    end
                end
                if ~suc
                    error('Didn''t work after %u tries. Giving up.',maxTry);
                end
                t2 = now;
                fprintf('Succes. Time elapsed = %.3f s. \n',(t2-t1)*86400);
                ds.(opt.vars{iv}).data = squeeze(ncSub.data);
                ds.(opt.vars{iv}).unit = ncVar.attribute('units');
                ds.(opt.vars{iv}).longname = ncVar.attribute('long_name');
                %Get dims
                fn=fieldnames(ncSub.grid);
                ds.(opt.vars{iv}).dims = fn((cellfun(@numel,ncSub.indices)>1));
                %Translate to IMDC style
                for id = 1:numel(ds.(opt.vars{iv}).dims);
                    ds.(opt.vars{iv}).dims{id} = hycom2Imdc(ds.(opt.vars{iv}).dims{id});
                end
            end
            ds.Time.data  = ncSub.grid.time;
            ds.Lat.data   = ncSub.grid.lat;
            ds.Lon.data   = ncSub.grid.lon;
            if isfield(ncSub.grid,imdc2Hycom('Z'));
                ds.Z.data     = ncSub.grid.(imdc2Hycom('Z'));
            end
            ds.metaData.description = 'Ocean data from Global HYCOM.';
            if ~iscell(opt.dapLink);
                ds.metaData.source = sprintf('Data comes from %s',opt.dapLink);
            else
                ds.metaData.source = opt.dapLink;
            end
            
        end
        
        function [ds] = Gebco()
            % Gebco global bottom dataset
            %
            % [ds] = GlobalModel.Gebco;
            
            % Location of the GEBCO file
            gebcoFile = 'M:\Geo-Databank\Worldwide\20 - GEBCO Bathy\GEBCO_2014_2D.nc';
            
            % Read
            dsRaw = NetCdf.readNetCdf(gebcoFile);
            
            % Clean up variable names
            ds.Lat = dsRaw.lat;
            ds.Lon = dsRaw.lon;
            ds.BotLev = dsRaw.elevation;
        end
        
        %
        function [varData,lon,lat,wDay] = readFileD(fileName,iT,nrField)
            % read CFSR .d file
            %
            % [varData,lon,lat,wDay] = readFileD(fileName,iT,nrField)
            %
            % INPUT:
            %  - fileName: name of the file to read
            %  - iT: time step
            %  - nrField: number of fields
            %
            % OUTPUT:
            %  - varData: the data to read
            %  - lon,lat: lat lon coordinates of the data
            %  - wDay: the time of the variable
            fid = fopen(fileName,'r','ieee-be');
            % read header
            rec1Start = fread(fid, 1, 'int32');
            title = fread(fid,[1,rec1Start],'*char');
            rec1End = fread(fid, 1, 'int32');
            rec2Start = fread(fid, 1, 'int32');
            idm     = fread(fid, 1, 'int32');
            jdm     = fread(fid, 1, 'int32');
            xFin    = fread(fid, 1, 'single');
            yFin    = fread(fid, 1, 'single');
            dXin    = fread(fid, 1, 'single');
            dYin    = fread(fid, 1, 'single');
            nRec    = fread(fid, 1, 'int32');
            wDay    = fread(fid, max(nRec+1,9000), 'single');
            rec2End = fread(fid, 1, 'int32');
            
            % conversion of date number
            wDay = wDay+datenum([1901 1 0]);
            
            
            % make mesh
            if nargout > 1
                lat = GlobalModel.gausGrid(jdm/2);
                lon = xFin:dXin:xFin+dXin*(idm-1);
                
            end
            % only read header
            if iT ==0
                varData = 0;
                wDay = wDay(1:nRec);
                return
            end
            % go to correct time step
            nn   =  ceil(jdm*idm*nrField/4096)*4096;
            offs = (iT-1)*(nn+2)*4;
            fseek(fid,offs,'cof');
            
            %fseek(fid,36092,'bof');
            
            % read data
            recTimeStart = fread(fid, 1, 'int32');
            varData = zeros(jdm,idm,nrField);
            for i=1:nrField
                tmp          = fread(fid,[1,jdm*idm],'real*4');
                varData(:,:,i)      = reshape(tmp,[idm,jdm])';
            end
            
            varData(varData>=2^100) = nan;
            recTimeEnd   = fread(fid, 1, 'int32');
            if recTimeStart~=recTimeEnd
                error('Problem reading .D file. Maybe an error in nr if fields');
            end
            
            % close file
            fclose(fid);
            
            % extract time;
            wDay = wDay(iT);
            
        end
        
        function lat = gausGrid(jh)
            % calculates latitude at a gaussian grid
            %
            % lat = gausGrid(jh)
            %
            % INPUT:
            %   - jh: number of cells devided by two
            % OUTPUT
            %  - lat: mesh with latitudes
            %
            
            % constants
            C   = (1-(2./pi)^2)*0.25;
            EPS = 1.E-14;
            
            bz = [       2.4048255577,  5.5200781103,...
                8.6537279129, 11.7915344391, 14.9309177086, 18.0710639679,...
                21.2116366299, 24.3524715308, 27.4934791320, 30.6346064684,...
                33.7758202136, 36.9170983537, 40.0584257646, 43.1997917132,...
                46.3411883717, 49.4826098974, 52.6240518411, 55.7655107550,...
                58.9069839261, 62.0484691902, 65.1899648002, 68.3314693299,...
                71.4729816036, 74.6145006437, 77.7560256304, 80.8975558711,...
                84.0390907769, 87.1806298436, 90.3221726372, 93.4637187819,...
                96.6052679510, 99.7468198587, 102.888374254, 106.029930916,...
                109.171489649, 112.313050280, 115.454612653, 118.596176630,...
                121.737742088, 124.879308913, 128.020877005, 131.162446275,...
                134.304016638, 137.445588020, 140.587160352, 143.728733573,...
                146.870307625, 150.011882457, 153.153458019, 156.295034268 ];
            
            jbz = length(bz);
            
            %  ESTIMATE LATITUDES USING BESSEL FUNCTION
            R= 1./sqrt((2*jh+0.5)^2+C);
            
            sinLat = zeros(jbz,1);
            for j=1:min(jh,jbz)
                sinLat(j) = cos(bz(j)*R);
            end
            for j=jbz+1:jh
                sinLat(j) = cos((bz(jbz)+(j-jbz)*pi)*R);
            end
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            %  CONVERGE UNTIL ALL SINES OF GAUSSIAN LATITUDE ARE WITHIN EPS
            spMax = 2*EPS;
            while(spMax>EPS)
                PKM1 = ones(jh,1);
                PK   = sinLat;
                for N=2:2*jh
                    for j=1:jh
                        PKM2   = PKM1(j);
                        PKM1(j)= PK(j);
                        PK(j)  =((2*N-1)*sinLat(j)*PKM1(j)-(N-1)*PKM2)/N;
                    end
                end
                sp =PK.*(1.-sinLat.^2)./(2.*jh.*(PKM1-sinLat.*PK));
                sinLat = sinLat - sp;
                spMax  = max(abs(sp));
            end
            
            % convert to latitudes and double mesh
            lat = asind(sinLat');
            lat = fliplr([lat -fliplr(lat)]);
            
        end
        
        %--------------------------------------------------------------------------
        
        function sctCop = readAllCop(ncDir)
            % read all data from copernicus files read with the
            % downloadMEDSEA.bat script
            %
            % sctCop = readAllCop(ncDir,startDate,endDate)
            
            % find all netcdf files and split them according to the
            % filename convention
            % varname period_numberperperiod
            
            % eg. sal20180201_01.nc
            ncFiles = dir(fullfile(ncDir,'*.nc'));
            for i=length(ncFiles):-1:1
                theFile = ncFiles(i).name;
                tmp = regexp(theFile,'\D*','match');
                vars{i} = tmp{1};
                tmp = regexp(theFile,'\d*','match');
                date{i} = tmp{1};
                if length(tmp)>1
                    ind{i}  = tmp{2};
                end
            end
            [allVars,~,indAllVar] = unique(vars);
            
            % read all the headers
            for i=1:length(allVars)
                indVar = find(indAllVar==i);
                for j=1:length(indVar)
                    theFile = fullfile(ncDir,ncFiles(indVar(j)).name);
                    if j==1
                        sctTmp = GlobalModel.readCopHead(theFile);
                    else
                        sctTmp = sctCop(i);
                        sctTmp = GlobalModel.readCopHead(theFile,sctTmp);
                    end
                    sctCop(i) = sctTmp;
                end
            end
            
            % make times unique
            for i=1:length(allVars)
                [sctCop(i).t,ind] = unique(sctCop(i).t);
                sctCop(i).fileInd = sctCop(i).fileInd(ind,:);
            end
            
            %set the index
            for i=1:length(allVars)
                sctCop(i).varsId = sctCop(i).varsId*i;
            end
            
            % check times in the files
            for i=2:length(allVars)
                if any(sctCop(i).t-sctCop(1).t)~=0
                    error('Times are different');
                end
            end
            
            
            
        end
        
        function sct = readCopHead(ncFile,sct)
            % read data from copernicus netcdf file; header
            %
            % sct = readCopHead(ncFile,sct)
            %
            % INPUT:
            % - ncFiles: cell array with netCdf files to read
            %
            % OUTPUT:
            % - sct: structure with time and lat lon coordinates
            
            SMALL = 1E-9;
            if nargin == 1
                sct = struct;
            end
            
            
            
            % counter to see how often the function is called
            if ~isfield(sct,'nrCall')
                sct.nrCall = 0;
            end
            
            sct.nrCall =  sct.nrCall+1;
            
            % get information
            ncInfo   = ncinfo(ncFile);
            varNamesIni = {ncInfo.Variables.Name};
            % find the variables
            varNames = setdiff(varNamesIni,{'latitude','longitude','lon','lat','time'});
            % determine weeter it is a 3d file
            is3d = any(strcmpi('depth',varNames));
            if is3d
                varNames(strcmpi('depth',varNames))= [];
            end
            sct.vars   = varNames;
            sct.varsId = ones(size(varNames));
            
            % read time and coordinates (any data standards)
            idx = strcmp('time',varNamesIni);
            idxSpace = strfind(ncInfo.Variables(idx).Attributes(1).Value,' ');            
            strTime = ncInfo.Variables(idx).Attributes(1).Value(1:idxSpace(1)-1);            
            if strcmp(strTime,'seconds')
                % The only thing that is hardcoded right now - assume that
                % date variable is located in 1st place in the new format
                iniDate = datenum(ncInfo.Variables(idx).Attributes(1).Value(idxSpace(2):end));
                t   = (ncread(ncFile,'time')/86400) + iniDate;
            else
                % The only thing that is hardcoded right now - assume that
                % date variable is located in 4th place in the old format
                iniDate = datenum(ncInfo.Variables(idx).Attributes(4).Value(end-18:end));
                t   = (ncread(ncFile,'time')/24) + iniDate;
            end
            % read lat lon
            idxLat = contains(varNamesIni,'lat');
            idxLon = contains(varNamesIni,'lon');
            lat = double(ncread(ncFile,varNamesIni{idxLat}));
            lon = double(ncread(ncFile,varNamesIni{idxLon}));
            
            % look up table; first column is file number; second number
            % is place in the file
            indNr  = (1:length(t))';
            fileNr = ones(size(indNr))*sct.nrCall;
            fileInd = [fileNr,indNr];
            
            if sct.nrCall==1
                sct.t = t;
                sct.fileInd = fileInd;
            else
                sct.t = [sct.t;t];
                sct.fileInd = [sct.fileInd;fileInd];
            end
            
            % read depth if needed
            if is3d
                sct.depth = ncread(ncFile,'depth');
                sct.nrDep = length(sct.depth);
            else
                sct.depth = [];
                sct.nrDep = 0;
            end
            
            % process mesh
            if sct.nrCall==1
                [sct.Lon,sct.Lat] = meshgrid(lon,lat);
                sct.nrLon = length(lon);
                sct.nrLat = length(lat);
            else
                [Lon,Lat] = meshgrid(lon,lat);
                if any(abs(Lon(:)-sct.Lon(:)))>SMALL || any(abs(Lat(:)-sct.Lat(:)))>SMALL
                    error('Meshes are different');
                end
            end
            
            % save extra data to structure
            sct.ncFile{sct.nrCall} = ncFile;
            sct.is3d = is3d;
            
        end
        
        function var = readCop(sctIn,varName,i)
            % read data from copernicus netcdf file; data
            %
            % var = readCop(sctIn,varName,i)
            %
            % INPUT
            % - sctIn  : structure determined by readCopHead
            % - varName: string with the variable name to read
            % - i      :      number of the time step
            %
            % OUTPUT
            % - var    : read data
            
            %lookup the right structure
            for iFile=1:length(sctIn)
                mask = strcmpi(varName,sctIn(iFile).vars);
                if any(mask)
                    sct = sctIn(iFile);
                    break;
                end
            end
            if strcmpi(varName,'bottomT')
                sct.is3d = false;
            end
            
            iFile = sct.fileInd(i,1);
            iTime = sct.fileInd(i,2);
            if sct.is3d
                var = ncread(sct.ncFile{iFile},varName,[1 1 1 iTime],[sct.nrLon,sct.nrLat,sct.nrDep,1]);
            else
                var = ncread(sct.ncFile{iFile},varName,[1 1 iTime],[sct.nrLon,sct.nrLat,1]);
            end
            
        end
        
        %--------------------------------------------------------------------------
        
        
        
        
    end
    
end

