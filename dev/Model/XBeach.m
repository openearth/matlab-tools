%Class with Xbeach functions
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef XBeach < handle
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
        
        function init()
            % initializes the use of the model (by setting open Earth in
            % the Path)
            % XBeach.init
            %
            if exist('xb_read_output','file')==0
                addOpenEarth
            end
        end
        
        function [ds] = loadInitBathy(opt)
            % Load initial hard / soft bathymetry in XBeach
            %
            % [ds] = XBeach.loadInitBathy(opt)
            %INPUTS:
            % - opt: structure, containing fields:
            % - opt.gridFile: xy-grid (.grd) file
            % - opt.gridXFile: x.grd file
            % - opt.gridYFile: y.grd file.
            % - opt.depFile: .dep bathy file
            % - opt.neFile: .dep elevation of hard layer (optional)
            % Either an opt.gridFile (XY grid) or opt.gridXfile and
            % opt.gridYfile (x.grd and y.grd) must be provided.
            %
            %OUTPUTS:
            % - ds: IMDC dataset with X,Y, InitBotlev, and HardLayer fields
            
            % Load hard/soft bathy
            if isfield(opt,'depFile')
                if isfield(opt,'gridFile')
                    grd = wlgrid('read',fullfile(opt.modelDir,opt.gridFile));
                    dep = -wldep('read',fullfile(opt.modelDir,opt.depFile),grd);
                    dep = dep(1:end-1,1:end-1)';
                    n = ceil(size(dep,1)/2);
                    if median(diff(dep(n,:)))<0; %If depth was defined in reverse
                        dep =-dep;
                    end
                    if isfield(opt,'neFile')
                        nel = wldep('read',fullfile(opt.modelDir,opt.neFile),grd);
                        nel = dep - nel(1:end-1,1:end-1)';
                    else
                        nel = nan(size(dep));
                    end
                elseif isfield(opt,'gridXFile')
                    x = dlmread(fullfile(opt.modelDir,opt.gridXFile));
                    y = dlmread(fullfile(opt.modelDir,opt.gridYFile));
                    if any(size(y)==1) && numel(unique(y))==1%1D mode
                        y = y(1);
                        dep = dlmread(fullfile(opt.modelDir,opt.depFile));
                        n = ceil(size(dep,1)/2);
                        if median(diff(dep(n,:)))<0 %If depth was defined in reverse
                            dep =-dep;
                        end
                        if isfield(opt,'neFile')
                            nel = dep-dlmread(fullfile(opt.modelDir,opt.neFile));
                        else
                            nel = nan(size(dep));
                        end
                    else % 2D mode
                        dep = dlmread(fullfile(opt.modelDir,opt.depFile));
                        
                        if median(diff(dep))<0 %If depth was defined in reverse
                            dep =-dep;
                        end
                        if isfield(opt,'neFile')
                            nel = dep - dlmread(fullfile(opt.modelDir,opt.neFile));
                        else
                            nel = nan(size(dep));
                        end
                    end
                    grd.X = x';
                    grd.Y = y';
                end
                
                dep(abs(dep)>900)=nan;
                nel(abs(nel)>900)=nan;
                
                ds.X.data = grd.X';
                ds.Y.data = grd.Y';
                ds.InitBotlev.data = dep;
                ds.HardLayer.data = nel;
                
            else
                error('Please give dep and grid file in opt.depFile and opt.gridFile');
                
            end
        end
        
        function [] = mapPlot(ds,opt)
            % Plot maps of XBeach output
            %
            % [] = mapPlot(ds,opt)
            %
            for iM = 1:numel(opt.variables)
                if size(ds.(opt.variables{iM}).data,1)>=opt.timeInd;
                    
                    f = UtilPlot.reportFigureTemplate(15,9);
                    
                    hold all;
                    switch opt.variables{iM}
                        case 'WaveDir'
                            
                            hp = pcolor(ds.X.data,ds.Y.data,squeeze(ds.WaveHeightRMS.data(opt.timeInd,:,:)));
                            
                            scale = 0.1;
                            da = 3;
                            wh = squeeze(ds.WaveHeightRMS.data(opt.timeInd,:,:));
                            wd = squeeze(ds.WaveDir.data(opt.timeInd,:,:));
                            wd(wh<0.01)=nan;
                            [ux,uy]=degN2xy(180+wd,scale*ones(size(wd)));
                            quiver(ds.X.data(1:da:end,1:da:end),ds.Y.data(1:da:end,1:da:end),ux(1:da:end,1:da:end),uy(1:da:end,1:da:end),'k','linewidth',0.5);
                            cb = colorbar;
                            cb.Label.String = sprintf('%s [%s]','WaveHeightRMS',ds.('WaveHeightRMS').unit);
                        case 'Sedero'
                            hp = pcolor(ds.X.data,ds.Y.data,squeeze(ds.(opt.variables{iM}).data(opt.timeInd,:,:)));
                            colormap(UtilPlot.colormapIMDC('rwb',128));
                            a= squeeze(ds.(opt.variables{iM}).data(opt.timeInd,:,:));
                            caxis(max(abs(a(:)))*[-1 1])
                            cb = colorbar;
                            cb.Label.String = sprintf('%s [%s]',opt.variables{iM},ds.(opt.variables{iM}).unit);
                            
                        otherwise
                            hp = pcolor(ds.X.data,ds.Y.data,squeeze(ds.(opt.variables{iM}).data(opt.timeInd,:,:)));
                            cb = colorbar;
                            cb.Label.String = sprintf('%s [%s]',opt.variables{iM},ds.(opt.variables{iM}).unit);
                            
                    end
                    axis equal;
                    if max(max([ds.X.data(:) ds.Y.data(:)]))<1e3
                        xlabel('x [m]')
                        ylabel('y [m]')
                    else
                        set(gca,'xticklabel',get(gca,'xtick')/1000);
                        set(gca,'yticklabel',get(gca,'ytick')/1000);
                        xlabel('x [km]')
                        ylabel('y [km]')
                    end
                    
                    
                    box on;
                    grid on;
                    shading flat
                    axis equal
                    
                    if strcmpi(opt.variables{iM}(end-3:end),'mean');
                        title({sprintf('%s at timestep %u of %u',opt.variables{iM},opt.timeInd,size(ds.MeanTime.data,1))
                            sprintf('t = %.0f s',ds.MeanTime.data(opt.timeInd))});
                        figFilename = sprintf('%s at timestep %u of %u',opt.variables{iM},opt.timeInd,size(ds.MeanTime.data,1));
                    else
                        title({sprintf('%s at timestep %u of %u',opt.variables{iM},opt.timeInd,size(ds.GlobalTime.data,1))
                            sprintf('t = %.0f s',ds.GlobalTime.data(opt.timeInd))});
                        figFilename = sprintf('%s at timestep %u of %u',opt.variables{iM},opt.timeInd,size(ds.GlobalTime.data,1));
                    end
                    
                    if ~isdir(opt.outputFolder)
                        mkdir(opt.outputFolder)
                    end
                    
                    print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220')
                end
            end
        end
        
        
        function [dataSet,inputData] = readData(inputPath,sctOpt)
            % loads xbeach data and converts them to IMDC format
            %sctOpt.inputFile
            %sctOpt.vars
            %sctOpt.readInput
            if nargin==1
                sctOpt = struct;
            end
            
            sctOpt = Util.setDefault(sctOpt,'inputFile','params.txt');
            sctOpt = Util.setDefault(sctOpt,'readInput',false);
            
            if ~ischar(inputPath)
                inputPath = convertStringsToChars(inputPath);
            end
            
            if ~exist(inputPath,'dir')
                error([inputPath,' does not exist.']);
                % inputfile
            end
            
            if sctOpt.readInput;
                inputData = XBeach.readInput(inputPath,sctOpt.inputFile);
            else
                inputData = [];
            end
            
            readOpt = struct; %Structure with only the options for reading
            readFields = {'vars','start','length','stride','index'};
            for iF = 1:numel(readFields);
                if isfield(sctOpt,readFields{iF})
                    readOpt.(readFields{iF}) = sctOpt.(readFields{iF});
                end
            end
            if isfield(readOpt,'start')
                readOpt.start = readOpt.start-1;
            end
            warning off;
            outputData=xb_read_output(inputPath,struct2arg(readOpt));
            warning on;
            if isfield(readOpt,'start')
                readOpt.start = readOpt.start+1;
            end
            
            
            %unpack output data
            nrData = length(outputData.data);
            for i=1:nrData
                tmpVarName = outputData.data(i).name;
                if ~strcmpi(tmpVarName,'DIMS')
                    outputVarName = XBeach.getVarName(tmpVarName);
                else
                    outputVarName = tmpVarName;
                end
                if ~isempty(outputVarName)
                    dataSet.(outputVarName).data = outputData.data(i).value;
                    dataSet.(outputVarName).unit = outputData.data(i).units;
                    if strcmpi('WaveDir',outputVarName)
                        dataSet.(outputVarName).unit = '°';
                    end
                    dataSet.(outputVarName).dim  = {'T','Y','X'};
                    
