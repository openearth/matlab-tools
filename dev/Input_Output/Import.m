% %Class to declare the most common Input
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Import < handle
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
        function dataset = convertAdcpToImdc(mData, cCol)
            %function dataset = convertAdcpToImdc(sctInput)
            %Fields in sctInput:
            % mPoints  (optional)
            % WGS84
            % bank (optional)
            % mProjCo (optional)
            % nZone (optional); default = 31;
            %
            % Fields in dataset:
            % %mConc,
            % mDis
            % mFlux
            % mVelX
            % mVelY
            % mDist
            % mDepthBins
            % vTrange
            % nDir
            % mBott
            % mPoints
            % mUTM
            % mDateNum
            % mEnsemble
            % vTrackDist
            %
            % OLD Documentation follows below
            %
            %1/This function analyses cross section data described in 'data'. 'data' is a structure array
            %obtained by the rdfread.m function. The file structure of the original
            %imported csv file is determined by specific settings of the 'Sediview
            %Export module', with 1 EXEPTION: Date and time are exported in dd/mm/yyyy and HH:MM:SS formats,
            %But have to be changed to ddmmyyyy and HHMMSS formats respectively. This can be done easily in
            %'EditPadLite' for instance.
            %Csv contains following columns:
            %     1/Filename
            %     2/Ensemble nr
            %     3/Date
            %     4/Time
            %     5/Ensemble Time
            %     6/Track distance (unprojected!!)
            %     7/Longitude [dd.ddd]
            %     8/Latitude [dd.ddd]
            %     9/Bottom Depth
            %     ...
            %     ...
            %For more info: BDC is at your service.
            %
            %2/This function has on the output many matrices:
            %   1/ mdist : projected distance of ensembles relative to definition of
            %   track from shore to shore (mPoints)
            %   2/ mDepthBins
            %   3/ mConc
            %   4/ mVelX
            %   5/ mVelY
            %   6/ mDis
            %   7/ mFlux
            %   8/ vTrange
            
            %*****************************************************
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: Boudewijn Decrop
            % Date: February 2006
            % Modified by ABR
            % Date: Aug 2008/Jan 2010
            %*****************************************************
            cA.data     = mData;
            cA.varnames = cCol;
            
            varName = 'Conc';
            dataset = Dataset.createDataset;
            % look for imdcz data in header
            mAll = cA.data;
            nConcInd = find(~cellfun('isempty',strfind(cA.varnames,varName)),1,'first');
            cD = cA.varnames(nConcInd:size(mAll,2));
            cD2 = regexp(cD,'\D*','match');
            for nI = 1:length(cD2)
                cD3{nI} = cD2{nI}{1};
            end;
            cD3 =unique(cD3);
            
            nrBins = size(cD,2)/length(cD3);
            nNrEns = find(isnan(mAll(:,3)), 1 )-1;
            mA = mAll(1:nNrEns,:);
            
            dataset.Ensemble.data = mA(:,2);
            
            % convert time
            hh = floor(mA(:,4)/1e4);
            mm = floor((mA(:,4)-hh*1e4)/1e2);
            ss = mA(:,4)-hh*1e4-mm*1e2;
            
            DD = floor(mA(:,3)/1e6);
            MM = floor((mA(:,3)-DD*1e6)/1e4);
            yyyy = mA(:,3)-DD*1e6-MM*1e4;
            
            %Time
            dataset.Time.data     = datenum([yyyy MM DD hh mm ss]);
            dataset.Time.longname = 'Time';
            dataset.Time.unit     = 'days';
            dataset.Time.dim      = {'s'};
            
            %Read absolute track distance per ensemble
            dataset.S.data     = mA(:,6);
            dataset.S.dim      = {'s'};
            dataset.S.unit     = 'm';
            dataset.S.longname = 'Distance along the transect';
            
            % Read coordinates
            mCoordDD = mA(:,7:8);
            dataset.Long.data     = mCoordDD(:,2);
            dataset.Long.unit     = 'deg';
            dataset.Long.longname = 'Longitude';
            dataset.Long.dim      = {'s'};
            
            dataset.Lat.data      = mCoordDD(:,1);
            dataset.Lat.unit      = 'deg';
            dataset.Lat.longname  = 'Latitude';
            dataset.Lat.dim       = {'s'};
            
            %convert SedCond
            dataset.SedConc.data     = mA(:,nConcInd :nConcInd +nrBins-1);
            dataset.SedConc.unit     = ' mg/l';
            dataset.SedConc.longname = 'Sediment concentration';
            dataset.SedConc.dim      = {'s','z'};
            
            %convert velocities
            dataset.VelX.data     = mA(:,nConcInd +3*nrBins:nConcInd +4*nrBins-1);
            dataset.VelX.unit     = 'm/s';
            dataset.VelX.longname = 'Velocity in x - direction';
            dataset.VelX.dim      = {'s','z'};
            
            dataset.VelY.data     = mA(:,nConcInd +4*nrBins:nConcInd +5*nrBins-1);
            dataset.VelY.unit     = 'm/s';
            dataset.VelY.longname = 'Velocity in y - direction';
            dataset.VelY.dim      = {'s','z'};
            
            % Read Bottom depths
            dataset.BotDep.data     = mA(:,9);
            dataset.BotDep.dim      = {'s'};
            dataset.BotDep.unit     = 'm';
            dataset.BotDep.longname = 'Bottom depth';
            
            % read fields
            % dataset.mDis  = mA(:,nConcInd +nrBins:nConcInd +2*nrBins-1);
            % Check if mDis is == Q
            dataset.Q.data     =  mA(:,nConcInd +nrBins:nConcInd +2*nrBins-1);
            dataset.Q.dim      = {'q'};
            dataset.Q.unit     = 'm3/s';
            dataset.Q.longname = 'Discharge';
            
            % dataset.BedFlux.data     =  mA(:,nConcInd +2*nrBins:nConcInd +3*nrBins-1);
            % Check if mFlux is == BedFlux
            dataset.BedFlux.data     =  mA(:,nConcInd +nrBins:nConcInd +2*nrBins-1);
            dataset.BedFlux.dim      = {'e'};
            dataset.BedFlux.unit     = 'kg/m2/s';
            dataset.BedFlux.longname = 'Erosion flux';
            
            mDepthBins = zeros(nrBins,1);
            %Extract Bin Depths from csv file column headers
            for i=1:nrBins
                strDepth = strrep(char(cD(i)),varName,'');
                nDepth   = str2num(strDepth);
                mDepthBins(i,1) = nDepth;
            end
            
            %Bottom Depths
            dataset.Z.data     = mDepthBins;
            dataset.Z.unit     = 'm';
            dataset.Z.longname = 'Depth of the bins with respect to water level';
            dataset.Z.dim      = {'z'};
            
            % metadata
            dataset.metaData.coordinateSystem = 'WGS84-Geographic';
        end;
        
        function [] = downloadCfsrWind(opt);
            %Function [] = downloadCfsrWind(opt);
            % Download wind from the CFSR hindcast, http://cfs.ncep.noaa.gov/cfsr/
            %
            % Inputs:
            %  opt: Options structure containing the following options:
            %    outFile: Name of the output file
            %    latRange: 2-number vector containing the latitude range
            %    (minimum and maximum latitude)
            %    lonRange: 2-number vector containing the latitude range
            %    (minimum and maximum longitude). Longitude can range
            %    either from -180 to +180 or from 0 to 360, as long as the
            %    zero meridian is in Greenwich and the longitude increases
            %    towards the east.
            %    timeRange: 2-number vector containing the start and
            %    end time of the dataset
            %    timeStride: time step (in hours) of the output data
            %    tempFolder: the name of a folder to save temporary files
            %    in
            %    CfsrVersion: 'CFSRv1'; %For data from 01/01/1979 to 31/12/2009
            %                 'CFSRv2'; %For data from 01/04/2011 to 01/07/2014
            %    (see
            %    http://nomads.ncdc.noaa.gov/data.php?name=access#CFSR-data
            %    for details);
            %    variables: The variables that you want to download.
            %    Supported are: 'WindVelX','WindVelY','AirPress'
            %
            % Usage example:
            % opt.outFile = 'testCFSRdata';
            % opt.latRange = [7 8];
            % opt.lonRange = [1 2];
            % opt.timeRange = [datenum([2005 01 1]) datenum([2005 03 1])];
            % opt.timeStride =  96;
            % opt.tempFolder = './tempCSFR';
            % opt.CfsrVersion = 'CFSRv1';
            % opt.variables = {
            %     'WindVelX'
            %     'WindVelY'
            %     'AirPress'};
            %
            % Import.downloadCfsrWind(opt);
            
            %*****************************************************
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: Thijs Lanckriet
            % Date: February 2015
            %*****************************************************
            
            %% Make some defaults:
            if ~isfield(opt,'tempFolder');
                opt.tempFolder = './tempCFSRdownload';
            end
            
            
            
            %% Check if Openearth is available
            if exist('nc_varget')~=2;
                error('Openearth toolbox functions are not found.');
            end
            
            %% Create temp directory to save results in
            if ~exist(opt.tempFolder,'dir');
                mkdir(opt.tempFolder);
            end
            
            %% Longitude can be either from -180 to +180 or from 0 to 360
            opt.lonRange = mod(opt.lonRange,360);
            
            %% Put the date in a vector format rounded to the month
            dvMonth = datevec(opt.timeRange(1));
            dvMonth(3:6) = [1 0 0 0]; %Set to the first of the month
            
            opt.tempFileNum = 0;
            while datenum(dvMonth)<opt.timeRange(2);
                
                opt.tempFileNum = opt.tempFileNum +1;
                
                % Make URL
                
                dvStr1 = datestr(dvMonth,'yyyymm');
                dvStr2 = datestr(dvMonth,'yyyy');
                
                switch opt.CfsrVersion;
                    case 'CFSRv1'
                        url_wind = sprintf('http://nomads.ncdc.noaa.gov//thredds//dodsC//cfsr1hr//%s//wnd10m.gdas.%s.grb2',dvStr1,dvStr1);
                        url_pressure = sprintf('http://nomads.ncdc.noaa.gov//thredds//dodsC//cfsr1hr//%s//prmsl.gdas.%s.grb2',dvStr1,dvStr1);
                    case 'CFSRv1coarse'
                        url_wind = sprintf('http://nomads.ncdc.noaa.gov//thredds//dodsC//cfsr1hr//%s//wnd10m.l.gdas.%s.grb2',dvStr1,dvStr1);
                        url_pressure = sprintf('http://nomads.ncdc.noaa.gov//thredds//dodsC//cfsr1hr//%s//prmsl.l.gdas.%s.grb2',dvStr1,dvStr1);
                    case 'CFSRv2'
                        url_wind = sprintf('http://nomads.ncdc.noaa.gov/thredds/dodsC/modeldata/cfsv2_analysis_timeseries/%s/%s/wnd10m.gdas.%s.grib2',dvStr2,dvStr1,dvStr1);
                        url_pressure = sprintf('http://nomads.ncdc.noaa.gov/thredds/dodsC/modeldata/cfsv2_analysis_timeseries/%s/%s/prmsl.gdas.%s.grib2',dvStr2,dvStr1,dvStr1);
                    otherwise
                        error('Invalid CFSR version.')
                end
                
                
                
                
                fprintf('Initiating download %s.\t',datestr(dvMonth,'mmmm yyyy'));
                
                for i = 1:numel(opt.variables);
                    
                    
                    imdcName = opt.variables{i};
                    
                    tempFilename = fullfile(opt.tempFolder,sprintf('temp_%s_%s.mat',imdcName,datestr(dvMonth,'mmmyyyy')));
                    fprintf('%s\t',imdcName);
                    
                    if exist(tempFilename,'file');
                        fprintf('exists.');
                        continue;
                    end
                    switch imdcName;
                        case 'WindVelX';
                            url = url_wind;
                            cfsrName = 'U-component_of_wind';
                            unit = 'm/s';
                            numDims = 4;
                        case 'WindVelY';
                            url = url_wind;
                            cfsrName = 'V-component_of_wind';
                            unit = 'm/s';
                            numDims = 4;
                        case 'AirPress';
                            url = url_pressure;
                            cfsrName = 'Pressure_reduced_to_MSL';
                            unit = 'Pa';
                            numDims = 3;
                    end
                    
                    %Load wind data files
                    %     ds = ncdataset(opt.url_wind); %Dataset
                    t = nc_cf_time(url,'time');
                    nT = numel(t);
                    t = nc_cf_time(url,'time',0,Inf,opt.timeStride);
                    lon = nc_varget(url,'lon');
                    lat = nc_varget(url,'lat');
                    
                    %Deal with longitudes that cross the Greenwich Meridian
                    if opt.lonRange(1) > opt.lonRange(2)
                        CrossGM = true;
                        mnlonind = find(lon >= opt.lonRange(1),1);
                        mxlonind = find(lon <= opt.lonRange(2),1, 'last');
                        nlon = numel(lon);
                        lon = [lon(mnlonind:end)-360; lon(1:mxlonind)];
                    else
                        CrossGM = false;
                        lonInd = find(lon >= opt.lonRange(1) & lon <= opt.lonRange(2));
                        lon= lon(lonInd);
                    end
                    latInd = find(lat >= opt.latRange(1) & lat <= opt.latRange(2));
                    
                    lat = lat(latInd);
                    
                    if ~CrossGM %If the domain does not cross the Greenwich Meridian
                        switch numDims;%Wind data has 4 dimensions, pressure data has 3
                            case 4;
                                rawDat = nc_varget(url,cfsrName,[0 0 min(latInd)-1 min(lonInd)-1],[inf 1 numel(latInd) numel(lonInd)],[opt.timeStride 1 1 1]);
                                rawDat = squeeze(rawDat);
                            case 3;
                                rawDat = nc_varget(url,cfsrName,[0 min(latInd)-1 min(lonInd)-1],[inf numel(latInd) numel(lonInd)],[opt.timeStride 1 1]);
                        end
                    else
                        switch numDims;%Wind data has 4 dimensions, pressure data has 3
                            case 4;
                                rawDat1 = squeeze(nc_varget(url,cfsrName,[0 0 min(latInd)-1 mnlonind-1],[inf 1 numel(latInd) inf]     ,[opt.timeStride 1 1 1]));
                                rawDat2 = squeeze(nc_varget(url,cfsrName,[0 0 min(latInd)-1        0]  ,[inf 1 numel(latInd) mxlonind],[opt.timeStride 1 1 1]));
                                rawDat = cat(3,rawDat1, rawDat2); %Merge two matrices
                                clear rawDat1 rawDat2
                            case 3;
                                rawDat1 = (nc_varget(url,cfsrName,[0 min(latInd)-1 mnlonind-1],[inf numel(latInd) inf]     ,[opt.timeStride 1 1]));
                                rawDat2 = (nc_varget(url,cfsrName,[0 min(latInd)-1        0]  ,[inf numel(latInd) mxlonind],[opt.timeStride 1 1]));
                                rawDat = cat(3,rawDat1, rawDat2); %Merge two matrices
                                clear rawDat1 rawDat2
                                
                                
                                lon1 = nc_varget(url,'lon',mnlonind-1,Inf,1);
                                lon2 = nc_varget(url,'lon',0,mxlonind,1);
                                lonB = [lon1-360;lon2];
                                
                        end
                    end
                    
                    
                    
                    monthData.Time.data = t;
                    monthData.Time.dim = {'T'};
                    monthData.Time.unit = 'days';
                    monthData.Time.longname= 'Time';
                    
                    monthData.Lat.data = lat;
                    monthData.Lat.dim = {'Lat'};
                    monthData.Lat.unit = 'dec deg';
                    monthData.Lat.longname= 'Latitude';
                    
                    monthData.Lon.data = lon;
                    monthData.Lon.dim = {'Lon'};
                    monthData.Lon.unit = 'dec deg';
                    monthData.Lon.longname= 'Longitude';
                    
                    monthData.(imdcName).data = rawDat;
                    monthData.(imdcName).dim = {'T','Lon','Lat'};
                    monthData.(imdcName).unit = 'Pa';
                    monthData.(imdcName).longname= cfsrName;
                    
                    Dataset.saveData(monthData,tempFilename);
                    clear monthData
                    
                end
                fprintf('\n');
                
                
                %Step to next month
                dvMonth = dvMonth + [0 1 0 0 0 0];
            end
            
            fprintf('Finished downloading all files.\n');
            
            %% Merge all the files together;
            fprintf('Commencing merging process.\t');
            
            dvMonthM = datevec(opt.timeRange(1));
            dvMonthM(3:6) = [1 0 0 0]; %Set to the first of the month
            
            
            for j = 1:numel(opt.variables);
                imdcName = opt.variables{j};
                fprintf('%s\t',imdcName);
                
                dvMonthM = datevec(opt.timeRange(1));
                dvMonthM(3:6) = [1 0 0 0]; %Set to the first of the month
                firstFile = true;
                while datenum(dvMonthM)<datenum(dvMonth);
                    fprintf('%s\t',datestr(dvMonthM,'mmmyyyy'));
                    tempFilename = fullfile(opt.tempFolder,sprintf('temp_%s_%s.mat',imdcName,datestr(dvMonthM,'mmmyyyy')));
                    
                    [monthData,loadOK] = Dataset.loadData(tempFilename);
                    
                    if firstFile
                        firstFile = false;
                        allData = monthData;
                    else
                        if ...
                                any(monthData.Lat.data ~= allData.Lat.data) || ...
                                any(monthData.Lon.data ~= allData.Lon.data);
                            error('Lat, lon not the same across all temporary files');
                        end
                        
                        allData.Time.data = [allData.Time.data; monthData.Time.data];
                        allData.(imdcName).data = [allData.(opt.variables{j}).data; monthData.(imdcName).data];
                    end
                    %Step to next month
                    dvMonthM = dvMonthM + [0 1 0 0 0 0];
                end
                Dataset.saveData(allData,sprintf('%s_%s',opt.outFile,imdcName));
                
                
            end
            fprintf('\n');
        end
        
        function isdMeteoImport(opt);
            %% Import Integrated Surface Database meteo data
            % For format see ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-format-document.pdf
            % For technical documentation see ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-tech-report.pdf
            % Input: opt structure, containing:
            % - opt.workingDir: Working directory where raw data files will be stored.
            %           Default = './isdWorkingDir';
            % - opt.yearRange: Range of years over which you want the wind data.
            %           Default = 1990:2020;
            % - opt.fileNameOut: Name of the datafile where you want to save.
            %           Default = 'winddata';
            % - opt.usafCode: USAF code of the weatherstation. Can look this up from
            % http://www7.ncdc.noaa.gov/CDO/cdopoemain.cmd?datasetabbv=DS3505&countryabbv=&georegionabbv=&resolution=40
            % - opt.wbanCode: WBAN code of the weatherstation. Can look this up from
            % http://www7.ncdc.noaa.gov/CDO/cdopoemain.cmd?datasetabbv=DS3505&countryabbv=&georegionabbv=&resolution=40.
            % If not specified, use 99999.
            opt = Util.setDefault(opt,'workingDir','./isdWorkingDir');
            opt = Util.setDefault(opt,'yearRange',1990:2020);
            opt = Util.setDefault(opt,'fileNameOut','winddata');
            if ~isfield(opt,'usafCode');
                error('Need to specify USAF code of weather station in opt.usafCode. Look this up at http://www7.ncdc.noaa.gov/CDO/cdopoemain.cmd?datasetabbv=DS3505&countryabbv=&georegionabbv=&resolution=40');
            end
            if ~isfield(opt,'wbanCode');
                error('Need to specify WBAN code of weather station in opt.usafCode. Look this up at http://www7.ncdc.noaa.gov/CDO/cdopoemain.cmd?datasetabbv=DS3505&countryabbv=&georegionabbv=&resolution=40. If not specified, use 99999.');
            end
            if ~exist(opt.workingDir,'dir');
                mkdir(opt.workingDir);
            end
            
            
            
            baseIsdFile = sprintf('%06u-%05u-%%u.gz',opt.usafCode,opt.wbanCode);
            baseUrl = 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/%u/';
            
            rawDat = [];
            
            for i = 1:numel(opt.yearRange);
                fprintf('Downloading wind for year %u.\n',opt.yearRange(i));
                isdFile = sprintf(baseIsdFile,opt.yearRange(i));
                fullUrl = [sprintf(baseUrl,opt.yearRange(i)) isdFile];
                
                try;
                    urlwrite(fullUrl,fullfile(opt.workingDir,isdFile));
                    
                    txtFile = gunzip(fullfile(opt.workingDir,isdFile));
                    newFileLoaded = true;
                    
                catch;
                    newFileLoaded = false;
                end
                if newFileLoaded;
                    rawDat = [rawDat fileread(txtFile{1})];
                end
            end
            
            if isempty(rawDat);
                error('Couldn''t load any data');
            end
            rowDat = char(strsplit(rawDat,'\n')');
            
            %Remove last line if it's empty
            temp = cellstr(rowDat);
            if isempty(temp{end});
                rowDat = rowDat(1:end-1,:);
            end
            
            % USAF CODE
            ind = 5:10;
            temp = unique(cellstr(rowDat(:,ind)));
            if numel(temp)>1;
                error('Dataset corresponds to more than 1 station code');
                elsef
                newDat.usafCode = temp{1};
            end
            
            % WBAN CODE
            ind = 11:15;
            temp = unique(cellstr(rowDat(:,ind)));
            if numel(temp)>1;
                error('Dataset corresponds to more than 1 station code');
            else
                newDat.wbanCode = temp{1};
            end
            
            % TIME
            ind = 16:27;
            time = datenum(cellstr(rowDat(:,ind)),'yyyymmddHHMM');
            newDat.Time.data = time;
            newDat.Time.dim = {'T'};
            newDat.Time.longname = 'Time';
            newDat.Time.unit = 'Days UTC - Matlab Serial time';
            
            % LATITUDE
            ind = 29:34;
            newDat.Latitude.data = str2double(cellstr((rowDat(:,ind))))/1000;
            newDat.Latitude.dim = {'T'};
            newDat.Latitude.longname = 'Latitude';
            newDat.Latitude.unit = 'Degrees';
            
            % LONGITUDE
            ind = 35:41;
            newDat.Longitude.data = str2double(cellstr((rowDat(:,ind))))/1000;
            newDat.Longitude.dim = {'T'};
            newDat.Longitude.longname = 'Longitude';
            newDat.Longitude.unit = 'Degrees';
            
            % OBSERVATION TYPE
            ind = 42:46;
            newDat.ObsType.data = cellstr(rowDat(:,ind));
            newDat.ObsType.dim = {'T'};
            newDat.ObsType.longname = 'GEOPHYSICAL-REPORT-TYPE';
            newDat.ObsType.unit = 'See ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-tech-report.pdf';
            
            newDat.WindVelMag.data = rawDat(:,9)/10;
            newDat.WindVelMag.dim = {'T'};
            newDat.WindVelMag.longname = 'Wind velocity magnitude';
            newDat.WindVelMag.unit = 'm/s';
            
            % WIND VEL DIR
            ind = 61:63;
            newDat.WindVelDir.data = str2double(cellstr((rowDat(:,ind))));
            newDat.WindVelDir.dim = {'T'};
            newDat.WindVelDir.longname = 'Wind velocity direction';
            newDat.WindVelDir.unit = '° from North';
            ind = 64;
            newDat.WindVelDir.flag_values = str2double(cellstr((rowDat(:,ind))));
            newDat.WindVelDir.flag_expl = ' 0 = Passed gross limits check \n 1 = Passed all quality control checks \n 2 = Suspect \n 3 = Erroneous \n 4 = Passed gross limits check , data originate from an NCEI data source \n 5 = Passed all quality control checks, data originate from an NCEI data source \n 6 = Suspect, data originate from an NCEI data source \n 7 = Erroneous, data originate from an NCEI data source \n 9 = Passed gross limits check if element is present';
            newDat.WindVelDir.flag_expl = strrep(newDat.WindVelDir.flag_expl,'\n',char(10));
            
            
            % WIND VEL MAG
            ind = 66:69;
            newDat.WindVelMag.data = str2double(cellstr((rowDat(:,ind))))/10;
            newDat.WindVelMag.dim = {'T'};
            newDat.WindVelMag.longname = 'Wind velocity magnitude';
            newDat.WindVelMag.unit = 'm/s';
            ind = 70;
            newDat.WindVelMag.flag_values = str2double(cellstr((rowDat(:,ind))));
            newDat.WindVelMag.flag_expl = ' 0 = Passed gross limits check \n 1 = Passed all quality control checks \n 2 = Suspect \n 3 = Erroneous \n 4 = Passed gross limits check , data originate from an NCEI data source \n 5 = Passed all quality control checks, data originate from an NCEI data source \n 6 = Suspect, data originate from an NCEI data source \n 7 = Erroneous, data originate from an NCEI data source \n 9 = Passed gross limits check if element is present';
            newDat.WindVelMag.flag_expl = strrep(newDat.WindVelMag.flag_expl,'\n',char(10));
            ind = 65;
            newDat.WindVelMag.obs_type = (cellstr((rowDat(:,ind))));
            newDat.WindVelMag.obs_type_expl = ' A: Abridged Beaufort \n B: Beaufort \n C: Calm \n H: 5-Minute Average Speed \n N: Normal \n R: 60-Minute Average Speed \n Q: Squall \n T: 180 Minute Average Speed \n V: Variable \n 9 = Missing \n NOTE: If a value of 9 appears with a wind speed of 0000, this indicates calm winds.';
            newDat.WindVelMag.obs_type_expl = strrep(newDat.WindVelMag.obs_type_expl,'\n',char(10));
            
            
            newDat.title = 'Wind velocity from ISD dataset';
            newDat.location = sprintf('Weather station USAF %u WBAN %u',opt.usafCode,opt.wbanCode);
            newDat.history = sprintf('Created on %s using %s', mfilename('fullpath'),datestr(now));
            
            
            Dataset.saveData(newDat,opt.fileNameOut);
        end
        
        
        function [mData,cMeta,cCol] = readAdcpCsv(strFile,bFlip)
            % This function reads an ADCP - CVS file
            %  [mData,cMeta,cCol] = readAdcpCsv(strFile,bFlip)            
            % INPUTS:-strFile: a string containing the path and filename of a CSV file
            %with ADCP data (such as exported by Sediview) to be read. Note that this
            %version does not need to have the slashes and colons to be remouved from
            %the CSV files. If present, they will be removed automatically.
            %   -bFlip (optional: if set to one, the date is converted from ddmmyyyy to yyyymmdd
            % OUTPUTS: cA: a struc conrtaing the fields:
            %       -varnames: a cell array conating the hearders of the file
            %       -data: a matrix containing the data from the file.
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: December 2008
            % Modified by: ABR
            % Date:
            
            if nargin ==1
                bFlip = 0;
            end;
            %nBufSize = 10000;
            delimiterType = ',';
            fid = fopen(strFile);
            if fid<0
                error(['File ',strFile,' does cannot be opened. Control whether it exist and is not read protected.']);
            end;
 %          strData   = textscan(fid,'%s\n',1,'BufSize',nBufSize,'delimiter','*****'); %inlezen eerste regel
           strData   = textscan(fid,'%s\n',1,'delimiter','*****'); %inlezen eerste regel

            cDummy    = regexpi(strData{1},'[,;]');
            nrFields  = length(cDummy{1})+1; %tellen aantal kommas in CSV
            strFormat = repmat('%s ',1,nrFields);
            
%            cHeader  = textscan(strData{1}{1},strFormat,'delimiter',',','BufSize',nBufSize); %omzetten eerste lijn naar text
            cHeader  = textscan(strData{1}{1},strFormat,'delimiter',delimiterType); %omzetten eerste lijn naar text
            if isempty(cHeader{2})
                 cHeader  = textscan(strData{1}{1},strFormat,'delimiter',';'); %omzetten eerste lijn naar text
                 delimiterType = ';';
            end
            
            %verwijderen van cell arrays
            for nI = 1:length(cHeader)
                cA.varnames{nI} = cHeader{nI}{1};
                cCol{nI}        = cHeader{nI}{1};
            end;
            
            %inlezen rest van de tekst
            strFormat = ['%s %f %s %s ',repmat('%f ',1,nrFields-4)];
            %cData     = textscan(fid,strFormat,'delimiter',',','BufSize',nBufSize);
            cData     = textscan(fid,strFormat,'delimiter',delimiterType);
            fclose(fid);
            
            %omzetten cell array naar matrix
            for nI = [2, 5:length(cData)]
                mData(:,nI)=cData{nI};
            end;
            mData(:,1) = nan;
            
            %verwijderen slash en dubbele punt in datum en tijd
            if bFlip
                %verwijderen estimates discharge
                mData(end-5:end,:)= [];
                for nI = 1:length(mData(:,3))
                    strData = strrep(cData{3}{nI},'/','');
                    if  length(strData)==8
                        mData(nI,3)  = str2double(strData([5:8,3,4,1,2]));
                    else
                        mData(nI,3)  = str2double([strData([4:7,2,3]),'0',strData(1)]);
                    end;
                    mData(nI,4)  = str2double(strrep(cData{4}{nI},':',''));
                end;
            else
                for nI = 1:length(cData{3})
                    mData(nI,3)  = str2double(strrep(cData{3}{nI},'/',''));
                    mData(nI,4)  = str2double(strrep(cData{4}{nI},':',''));
                end;
            end;
            
            cMeta = {};
        end;
        
        function [x,y,z] = readArcView(fileName)
            % this function reads an arcview file
            %
            %[x,y,z] = Import.readArcView(fileName)
            %
            % INPUT: fileName: name and path of the filename
            %
            % OUTPUT: x,y,z,: matrices with x y and z coordinates of the
            % file
            
            fid = fopen(fileName);
            % read header
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            nrCol = str2double(aNum);
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            nrRow = str2double(aNum);
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            xLL = str2double(aNum);
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            yLL = str2double(aNum);
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            dx = str2double(aNum);
            aLine = fgetl(fid);
            [~,aNum] = strtok(aLine);
            nodata = str2double(aNum);
            
            % read data
            cellData = textscan(fid,'%f');
            fclose(fid);
            
            % process data
            z = cell2mat(cellData);
            
            mask = abs(z-nodata)<1e-15;
            z(mask) = nan;
            z = reshape(z,nrCol,nrRow)';
            
            
            % construct the grid
            x1 = xLL + dx*(0:nrCol-1);
            y1 = yLL + dx*(nrRow-1:-1:0);
            x = repmat(x1,nrRow,1);
            y = repmat(y1',1,nrCol);
        end
        
        function [mData,cCol,cMeta] = readAltus(strFile,nNrLines)
            %this function reads an Altus file
            %
            % INPUTS:-strFile: a string containing the path and filename of the
            %                  datafile.
            %         -nNrLines (optional): the number of lines that must be read
            %
            % OUTPUTS: - mData: a matrix with the data (containing the time in IMDC
            %                   format)
            %          - cCol: a cell string with the headers of the appropriate data
            %          as read from the file
            %          - cMeta: a cell string with metadata
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            % Written by: Alexander Breugem
            %
            % Date: September 2009
            % Modified by: JCA (some extra metadata)
            % Modified by: SEO (use new ALTUS format)
            % Date: August 2011
            
            bGo = 1;
            %openen file
            
            fid = fopen(strFile);
            if fid<0
                error(['Error opening file',strFile]);
            end;
            
            %reading and parsing header
            cMeta{1,1} = 'Type of instrument';
            cMeta{1,2} = 'Altus';
            bSN = 1; cHeader = []; k = 1;
            while bGo
                fidPosition = ftell(fid);
                strHeader   = fgetl(fid);
                
                if  ~isempty(strfind(strHeader,'Date'))
                    bGo = 0;
                elseif ~isempty(strfind(strHeader,'S_ALTUS')) && bSN
                    vSN = regexp(strHeader,'[0-9]');
                    cMeta = [cMeta;{'Serial number of the instrument',strHeader(vSN)}];
                    bSN = 0;
                elseif ~isempty(strfind(strHeader,'WAY'))
                    if ~isempty(strfind(strHeader,'Profondeur'))
                        strHeader = 'Total pressure [m]';
                    elseif ~isempty(strfind(strHeader,'Echo'))
                        strHeader = 'Max. echo [%]';
                    elseif ~isempty(strfind(strHeader,'Vitesse'))
                        vN = regexp(strHeader,'[0-9]');
                        strHeader = ['Distance from sensor ',num2str(k), ' (sonar speed ', strHeader(vN(2:end)),' m/s) [cm]'];
                        k=k+1;
                    end;
                    cHeader = [cHeader,{strHeader}];
                else
                    %Add exit loop if the text does not match with any predefined text
                    %after read the sonars
                    if k > 1
                        bGo = 0;
                        frewind(fid);
                        fseek(fid, fidPosition, 0);
                    end;
                end;
            end;
            
            strFormat = '%s %s %s %s %s %s %s %s';%'%f %f %f %f %f %f %f/%f/%f %f:%f:%f ';
            %lezen data
            cData = textscan(fid,strFormat, 'delimiter', ';\t');
            fclose(fid);
            
            
            %omzetten tijden uit de excel file
            mDate = datenum(cData{:,7},'dd/mm/yyyy');
            mTime = datenum(cData{:,8},'HH:MM:SS')-datenum(['0101',datestr(now,'yyyy')],'ddmmyyyy');
            mData = serial2DateTime(mDate+mTime);
            
            cData(end-1:end) = [];
            cCol = [{'Date [yyyymmdd]','Time [hhmmss]'},cHeader];
            %controleren of alle kolommen even lang zijn en samenvoegen kolommen
            
            for nI = 1:length(cData)
                if length(cData(nI))==length(cData(1))
                    vData=cData{nI};
                    for nR=1:size(cData{nI},1)
                        str       = vData{nR};
                        nK        = regexp(str,',');
                        str(nK)   = '.';
                        vData{nR} = str2num(str);
                    end
                    mData = [mData,cell2mat(vData)];
                else
                    error(['The number of data in the columns is different (',num2str(length(cData(nI))) ,' vs ',num2str(length(cData(1))),')! Check the data.']);
                end;
            end;
            
            %mData(:,3)=(mData(:,3)-mData(1,3))./100; %luchtdrukcorrectie en conversie van cm naar m
            mData(:,5:8) = (mData(:,5:8))./10; %conversie van mm naar cm
            
            %delete bad data in depth
            idxDepth = mData(:,3) <= 0.7;
            mData(idxDepth, 3) = nan;
            
            %delete bad data in way2
            idxWay2 = mData(:,5) <= 0.5;
            mData(idxWay2, 5) = nan;
            
            %delete bad data in way3
            idxWay3 = mData(:,6) <= 0.6;
            mData(idxWay3, 6) = nan;
            
            %delete bad data in way4
            idxWay4 = mData(:,7) <= 0.7;
            mData(idxWay4, 7) = nan;
            
            %delete bad data in way5
            idxWay5 = mData(:,8) <= 0.8;
            mData(idxWay5, 8) = nan;
        end;
        
        
        function  xyPoly = readCadLisp(polyFile,dtheta)
            % read Lisp export from autocad (for polylines)
            %
            % xyPoly = readCadLisp(polyFile,dtheta)
            %
            % INPUT: polyFile: path of the ascii file containing the data
            %        dtheta (optional):  angle in degrees for resamping
            %        arcs. Default is 5 deg.
            %
            % OUTPUT: xyPoly: Mx2 matrix with x and y coordinates
            %
            % Limitations: for now only arcs and straight lines are
            % allowed.
            %
            if nargin ==1
                dtheta = 5;
            end
            % preallocate
            nrPoin = 30000;
            xL = zeros(nrPoin,1);
            yL = zeros(nrPoin,1);
            
            % open file
            i = 1;
            fid = fopen(polyFile);
            while true
                strLine = fgets(fid);
                %delete spaces
                
                strLine(strLine==32)= [];
                %disp(strLine);
                % parse points
                % read lines
                if ~isempty(strfind(strLine,'atpoint'))
                    iX = strfind(strLine,'X=');
                    iY = strfind(strLine,'Y=');
                    if ~isempty (iX) && ~isempty(iY)
                        x = str2double(strLine(iX+2:iY-1));
                        y = str2double(strLine(iY+2:end));
                        xL(i) = x;
                        yL(i) = y;
                        i = i+1;
                    end
                end
                % read arcs
                if ~isempty(strfind(strLine,'bulge'))
                    % read bulge
                    iB = strfind(strLine,'bulge');
                    b = str2double(strLine(iB+5:end));
                    
                    %read center
                    strLine = fgets(fid);
                    strLine(strLine==32)= [];
                    iX = strfind(strLine,'X=');
                    iY = strfind(strLine,'Y=');
                    if ~isempty (iX) && ~isempty(iY)
                        xC = str2double(strLine(iX+2:iY-1));
                        yC = str2double(strLine(iY+2:end));
                    else
                        error('wrong format')
                    end
                    
                    %read radius
                    strLine = fgets(fid);
                    strLine(strLine==32)= [];
                    iR = strfind(strLine,'radius');
                    if ~isempty (iR)
                        R = str2double(strLine(iR+6:end));
                    else
                        error('wrong format')
                    end
                    
                    % read start angle
                    strLine = fgets(fid);
                    strLine(strLine==32)= [];
                    iR = strfind(strLine,'startangle');
                    if ~isempty (iR)
                        theta1 = str2double(strLine(iR+10:end));
                    else
                        error('wrong format')
                    end
                    
                    % read end angle
                    strLine = fgets(fid);
                    strLine(strLine==32)= [];
                    iR = strfind(strLine,'endangle');
                    if ~isempty (iR)
                        theta2 = str2double(strLine(iR+8:end));
                    else
                        error('wrong format')
                    end
                    
                    % resample
                    b2 = 180/pi*4*atan(b);
                    %disp(num2str([b,b2,theta1,theta2,R,xC,yC]))
                    theta2 = theta1+b2;
                    if b>0
                        theta = theta1:dtheta:theta2;
                    else
                        theta = theta1:-dtheta:theta2;
                    end
                    x = xC + R.*cosd(theta);
                    y = yC + R.*sind(theta);
                    
                    nrX = length(x);
                    
                    % add to data
                    xL(i:i+nrX-1)=x;
                    yL(i:i+nrX-1)=y;
                    i = i + nrX;
                end
                
                
                % stop at end of file
                if ~ischar(strLine);
                    break;
                end
                
            end
            fclose(fid);
            % make data for output
            xyPoly = [xL(1:i-1),yL(1:i-1)];
            
        end
        
        function [mData, cMeta, cCol] = readCtd(strFile,nNrLines)
            % This job reads data from a Wiski files of WL (.ZRX file)
            %
            % INPUTS:-strFile: a string containing the path and filename of the
            %                  datafile.
            %         -nNrLines (optional): the number of lines that must be read
            %
            % OUTPUTS: - mData: a matrix with the data (containing the time in IMDC
            %                   format)
            %          - cCol: a cell string with the headers of the appropriate data
            %          as read from the file
            %          - cMeta: a cell string with metadata
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: September 2009
            % Modified by: JCA (some extra metadata)
            % Date: August 2011
            
            bGo = 1;
            %openen file
            
            fid = fopen(strFile);
            if fid<0
                error(['Error opening file',strFile]);
            end;
            
            %reading and parsing header
            cMeta{1,1} = 'Type of instrument';
            cMeta{1,2} = 'CTD-Diver';
            bSN=1;bIN=1;
            while bGo
                strHeader=fgetl(fid);
                if  ~isempty(strfind(strHeader,'[Data]'))
                    bGo = 0;
                elseif ~isempty(strfind(strHeader,'Serial number')) && bSN
                    nStart=min(strfind(strHeader,'='))+1;
                    cMeta=[cMeta;{'Serial number of the instrument',strHeader(nStart:end)}];
                    bSN=0;
                elseif ~isempty(strfind(strHeader,'Instrument number')) && bIN
                    nStart=min(strfind(strHeader,'='))+1;
                    cMeta=[cMeta;{'IMDC Instrument Reference',strHeader(nStart:end)}];
                    bIN=0;
                end;
            end;
            strLines = fgetl(fid);
            nLines   = num2str(strLines);
            
            if nargin == 1
                nNrLines = nLines;
            end;
            
            strFormat = '%f/%f/%f %f:%f:%f %f %f %f';
            %lezen data
            cData = textscan(fid,strFormat,nNrLines);
            fclose(fid);
            
            
            %omzetten tijden uit de excel file
            vTime = 1e4.*cData{4}+1e2.*cData{5}+cData{6};
            vDate = 1e4.*cData{1}+1e2.*cData{2}+cData{3};
            mData = [vDate vTime];
            
            cCol = {'Date [yyyymmdd]','Time [hhmmss]','Total pressure [dbar]','Temperature [ÂºC]','Conductivity [mS/cm]'};
            %controleren of alle kolommen even lang zijn en samenvoegen kolommen
            
            for nI = 7:length(cData)
                if length(cData(nI))==length(cData(1))
                    mData(:,nI-4)=cData{nI};
                else
                    error(['The number of data in the columns is different (',num2str(length(cData(nI))) ,' vs ',num2str(length(cData(1))),')! Check the data.']);
                end;
            end;
            
            %mData(:,3)=(mData(:,3)-mData(1,3))./100; %luchtdrukcorrectie en conversie van cm naar m
            mData(:,3)=(mData(:,3))./100; %luchtdrukcorrectie en conversie van cm naar m
        end;
        
        function [mData,cMeta,cCol] = readGrainSize(strFile, onlyDisplay)
            cMeta = {};
            nBufSize = 10000;
            fid = fopen(strFile);
            if fid<0
                error(['File ',strFile,' does cannot be opened. Control whether it exist and is not read protected.']);
            end;
            
            dHeaderIdx = []; DheaderIdx = []; resultIdx = []; resultNumberIdx = [];
            numberIdx = []; columnTextIdx = [];
            
            firstLine = fgetl(fid);
            secondLine = fgetl(fid);
            
            %fix the first line content
            [firstLineContent, summary]= readtext(firstLine, '","', '', '', 'textsource');
            
            %fix second line content
            [secondLineContent, summary]= readtext(secondLine, ',', '', '', 'textsource');
            
            
            [data, result]= readtext(strFile, ',', '', '""', 'textual-empty2NaN');
            %delete quotes
            data = strrep(data(:,:),'"',''); %get rid of double quotes
            
            firstLineContent = data(1,:);
            
            allColumns = {};
            cCol = {};
            
            flagTime = 0;
            %get the column names/info
            for i=1:numel(firstLineContent)
                text = firstLineContent{i};
                if isempty(text)
                    numberIdx = [numberIdx i];
                    allColumns{length(allColumns)+1} = 'GsdFreq';
                    
                    continue;
                end
                
                text = strtrim(strrep(text, '"', ''));
                
                %get the info match with d (0.1)
                if ~isempty(regexp(text, 'd \(([-0-9. ]+.)\)', 'tokens'))
                    dHeaderIdx = [dHeaderIdx i];
                    allColumns{length(allColumns)+1} = text;
                    cCol{length(cCol)+1} = text;
                    
                    %get the info match with D [3, 2] - Surface weighted mean
                elseif regexp(text, 'D \[[-0-9,. ]+\].')
                    DheaderIdx = [DheaderIdx i];
                    allColumns{length(allColumns)+1} = text;
                    cCol{length(cCol)+1} = text;
                    
                    %get the info match with Result Below 4.00µm
                elseif regexp(text, 'Result [a-zA-Z]+.')
                    resultIdx = [resultIdx i];
                    allColumns{length(allColumns)+1} = text;
                    cCol{length(cCol)+1} = text;
                    
                    %get the info match with Result 4.00µm-8.00µm
                elseif regexp(text, 'Result \d+.')
                    resultNumberIdx = [resultNumberIdx i];
                    allColumns{length(allColumns)+1} = text;
                    cCol{length(cCol)+1} = text;
                    
                    %get the info match with 0.044438
                elseif isempty(text)
                    %                     numberIdx = [numberIdx i];
                    %                     allColumns{length(allColumns)+1} = 'GsdFreq';
                    
                elseif strcmpi(text, 'Sample Name')
                    cCol{i} = text;
                    columnTextIdx = [columnTextIdx i];
                    allColumns{length(allColumns)+1} = 'Sample Name';
                else
                    
                    allColumns{length(allColumns)+1} = 'Result Between User Sizes (Sizes in um)';
                end
                
            end
            
            %             cCol{length(cCol)+1} = 'd';
            %             cCol{length(cCol)+1} = 'D';
            %             cCol{length(cCol)+1} = 'Result';
            %             cCol{length(cCol)+1} = 'Result number';
            %             cCol{length(cCol)+1} = 'GsdFreq';
            
            
            if onlyDisplay%just to see in the web interface
                mData =str2double(data);
            else
                mData = data;
                cCol = allColumns;
            end
            
            
        end
        
        function [mData,cMetaData,cColumns] = readImdcOldFormat(strFile, nNrOfLines)
            % This job reads any file in IMDC format (irrespective of the number of
            % headerlines and datacolumns, and returns information from the header
            %
            % INPUTS:-strFile: a string with the path and name of the text file to be
            %read.
            %        -nNrOfLines (optional): the number of lines that should be read;
            %        If only the header is needed, set to zero.
            % OUTPUTS:-mData: A Matrix with the dat afrom the file
            %         -cMetaData, a Nx2 cell array, containing in the first column the name of the metadatafield and
            %         the second column, the corresponding metadatavalue.
            %         -cColumns: a cell array containing the names of the column
            %         variables.
            
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: Alexander Breugem
            % Date: May 2008
            % Modified by: ABR
            % Date: Sep 2008 Toegevoegd dat ook Nederlands IMDC files gelezen kunnen worden.
            % Modified by: ABR
            % Date: May 2009 De optionele nNrofLines is toegevoegd om files
            % gedeeltelijk te kunne inlezen.
            % Date: June 2009 Bugfix, nu kunnen ook files zonder data (waarbij lege
            % variabele mdata wordt teruggegeven) ingelzen worden.
            
            fid = fopen(strFile,'r');
            if nargin ==1
                bReadPartial = 0;
            else
                bReadPartial = 1;
            end;
            
            if fid< 0
                strError = [strFile, ' cannot be read.'];
                errordlg(strError);
                return;
            end;
            nI               = 1;
            nMetadata        = 1;
            nMetadataContent = 1;
            nColumns         = 1;
            bDoorgaan        = 1;
            %nData           = 1;
            cMetaData        = {};
            cColumns         = {};
            vData            = [];
            while bDoorgaan
                %nPos = ftell(fid);%positie onthouden
                strLine = fgetl(fid);
                if (strLine ==-1) %end of file
                    bDoorgaan = 0;
                else
                    if isempty(strLine)
                        strLine=' ';
                    end;
                    if strLine(1)=='*' % comment lines
                        nI=nI+1;
                        if ~isempty(strfind(strLine,'Column'))|~isempty(strfind(strLine,'Kolom'))
                            nLinePosition = strfind(strLine,':');
                            cColumns{nColumns} = strLine(nLinePosition+2:end);
                            strColmax = regexp(strLine,'(?<=((Column)\s*\d*[-]))\d*','match');
                            if ~isempty(strColmax)
                                nColumns = str2double(strColmax)+1;
                            else
                                nColumns = nColumns+1;
                            end;
                            
                        end;
                        if ~isempty(strfind(strLine,'Line'))|~isempty(strfind(strLine,'Lijn'))
                            nLinePosition = strfind(strLine,':');
                            cMetaData{nMetadata,1} = strLine(nLinePosition+2:end);
                            nMetadata = nMetadata+1;
                        end;
                    else
                        if nMetadataContent<nMetadata
                            cMetaData{nMetadataContent,2}=strLine;
                            nMetadataContent = nMetadataContent+1;
                        else
                            strFormat='';
                            for nJ=1:nColumns-1
                                strFormat = [strFormat,'%f '];
                            end;
                            %fseek(fid,nPos,'bof');
                            vData=sscanf(strLine,strFormat);
                            bDoorgaan = 0;
                        end;
                    end
                end;
            end;
            if ~isempty(vData)
                if bReadPartial
                    if (nNrOfLines>1)
                        cData = textscan(fid,strFormat,nNrOfLines-1);
                        for nI = 1:length(cData)
                            mData(:,nI)=cData{nI};
                        end;
                    else
                        mData = [];
                    end;
                else
                    cData = textscan(fid,strFormat);
                    for nI = 1:length(cData)
                        mData(:,nI)=cData{nI};
                    end;
                end;
            else
                mData = [];
            end;
            
            fclose(fid);
            
            if bReadPartial && (nNrOfLines==0)
                mData = [];
            else
                mData = [vData';mData];
            end;
            
            if (nColumns-1) ~= size(vData,1) %size(mData,2)
                %disp(['warning: the number of columns in the data(',num2str(size(mData,2)),') is not equal to the number of columns indicated in the header(',num2str(nColumns-1),')!']);
                disp(['warning: the number of columns in the data(',num2str(size(vData,1)),') is not equal to the number of columns indicated in the header(',num2str(nColumns-1),')!']);
            end;
            
            %verwijderen foute data
            mData(mData<=-999)=nan;
        end;
        
        function [mData,cMeta,cCol] = readImdcStandardFormat(fileName, colsOrder)
            %read an IMDC standard format in .mat
            %colsOrder is a Cell array optional with the name of the fields
            %that the user wants to export, They will be export this order.
            try
                if isempty(fileName)
                    errordlg('You have to set the file name.');
                    return;
                end;
                
                [~,~,ext] = fileparts(fileName);
                if ~strcmp(lower(ext), '.mat')
                    errordlg('The file extension is invalid.');
                    return;
                end;
                
                [dataset loadOk] = Dataset.loadData(fileName,0);
                if ~loadOk
                    errordlg('Error to read the source file. Please verify the format.');
                    return;
                end;
                dataset = Dataset.addFields(dataset, false);
                
                fieldsDataset = fieldnames(dataset);
                mData = [];
                cCol  = {};
                cMeta = {};
                cont  = 1;
                for i=1:length(fieldsDataset)
                    field = fieldsDataset{i};
                    %if is a variable
                    if isfield(dataset.(field), 'data')
                        %Add the data to mData matrix
                        %TODO: improve the method to repmat the data - ask to
                        %Alex
                        sizeData = size(mData);
                        sizeNewField = size(dataset.(field).data);
                        
                        %To sort columns
                        if nargin == 2 && ~isempty(colsOrder)
                            newSizeData = size(mData);
                            if newSizeData(2) > 0
                                idxStart = newSizeData(2);
                                idxEnd   = sizeNewField(2);
                                dataset.(field).orderIndex = [idxStart+1 idxStart+idxEnd];
                            else
                                idxEnd = sizeNewField(2);
                                dataset.(field).orderIndex = [1 idxEnd];
                            end;
                            
                            if sizeData(1) > sizeNewField(1)
                                dataReplicated = dataset.(field).data;
                                dataReplicated(sizeNewField+1:sizeData(1),:) = NaN;
                                mData = [mData dataReplicated];
                            else
                                mData = [mData dataset.(field).data];
                            end;
                        else
                            if sizeData(1) > sizeNewField(1)
                                dataReplicated = dataset.(field).data;
                                dataReplicated(sizeNewField+1:sizeData(1),:) = NaN;
                                mData = [mData dataReplicated];
                            else
                                mData = [mData dataset.(field).data];
                            end;
                        end
                        
                        newSizeData = size(mData);
                        
                        %get the column text with the unit
                        textCol = [dataset.(field).longname ' [' dataset.(field).unit ']'];
                        if sizeNewField(2) > 2
                            %get the column text with the unit
                            if isfield(dataset, 'Z')
                                %replicate the text according to the number of columns
                                %in the file
                                repeatedColsName = repmat(cellstr(textCol), 1, sizeNewField(2));
                                for ii=1:length(repeatedColsName)
                                    textColWithZ{ii} = [repeatedColsName{ii} ' at ' num2str(dataset.Z.data(ii,1))];
                                end;
                                cCol = [cCol textColWithZ];
                            else
                                textCol = [dataset.(field).longname ' [' dataset.(field).unit ']'];
                                cCol = [cCol repmat(cellstr(textCol), 1, sizeNewField(2))];
                            end;
                            
                        else
                            cCol = [cCol repmat(cellstr(textCol), 1, sizeNewField(2))];
                        end;
                        
                        
                    else
                        %if is metadata
                        %the metadata should have longname and value fields
                        dataset.(field) = Util.setDefault(dataset.(field),'longname','');
                        cMeta{cont,1}   = dataset.(field).longname;
                        %if there is not longname set the short name;
                        if isempty(cMeta{cont,1})
                            cMeta{cont,1} = (field);
                        end;
                        dataset.(field) = Util.setDefault(dataset.(field),'value','');
                        cMeta{cont,2}   = dataset.(field).value;
                        cont = cont + 1;
                    end;
                end;
                
                %if the user wants an specific order.
                if nargin == 2 && ~isempty(colsOrder)
                    sortedData = [];
                    newColsNames = {};
                    for i=1:length(colsOrder)
                        for j=1:length(fieldsDataset)
                            field = fieldsDataset{j};
                            if strcmpi(colsOrder{i},field)
                                sortedData = [sortedData mData(:,dataset.(field).orderIndex(1):dataset.(field).orderIndex(2))];
                                timesColName = dataset.(field).orderIndex(2) - dataset.(field).orderIndex(1);
                                newColsNames = [newColsNames repmat(cellstr(dataset.(field).longname), 1, timesColName+1)];
                                break;
                            end;
                        end;
                    end;
                    clear mData;
                    clear cCol;
                    mData = sortedData;
                    cCol  = newColsNames;
                end;
                
            catch
                sct = lasterror;
                errordlg(['Error. The file in IMDC Standard format could not be readed. ' sct.message]);
                return;
            end;
        end;
        
        function [mData, cMeta, cCol] = readJme(strFile,nNrLines)
            % This job reads data from an CSV file (.csv) format and returns the values
            % and the headers  in the file. I
            %
            % INPUTS:-strFile: a string containing the path and filename of the
            %                  datafile. THis file has the following format: the first line contains the header, describing for EACH COLUMN the data that is inside this file. The second line gives for EACH COLUMN the unit for this data. Aftwerwards follow the data columns. It can
            %                  easily be generated and manipulated in excel. Note that
            %                  either commas or semicolumns can be used to separate the
            %                  columns. The program will decide which one is used based
            %                  on the number of semicolons and commas (the largest
            %                  occuring number is supposed to be the columns
            %                  separator). The first column is expected to contain the
            %                  date and time in the format dd/mm/yyyy hh:mm:ss
            %         -nNrLines (optional): the number of lines that must be read
            %
            % OUTPUTS: - mData: a matrix with the data (containing the time in IMDC
            %                   format)
            %          - cCol: a cell string with the headers of the appropriate data
            %          as read from the file
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: September 2009
            % Modified by:
            % Date:
            
            %openen file
            
            fid = fopen(strFile);
            if fid<0
                error(['Error opening file',strFile]);
            end;
            
            %reading and parsing header
            
            strHeader = fgetl(fid);
            nNrSemi   = length(strfind(strHeader,';'));
            nNrCom    = length(strfind(strHeader,','));
            if nNrCom> nNrSemi
                strTok = ',';
                nNrCel = nNrCom+1;
            else
                strTok = ';';
                nNrCel = nNrSemi+1;
            end;
            
            vToks = [0, strfind(strHeader,strTok), length(strHeader)];
            %units
            strHeaderUnits=fgetl(fid);
            vToksUnits = [0, strfind(strHeaderUnits,strTok), length(strHeaderUnits)];
            cCol{1} = 'Date [yyyymmdd]';
            for nI = 1:nNrCel-1
                cCol{nI+1} = [strHeader(vToks(nI)+1:vToks(nI+1)-1),' [',strHeaderUnits(vToksUnits(nI)+1:vToksUnits(nI+1)-1),']'];
            end;
            %laatste kolom heeft geen token aan het eind!
            nI=nI+1;
            cCol{nI+1} = [strHeader(vToks(nI)+1:vToks(nI+1)-1),' [',strHeaderUnits(vToksUnits(nI)+1:vToksUnits(nI+1)),']'];
            
            strFormat = ['%f/%f/%f %f:%f:%f ',repmat('%f ',1,nNrCel-1)];
            %lezen data
            switch nargin
                case 1
                    cData = textscan(fid,strFormat,'Delimiter',strTok);
                case 2
                    cData = textscan(fid,strFormat,nNrLines,'Delimiter',strTok);
                otherwise
                    error('Wrong number of input arguments');
            end;
            fclose(fid);
            
            mData = [cData{1}+cData{2}*1e2+cData{3}*1e4, cData{6}+cData{5}*1e2+cData{4}*1e4];
            cMeta = {};
            
            %controleren of alle kolommen even lang zijn en samenvoegen kolommen
            for nI = 7:length(cData)
                if length(cData{nI})==length(cData{1})
                    mData(:,nI-4)=cData{nI};
                else
                    error(['The number of data in the columns is different (',num2str(length(cData{nI})) ,' vs ',num2str(length(cData{1})),')! Check the data.']);
                end;
            end;
        end;
        
        function dataSet = Lisst(varargin)
            % This script reads data from LISST output file (type
            % 100X and 200X) and organize the data to new IMDC matlab data
            % structure
            %
            % eg:
            % dataSet = Import.Lisst(filename);
            % ASCII
            % or dataSet = Import.Lisst(filename, reductionFactor, type);
            %
            % or dataSet = Import.Lisst(filename, reductionFactor, type, RefYear);
            %
            % or dataSet = Import.Lisst(filename, type, RefYear, reductionFactor);
            % BINARY (only 200x)
            % or dataSet = Import.Lisst(filename, backgroundfile);
            % 
            % or dataSet = Import.Lisst(filename, backgroundfile, shape); 
            %
            % INPUTS: - filename: string of name or path from source LISST file
            %         - optional:
            %           * reductionFactor: a number of reduction factor of the path
            %           length  (default: 1);
            %           * RefYear: the year number of obtaining the data,
            %           only necessary for LISST-100x (eg: 2007);
            %           * type 100x: option A (default), B, C;
            %           * backgroundfile: backgroundfile (ext: *.BGT)
            %             only for binary data files
            %           * shape: 'spherical' or 'random' (default), only for binary files
            %
            % OUTPUTS: standardised IMDC data structure with parameter fields as described
            %          by IMDC.
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA (based ABR reading script of 100x)
            %
            % Date: 10/2017
            % Modified by:
            % Date:
            
            % defaults
            fileName = varargin{1};
            refYear = str2double(datestr(now,'yyyy'));
            reductionFactor = 1;
            type = 'B'; % only for 100x
            % binary input
            shape = 1; % default: 1 = random shapes model/ 0: spherical model 
            backgroundfile = '';
            sharpen = 1; % recommended by manual => no input parameter
            
            if length(varargin) > 1
                for i = 2:length(varargin)
                    if isnumeric(varargin{i})
                        if varargin{i} > 1900
                            refYear = varargin{i};
                        else
                            reductionFactor = varargin{i};
                        end
                    else
                        [x, x, ext] = fileparts(varargin{i}); 
                        if strcmpi(shape,'spherical')
                            shape = 0;
                        elseif strcmpi(ext,'.bgt');
                            backgroundfile = varargin{i};
                        else 
                           type = varargin{i}; 
                        end
                    end
                end
            end

            % some metadata
            dataSet = Dataset.createDataset(1);
            dataSet.metaData.source = fileName;
            dataSet.metaData.sourceBackgrnd = backgroundfile;
            dataSet.metaData.sourceBackgrnd = backgroundfile;
            if shape
                dataSet.metaData.usedShape = 'random';
            else
                dataSet.metaData.usedShape = 'spherical';
            end
            dataSet.metaData.usedSharpen = 1;
            
            % parameters for all the LISST types
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Time');
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Depth');
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Temp');
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Battery');
            dataSet.AbsPres.unit = 'm';
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'SedConcVol');
            dataSet.SedConcVol.longname = 'Volume concentration';
            dataSet.SedConcVol.unit = 'µL/L';
            dataSet.SedConcVol.dim = {'T','dp'};
            dataSet.SedConcVol.equation = 'y = a*x';
            dataSet.SedConcVol.x = 'volume concentration';
            dataSet.SedConcVol.a = 'reduction factor';
            dataSet.SedConcVol.parameters = reductionFactor;
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDcum');
            dataSet.PSDcum.longname = 'Cummulative Particle Size Distribution';
            dataSet.PSDcum.unit = '%';
            dataSet.PSDcum.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD');
            dataSet.PSD.longname = 'Particle Size Distribution';
            dataSet.PSD.unit = '%';
            dataSet.PSD.dim = {'T','dp'};
                      
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'LaserTrans');
            dataSet.LaserTrans.longname = 'Laser transmission sensor';
            dataSet.LaserTrans.unit = 'mW';
            dataSet.LaserTrans.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Ext1');
            dataSet.Ext1.longname = 'External analog input 1';
            dataSet.Ext1.unit = 'V';
            dataSet.Ext1.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'LaserRef');
            dataSet.LaserRef.longname = 'Laser reference sensor';
            dataSet.LaserRef.unit = 'mW';
            dataSet.LaserRef.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'OptTrans');
            dataSet.OptTrans.longname = 'Computed optical transmission over path';
            dataSet.OptTrans.unit = '-';
            dataSet.OptTrans.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'BmAtten');
            dataSet.BmAtten.longname = 'Beam attenuation (c)';
            dataSet.BmAtten.unit = '1/m';
            dataSet.BmAtten.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'ParticleSize');
            dataSet.ParticleSize.longname = 'Particle Size Diameter (midpoints)';
            dataSet.ParticleSize.unit = 'µm';
            dataSet.ParticleSize.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'ParticleSizeBin');
            dataSet.ParticleSizeBin.longname = 'Particle Size Diameter (bins)';
            dataSet.ParticleSizeBin.unit = 'µm';
            dataSet.ParticleSizeBin.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Ext2');
            dataSet.Ext2.longname = 'External analog input 2';
            dataSet.Ext2.unit = 'V';
            dataSet.Ext2.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDmean');
            dataSet.PSDmean.longname = 'Geometric Mean Particle size diameter';
            dataSet.PSDmean.unit = 'µm';
            dataSet.PSDmean.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDD32');
            dataSet.PSDD32.longname = 'Estimated Sauter mean Particle size diameter';
            dataSet.PSDD32.unit = 'µm';
            dataSet.PSDD32.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDD43');
            dataSet.PSDD43.longname = 'Estimated volume weighted mean Particle size diameter';
            dataSet.PSDD43.unit = 'µm';
            dataSet.PSDD43.dim = {'T','dp'};
                                 
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDstd');
            dataSet.PSDstd.longname = 'Geometric standard deviation of Particle size distribution';
            dataSet.PSDstd.unit = 'µm';
            dataSet.PSDstd.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDskewness');
            dataSet.PSDskewness.longname = 'Geometric skewness of Particle size distribution';
            dataSet.PSDskewness.unit = 'µm';
            dataSet.PSDskewness.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSDkurtosis');
            dataSet.PSDkurtosis.longname = 'Kurtosis of Particle size distribution';
            dataSet.PSDkurtosis.unit = 'µm';
            dataSet.PSDkurtosis.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD50');
            dataSet.PSD50.longname = 'Median of Particle size distribution';
            dataSet.PSD50.unit = 'µm';
            dataSet.PSD50.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD10');
            dataSet.PSD10.longname = '10%-percentile of the Particle size distribution';
            dataSet.PSD10.unit = 'µm';
            dataSet.PSD10.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD90');
            dataSet.PSD90.longname = '90%-percentile of the Particle size distribution';
            dataSet.PSD90.unit = 'µm';
            dataSet.PSD90.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD20');
            dataSet.PSD20.longname = '20%-percentile of the Particle size distribution';
            dataSet.PSD20.unit = 'µm';
            dataSet.PSD20.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'PSD80');
            dataSet.PSD80.longname = '80%-percentile of the Particle size distribution';
            dataSet.PSD80.unit = 'µm';
            dataSet.PSD80.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'VolConcTot');
            dataSet.VolConcTot.longname = 'Total Volume Concentration';
            dataSet.VolConcTot.unit = 'ppm';
            dataSet.VolConcTot.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Humidity');
            dataSet.Humidity.longname = 'Relative Humidity';
            dataSet.Humidity.unit = '%';
            dataSet.Humidity.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Acceleration');
            dataSet.Acceleration.longname = 'Accelerometer X, Y, Z [not calibrated]';
            dataSet.Acceleration.unit = 'counts';
            dataSet.Acceleration.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'AmbLight');
            dataSet.AmbLight.longname = 'Ambient Light [not calibrated]';
            dataSet.AmbLight.unit = 'counts';
            dataSet.AmbLight.dim = {'T','dp'};
            
            %% binary format
            [x x ext] = fileparts(fileName);
            if strcmpi(ext,'.rbn') % data format LISST-200x
                if isempty(backgroundfile)
                    data = getscat_L200X(fileName);
                else
                    data = getscat_L200X(fileName,backgroundfile);
                end
                [dataSet.SedConcVol.data, dataSet.ParticleSize.data] = invert_L200X(data.cscat,shape,sharpen,0); %
                dataSet.metaData.instrument = 'LISST-200x';
                
                dataSet.Time.data = data.date;
                dataSet.SedConcVol.data = reductionFactor.*dataSet.SedConcVol.data;
                dataSet.LaserTrans.data = data.Lp;
                dataSet.Battery.data = data.supplyVolts;
                dataSet.Ext1.data = data.analog1;
                dataSet.LaserRef.data = data.Lref;
                dataSet.Depth.data = data.depth;
                dataSet.Temp.data = data.temperature;
                dataSet.OptTrans.data = data.transmission;
                dataSet.BmAtten.data = data.cscat;
                dataSet.Ext2.data = data.analog2;            
                dataSet.PSDmean.data = data.estMeanDiameter;
                dataSet.VolConcTot.data = data.estTotalConc;
                dataSet.Humidity.data = data.humidity;
                dataSet.Acceleration.data = data.accelXYZ;
                dataSet.AmbLight.data = data.ambientLight;
            else
                %% ASCII-data format
                % select LISST type and format if ascii
                colLISST = [61,42,43];
                try
                    fid      = fopen(fileName);
                    firstline = fgetl(fid);
                    fclose(fid);
                    
                    str = {',',';','\t',' '}';
                    
                    for iD = 1:length(str)
                        cfirstline = regexpi(firstline,['[',str{iD},']'],'split');
                        if sum(colLISST == size(cfirstline,2)) > 0
                            delimiter = str{iD};
                            columnnumber = size(cfirstline,2);
                        end
                    end
                    % delimiter
                catch
                    error('Error. The lisst file could not be readed');
                end
                
                %open file and read contents
                try
                    fid      = fopen(fileName);
                    format   = repmat('%f ',1,columnnumber);
                    cellData = textscan(fid,format,'delimiter',delimiter);
                    data     = cell2mat(cellData);
                    fclose(fid);
                catch
                    error('Error. The file could not be readed');
                end
                
                if columnnumber == 43 && sum(isnan(data(:,43))) == size(data,1)
                    data(:,43) = [];
                end
                
                switch size(data,2)
                    case 61 % LISST 200x
                        dataSet.metaData.instrument = 'LISST-200x';
                        
                        dataSet.Time.data = datenum(data(:,43:48));
                        dataSet.SedConcVol.data = reductionFactor.*data(:,1:36);
                        dataSet.LaserTrans.data = data(:,37);
                        dataSet.Battery.data = data(:,38);
                        dataSet.Ext1.data = data(:,39);
                        dataSet.LaserRef.data = data(:,40);
                        dataSet.Depth.data = data(:,41);
                        dataSet.Temp.data = data(:,42);
                        dataSet.OptTrans.data = data(:,60);
                        dataSet.BmAtten.data = data(:,61);
                                              
                        dataSet.Ext2.data = data(:,49);
                        dataSet.Dmean.data = data(:,50);       
                        dataSet.VolConcTot.data = data(:,51);
                        dataSet.Humidity.data = data(:,52);
                        dataSet.Acceleration.data = data(:,53:55);
                        dataSet.AmbLight.data = data(:,58);
                        
                    case 42 %LISST 100x
                        dataSet.metaData.instrument = ['LISST-100x Type ', type];
                        if isempty(refYear)
                            errordlg('Error. You have to set a reference year');
                            return;
                        end
                        
                        day     = floor(data(:,39)/100);
                        hour    = data(:,39)-100*day;
                        minutes = floor(data(:,40)/100);
                        seconds = data(:,40)-100*minutes;
                        
                        % add data to dataset
                        sizeDay = size(day);
                        
                        dataSet.Time.data = datenum([repmat(refYear,sizeDay),zeros(sizeDay),day,hour,minutes,seconds]);
                        dataSet.SedConcVol.data = reductionFactor.*data(:,1:32);
                        dataSet.LaserTrans.data = data(:,33);
                        dataSet.Battery.data = data(:,34);
                        dataSet.Ext1.data = data(:,35);
                        dataSet.LaserRef.data = data(:,36);
                        dataSet.Depth.data = data(:,37);
                        dataSet.Temp.data = data(:,38);
                        dataSet.OptTrans.data = data(:,41);
                        dataSet.BmAtten.data = data(:,42);
                        
                        
                        dataSet.Ext2.data = [];
                        dataSet.Dmean.data = [];       
                        dataSet.VolConcTot.data = [];
                        dataSet.Humidity.data = [];
                        dataSet.Acceleration.data = [];
                        dataSet.AmbLight.data = [];
                       
                end                  
            end
            
            % get the midpoints of the bins
            if strcmpi(dataSet.metaData.instrument, 'LISST-200x')
                type = '200';
            end
            [dataSet.ParticleSize.data, tempUp, tempLow, x] = get_lisst_bins(type, shape); % only the midpoints
            
            % get the cummulative distribution function
            dataSet.ParticleSizeBin.data = unique([tempUp; tempLow])';
            dataSet.PSD.data = dataSet.SedConcVol.data./repmat(sum(dataSet.SedConcVol.data, 2),1,size(dataSet.SedConcVol.data,2)).*100;
            dataSet.PSDcum.data = cumsum(dataSet.PSD.data,2,'omitnan');
            
            % some statistics;
            sctTmp = Statistics.quickStatisticsPsd(dataSet.ParticleSizeBin.data/1000, dataSet.PSD.data, 'volume','geometric_seq');% let op conversion from µm to mm;
            dataSet.PSDmean.data = sctTmp.mean.data*1000; 
            dataSet.PSDD32.data = sctTmp.meanD32.data*1000;
            dataSet.PSDD43.data = sctTmp.meanD43.data*1000;
            dataSet.PSDstd.data = sctTmp.std.data*1000;
            dataSet.PSDskewness.data = sctTmp.skew.data;
            dataSet.PSDkurtosis.data = sctTmp.kurt.data;
            dataSet.PSD50.data = sctTmp.d50.data*1000;
            dataSet.PSD10.data = sctTmp.d10.data*1000;
            dataSet.PSD90.data = sctTmp.d90.data*1000;
            dataSet.PSD80.data = sctTmp.d80.data*1000;
            dataSet.PSD20.data = sctTmp.d20.data*1000;
            
        end
        
        function nDat = readMultibit(fid,nBit)
            %functie die een waarde oevr meerdere bits direct inleest en converteert naar een decimaal getal (integer)
            vDat  = fread(fid, nBit, 'uint8')';
            vHulp = fliplr(2.^((0:nBit-1)*8));
            nDat  = sum(vDat.*vHulp);
        end
        
        function [mData,cMeta,cCol] = readObs(strFile,nNrLines)
            % This job reads data from an OBS file (.dat) format and returns the values
            % and the headers and metadata in the file. In has been tested with an
            % example of a ong term filewith  and withourt waves, as well as with a
            % file obtained fromservey mode (OBS is connected to serial port during
            % measurement).
            %
            % INPUTS:-strFile: a string containing the path and filename of the
            %                  datafile
            %         -nNrLines (optional): the number of lines that must be read
            %
            % OUTPUTS: - mData: a matrix with the data (containing the time in IMDC
            %                   format)
            %          - cCol: a cell string with the headers of the appropriate data
            %          as read from the file: WARNING: THESE FILES ARE KNOWN TO CONTAIN
            %          FAULTY HEADERS (ESPECIALLY WHEN SALINITY IS INVOLVED). ALWAYS
            %          CHECK MANUALLY!
            %          - cMeta: a cell string containing the metadata (instrument type
            %          and serial number)
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: July 2009
            % Modified by:
            % Date:
            
            %openen file
            
            fid = fopen(strFile);
            if fid <=0
                error(['File ',strFile,' cannot be opened. check whether the file exists or is read or write protected.'])
            end;
            
            % inlezen header
            strData = fgetl(fid);
            while isempty(strData)
                strData = fgetl(fid);
            end;
            
            if strfind(strData,'#')
                bLongTerm = 1;
                %formaat voor langdurige metingen
                [strInstr,strOther] = strtok(strData);
                [strSerial] = strtok(strOther);
                strSerial   = strSerial(2:end);
                cMeta{1,1}  = 'Instrument';
                cMeta{1,2}  = strInstr;
                cMeta{2,1}  = 'Serial number';
                cMeta{2,2}  = strSerial;
            else
                cMeta = {};
                bLongTerm = 0;
            end;
            
            
            %inlezen regel met  'columns'
            strData = fgetl(fid);
            %inlezen
            nI = 1;
            while ~isempty(strData) && (isempty(strfind(strData,':')))
                nPosInd = ftell(fid);
                strData = fgetl(fid);
                bGo = 1;
                strRest = strData;
                while bGo
                    [strPart,strRest]=strtok(strRest,',');
                    bGo = ~isempty(strRest);
                    if ~isempty(regexp(strPart,'OBS','ignorecase'))
                        cCol{nI}='Turbidity [NTU]';
                    elseif ~isempty(regexp(strPart,'depth','ignorecase'))
                        cCol{nI}='Depth [m]';
                    elseif ~isempty(regexp(strPart,'conductivity','ignorecase'))
                        cCol{nI}='Conductivity [mS/cm]';
                    elseif ~isempty(regexp(strPart,'sal','ignorecase'))
                        cCol{nI}='Calculated Salinity by the instrument [psu]';
                    elseif ~isempty(regexp(strPart,'temperature','ignorecase'))
                        cCol{nI}='Temperature [Â°C]';
                    elseif ~isempty(regexp(strPart,'battery','ignorecase'))
                        cCol{nI}='Battery [V]';
                    else
                        cCol{nI} = strPart;
                    end
                    nI = nI+1;
                end;
            end;
            cCol(nI-1)=[];
            
            if bLongTerm
                strFormat = ['%f:%f:%f %f/%f/%f ', repmat('%f ',1,nI-2)];
                nNrCols   = nI-2;
            else
                strFormat = ['%f:%f:%f %f/%f/%f ', repmat('%f ',1,nI-2)];
                fseek(fid,nPosInd,-1);%terugzetten file naar begin van de regel
                nNrCols = nI-2;
            end;
            
            
            % inlezen data
            if (nargin == 2)
                cData = textscan(fid,strFormat,nNrLines);
            else
                cData = textscan(fid,strFormat);
            end;
            
            % sluiten file
            fclose(fid);
            
            % controleren of eerste kolom even lang is als de andere, anders aanpassen
            
            if length(cData{2})~=length(cData{1})
                cData{1} = cData{1}(1:length(cData{2}));
            end;
            
            %berekenen tijd uit file
            vTime = datenum([cData{6},cData{4},cData{5},cData{1},cData{2},cData{3}]);
            mTime = Time.num2DateTime(vTime);
            
            %samenvoegen data in IMDC formaat
            mData = mTime;
            for nJ = 1:nNrCols
                %,cData{7},cData{8},cData{9},cData{10},cData{11},cData{12}];
                mData = [mData,cData{nJ+6}];
            end;
            %invoegend tijd in metadata
            cCol = ['Date [yyyyhhdd]','Time [hhmmss]',cCol];
            
            % verwijderen niet chronologsiche data
            vIndexWrong = find((diff(vTime)<0),1,'first');
            if ~isempty(vIndexWrong)
                mData = mData(1:vIndexWrong,:);
            end;
            
        end;
        
        function [mData,cColumns] = readRBR(strFile)
            % Reads an RBR file
            %  [mData,cColumns] = readRDR(strFile)
            %
            % #INPUTS:
            % XstrFile
            %           -
            % #OUTPUTS:
            % mData: a matrix with data
            % cMetaData: metadata from the file
            % cColumns: cell array with column hedaers
            %
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: ABR
            % Date: 26-7-2012
            % Modified by:
            % Date:
            
            % open file to read
            fid = fopen(strFile);
            if fid<0
                error(['File ', strFile,' cannot be opened']);
            end;
            
            % read header and trow away the results
            bGo = 1;
            while bGo
                strLine = fgetl(fid);
                if  ~isempty(strfind(strLine,'Generic')) && ...
                        ~isempty(strfind(strLine,'Temp')) && ...
                        ~isempty(strfind(strLine,'Cond')) && ...
                        ~isempty(strfind(strLine,'Pres'))
                    bGo = 0;
                end;
            end;
            
            % Read the data in the following format yymmddhhmmss
            %TIM 120417075435 $C0.0P-12.4R50.0T12.3E002*7D  :   10.7298 10.4681 -0.0000 0.0960 FET
            strf     = 'TIM %f %s : %f %f %f %f FET';
            bGo      = 1;
            cAllData = {};
            while bGo
                cData = textscan(fid,strf);
                % correct data for not reading correctly
                [cData,bGo] = Util.adaptData(cData([1 3:6]));
                cAllData    = Util.addData(cData,cAllData);
                if isempty(cAllData{1})
                    bGo = 1;
                end;
                if bGo
                    strLine=fgetl(fid);
                    if isempty(strfind(strLine,'TIM'))
                        warning(['Your inputfile has not the right dataformat! Check line: ' num2str(cData{1,1} (end))]);
                        error('Your inputfile has not the right dataformat! Check the format.');
                    end
                end;
            end;
            
            % close the file
            fclose (fid);
            
            mData = cell2mat(cAllData);
            
            % convert time format
            [yymmdd, hhmmss] = Calculate.round2integer(mData(:,1),1e6);
            
            yymmdd = yymmdd./1e6+2e7;
            mData  = [yymmdd,hhmmss,mData(:,2:end)];
            
            % add metadata
            cColumns = {'date [yyyymmdd]','time[mmddss]','Temp [C]','Absolute Pressure [dbar]','Cond [mS/cm]','Turbidity [NTU]'};
        end;
        
        function sctData = readSiltProfilerBin(strFile,sctChannels)
            % This function read a binary SiltProfilerFile and Applies a calibration ()
            %
            %
            % INPUTS:-strFile: the file name of the bin file
            %        -sctChannels: a struct with the calibration parameters. This is output from Script_ReadSiltProfilerIni
            %
            % OUTPUTS:-
            % sctData.strVersion
            % sctData.nNrSensors
            % sctData.nSamplInt
            % sctData.nTime
            % sctData.nPres
            % sctData.mData
            % sctData.cHeader
            % sctData.nTimeDown
            
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: Okt 2009
            % Modified by: JCA (add download time)
            % Date: 4/01/2012
            
            %openen binaire file
            fid = fopen(strFile);
            if fid <0
                error(['File ',strFile,' cannot be opened!']);
            end;
            % inlezen download tijd op basis van filename (PC-tijd)
            cNumbers = regexp(strFile,'[0-9]','match');
            for ic=1:length(cNumbers)
                cNumbers{ic}=str2num(cNumbers{ic});
            end
            if ~isempty(cNumbers)
                if length(cNumbers)>=12
                    sctData.nTimeDown=datenum([2000+cNumbers{end-11}*10+cNumbers{end-10},cNumbers{end-9}*10+cNumbers{end-8},...
                        cNumbers{end-7}*10+cNumbers{end-6},cNumbers{end-5}*10+cNumbers{end-4},cNumbers{end-3}*10+cNumbers{end-2},cNumbers{end-1}*10+cNumbers{end}]);
                end
            end
            %inlezen header
            
            sctData.nNrSensors = double(fread(fid,1));
            nDum               = fread(fid,1);
            sctData.strVersion = fread(fid, 5, 'uint8=>char')';
            nNrRows            = Import.readMultibit(fid,4);%(fread(fid, 4, 'uint8'));
            sctData.nSamplInt  = Import.readMultibit(fid,2)/1000; %incl conversie naar seconds
            nYY = double(fread(fid,1));
            nMM = double(fread(fid,1));
            nDD = double(fread(fid,1));
            nHh = double(fread(fid,1));
            nDd = double(fread(fid,1));
            nSs = double(fread(fid,1));
            sctData.nTime = datenum([2e3+nYY nMM nDD nHh nDd nSs]); % in Matlab formaat
            
            sctData.nPres = Import.readMultibit(fid,2)/16;
            nDum          = fread(fid,11,'uint8=>char'); %fill characters
            %inlezen data
            nS = sctData.nNrSensors;
            
            mBinData = fread(fid, [2*nS,nNrRows])'; %inlezen alle datakolommen
            vBits    = [2^8 1];
            
            if size(mBinData,1)~= nNrRows
                nNrRows = size(mBinData,1);
                warning(['Nr of rows in ',strFile,' does not agree with those in the  header!']);
            end;
            
            for nI = 1:nS %voor ieder kanaal
                %terugrekenen 16 bit data naar binaire getallen
                
                vData = sum(mBinData(:,2*(nI-1)+1:2*nI).*repmat(vBits,nNrRows,1),2)/16;
                
                %toepassen calibratie met data uit inifile
                if nargin >1
                    %toepassen barometrsiche correctie op de drukfile
                    if ~isempty(strfind(sctChannels(nI).Name,'press'))
                        vData = vData - sctData.nPres;
                    end;
                    %calibratie
                    vCalib = [sctChannels(nI).D, sctChannels(nI).C, sctChannels(nI).B, sctChannels(nI).A];
                    mData(:,nI)  =  polyval(vCalib,vData );
                    %toevoegen heading
                    cHeader{nI} =  [sctChannels(nI).Name,' [', sctChannels(nI).Unit,']'];
                else
                    mData(:,nI)  =vData;
                end;
            end;
            
            % sluiten binaire file
            fclose(fid);
            
            %toevoegen data an output data
            sctData.mData = mData;
            if nargin>1
                sctData.cHeader = cHeader;
            end;
        end;
        
        function sctChannels = readSiltProfilerIni(strFile)
            %This function read a SiltProfiler Ini file and extracts data from it
            %
            % INPUTS:-strFile: a string with the filename of the .ini file.
            %
            % OUTPUTS:- sctChannels: a vector of structs. Each struct represents a
            %channel. It has the following fields:
            %
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %% Written by: Alexander Breugem
            %
            % Date: Okt 2009
            % Modified by:
            % Date:
            
            %openen binaire file
            fid = fopen(strFile);
            if fid <0
                error(['File ',strFile,' cannot be opened!']);
            end;
            strChannel = '';
            bGo = 1;
            while bGo
                strLine = fgetl(fid);
                if ischar(strLine)
                    if ~isempty(strfind(strLine,'[Chan'))
                        strChannel = regexp(strLine,'(?<=([Chan))[\d]*','match');
                        nChannel = str2num(strChannel{1});
                        sctChannels(nChannel+1).nChannel = nChannel;
                    else
                        if ~isempty(strChannel)
                            [strTok,strRest] = strtok(strLine,'=');
                            switch strTok
                                case {'A','B','C','D'}
                                    sctChannels(nChannel+1).(strTok) = str2num(strRest(2:end));
                                case {'Name','Unit'}
                                    sctChannels(nChannel+1).(strTok) = strtrim(strRest(2:end));
                            end;
                        end;
                    end;
                else
                    bGo = 0;
                end;
                
            end;
            
            fclose(fid);
            
        end;
        
        function [stlData,name] = readStl(theFile)
            % reads ascii STL  (stereolitography) file
            %
            % [stlData,name] = readStl(theFile)
            %
            % INPUT: the File, string with the filename
            %
            % OUTPUT:stldata: structuire with the fields vertices (Nx3 array with
            % vertices) and facet (Mx3) array with triangles of the STL file. Here M is
            % the number of triangles and N the number of points (many of which
            % overlap). No effort is done to eliminate multiple points
            %        name
            %
            % Note in order to plot use:
            %
            % plot3(dv.vertices(:,1),dv.vertices(:,2),dv.vertices(:,3),'.')
            % patch(dv,'FaceColor',       [0.8 0.8 1.0],'EdgeColor',[1 1 1],'FaceLighting', 'gouraud', 'AmbientStrength', 0.15);camlight('headlight');material('dull');
            
            
            
            % preallocate
            vertex = zeros(100000,3);
            faces  = zeros(100000,3);
            
            % open file and read header
            fid = fopen(theFile);
            theLine = fgetl(fid);
            [theData,theName] = strtok(theLine);
            if strcmpi(theData,'solid')
                name = theName;
            else
                error('Unrecognized format');
            end
            
            % read data
            
            % solid DarthVaderHead
            % facet normal -0.478630477270305 -0.455257556648734 -0.750768555110178
            % outer loop
            % vertex 1670.82011264498 -1336.70510158196 3335.86603176086
            % vertex 1651.17247470552 -1358.03674525871 3361.3270745465
            % vertex 1620.83169101412 -1275.26418132439 3329.43415691344
            % endloop
            % endfacet
            
            i = 1;
            while theLine~=-1
                
                theLine = fgetl(fid); % facet normal
                theLine = fgetl(fid); % outer loop
                if theLine==-1
                    break;
                end
                % vertices
                theLine = fgetl(fid); %
                vertex(3*(i-1)+1,:)  = str2num(theLine(8:end));
                theLine = fgetl(fid); %
                vertex(3*(i-1)+2,:)  = str2num(theLine(8:end));
                theLine = fgetl(fid); %
                vertex(3*i,:)  = str2num(theLine(8:end));
                faces(i,:) = [3*(i-1)+1,3*(i-1)+2,3*i];
                i = i+1;
                theLine = fgetl(fid); % endloop
                theLine = fgetl(fid); % endfacet
            end
            
            stlData.vertices = vertex(1:3*(i-1),:);
            stlData.faces  = faces(1:i-1,:);
        end
        
        function [dataset] = readWISKI(strFile)
            %[dataset] = Import_readWISKI(strFile,nNrLines)
            % This job reads data from a WISKI-database from WL ('txt' file)
            %
            % INPUTS:-strFile: a string containing the path and filename of the
            %                  datafile.
            %
            % OUTPUTS: - dataset: the data in IMDC's standard dataset format
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: September 2009
            % Modified by: JCA (some extra metadata)
            % Date: August 2011
            % Modifid by: THL - rewrite to use IMDC dataset format and datenum format
            
            
            bGo = 1;
            %openen file
            
            fid = fopen(strFile);
            if fid<0
                error(['Error opening file',strFile]);
            end;
            
            %reading and parsing header
            cMeta=[];
            k=0;
            
            nEmptyValue={'---','-777'};
            while bGo
                strHeader=fgetl(fid);
                if  ~isempty(regexp(strHeader,'time','ignorecase')) & ~isempty(regexp(strHeader,'date','ignorecase'))
                    bGo = 0;
                else
                    cHeader=regexp(strHeader,'[,;:]','split');
                    cHeader(strcmpi(cHeader,'')==1)=[];
                    if size(cHeader,2)==2
                        cMeta=[cMeta;cHeader];
                    end
                end
            end
            cHeader=regexp(strHeader,'[,;\t]','split');
            if length(regexp(strHeader,'[,]','split')) > 1;
                strDelimiter = ',';
            elseif length(regexp(strHeader,'[;]','split')) > 1;
                strDelimiter = ';';
            elseif length(regexp(strHeader,'[\t]','split')) > 1;
                strDelimiter = '\t';
            end
            
            strFormat = repmat('%s ',size(cHeader));
            cData = textscan(fid,strFormat,'delimiter',strDelimiter);
            fclose(fid);
            
            iDate = find(strcmpi(cHeader,'date'));
            iTime = find(strcmpi(cHeader,'time'));
            
            
            vDate = datenum(cData{iDate},'dd/mm/yyyy');
            vTime = datenum(cData{iTime},'HH:MM:SS');
            vTime = vTime - floor(vTime);
            mTime = vDate + vTime;
            
            dataset.meta = cMeta;
            dataset.Time.data = mTime;
            
            for iH = 1:numel(cHeader);
                if iH == iDate || iH == iTime;
                    continue;
                end
                
                fn = strrep(cHeader{iH},' ','_');
                [a,b]=regexp(fn,'\[.*]');
                if ~isempty(a);
                    unit = fn(a+1:b-1);
                    fn = fn(1:a-2);
                    dataset.(fn).data = cData{:,iH};
                    dataset.(fn).unit = unit;
                else
                    dataset.(fn).data = cData{:,iH};
                end
                rn = randi(numel(dataset.(fn).data),20,1);
                nums = str2double(dataset.(fn).data(rn));
                if ~all(isnan(nums));
                    dataset.(fn).data = str2double(dataset.(fn).data);
                end
            end
            
        end
        
       function [mData,cColumns,cMetadata] = readDensX(strFile)
            % Reads a DENSX- CSV-output file
            %  [mData,cColumns] = readDensX(strFile)
            %
            % #INPUTS:
            % strFile
            %           -
            % #OUTPUTS:
            % mData: a matrix with data
            % cColumns: cell array with column headers
            
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: WIB
            % Date: 14-11-2018
            % Modified by:
            % Date:
            
            % open file to read
            fid = fopen(strFile);
            if fid<0
                error(['File ', strFile,' cannot be opened']);
            end;
            
            % read header
            
            strf  = '%s ';
            strN = 8;
            tmpColumns = {};
                tmpColumns = textscan(fid,strf,strN,'delimiter',',')';
                if isempty(strfind(tmpColumns{1,1}(1,1),'Name'))
                        warning(['Your inputfile has not the right dataformat! Check line: ' num2str(cData{1,1} (end))]);
                        error('Your inputfile has not the right dataformat! Check the format.');
                end;
                 
            % remove first two columns from the tmpColumns
            for i=3:length(tmpColumns{1})
                cColumns{i-2,1}=tmpColumns{1}{i};
            end
            
            % Read the data in the following format yymmddhhmmss
            % D O2.01,2018.10.22 10:32:46.546,-6.030569,982.8125,0,0,0
            %strf     = '%s %{yyyy.MM.dd hh:mm:ss.SSS}D %f %f %f %f%f';
            strf     = '%s %s %f %f %f %f%f';
            cAllData = {};

            cAllData = textscan(fid,strf,'delimiter',',');
            for i=length(cAllData{2}):-1:1
                tmpNum(i,1)   = datenum(cAllData{2}{i},'yyyy.mm.dd HH:MM:SS.fff');
            end
            cAllData{2} = datetime(tmpNum,'ConvertFrom','datenum');
            
            % correct data for not reading correctly
            [cAllData] = Util.adaptData(cAllData);
            
            if isempty(cAllData{1})
                    warning(['Your inputfile has not the right dataformat! Check format']);
                    error('Your inputfile has not the right dataformat! Check the format.');
            end;
            
            % close the file
            fclose (fid);
            % Fill first two columns with date and time % 2018.01.22 10:32:57.868

            cMetadata{1,1}= ['Profile Date'];
            cMetadata{1,2}=datestr(cAllData{1,2}(1),'yyyymmdd');
            
            cMetadata{2,1}= ['Profile Time (UTC)'];
            cMetadata{2,2}=datestr(cAllData{1,2}(1),'HHMMSS');

            cMetadata{3,1}= ['Matlab Time'];
            cMetadata{3,2}=datenum(cAllData{1,2}(1));
            
            mData=zeros(size(cAllData{1,2},1),size(cColumns,1));
           
            for i=3:size(cAllData,2)
                mData(:,i-2)= cAllData{:,i};
            end
            
       end
                     
       
             function [mData,cColumns] = readGPX(fileName)
            % Reads a GPX-file
            %  [mData,cColumns] = readgpx(strFile)
            %
            % #INPUTS:
            % strFile
            %           -
            % #OUTPUTS:
            % mData: a matrix with data
            % cColumns: cell array with column headers
            
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: WIB
            % Date: 07-01-2018
            % Modified by:
            % Date:
                       
            %Column identifiers
            COL_t   = 1; % time
            COL_LAT = 2; % latitude
            COL_LNG = 3; % longitude
            COL_ele = 4; % elevation
            
            cColumns={'time', 'Latitude', 'Longitude', 'Elevation'};
            
            d = xmlread(fileName);
            
            if ~strcmp(d.getDocumentElement.getTagName,'gpx')
                warning('loadgpx:formaterror','file is not in GPX format');
            end
                                 
            ptList = d.getElementsByTagName('trkpt');
            ptCt = ptList.getLength;
            
            mData = nan(ptCt,3);
            for i=1:ptCt
                pt = ptList.item(i-1);
                try
                    mData(i,COL_LAT) = str2double(pt.getAttribute('lat'));
                catch
                    warning('loadgpx:bad_latitude','Malformed latitutude in point %i.  (%s)',i,lasterr);
                end
                try
                    mData(i,COL_LNG) = str2double(pt.getAttribute('lon'));
                catch
                    warning('loadgpx:bad_longitude','Malformed longitude in point %i.  (%s)',i,lasterr);
                end
                
                ele = pt.getElementsByTagName('ele');
                if ele.getLength>0
                    try
                        mData(i,COL_ele) = str2double(ele.item(0).getTextContent);
                    catch
                        warning('loadgpx:bad_elevation','Malformed elevation in point %i.  (%s)',i,lasterr);
                    end
                end
                
                time = pt.getElementsByTagName('time');
                if time.getLength>0
                    try
                        timestr = cell(time.item(0).getTextContent);
                        mData(i,COL_t)=datenum([str2num(timestr{1,1}(1:4)) str2num(timestr{1,1}(6:7)) str2num(timestr{1,1}(9:10)) str2num(timestr{1,1}(12:13)) str2num(timestr{1,1}(15:16)) str2num(timestr{1,1}(18:19)) ]);
                    catch
                        warning('loadgpx:bad_time','Malformed time in point %i.  (%s)',i,lasterr);
                    end
                end
            end
            
             end
		     
            function dataSet = awac(fileName)
            % Reads a Awax CSV-output file
            %  [dataSet] = awac(strFile)
            %
            % #INPUTS:
            % strFile
            %           -
            % #OUTPUTS:
            % mData: a matrix with data
            % cColumns: cell array with column headers
            
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: JCA
            % Date: 06-08-2019
            % Modified by:
            % Date:
            
            % read data
            [data, header] = Import.readAscii(fileName,'delimiter',';');
            
            % some metadata
            dataSet = Dataset.createDataset(1);
            dataSet.metaData.source = fileName;
            dataSet.metaData.instrument = 'Nortek Awac';
            
            % parameters for the AWAC
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Time');
            mask = strcmpi(header, 'dateTime');
            dataSet.Time.data = datenum(data(:,mask),'dd/mm/yyyy HH:MM:SS');
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'WatPress');
            mask = strcmpi(header, 'pressure');
            dataSet.WatPress.data = cell2mat(data(:,mask));
                      
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Temp');
            mask = strcmpi(header, 'temperature');
            dataSet.Temp.data = cell2mat(data(:,mask));
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Battery');
            mask = strcmpi(header, 'battery');
            dataSet.Battery.data = cell2mat(data(:,mask));
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Vel');
            mask = cellfun(@(x) ~isempty(regexpi(x,'speed#')), header);
            dataSet.Vel.data = cell2mat(data(:,mask));
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'VelDir');
            mask = cellfun(@(x) ~isempty(regexpi(x,'dir#')), header);
            dataSet.VelDir.data = cell2mat(data(:,mask));
            
            mDepthBins = header(mask);
            for i = 1:length(mDepthBins)
                indNumber =regexpi(mDepthBins{i},'[(m]');
                mDepthBins{i} = str2double(mDepthBins{i}(indNumber(1)+1:indNumber(end)-1));
            end
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'DistBin');
            dataSet.DistBin.data     = cell2mat(mDepthBins);
            dataSet.DistBin.unit     = 'm';
            dataSet.DistBin.longname = 'Distance of the bins with respect to the device';
            dataSet.DistBin.dim      = {'z'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'VelX');
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'VelY');
            [dataSet.VelX.data, dataSet.VelY.data] = Calculate.calcXY(dataSet.Vel.data, dataSet.VelDir.data);

            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Heading');
            mask = strcmpi(header, 'heading');
            dataSet.Heading.data = cell2mat(data(:,mask));
            dataSet.Heading.longname = 'Heading reffered to the North';
            dataSet.Heading.unit = '°';
            dataSet.Heading.dim = {'T','dp'};
             
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Pitch');
            mask = strcmpi(header, 'pitch');
            dataSet.Pitch.data = cell2mat(data(:,mask));
            dataSet.Pitch.longname = 'Pitch';
            dataSet.Pitch.unit = '°';
            dataSet.Pitch.dim = {'T','dp'};
            
            dataSet = Dataset.addDefaultVariableFields(dataSet, 'Roll');
            mask = strcmpi(header, 'roll');
            dataSet.Roll.data = cell2mat(data(:,mask));
            dataSet.Roll.longname = 'Heading reffered to the North';
            dataSet.Roll.unit = '°';
            dataSet.Roll.dim = {'T','dp'};
            
            end
            
            function [data, header] = readAscii(varargin)
            % Reads a CSV ASCII file
            %  [dataSet] = awac(strFile)
            %
            % #INPUTS:
            % strFile
            %           -
            % #OUTPUTS:
            % data: a cell with data
            % header: cell array with column headers
            
            % #STEPS:
            % #KNOWN ISSUES:
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: JCA
            % Date: 06-08-2019
            % Modified by:
            % Date:
            fileName = varargin{1};
            %defaults
            delimiter = ',';
            headerlines = 1;
            header = {};
            heading = [];
            bHeader = true;
            if length(varargin) > 1
                for i = 2:length(varargin)
                    switch lower(varargin{i})
                        case 'delimiter'
                            delimiter = varargin{i+1};
                        case 'headerlines'
                            headerlines = varargin{i+1};
                        case 'heading'
                            heading = varargin{i+1};
                    end
                end
            end
            
             if headerlines == 0
                headerlines = 1;
                bHeader = false;
             end
            
            % check reading file
            fid = fopen(fileName);
            if fid<0
                error(['File ', fileName,' cannot be opened']);
            end
            % read header
            
            for i = 1:headerlines
                tmpHeader = fgetl(fid);
                tmpHeader = regexp(tmpHeader,delimiter,'split');
                if size(header,2) == size(tmpHeader,2)
                    header(i,:) = tmpHeader;
                else
                    header = [header;{tmpHeader}];
                end
            end
            if isempty(header{1,end})
               header(:,end) = []; 
            end
            if iscell(header{end,:})
                if isempty(heading)
                    nColumns = size(header{end,:}{1},2);
                else
                    nColumns = size(header{end,:}{heading},2);
                end
            else
                nColumns = size(header,2);
            end
            if ~bHeader
                fclose(fid);
                fid = fopen(fileName);
            end
             % read data
            format = repmat('%s',1,nColumns);
            tmpData = textscan(fid, format, 'delimiter', delimiter);
            
            %check number of rows
            [nRows, nCols] = cellfun(@size, tmpData);
            if sum(nRows - median(nRows)) > 0
                error(['Number of rows has not the same size in', fileName]);
            end
            % convert to cell matrix
            for i = 1:size(tmpData,2)
                data(:,i) = tmpData{i};
                mask = cellfun(@(x) ~isnan(str2double(x)) | strcmpi(x,'nan'), data(:,i));
                if sum(mask) == median(nRows)
                   data(:,i) = num2cell(str2double(data(:,i))); 
                end
            end
             
            % close file
            fclose(fid);
            end
                     
             
            
    end
end