%                     Transpose matrix when dimentions are inverted wrt X and Y
                    if strcmpi(outputVarName,'DIMS') 
                        dimNames = {dataSet.DIMS.data.data.name};
                        ind = strcmpi('globalx_DATA',dimNames);
                        [m,n] = size(dataSet.DIMS.data.data(ind).value);
                    else
                        if length(size(dataSet.(outputVarName).data)) == 3
                            if size(dataSet.(outputVarName).data,2) == n & size(dataSet.(outputVarName).data,3) == m
                                dataSet.(outputVarName).data = permute(dataSet.(outputVarName).data,[1,3,2]);
                            end
                        elseif length(size(dataSet.(outputVarName).data)) == 3
                             if size(dataSet.(outputVarName).data,1) == n & size(dataSet.(outputVarName).data,2) == m
                                 dataSet.(outputVarName).data = permute(dataSet.(outputVarName).data,[2,1]);
                             end

                        end
                    end
                    
                end
            end
            
            if isfield(readOpt,'length');
                nt = readOpt.length; %Number of timesteps that are read
                readInd = readOpt.start:readOpt.stride:(readOpt.length-1)*readOpt.stride+readOpt.start;
            else
                nt = inf;
            end
            
            
            % add time and mesh from dims
            dimStruct = dataSet.DIMS;
            dataSet = rmfield(dataSet,'DIMS');
            dimNames = {dimStruct.data.data.name};
            ind = strcmpi('globalx_DATA',dimNames);
            dataSet.X.data = dimStruct.data.data(ind).value;
            dataSet.X.unit = dimStruct.data.data(ind).units;
            dataSet.X.dim = {'Y,X'};
            ind = strcmpi('globaly_DATA',dimNames);
            dataSet.Y.data = dimStruct.data.data(ind).value;
            dataSet.Y.unit = dimStruct.data.data(ind).units;
            dataSet.Y.dim = {'Y,X'};
            ind = strcmpi('meantime_DATA',dimNames);
            if any(ind)
                dataSet.Time.data = dimStruct.data.data(ind).value;
                dataSet.Time.unit = dimStruct.data.data(ind).units;
                dataSet.Time.dim = {'T'};
                if numel(dataSet.Time.data) > nt
                    dataSet.Time.data = dataSet.Time.data(readInd);
                end
            end
            ind = strcmpi('meantime_DATA',dimNames);
            if any(ind);
                dataSet.MeanTime.data = dimStruct.data.data(ind).value;
                dataSet.MeanTime.unit = dimStruct.data.data(ind).units;
                dataSet.MeanTime.dim = {'MT'};
                if numel(dataSet.MeanTime.data) > nt
                    dataSet.MeanTime.data = dataSet.MeanTime.data(readInd);
                end
            end
            ind = strcmpi('globaltime_DATA',dimNames);
            if any(ind);
                dataSet.GlobalTime.data = dimStruct.data.data(ind).value;
                dataSet.GlobalTime.unit = dimStruct.data.data(ind).units;
                dataSet.GlobalTime.dim = {'GT'};
                if numel(dataSet.GlobalTime.data) > nt
                    dataSet.GlobalTime.data = dataSet.GlobalTime.data(readInd);
                end
            end;
            %1D case
            if any(size(dataSet.X.data)==1);
                dataSet.X.data = dataSet.X.data;
                dataSet.Y.data = dataSet.Y.data;
            end
            
            % convert data to c points
            uVarList = {'VelX','TotalLoadX'};
            vVarList = {'VelY','TotalLoadY'};
            for i =1:length(uVarList)
                varName = uVarList{i};
                if isfield(dataSet,varName)
                    xDim = find(strcmpi('X',dataSet.(varName).dim));
                    dataSet.(varName).data = Interpolate.uVarAtC(dataSet.(varName).data,xDim); %#ok<FNDSB>
                end
            end
            for i =1:length(vVarList)
                varName = vVarList{i};
                if isfield(dataSet,varName)
                    yDim = find(strcmpi('Y',dataSet.(varName).dim));
                    dataSet.(varName).data = Interpolate.vVarAtC(dataSet.(varName).data,yDim); %#ok<FNDSB>
                end
            end
            
            % convert coordinate system
            dataSet = XBeach.shoreMesh(dataSet);
            
            % add extra variables (magnitude and direction)
            dataSet = ModelUtil.addMagDir(dataSet);
            
        end
        
        function inputData = readInput(inputPath,inputFilename)
            % Read XBeach input file
            %
            % inputData = readInput(inputPath,inputFile)
            
            if nargin < 2
                inputFilename = 'params.txt';
            end
            % read input
            warning off;
            inputData = xb_read_input(fullfile(inputPath,inputFilename));
            warning on;
            % unpack input data
            nrData = length(inputData.data);
            for i=1:nrData
                inputVarName = inputData.data(i).name;
                tmpDataSet.(inputVarName).data = inputData.data(i).value;
                tmpDataSet.(inputVarName).unit = inputData.data(i).units;
            end
            inputData = tmpDataSet;
        end
        
        function dataSet = shoreMesh(dataSet)
            % compute grid resolution, orientation and area
            %
            % dataSet = XBeach.shoreMesh(dataSet)
            % INPUT:
            %      - dataSet: data  structure in IMDC format
            % OUTPUT:
            %      - dataSet: output in IMDC format with the added
            %                 fields:
            %              - distCross: distance in crossshore
            %                           direction
            %              - distLong: distance in longshore
            %                          direction
            %              - meshDir: direction o fthe mesh cells
            %              (radians)
            
            x = dataSet.X.data;
            y = dataSet.Y.data;
            
            [m,n] = size(x);
            
            if any(size(y)==1)
                %1D MODE (trivial)
                dataSet.distCross.data = x;
                dataSet.distCross.data = y;
                dirGrid = zeros(size(x));
            else
                %2D MODE
                % cross shore and alonggshore distances (only valid on
                % regular grid not on curvilinear
                

                dataSet.distCross.data = nan(size(x));
                dataSet.distCross.data(:,1)=0;
                for j = 2:n
                    dataSet.distCross.data(:,j) = dataSet.distCross.data(:,j-1)+sqrt(...
                        (x(:,j)-x(:,j-1)).^2+...
                        (y(:,j)-y(:,j-1)).^2);
                end
                dataSet.distLong.data = nan(size(x));
                dataSet.distLong.data(1,:) = 0;
                for i = 2:m
                    dataSet.distLong.data(i,:) = dataSet.distLong.data(i-1,:)+sqrt(...
                        (x(i,:)-x(i-1,:)).^2+...
                        (y(i,:)-y(i-1,:)).^2);
                    
                end
%                 dxL          = sqrt(diff(x,1,1).^2+diff(y,1,1).^2);
%                 dxL(end+1,:) = dxL(end,:);
%                 dxC          = sqrt(diff(x,1,2).^2+diff(y,1,2).^2);
%                 dxC(:,end+1) = dxC(:,end);
                % grid orientation
                dirGrid=atan2(diff(y,1,2),diff(x,1,2));
                dirGrid(:,end+1)=dirGrid(:,end);
%                 % cumulative distance
%                 dataSet.distCross.data = cumsum(dxC,2);
%                 dataSet.distLong.data  = cumsum(dxL,1);
            end
            % changing fields
            varNameIn  = {'VelX','VelY'};
            varNameOut = {'VelLong','VelCross'};
            dataSet = XBeach.crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut);
            % changing fields
            varNameIn  = {'VelXMean','VelYMean'};
            varNameOut = {'VelLongMean','VelCrossMean'};
            dataSet = XBeach.crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut);
            % changing fields
            varNameIn  = {'VelXEulerianMean','VelYEulerianMean'};
            varNameOut = {'VelLongEulerianMean','VelCrossEulerianMean'};
            dataSet = XBeach.crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut);
            % changing fields
            if isfield(dataSet,'TotalLoadXMean')
                varNameIn  = {'TotalLoadXMean','TotalLoadYMean'};
                varNameOut = {'TotalLoadLongMean','TotalLoadCrossMean'};
                dataSet = XBeach.crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut);
            end
            
            
            % Area
            dataSet.gridArea.data = nan(m,n);
            % 2D case
            if min(m,n)>1
                for i=2:m-1;
                    for j = 2:n-1;
                        dataSet.gridArea.data(i,j) = polyarea(...
                            [x(i-1,j-1);x(i+1,j-1);x(i+1,j+1);x(i-1,j+1)],...
                            [y(i-1,j-1);y(i+1,j-1);y(i+1,j+1);y(i-1,j+1)])/4;
                    end
                end
                dataSet.gridArea.data(1,:)   = dataSet.gridArea.data(2,:);
                dataSet.gridArea.data(end,:) = dataSet.gridArea.data(end-1,:);
                dataSet.gridArea.data(:,1)   = dataSet.gridArea.data(:,2);
                dataSet.gridArea.data(:,end) = dataSet.gridArea.data(:,end-1);
            else %1D case
                % Program later
            end
        end
        
        function  dataSet = crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut)
            % add variables in alongshore and cross shore direction
            %
            % dataSet = XBeach.crossShoreVar(dataSet,dirGrid,varNameIn,varNameOut)
            %
            % INPUT:
            %        - dataSet: dataset in IMDC standard format
            %        - dirGrid: mesh with the direction of each mesh cell
            %                   (in radians)
            %        - varNameIn: [Nx2] cell array with the names of the x
            %                          and y component of a variable
            %        - varNameOut: [Nx2] cell array with the names of the
            %                          along shore and cross shore components
            %                          of the variable
            %
            % OUTPUT:
            %        - dataSet: updated dataset in IMDC standard format
            % NOTES: This should only be used for rectangular grids!
            %
            for iField=1:size(varNameIn,1)
                varX = varNameIn{iField,1};
                varY = varNameIn{iField,2};
                varL = varNameOut{iField,1};
                varC = varNameOut{iField,2};
                if isfield(dataSet,varX) && isfield(dataSet,varY)
                    % preallocate
                    dataSet.(varL).data  = zeros(size(dataSet.(varX).data));
                    dataSet.(varC).data  = zeros(size(dataSet.(varX).data));
                    % copy metadata
                    dataSet = ModelUtil.copyMetaData(dataSet,varX,varL);
                    dataSet = ModelUtil.copyMetaData(dataSet,varX,varC);
                    % convert each timestep
                    for iTime = 1:length(dataSet.Time.data)
                        
                        u = squeeze(dataSet.(varX).data(iTime,:,:));
                        v = squeeze(dataSet.(varY).data(iTime,:,:));
                        if any(size(u)==1)
                            %1D case
                            u = u';
                            v = v';
                        end
%                         
%                         if size(dirGrid,1) == size(u,2) & size(dirGrid,2) == size(u,1)
%                            u = u';
%                            v = v';
%                         end
%                         
                        [uLong,uCross] = Calculate.rotateVector(u,v,-dirGrid,'radians');
                        dataSet.(varL).data(iTime,:,:)  = uLong;
                        dataSet.(varC).data(iTime,:,:) = uCross;
                    end
                end
            end
        end
        
        
        
        function varName = getVarName(tmpName)
            % gets a standardized variable name from an XBeach name
            [tmpName,modeName] = strtok(tmpName,'_');
            switch (tmpName)
                case 'zb'
                    varName = 'BotDep';
                case 'zb0'
                    varName = 'InitBotDep';
                case 'zs'
                    varName = 'WatLev';
                case 'zs0'
                    varName = 'StillWatLev';
                case 'H'
                    varName = 'WaveHeightRMS';
                case 'u'
                    varName = 'VelX';
                case 'v'
                    varName = 'VelY';
                case 'ue'
                    varName = 'VelXEulerian';
                case 've'
                    varName = 'VelYEulerian';
                case 'Sutot'
                    varName = 'TotalLoadX';
                case 'Svtot'
                    varName = 'TotalLoadY';
                case 'cctot'
                    varName = 'SedConc';
                case 'sedero'
                    varName = 'Sedero';
                case 'thetamean'
                    varName = 'WaveDir';
                case 'qx'
                    varName = 'DischargeX';
				case 'L1'
					varName = 'WaveLength'
				case 'k'
					varName = 'WaveNumber'
                otherwise
                    varName = '';
                    warning(sprintf('Variable %s not recognized',tmpName));
            end
            if ~isempty(modeName);
                modeName(1)=[];
                modeName(1)=upper(modeName(1));
            end
            varName = [varName modeName];
            
        end
        
        function [] =standardPostprocess(opt)
            % [] = XBeach.standardPostprocess(sctInput)
            %
            % Make set of standard postprocessing figures of XBeach run
            % INPUT:
            % - opt: Structure with the following fields:
            %   - modelDir: Model run directory
            %   - outputFolder: Output folder where standard figures are saved
            %
            
            if ~exist(opt.outputFolder,'dir')
                mkdir(opt.outputFolder);
            end
            
            opt.vars = {'zs_mean','H','H_mean','thetamean','sedero','zb','zb0'};
            
            ds = XBeach.readData(opt.modelDir,opt);
            
            dsi = XBeach.loadInitBathy(opt);
            
            [m,n] = size(ds.X.data);
            % Plot some timeseries
            UtilPlot.reportFigureTemplate(15,9);
            it = round(m/2);
            jt = 10;
            
            tsVars = {'WatLevMean','WaveHeightRMSMean','WaveDir'};
            nVars = numel(tsVars);
            
            for ia = 1:nVars
                ax(ia) = subaxis(nVars,1,ia,'mb',0.12,'mr',0.08,'ml',0.12);
                if strcmp(tsVars{ia},'WaveDir')
                    plot(ds.GlobalTime.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                else
                    plot(ds.Time.data/3600,ds.(tsVars{ia}).data(:,it,jt));
                end
                ylabel({tsVars{ia};sprintf('[%s]',ds.(tsVars{ia}).unit)});
                
                grid on;
                box on;
                
                if ia == nVars
                    xlabel('Time [hours]');
                else
                    set(gca,'xticklabel',[]);
                end
                
            end
            figFilename = 'Timeseries offshore';
            print([fullfile(opt.outputFolder,figFilename)],'-dpng','-r220');
            savefig([fullfile(opt.outputFolder,figFilename)]);
            
            
            % Plot some profiles
            if m>1
                opt = Util.setDefault(opt,'iprof',repmat(round(m*[1/3 1/2 2/3])',1,2)); %Default locations for
                opt = Util.setDefault(opt,'jprof',repmat([1 n],3,1)); %Default locations for
            else
                opt = Util.setDefault(opt,'iprof',[1 1]);
                opt = Util.setDefault(opt,'jprof',[1 n]);
            end
            opt.writeTextOutput = false;
            opt.interp = false;
            for i = 1:size(opt.iprof,1);
                opt.profileName{i} = ['Dummy profile ',num2str(i,'%02.0f')];
            end
            
            CosaTool.extractProfiles(opt);
            
            % Now do some mapplots
            %First, at peak time of mean variables
            nT = size(ds.MeanTime.data,1);
            mpOpt.variables = {'WaveHeightRMSMean','WatLevMean'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            %First, at peak time of global variables
            nT = size(ds.GlobalTime.data,1);
            mpOpt.variables = {'WaveDir'};
            mpOpt.timeInd = round(nT/2);
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
            
            %Then, at end time
            nT = size(ds.GlobalTime.data,1);
            if ~isfield(ds,'Sedero')
                ds.Sedero.data = ds.BotDep.data - ds.BotDep.data(1,:,:);
                ds.Sedero.unit = ds.BotDep.unit;
            end
            mpOpt.variables = {'Sedero'};
            mpOpt.timeInd = nT;
            mpOpt.outputFolder = opt.outputFolder;
            if m>1
                XBeach.mapPlot(ds,mpOpt);
            end
        end
		
		function bCeof = writeInputXBeach(strProtoFile, sctAdap)
            
            % Write XBeach input files casted to a prototype-file. - Adapted from swash.writeInput function 
         
            % INPUTS
            %   strProtoFile: string, which contains the filename of the prototype-XBeach file
            %   sctAdap   : structure, for which the fieldnames are the variables
            %               that will be replaced in the prototype xbeach-file, by the content of the field.
            %               (variables in the XBeach file between brackets, for example: fieldname {nx} in Prototype XBeach: {nx}
            %             a) it should also contain the fields 'directory' and
            %                'filename' under which the xbeachfile will be saved.
            %                (NO extension!!!!)
  
            % OUTPUTS
            %   bCeof       : boolean; correct ending of function
            
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: sdo
            % Date:  monday, June 12th 2006
            % Modified: HCA
            % Date: 05/2019
            % Adapted to XBeach and number to be copied with 6 digits after
            % decimal (for grain size)
    

            
            bCeof = 0;                    % boolean correct ending of function
            cAdap = fieldnames(sctAdap);  % Obtaines the variables that will be replaced
            
            for indVar = 1:size(cAdap,1) %Divide cAdap list in a list with strings and a list with numbers
                indchar(indVar) = ischar(getfield(sctAdap,{1}, cAdap{indVar}));
            end
            cAdapStr = cAdap(indchar);
            cAdapNum = cAdap(~indchar);
            
            % read the entire prototype XBeachfile, line by line into a cell array.
  
            cellProtoFile = strsplit(fileread(strProtoFile),'\n');
            
            % for each set of variables adapt the cell array and write xbeach file.
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
                        if abs(rem(matr,1))>1e-6 %If it's pretty much a whole number, write it as such
                            cellFile = strrep(cellFile,['{',cAdapNum{indVar},'}'],sprintf('%.6f',getfield(sctAdap,{indFile}, cAdapNum{indVar})));
                        else
                            cellFile = strrep(cellFile,['{',cAdapNum{indVar},'}'],sprintf('%.0f',getfield(sctAdap,{indFile}, cAdapNum{indVar})));
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
                % Create directories if they dont exist
                if ~exist(sctAdap(indFile).directory,'dir')>0
                    mkdir(sctAdap(indFile).directory);
                end
                fid = fopen(fullfile(sctAdap(indFile).directory, sctAdap(indFile).filename), 'w');
                for indLine  = 1:length(cellFile)
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
        
        function [netVol,grossSedVol,grossEroVol,absGrossVol] = obtainSeaBedChanges(data,polyData,coordinateConversion,ts,iFile,varargin)
            
            % Calculate sedimentation-erosion volumes from a given cell from the XBeach simulations
            % HCA - 10/19

            % Inputs
            % data: Output data from XBeach (it can be previously read by the function XBeach.readData) 
            % polyData: Polygon data
            % coordinateConversion: Logical value. If 1, the polygon coordinates need to be changed (conversion given in varargin)
            % ts: Cell variable with time boundary for the sedero calculations (Global Time)
            % iFile: logical value. If 1, polyInfo is the link to the polygon file, if 0, it is the coordinates of the polygons
            % varargin: Double cell. initial coordinate reference and final coordinate reference
            %
            % Ouputs 
            %
            % netVol: Net sedimentation volume [m3]
            % grossSedVol: Gross sedimentation volume [m3]
            % grossEroVol: Gross erosion volume [m3]
            % absGrossVol: Absolute gross volume abs(grossSedVol + grossEroVol) [m3]

            if iFile == 1
                fid = fopen(polyData,'r');
                mPol = cell2mat(textscan(fid,'%f %f'));
            else
                mPol = polyData;
            end


            % Conversion of polygon coordinates

            if coordinateConversion == 1
                [aPol.x aPol.y] = convertCoordinates(mPol(:,1),mPol(:,2),...
                    'CS2.code',varargin{1},'CS1.code',varargin{2});
            else
                aPol.x = mPol(:,1);
                aPol.y = mPol(:,2);
            end

            % Find cells within area and compute cell sizes

            maskIn = inpolygon(data.X.data,data.Y.data,aPol.x,aPol.y);

            % Final sedero 

            tmEroded = squeeze(data.BotDep.data(ts{2},:,:))-squeeze(data.BotDep.data(ts{1},:,:));
           
            maskSed = tmEroded>0;
            gridArea = data.gridArea.data;
            
          
            % Calculate net sedimentation volume within the cell

            netVol = sum(tmEroded(maskIn).*data.gridArea.data(maskIn));

            % Calculate gross sedimentation volume within the cell

            grossSedVol = sum(tmEroded(maskIn & maskSed).*data.gridArea.data(maskIn & maskSed));

            % Calculate gross erosion volume within the cell

            grossEroVol = grossSedVol - netVol;

            % Calculate absolute gross volume within the cell

            absGrossVol = grossSedVol +  grossEroVol;

        end
        
        function volCell = volAbovePlane(data,level,polyData,coordinateConversion,ts,iFile,varargin)
            
            % Calculate total volumes above a constant plane from a given cell from the XBeach simulations
            % HCA - 11/19
            
            % Input
            % data: Output data from XBeach (it can be previously read by the function XBeach.readData) 
            % polyData: Polygon data, either file link or matrix with x (:,1) and y (:,2) coordinates
            % coordinateConversion: Logical value. If 1, the polygon coordinates need to be changed (conversion given in varargin)
            % ts: Time step (in Global time) at which the volume is to be calculated
            % iFile: logical value. If 1, polyInfo is the link to the polygon file, if 0, it is the coordinates of the polygons
            % varargin: Double cell. initial coordinate reference and final coordinate reference
            
            % Output
            % volCell [m3]: cell (from the polyFile) volume above plane defined by level 
            
            
            if iFile == 1
                fid = fopen(polyFile,'r');
                mPol = cell2mat(textscan(fid,'%f %f'));
            else
                mPol = polyData;
            end
            
            % Conversion of polygon coordinates

            if coordinateConversion == 1
                [aPol.x aPol.y] = convertCoordinates(mPol(:,1),mPol(:,2),...
                    'CS2.code',varargin{1},'CS1.code',varargin{2});
            else
                aPol.x = mPol(:,1);
                aPol.y = mPol(:,2);
            end
            
            
            % Find cells within area and compute cell sizes

            maskIn = inpolygon(data.X.data,data.Y.data,aPol.x,aPol.y);
            
            %  Volume calculation

            bathyElev = squeeze(data.BotDep.data(ts,:,:)) - level;
            volCell = sum(bathyElev(maskIn).*data.gridArea.data(maskIn));
            
        end
        
        function [meanSl,stdSl,maxSl,minSl,maxElev,minElev,r2Slope] = calculateSlopeCell(data,polyData,coordinateConversion,ts,iFile,plotLogical,varargin)
                        
        % Calculate mean and standard deviation value of the slopes withina cell
        % HCA - 11/19

        % Input
        % data: Output data from XBeach (it can be previously read by the function XBeach.readData) 
        % polyData: Polygon data
        % coordinateConversion: Logical value. If 1, the polygon coordinates need to be changed (conversion given in varargin)
        % ts: Time step (in Global time) at which the volume is to be calculated
        % iFile: logical value. If 1, polyInfo is the link to the polygon file, if 0, it is the coordinates of the polygons
        % plotLogical: Logical value. If 1, make plot with all profiles within the cell and average slope
        % varargin: Double cell. initial coordinate reference and final coordinate reference

        % Output
      
        % meanSl: mean slope value in the cell [cotg alpha]
        % stdSl: standard deviation of that value [cotg alpha]
        % maxSl: maximum slope value [cotg alpha]
        % minSl: minimum slope value [cotg alpha]
        
        
                    
         if iFile == 1
                fid = fopen(polyFile,'r');
                mPol = cell2mat(textscan(fid,'%f %f'));
            else
                mPol = polyData;
            end
            
            % Conversion of polygon coordinates

            if coordinateConversion == 1
                [aPol.x aPol.y] = convertCoordinates(mPol(:,1),mPol(:,2),...
                    'CS2.code',varargin{1},'CS1.code',varargin{2});
            else
                aPol.x = mPol(:,1);
                aPol.y = mPol(:,2);
            end
            
            
            % Find cells within area and compute cell sizes

            maskIn = inpolygon(data.X.data,data.Y.data,aPol.x,aPol.y);
            [m,n] = find(maskIn ==1);
            
            if isequal(size(unique(m),1)*size(unique(n),1),length(n),length(m))
                minn = min(n);
                maxn = max(n);
                locMinn = find(n == minn);
                locMaxn = find(n == maxn);
                
                minLineDep = squeeze(data.BotDep.data(ts,m(locMinn),minn));
                minLineX = data.X.data(m(locMinn),minn);
                minLineY = data.Y.data(m(locMinn),minn);
                mindistCross = data.distCross.data(m(locMinn),minn);

                
                maxLineDep = squeeze(data.BotDep.data(ts,m(locMaxn),maxn));
                maxLineX = data.X.data(m(locMaxn),maxn);
                maxLineY = data.Y.data(m(locMaxn),maxn);
                maxdistCross = data.distCross.data(m(locMaxn),maxn);
                
                dist = sqrt((maxLineX - minLineX).^2 + (maxLineY - minLineY).^2);
                height = maxLineDep - minLineDep;
                slope = transpose(dist)./height;
                
                                
                meanSl = mean(slope);
                stdSl = std(slope);
                maxSl = max(slope);
                minSl = min(slope);
                
                maxElev = max(maxLineDep);
                minElev = min(minLineDep);
                

                    
                for pp = 1: length(m(locMinn))
                    xVect{pp} = [data.distCross.data(m(locMinn(pp)),minn):0.01:data.distCross.data(m(locMaxn(pp)),maxn)];
                    zVect(pp,:) = interp1(data.distCross.data(m(locMinn(pp)),minn:maxn),transpose(squeeze(data.BotDep.data(ts,m(locMinn(pp)),minn:maxn))),xVect{pp});

                    zRef(pp,:) = interp1([data.distCross.data(m(locMinn(pp)),minn),data.distCross.data(m(locMinn(pp)),maxn)],...
                        [transpose(squeeze(data.BotDep.data(ts,m(locMinn(pp)),minn))), transpose(squeeze(data.BotDep.data(ts,m(locMinn(pp)),maxn)))],xVect{pp});
                    r2(pp) = sum((zRef(pp,:)-zVect(pp,:)).^2)/length(zRef(pp,:));
                end

                r2Slope = mean(r2);
                
                if ts == 2 && plotLogical == 1 
                    figure
                    hold on; box on
                    for mm = 1:length(locMaxn)
                        plot(data.distCross.data(m(locMaxn(mm)),:),squeeze(data.BotDep.data(ts,m(locMaxn(mm)),:)),'LineWidth',1.2)
                        plot(data.distCross.data(m(locMaxn(mm)),maxn),squeeze(data.BotDep.data(ts,m(locMaxn(mm)),maxn)),'r.','MarkerSize',16)
                        plot(data.distCross.data(m(locMinn(mm)),minn),squeeze(data.BotDep.data(ts,m(locMinn(mm)),minn)),'r.','MarkerSize',16)
                        ylim([minElev - 0.2, maxElev + 0.2])
                        xlim([mindistCross(1)-50,maxdistCross(1)+50])
                    end
                    plot(xVect{mm},mean(zRef),'k-','LineWidth',1.5)
                    xlabel('cross-shore distance [m]')
                    ylabel('elevation [m TAW]')
                end


            else
                warning(strcat('The polygon did not find matching slopes'));
                meanSl = NaN;
                stdSl = NaN;
                maxSl = NaN;
                minSl = NaN;
                r2Slope = NaN;
                maxElev = NaN;
                minElev = NaN;
               
                
            end

        end
        
        function createJonsTable(Hm0,Tp,WaveDir,s,duration,pathSave,varargin)
         
         % Function to create wave and water level time series input files for XBeach. wbcfile = jonstable
         % HCA - 04/20
         
         % Hm0: data array with Hm0 values [m]
         % Tp: data array with Tp values [s]
         % Wave Direction: data array with wave directions [°]
         % s: directional spreading, defined by the parameter s. See relation with gamma in Page 46 of the XBeach X User Manual. s = 25 corresponds to gamma = 16°. Specified as one value (for all wave conditions) or a vector with all values
         % duration: duration of wave condition. Specified as one value (for all wave conditions) or a vector with all values [s]
         % pathSave: Path (including filename.txt) where to save the time series file
         % Varargin{1}: Peak enhancement factor from JONSWAP, in case it is
         % desired to have a different one from 3.3. Specified as one value (for all wave conditions) or a vector with all values [-]
         % Varargin{2}: dtbc, in case it is different from 0.5. Specified as one value (for all wave conditions) or a vector with all values [s]
         
         
         nConditions = length(Hm0);
         
         if nConditions>= 900
             warning('XBeach stops automatically when the number of wave conditions exceeds 900')
         end
         
         if nConditions ~= length(Tp) | nConditions ~= length(WaveDir)
             error('The number of values of the arrays Hm0, Tp and WaveDir must be the same')
         end
         
         if length(find(isnan(Hm0)))>1 | length(find(isnan(Tp)))>1 | length(find(isnan(WaveDir)))>1             
             error('AVoid including NaN values')
         end
         
         % Check dimensions of Hm0,Tp and WaveDir
         
         if size(Hm0,2)>size(Hm0,1)
             Hm0 = transpose(Hm0);
         end
         
         if size(Tp,2)>size(Tp,1)
             Tp = transpose(Tp);
         end         
                  
         if size(WaveDir,2)>size(WaveDir,1)
             WaveDir = transpose(WaveDir);
         end
         
         % Prepare directional spreading 
         
         if length(s) == 1 
             sVec = ones(nConditions,1);
             sVec = s.*sVec;
         else
            sVec = s;
            if size(sVec,2)>size(sVec,1)
                sVec = transpose(sVec);
            end
         end
         
         % Prepare duration
         
         if length(duration) == 1 
             durationVec = ones(nConditions,1);
             durationVec = duration.*durationVec;
         else
            durationVec = duration;
            if size(durationVec,2)>size(durationVec,1)
                durationVec = transpose(durationVec);
            end
         end
         
         % Prepare peah enhancement factor and dtbc
         
        if isempty(varargin) == 1
             
             % Define peak enhancement factor of the JONSWAP spectrum
             gamma = ones(nConditions,1);
             gamma = 3.3.*gamma;
             
             % Define timesetp used to describe time series of wave energy and long wave flux at offshore boundary

             dtbc = ones(nConditions,1);
             dtbc = 0.5.*dtbc;
             
        else
             if length(varargin{1}{1})==1
                 gamma = ones(nConditions,1);
                 gamma = varargin{1}{1}.*gamma;
             elseif length(varargin{1}{1})==0
                 gamma = ones(nConditions,1);
                 gamma = 3.3.*gamma;
             else
                 gamma = varargin{1}{1};
                 if size(gamma,2)>size(gamma,1)
                    gamma = transpose(gamma);
                 end
                 
                 if nConditions ~= length(gamma)
                      error('The number of values of the array gamma must be the same as the number of wave conditions')
                 end

             end
                              
            
             if length(varargin{1}{2})==1
                 dtbc = ones(nConditions,1);
                 dtbc = varargin{1}{2}.*dtbc;
             elseif length(varargin{1}{2})==0
                 dtbc = ones(nConditions,1);
                 dtbc = 0.5.*dtbc;
             else
                 dtbc = varargin{1}{2};
                 if size(dtbc,2)>size(dtbc,1)
                    dtbc = transpose(dtbc);
                 end
                 
                 if nConditions ~= length(dtbc)
                     error('The number of values of the array dtbc must be the same as the number of wave conditions')
                 end
             end
        end
             
         % Round values
         
         Hm0 = round(Hm0,3); Tp = round(Tp,3); WaveDir = round(WaveDir,3);
         sVec = round(sVec,3); durationVec = round(durationVec,3); 
         % Make table         
        
         tableWaves = table(Hm0,Tp,WaveDir,gamma,sVec,durationVec,dtbc,...
        'VariableNames', {'Hm0', 'Tp', 'Dir','gamma','s','dur','dtbc'});
    
         % Write wave table
                  
         writetable(tableWaves, pathSave,'Delimiter','tab','WriteVariableNames',0)

            
        end
        
    end
end