%Class to declare the most common WebPlot
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebPlot < handle
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
        function allAxesHandles = applyTemplate(axesProperties, textsInAxes, rectanglesInAxes, imagesInAxes, globalConfig)
            %Apply the layout configuration from the web and
            %return a structure with the axes handle and the axes position.
            %To apply this function you need to have the inputs in the right
            %format the. If you have a .json file from Web apply
            
            %Set the main configuration to the template size
            globalConfig = Util.setDefault(globalConfig,'pageWidth',600);
            globalConfig = Util.setDefault(globalConfig,'pageHeight',849);
            globalConfig = Util.setDefault(globalConfig,'pageOrientation','portrait');
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageWidth');
            globalConfig = Util.setDefaultNumberField(globalConfig, 'pageHeight');
            
            maxWidth  = globalConfig.pageWidth;
            maxHeight = globalConfig.pageHeight;
            
            %number of figures to generate
            indexFigures = 1;
            
            allAxesHandles = struct;
            
            % loop over all figures
            for jj = indexFigures%1:3
                %Open New figure
                screnSize = get(0,'ScreenSize');
                
                fig       = figure('PaperPositionMode','manual','PaperOrientation',globalConfig.pageOrientation,'PaperSize' ,[21 29.7],'PaperUnits','centimeters','Position',[100, 100, maxWidth, maxHeight]);
                set(fig,'Units','normalized');
                set(gcf,'renderer','zbuffer');
                
                %get the nr of axis from the template web
                nrAxes = size(axesProperties);
                for kk = 1:nrAxes(2)
                    %Apply the template and get the axes pos.
                    myPos = UtilPlot.getNewAxesPosition(axesProperties(kk).width, axesProperties(kk).height, axesProperties(kk).x, axesProperties(kk).y, globalConfig);
                    axesProperties(kk).pos = myPos;
                    
                    if kk == 1
                        hDummy = axes('outerpos',axesProperties(kk).pos);
                    end;
                    
                    allAxesPos(kk)              = axes('outerpos',axesProperties(kk).pos);
                    allAxes(kk)                 = axesProperties(kk);
                    allAxesHandles(kk).axes     = gca;
                    allAxesHandles(kk).position = get(gca, 'position');
                end
                
                %Set all the images in the template
                if isa(imagesInAxes, 'struct')
                    namesStructImage = fieldnames(imagesInAxes);
                    if length(namesStructImage) >= 1
                        [imageAxes, imageAxesPos, imagehDummy] = WebPlot.setImageInTemplateNew(imagesInAxes, globalConfig);
                        
                        %merge the plot axes with the image Axes
                        allAxesPos = [allAxesPos;imageAxesPos];
                        allAxes    = [allAxes;imageAxes];
                        if ~isempty(imagehDummy)
                            hDummy = imagehDummy;
                        end;
                    end
                end;
                
                %Delete the first axes to reference the positions
                delete(hDummy);
                %Fix the axes position
                %UtilPlot.changePos(allAxesPos,allAxes);
                
                %This is to draw the texts presents in the the template generator
                WebPlot.setTextInTemplate(textsInAxes, globalConfig);
                
                %This is to draw the rectangles presents in the the template generator
                WebPlot.setRectanglesInTemplate(rectanglesInAxes, maxWidth, maxHeight, globalConfig);
                
                %This is to draw the tables in the template.
                %WebPlot.setTableInTemplate(tablesInAxes, globalConfig);
            end;
        end
        
        function completeTemplate(textInAxes, rectanglesInAxes, imagesInAxes, globalConfig)
            %add the rectangles, texts, images to the current figure according to the template
            
            [imageAxes, imageAxesPos, hDummy] = WebPlot.setImageInTemplateNew(imagesInAxes, globalConfig);
            
            %remove the image dummy axes
            if ~isempty(hDummy)
                delete(hDummy);
            end;
            
            %TODO: reorder the axes to align some elements.
            
            %This is to draw the texts presents in the the template generator
            WebPlot.setTextInTemplate(textInAxes, globalConfig);
            
            %This is to draw the rectangles presents in the the template generator
            WebPlot.setRectanglesInTemplateNew(rectanglesInAxes, globalConfig);
        end;
        
        function fixColorbarPosition(hColorBar, hFirstLayer)
            colorPos = get(hColorBar,'pos');
            set(hColorBar,'pos',colorPos-[-0.09 0 0 0]);
            
            firstLayerPosition = get(hFirstLayer, 'position');
            set(gca, 'position', firstLayerPosition);
        end
        
        function [allAxesHandles,allAxesPos,allAxes] = getAxisFromTemplate(axesProperties, globalConfig, totalAxes)
            %return an structure with the axes handle and the handle position
            %Set the main configuration to the template size
            globalConfig = Util.setDefault(globalConfig,'pageWidth',600);
            globalConfig = Util.setDefault(globalConfig,'pageHeight',849);
            globalConfig = Util.setDefault(globalConfig,'pageOrientation','portrait');
            globalConfig = Util.setDefault(globalConfig,'closeFigureOpt',0);
            
            maxWidth  = globalConfig.pageWidth;
            maxHeight = globalConfig.pageHeight;
            
            allAxesHandles = struct;
            hDummy = [];
            
            % loop over all figures
            %Open New figure
            screnSize = get(0,'ScreenSize');
            
            if globalConfig.closeFigureOpt
                fig = figure('PaperPositionMode','manual','PaperOrientation',globalConfig.pageOrientation,'PaperSize' ,[21 29.7],'PaperUnits','centimeters','Position',[100, 100, maxWidth, maxHeight], 'visible', 'off');
            else
                fig = figure('PaperPositionMode','manual','PaperOrientation',globalConfig.pageOrientation,'PaperSize' ,[21 29.7],'PaperUnits','centimeters','Position',[100, 100, maxWidth, maxHeight]);
            end;
            
            set(fig,'Units','normalized');
            set(gcf,'renderer','zbuffer');
            
            %get the nr of axis from the template web
            if ~isempty(axesProperties)
                nrAxes = size(axesProperties);
                for kk = 1:nrAxes(2)
                    %Apply the template and get the axes pos.
                    myPos = UtilPlot.getNewAxesPosition(axesProperties(kk).width, axesProperties(kk).height, axesProperties(kk).x, axesProperties(kk).y, globalConfig);
                    axesProperties(kk).pos = myPos;
                    
                    if kk == 1
                        hDummy = axes('outerpos',axesProperties(kk).pos);
                    end;
                    
                    allAxesPos(kk)              = axes('outerpos',axesProperties(kk).pos);
                    allAxes(kk)                 = axesProperties(kk);
                    allAxesHandles(kk).axes     = gca;
                    allAxesHandles(kk).position = get(gca, 'position');
                end
            else
                %if the user not use the template generator
                conf = Configuration;
                for kk=1:totalAxes
                    tmpAxes(kk).width  = maxWidth / conf.GRID_SIZE;
                    tmpAxes(kk).height = (maxHeight / totalAxes)/ conf.GRID_SIZE;
                    tmpAxes(kk).x      = 1;
                    
                    if kk == 1
                        %set the first plot in 1 position
                        tmpAxes(kk).y = 1;
                    else
                        %get the new position based on the previous
                        aux = tmpAxes(kk-1).height;
                        tmpAxes(kk).y = tmpAxes(kk-1).height + tmpAxes(kk-1).y;
                    end;
                    
                    %get the axes position
                    myPos = UtilPlot.getNewAxesPosition(tmpAxes(kk).width, tmpAxes(kk).height, tmpAxes(kk).x, tmpAxes(kk).y, globalConfig);
                    
                    %return the info in the same way as template generator
                    axesProperties(kk).pos      = myPos;
                    allAxesPos(kk)              = axes('outerpos',axesProperties(kk).pos);
                    allAxes(kk)                 = axesProperties(kk);
                    allAxesHandles(kk).axes     = gca;
                    allAxesHandles(kk).position = get(gca, 'position');
                end;
                
            end;
            
            %Delete the first axes to reference the positions
            delete(hDummy);
            
            %Fix the axes position
            UtilPlot.changePos(allAxesPos,allAxes);
        end;
        
        function [x, y, z, u, v, nrColors, colorScale] = getDataColorQuiver(myData, plotOptions)
            %prepare the data to plot colorquiver
            % EXAMPLE:
            % [x,y] = meshgrid(-10:10);
            % u = x;
            % v = y;
            % z = sqrt(u.^2+v.^2);
            % arrowScale = 0.1;
            % plotOptions.colorScale = [0 15];
            % plotOptions.arrowScale = arrowScale;
            % plotOptions.colorMapStyle = 'jet'
            % plotOptions.nrColors = 15
            % data.x = x;
            % data.y = y;
            % data.u = u;
            % data.v = v;
            % data.z = z;
            
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            uVar    = myData.selection.uVar;
            vVar    = myData.selection.vVar;
            zVar    = myData.selection.zVar;
            x       = dataset.(xVar).data;
            y       = dataset.(yVar).data;
            z       = dataset.(zVar).data;
            u       = dataset.(uVar).data;
            v       = dataset.(vVar).data;
            
            %repeat the data
            [x,y] =  Util.repeatData(x, y, z);
            dataset.(xVar).data = x;
            dataset.(yVar).data = y;
            
            plotOptions = Util.setDefault(plotOptions,'colorMapStyle', 'jet');
            
            plotOptions = Util.setDefault(plotOptions,'nrColors', 8);
            %verifiy if the value is a number - is necesary for web app
            plotOptions = Util.setDefaultNumberField(plotOptions,'nrColors');
            
            plotOptions = Util.setDefault(plotOptions,'colorScale', [0 1]);
            %verifiy if the value is a number - is necesary for web app
            plotOptions = Util.setDefaultNumberField(plotOptions,'colorScale');
            
            plotOptions = Util.setDefault(plotOptions,'arrowScale', 1);
            %verifiy if the value is a number - is necesary for web app
            plotOptions = Util.setDefaultNumberField(plotOptions,'arrowScale');
            
            plotOptions.colorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, plotOptions.nrColors);
            nrColors = size(plotOptions.colorMap,1);
            
            % make index for colors
            colorScale = plotOptions.colorScale;
            if length(colorScale)==2
                colorScale = linspace(colorScale(1),colorScale(2),nrColors+1);
            end;
            
            %check if there is a subset selection
            plotOptions = Util.setDefault(plotOptions,'subsetIndex','');
            
            if ~isempty(plotOptions.subsetIndex)
                subset = myData.subset;
                
                x  = WebDataset.getData(dataset.(xVar), subset, subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVar), subset, subset.currentIndex);
                z  = WebDataset.getData(dataset.(zVar), subset, subset.currentIndex);
                u  = WebDataset.getData(dataset.(uVar), subset, subset.currentIndex);
                v  = WebDataset.getData(dataset.(vVar), subset, subset.currentIndex);
                
                % scale vector lengths
                u = u .*plotOptions.arrowScale;
                v = v .*plotOptions.arrowScale;
            else
                % scale vector lengths
                u = u .*plotOptions.arrowScale;
                v = v .*plotOptions.arrowScale;
            end;
            
        end;
        
        function [x, y, z] = getDataContourFigure(myData, plotOptions)
            %prepare the data to generate the contour figure from the web app
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            zVar    = myData.selection.zVar;
            x       = dataset.(xVar).data;
            y       = dataset.(yVar).data;
            z       = dataset.(zVar).data;
            
            z     = double(z);
            
            % y = y - y(1);
            
            %repeat the data
            [x,y] =  Util.repeatData(x, y, z);
            % sizeY = size(y);
            % depth = repmat( dataset.Depth.data, 1, sizeY(2));
            % y = depth - y;
            % y(y<0) = NaN;
            
            dataset.(xVar).data = x;
            dataset.(yVar).data = y;
            
            conf = Configuration;
            [xStart xEnd] = UtilPlot.getLimsXData(dataset.(xVar).data, xVar, plotOptions);
            
            plotOptions = Util.setDefault(plotOptions,'xInterval',1);
            %verifiy if the value is a number
            plotOptions = Util.setDefaultNumberField(plotOptions,'xInterval');
            
            if any(strcmpi(dataset.(xVar).longname, conf.TIME_VARS))
                %Determine if X variable is Time to apply pcolor patch
                limitsOptions.xData = dataset.(xVar).data;
                limitsOptions.xLim  = [xStart xEnd];
                options.start       = xStart;
                options.end         = xEnd;
                
                plotOptions = Util.setDefault(plotOptions,'intervalOption', 'days');
                
                %Get the xtick
                limitsOptions.xTick = UtilPlot.getXtick(options, plotOptions);
                
                limitsOptions.scaleMinX = true;
                %Transform the X data
                transformedData = UtilPlot.transformData(limitsOptions);
                
                if isfield(plotOptions, 'customTickType') && isempty(plotOptions.customTickType)
                    dataset.(xVar).data = transformedData.xData;
                end;
                
                x = dataset.(xVar).data;
            end;
            
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
                z  = WebDataset.getData(dataset.(zVar),subset,subset.currentIndex);
            end;
        end;
        
        function [x, y] = getDataLine(myData)
            dataset   = myData.dataset;
            xVariable = myData.selection.xVar;
            yVariable = myData.selection.yVar;
            
            x = dataset.(xVariable).data;
            y = dataset.(yVariable).data;
            
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                if length(subset.group(subset.currentIndex).indexVec) > 1
                    varSize = length(subset.group(subset.currentIndex).indexVec{2});
                    x1 = repmat(x, 1, varSize);
                    y1 = repmat(y, 1, varSize);
                    
                    dataset.(xVariable).data = x1;
                    dataset.(yVariable).data = y1;
                end;
                
                %substract data
                x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
            end;
            
        end
        
        function [x, y] = getDataPlotBar(myData)
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            x       = dataset.(xVar).data;
            y       = dataset.(yVar).data;
            
            %check if there is a subset selection
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                x = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
                y = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
                
                [xDataTemp,mask] = unique(x);
                if length(xDataTemp)~=length(y)
                    x = xDataTemp;
                    y = y(mask,:);
                    warning(['Replicated X data deleted in var ',dataset.(xVar).longname,'.']);
                end;
            else
                %veryfy duplicated data
                [xDataTemp,mask] = unique(x);
                if length(xDataTemp)~=length(y)
                    x = xDataTemp;
                    y = y(mask,:);
                    warning(['Replicated X data deleted in var ',dataset.(xVar).longname,'.']);
                end;
            end;
        end;
        
        function [x, y] = getDataPlotHorizontalLine(myData)
            dataset   = myData.dataset;
            xVariable = myData.selection.xVar;
            yVariable = myData.selection.yVar;
            
            x = dataset.(xVariable).data;
            y = dataset.(yVariable).data;
            
            %check if there is a subset selection
            if isfield(myData, 'subset')
                subset = myData.subset;
                %extract subset data selection
                x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
            end;
        end;
        
        function [x,y] = getDataPlotPyramid(myData)
            %Prepare data to apply patch
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            
            x = dataset.(xVar).data;
            y = dataset.(yVar).data;
            
            [x,y] =  Util.alwaysRepeatData(x, y);
            
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                dataset.(xVar).data = x;
                dataset.(yVar).data = y;
                
                x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
                
            end;
            
%             z = 100-x-y;% (percentage clay)            
        end;
        
        function [x, y] = getDataPlotPolar(myData)
            dataset   = myData.dataset;
            xVariable = myData.selection.xVar;
            yVariable = myData.selection.yVar;
            
            x = dataset.(xVariable).data;
            y = dataset.(yVariable).data;
            
            %check if there is a subset selection
            if isfield(myData, 'subset')
                subset = myData.subset;
                %time  = WebDataset.getData(dataset.Time,subset,plotOptions.subsetIndex);
                x = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
                y = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
            end;
            
        end;
        
        function [x,y,z,connections] = getDataPlotTriangle(myData)
            %Prepare data to apply patch
            
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            zVar    = myData.selection.zVar;
            connectionVar    = myData.selection.connectionVar;
            
            x = dataset.(xVar).data;
            y = dataset.(yVar).data;
            z = dataset.(zVar).data;
            connections = dataset.(connectionVar).data;
            
            %repeat the data
            [x,y] =  Util.repeatData(x, y, z);
            dataset.(xVar).data = x;
            dataset.(yVar).data = y;
            
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
                z  = WebDataset.getData(dataset.(zVar),subset,subset.currentIndex);
                connections = WebDataset.getData(dataset.(connVar),subset,subset.currentIndex);
            end;
            
        end;
        
        function [x, y] = getDataPlotVerticalLine(myData)
            dataset   = myData.dataset;
            xVariable = myData.selection.xVar;
            yVariable = myData.selection.yVar;
            
            x = dataset.(xVariable).data;
            y = dataset.(yVariable).data;
            
            %check if there is a subset selection
            if isfield(myData, 'subset')
                subset = myData.subset;
                %extract subset data selection
                x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
            end;
            
        end;
        
        function [x, y, u, v] = getDataScaleQuiver(myData, plotOptions)
            %Prepare data to plot Scale Quiver
            %initialize variables
            dataset = myData.dataset;
            xVar    = myData.selection.xVar;
            yVar    = myData.selection.yVar;
            uVar    = myData.selection.uVar;
            vVar    = myData.selection.vVar;
            
            x = dataset.(xVar).data;
            y = dataset.(yVar).data;
            u = dataset.(uVar).data;
            v = dataset.(vVar).data;
            
            %verify if the arrowScale option is present
            plotOptions = Util.setDefault(plotOptions,'arrowScale',1);
            %verifiy if the value is a number
            plotOptions = Util.setDefaultNumberField(plotOptions,'arrowScale');
            if ~isempty(plotOptions.arrowScale)
                u = dataset.(uVar).data .*plotOptions.arrowScale;
                v = dataset.(vVar).data .*plotOptions.arrowScale;
            end;
            
            %check if there is a subset selection
            if isfield(myData, 'subset')
                subset = myData.subset;
                x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
                
                %u = x .*str2double(plotOptions.arrowScale);
                %v = y .*str2double(plotOptions.arrowScale);
            end;
            
            %check the U and V size to avoid size problems
            %TODO - remove later
            sizeX = size(x);
            sizeY = size(y);
            sizeU = size(u);
            sizeV = size(v);
            if sizeU(2) > sizeX(2)
                u = u(:,1);
            end;
            if sizeV(2) > sizeY(2)
                v = v(:,1);
            end;
            %end;
            
        end;
        
        function legendText = getLegends(dataToPlot, dataset, index)
            %function to get the legends of the plot
            
            if any(strcmpi(dataToPlot(index).plotType, {'contour', 'color_quiver', 'triangle'}))
                legendText = dataset.(dataToPlot(index).zVar).longname;
            else
                legendText = dataset.(dataToPlot(index).yVar).longname;
            end;
            
            if isfield(dataToPlot, 'legendText')
                if ~isempty(dataToPlot(index).legendText)
                    legendText = dataToPlot(index).legendText;
                end;
            end;
        end
       
        function [allInfoPerFile nrFigures] = loadTemplateData(listSelectedFiles, myAxes, allOptions)
            %Function to load all necesary data to plot in the template
            nrAxes = 1;
            allSubsetSelections = [];
            allAxesInfo    = struct;
            loadedSubsets  = {};
            loadSubsetData = {};
            loadedFile     = {};
            loadedFileData = {};
            nrFigures = 1;
            nrModelsSelected = 0;
            allInfoPerFile = struct;
            
            %initialice the configuration class;
            conf = Configuration;
            
            %loop over all selected files to get the data
            for nrFile=1:length(listSelectedFiles)
                optPos = 1;
                for ii=1:length(myAxes)
                    axesToPlot  = myAxes{ii}.plot;
                    
                    %assging the right options according to the axes config
                    if length(allOptions{ii}) > 1
                        nrPlotPerAxe = 1;
                    else
                        nrPlotPerAxe = size(axesToPlot);
                        nrPlotPerAxe = nrPlotPerAxe(2);
                    end
                    
                    options = allOptions;
                    
                    if ii==1
                        currentOpt = options(optPos:nrPlotPerAxe);
                    else
                        currentOpt = options(optPos:optPos+nrPlotPerAxe-1);
                    end;
                    
                    optPos = optPos + nrPlotPerAxe;
                    
                    if length(currentOpt) > 1
                        optionsAxes = currentOpt;
                    else
                        optionsAxes = currentOpt{1};
                    end;
                    %end option assignation
                    
                    currentAxes = {};
                    for jj=1:length(axesToPlot)
                        axesInfo = struct;
                        plotInfo = axesToPlot{jj};
                        
                        if isa(optionsAxes, 'cell')
                            if jj > size(optionsAxes,2)
                               break; 
                            end
                            if isa(optionsAxes{jj}, 'cell')
                                currentOptions = optionsAxes{jj}{1};
                            else
                                currentOptions = optionsAxes{jj};
                            end;
                        else
                            currentOptions = optionsAxes;
                        end;
                        
                        %if is a layer
                        if isfield(plotInfo, 'plot')
                            axesInfo = plotInfo.plot{1};
                        else
                            axesInfo = plotInfo;
                        end;
                        
                        axesInfo.options = currentOptions;
                        %End add options
                        
                        %get the source information
                        sourceInfo = loadjson(axesInfo.dataset);
                        
                        %set the current file according the user selection: MODEL, FILE OR FOLDER
                        if strcmpi(sourceInfo{1}.sourceType, 'folder')
                            %get the file
                            currentFile = listSelectedFiles{nrFile};
                            axesInfo.filesSelected = currentFile;
                        elseif strcmpi(sourceInfo{1}.sourceType, 'model')
                            currentFile = sourceInfo{1}.sourcePath;
                        else
                            currentFile = axesInfo.filesSelected;
                        end;
                        
                        if exist(currentFile, 'file')
                            %check if the subset file was already loaded
                            indexFile       = strfind(loadedFile, currentFile);
                            indexLoadedFile = find(not(cellfun('isempty', indexFile)));
                            
                            %force to read the model again
                            if strcmpi(sourceInfo{1}.sourceType, 'model')
                                indexLoadedFile = '';
                            end;
                            
                            if isempty(indexLoadedFile)
                                %if the source is a model
                                if strcmpi(sourceInfo{1}.sourceType, 'model')
                                    %replace with the selected file.
                                    currentTimeStep = str2num(listSelectedFiles{nrFile})+1;
                                    %read model source
                                    [dataset loadOk] = WebDataset.loadModelData(sourceInfo{1}, currentTimeStep);
                                else
                                    %read the file / only metadata
                                    [dataset loadOk] = Dataset.loadData(currentFile,false);
                                end;
                                
                                if ~loadOk
                                    errordlg('Error to read the source file. Please verify the format.');
                                    return;
                                end;
                                
                                %add fields only metadata
                                dataset = Dataset.addFields(dataset, false);
                                
                                %add the dataset to the whole struct.
                                axesInfo.myData.dataset = dataset;
                                
                                %add the name of the file loaded
                                loadedFile{length(loadedFile)+1} = currentFile;
                                
                                %add the loadsubset data to avoid load multiple times.
                                loadedFileData{length(loadedFileData)+1} = dataset;
                            else
                                %add the dataset to the whole struct.
                                axesInfo.myData.dataset = loadedFileData{indexLoadedFile};
                            end;
                            
                            %get all the "variables" in the plot interface
                            fieldsAxesInfo = fieldnames(axesInfo);
                            for kk=1:length(fieldsAxesInfo)
                                if any(strcmpi(fieldsAxesInfo{kk},{'xVar', 'yVar', 'zVar', 'uVar', 'vVar', 'connectionVar'}))
                                    axesInfo.myData.selection.(fieldsAxesInfo{kk}) = axesInfo.(fieldsAxesInfo{kk});
                                end;
                            end;
                        else
                            errordlg('Error. The selected file does not exist!!!.');
                            return;
                        end;
                        
                        %add the subset to myData struct
                        if isfield(axesInfo, 'subset')
                            if ~isempty(axesInfo.subset)
                                pathSubset = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER '\' axesInfo.subset];
                                
                                if exist(pathSubset, 'file')
                                    
                                    %find the subset of the current file.
                                    subsetsCurrentFile = WebDataset.getSubsetFromDataset(currentFile);
                                    for nrSubFile=1:length(subsetsCurrentFile)
                                        tempSubsetName   = subsetsCurrentFile(nrSubFile).subsetName;
                                        [~, sName, sExt] = fileparts(tempSubsetName);
                                        
                                        %check if the name match with the selected
                                        %subset
                                        indexPoint = strfind(sName, '.');
                                        if isempty(indexPoint)
                                            indexPoint = length(sName);
                                        else
                                            indexPoint = indexPoint(end);
                                        end;
                                        
                                        %check if it is the real subset
                                        if ~regexp(axesInfo.subset, sName(1:indexPoint-1))
                                            continue;
                                        end;
                                        
                                        axesInfo.subset = [sName sExt];
                                        
                                        break; %if find the real subset
                                    end;
                                    
                                    %check if the subset file was already loaded
                                    indexSubset       = strfind(loadedSubsets, axesInfo.subset);
                                    indexLoadedSubset = find(not(cellfun('isempty', indexSubset)));
                                    
                                    if isempty(indexLoadedSubset)
                                        %load the selected subset
                                        load(pathSubset);
                                        
                                        %add the load subsetdata to the whole struct
                                        axesInfo.myData.subset = subset;
                                        
                                        %add the name of the subset loaded
                                        loadedSubsets{length(loadedSubsets)+1} = axesInfo.subset;
                                        
                                        %add the loadsubset data to avoid load multiple times.
                                        loadSubsetData{length(loadSubsetData)+1} = subset;
                                    else
                                        %add the load subsetdata to the whole struct
                                        axesInfo.myData.subset = loadSubsetData{indexLoadedSubset};
                                    end;
                                end;
                                
                            end;
                        end;
                        
                        %store the subset selection to determine the number of figures
                        axesInfo.subsetSelected = str2num(axesInfo.subsetSelected);
                        allSubsetSelections     = [allSubsetSelections;length(axesInfo.subsetSelected)];
                        
                        %clean the information of the axes and return the other fields/opts
                        axesInfo = UtilPlot.mergePlotOptions(axesInfo);
                        
                        currentAxes{jj} = axesInfo;
                        nrAxes = nrAxes + 1;
                    end;
                    
                    %add the info to the big structure
                    allAxesInfo(ii).axes = currentAxes;
                    
                end;
                %add the info to the current file info
                allInfoPerFile(nrFile).info = allAxesInfo;
                
            end;%end loop file
            
            %determine the number of figures based on the number of subset selected
            noSubsetSelected = find(allSubsetSelections == 0, 1); %check if the user select subset
            if ~isempty(noSubsetSelected)
                nrFigures = 1;
            else
                nrFigures = min(allSubsetSelections(allSubsetSelections>1));
                if isempty(nrFigures)
                    nrFigures = 1;
                end;
                
                oneSubsetSelected = find(allSubsetSelections == 1);
                
                %duplicate the selected subsets
                for i=1:length(oneSubsetSelected)
                    nrAxes = 0;
                    for k=1:length(allInfoPerFile.info)
                        temp = allInfoPerFile.info(k);
                        for j=1:length(temp.axes)
                            nrAxes = nrAxes + 1;
                            %find the selection
                            if nrAxes == oneSubsetSelected(i)
                                %replicate the subset selected.
                                newSubSelection = repmat(allInfoPerFile.info(k).axes{j}.subsetSelected, 1, nrFigures);
                                %update the old sub selection with the new one.
                                allInfoPerFile.info(k).axes{j}.subsetSelected = newSubSelection;
                                
                                break;
                            end;                            
                        end;
                    end
                end;
            end;
           
            %end data preparation to plot
            
        end;
        
        function [aLine, x, y] = plotLines(ax, myData, plotOptions)
            dataset   = myData.dataset;
            xVariable = myData.selection.xVar;
            yVariable = myData.selection.yVar;
            
            x = dataset.(xVariable).data;
            y = dataset.(yVariable).data;
            
            
            %start to build the line configuration for each line in
            %plot
            [plotProperty plotPropertyValue] = UtilPlot.buildLinePropertiesNew(plotOptions);
            
            if isfield(myData, 'subset')
                subset = myData.subset;
                
                if length(subset.group(subset.currentIndex).indexVec) > 1
                    varSize = length(subset.group(subset.currentIndex).indexVec{2});
                    x1 = repmat(x, 1, varSize);
                    y1 = repmat(y, 1, varSize);
                    
                    dataset.(xVariable).data = x1;
                    dataset.(yVariable).data = y1;
                end;
                
                %substract data
                x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
                y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
            end;
            
            %make the plot
            aLine = plot(ax,x,y);
            
            %set the custom properties plot
            for zz=1:length(plotProperty)
                set(aLine, plotProperty{zz}, plotPropertyValue{zz})
            end;
        end;
               
        function [aLine, x, y] = plotLinesNew(ax,data, dataToPlot, plotOptions)
            %plot lines from web interface
            %TESTING
            dataset       = '';
            newLegendText = '';
            
            sizeData = size(data);
            
            for i=1:sizeData(2)
                dataset   = data(i).dataset;
                xVariable = dataToPlot.xVar;
                yVariable = dataToPlot.yVar;
                
                x = dataset.(xVariable).data;
                y = dataset.(yVariable).data;
                
                
                %start to build the line configuration for each line in
                %plot
                [plotProperty plotPropertyValue] = UtilPlot.buildLineProperties(dataToPlot, i);
                
                %check if there is a subset selection
                plotOptions = Util.setDefault(plotOptions,'subsetIndex','');
                if ~isempty(plotOptions.subsetIndex)
                    subset = data(i).subset;
                    
                    if length(subset.group(plotOptions.subsetIndex).indexVec) > 1
                        varSize = length(subset.group(plotOptions.subsetIndex).indexVec{2});
                        x1 = repmat(x, 1, varSize);
                        y1 = repmat(y, 1, varSize);
                        
                        dataset.(xVariable).data = x1;
                        dataset.(yVariable).data = y1;
                    end;
                    
                    %substract data
                    x  = WebDataset.getData(dataset.(xVariable),subset,plotOptions.subsetIndex);
                    y  = WebDataset.getData(dataset.(yVariable),subset,plotOptions.subsetIndex);
                end;
                
                %make the plot
                aLine = plot(ax,x,y);
                %set the custom properties plot
                for zz=1:length(plotProperty)
                    set(aLine, plotProperty{zz}, plotPropertyValue{zz})
                end;
                
                %get all legend texts
                if isfield(dataToPlot(i),'legendText')
                    if ~isempty(dataToPlot(i).legendText)
                        newLegendText = [{newLegendText},{dataToPlot(i).legendText}];
                    end
                end
                %reset dataset for the next line;
                clear dataset;
            end;
        end;
        
        function plotTemplate(allInfoPerFile, nrFigures, axesProperties, textInAxes, imagesInAxes, rectanglesInAxes, globalConfig, saveOptions)
            %function to plot the template based on the user selections.
            try
                %loop over all files
                for nrFile=1:length(allInfoPerFile)
                    
                    %loop over all figures (subsets)
                    for jj=1:nrFigures
                        
                        %check if the save options
                        if ~isempty(fieldnames(saveOptions))
                            saveOptions = Util.setDefaultNumberField(saveOptions, 'closeFigureOpt');
                            globalConfig.closeFigureOpt = saveOptions.closeFigureOpt;
                        end;
                        
                        if isfield(allInfoPerFile(nrFile), 'info')
                           nrPlotWithoutTemplate = length(allInfoPerFile(nrFile).info);
                        else
                            nrPlotWithoutTemplate = length(allInfoPerFile(nrFile));
                        end
                        
                        %Create figure and get all the axes in the figure
                        [allAxesHandles,allAxesPos1,allAxes1] = WebPlot.getAxisFromTemplate(axesProperties, globalConfig, nrPlotWithoutTemplate);
                        
                        sctColors   = [];
                        allAxesInfo = allInfoPerFile(nrFile).info;
                        
                        %loop over all axes
                        for ii=1:length(allAxesInfo)
                            %get the entire axes
                            tempAxes = allAxesInfo(ii).axes;
                            %loop over all plots in axes
                            for kk=1:length(tempAxes)
                                currentAxes = tempAxes{kk};
                                
                                %if the axis is a layer, create a new axes with the same
                                %position
                                if strcmpi(currentAxes.options.isLayer,'true')
                                    set(gcf,'CurrentAxes',allAxesHandles(ii).axes);
                                    set(gca,'visible','off');
                                    
                                    pos   = allAxesHandles(ii).position;
                                    hPlot = axes('pos',pos);
                                    
                                    set(gcf,'CurrentAxes',hPlot);
                                    currentAxHandle = gca;
                                else
                                    if strcmpi(currentAxes.options.axisEqual, 'true')
                                        axis equal;
                                    end;
                                    
                                    set(gcf,'CurrentAxes',allAxesHandles(ii).axes);
                                    currentAxHandle = allAxesHandles(ii).axes;
                                end;
                                
                                %check if the user select subset
                                if isfield(currentAxes.myData, 'subset')
                                    currentAxes.myData.subset.currentIndex = currentAxes.subsetSelected(jj);
                                end;
                                
                                hold on;
                                %check the plot type
                                switch currentAxes.options.plotType
                                    case 'line'
                                        [aPlot, xData, yData] = WebPlot.plotLines(currentAxHandle, currentAxes.myData, currentAxes.options);
                                        
                                    case 'bar'
                                        [xData, yData] = WebPlot.getDataPlotBar(currentAxes.myData);
                                        %set different color to each bar.
                                        barColors = {'b', 'r', 'g', 'm', 'k'};
                                        plotOptions.barColor = barColors{kk};
                                        
                                        %Plot the bar
                                        aPlot = Plot.plotBar(currentAxHandle, xData, yData, plotOptions);
                                        
                                    case 'contour'
                                        %prepare the data to plot
                                        [xData, yData, zData] = WebPlot.getDataContourFigure(currentAxes.myData, currentAxes.options);
                                        
                                        %make the plot
                                        [hContour, hColorBar, posAxesBeforeColorbar] = Plot.contourFigure(currentAxHandle, xData, yData, zData, currentAxes.options);
                                        aPlot = gca; %update the last plot axes
                                        
                                        %TODO: check this because if you have multiple layers
                                        %at top, the plots could be larger than the contour
                                        %set(aPlot, 'position', posAxesBeforeColorbar);
                                        
                                        %apply external patch
                                        freezeColors;
                                        sctColors{length(sctColors) + 1} = freezeColorbar(hColorBar);
                                        
                                    case 'scale_quiver'
                                        [xData, yData, uData, vData] = WebPlot.getDataScaleQuiver(currentAxes.myData, currentAxes.options);
                                        
                                        aPlot = Plot.scaleQuiver(xData, yData, uData, vData, currentAxes.options);
                                        
                                    case 'color_quiver'
                                        [xData, yData, uData, vData, nrColors, colorScale] = WebPlot.getDataColorQuiver(currentAxes.myData, currentAxes.options);
                                        
                                        [aPlot,hColorBar] = Plot.colorQuiver(xData, yData, uData, vData, nrColors, colorScale, currentAxes.options);
                                        
                                        %apply external patch
                                        freezeColors;
                                        sctColors{length(sctColors) + 1} = freezeColorbar(hColorBar);
                                        
                                    case 'triangle'
                                        [xData, yData, zData,connections] = WebPlot.getDataPlotTriangle(currentAxes.myData);
                                        
                                        aPlot = Plot.plotTriangle(xData, yData, zData, connections, currentAxes.options);
                                        
                                    case 'vertical_line'
                                        %get data
                                        [xData, yData] = WebPlot.getDataPlotVerticalLine(currentAxes.myData);
                                        %make plot
                                        aPlot = Plot.plotVerticalLine(xData, yData, currentAxes.myData.selection.xVar, currentAxes.myData.selection.yVar, currentAxes.options);
                                        
                                    case 'horizontal_line'
                                        %get data
                                        [xData, yData] = WebPlot.getDataPlotHorizontalLine(currentAxes.myData);
                                        %make plot
                                        aPlot = Plot.plotHorizontalLine(xData, yData, currentAxes.myData.selection.xVar, currentAxes.myData.selection.yVar, currentAxes.options);
                                        
                                    case 'polar'
                                        %get the data
                                        [xData, yData] = WebPlot.getDataPlotPolar(currentAxes.myData);
                                        %make the plot
                                        aPlot = Plot.plotPolar(xData, yData, currentAxes.options);
                                        
                                    case 'pyramid'
                                        %get the data
                                        [xData, yData, zData] = WebPlot.getDataPlotPyramid(currentAxes.myData);
                                        
                                        %make plot
                                        Plot.plotPyramid(currentAxHandle, xData, yData, currentAxes.options);
                                        aPlot = gca;
                                end
                                
                                %guarantee it is the real first layer in the plot
                                if kk == 1
                                    hFirstLayer = aPlot;
                                end;
                                
                                currentAxes.options.hFirstLayer = hFirstLayer;
                                
                                %Update the options struct with the ploted data
                                xVar = currentAxes.myData.selection.xVar;
                                yVar = currentAxes.myData.selection.yVar;
                                
                                currentAxes.options.xVarInfo      = currentAxes.myData.dataset.(xVar);
                                currentAxes.options.xVarInfo.data = xData;
                                
                                currentAxes.options.yVarInfo      = currentAxes.myData.dataset.(yVar);
                                currentAxes.options.yVarInfo.data = yData;
                                
                                if isfield(currentAxes.myData.selection, 'zVar')
                                    zVar = currentAxes.myData.selection.yVar;
                                    currentAxes.options.zVarInfo = currentAxes.myData.dataset.(zVar);
                                end;
                                
                                %Apply all the options to the plot
                                if ~strcmpi(currentAxes.options.plotType, 'pyramid')
                                    Plot.setPlotOptions(currentAxHandle, currentAxes.options);
                                end
                                
                                %update the first layers with all the properties
                                if kk == 1
                                    hFirstLayer = gca;
                                end;
                                
                                %if there is a new layer -> Link axes
                                if currentAxHandle ~= allAxesHandles(ii).axes
                                    %compare if the current varible is the same as the
                                    %firstlayer
                                    if strcmpi(tempAxes{1}.myData.selection.xVar, currentAxes.myData.selection.xVar) && strcmpi(tempAxes{1}.myData.selection.yVar, currentAxes.myData.selection.yVar)
                                        linkaxes([hFirstLayer; currentAxHandle], 'xy')
                                    elseif strcmp(tempAxes{1}.myData.selection.xVar, currentAxes.myData.selection.xVar)
                                        linkaxes([hFirstLayer; currentAxHandle], 'x')
                                    elseif strcmp(tempAxes{1}.myData.selection.yVar, currentAxes.myData.selection.yVar)
                                        linkaxes([hFirstLayer; currentAxHandle], 'y')
                                    end
                                end
                                
                                %put the background "invisible" to see the plot
                                if strcmp(currentAxes.options.isLayer,'true')
                                    set(currentAxHandle,'visible','off');
                                    set(currentAxHandle,'color','none')
                                end;
                            end;
                            
                            %by default always show the bottom layer.
                            %Except when the plot is pyramid
                            if ~strcmpi(currentAxes.options.plotType, 'pyramid')
                                set(hFirstLayer,'visible','on');
                            end
                            
                        end;
                        
                        %Fix the colorbarcolor
                        if length(sctColors) > 1
                            for pp=(length(sctColors)-1):-1:1
                                UtilPlot.freezeColorbarApply(sctColors{pp}); %apply color correction to all colorbars
                            end;
                        end;
                        
                        %complete the template; put texts, tectangles and images
                        WebPlot.completeTemplate(textInAxes, rectanglesInAxes, imagesInAxes, globalConfig);
                        
                        %save the file
                        if ~isempty(saveOptions)
                            %the newFileName should have the number of the
                            %file and the subset to avoid override the
                            %file
                            newFileName = [saveOptions.fileName '_' num2str(nrFile) '_' num2str(jj) '.' saveOptions.outputFileFormat];
                            saveOptions.newFileName = newFileName;
                            
                            %save the figure
                            WebPlot.savePlotTemplate(saveOptions);
                        end;
                        
                    end;
                end;
            catch
                return;
            end
            
        end
        
        function savePlotTemplate(saveOptions)
            %save the plot template in the selected format
            try
                %TODO: work in print figures
                %                 X = 21;                  %# A4 paper size
                %                 Y = 29.7;                  %# A4 paper size
                %                 xMargin = 1;               %# left/right margins from page borders
                %                 yMargin = 1;               %# bottom/top margins from page borders
                %                 xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
                %                 ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)
                %
                %
                %                 %# figure size displayed on screen (50% scaled, but same aspect ratio)
                %                 set(hFig, 'Units','centimeters', 'Position',[0 0 xSize ySize]/2);
                %                 movegui(hFig, 'center')
                %
                %                 %# figure size printed on paper
                %                 set(hFig, 'PaperUnits','centimeters')
                %                 set(hFig, 'PaperSize',[X Y])
                %                 set(hFig, 'PaperPosition',[xMargin yMargin xSize ySize])
                %                 set(hFig, 'PaperOrientation','landscape')
                
                if isempty(saveOptions.outputFolder) || isempty(saveOptions.fileName)
                    return;
                end;
                
                %Save the figures in the selected folder
                saveOptions = Util.setDefault(saveOptions,'outputFolder','');
                saveOptions = Util.setDefault(saveOptions,'fileName','');
                saveOptions = Util.setDefault(saveOptions,'outputFormat','png');
                
                %the new name assigned by the template generator
                saveOptions = Util.setDefault(saveOptions,'newFileName','');
                
                if ~strcmp(saveOptions.outputFolder(end), '\')
                    saveOptions.outputFolder = [saveOptions.outputFolder '\'];
                end;
                
                %check the format to save
                switch lower(saveOptions.outputFormat)
                    case 'png'
                        print([saveOptions.outputFolder saveOptions.newFileName,'.png'],'-dpng','-r300');
                        
                    case 'eps'
                        print([saveOptions.outputFolder saveOptions.newFileName,'.eps'],'-depsc2');
                        
                    case 'fig'
                        saveas(gcf,[saveOptions.outputFolder saveOptions.newFileName,'.fig']);
                end;
                
            catch
                sct = lasterror;
                errordlg(['Error. The file could not be saved. ' sct.message]);
                return;
            end;
        end;
        
        function [myDataToPlot,myData,subsetIndex] = setDatatoPlot(dataToPlot,data ,jj)
            %return the data to plot according the subset selection.
            try
                dataSize = size(data);
                subsetIndex = [];
                myData.subset = [];
                if dataSize(2) > 1
                    dataset = data(dataToPlot.datasetIndex).dataset;
                else
                    dataset = data.dataset;
                end;
                
                %Verify if user select subsets option
                if isfield(dataToPlot, 'subsetIndex')
                    subset        = data(dataToPlot.subsetIndex).subset;
                    myData.subset = subset;
                    
                    %send the index to generate the selected subset
                    subsetIndex = dataToPlot.subsetSelected(jj);
                end;
                
                myDataToPlot   = dataToPlot;
                myData.dataset = dataset;
            catch
                sct = lasterror;
                errordlg(['Error. The selected data is not valid. Please check the data.' sct.message]);
                return;
            end;
        end;
        
        function [allAxes, allAxesPos, nCount, totalAxes, hDummy] = setImageInTemplate(imagesInAxes, globalConfig, totalAxes, allAxesPos, allAxes, nCount)
            %set image in the current figure according to the template generator.
            hDummy = [];
            sizeImages = size(imagesInAxes);
            %plot and fix the image size in the template
            if ~isempty(fieldnames(imagesInAxes))
                for ii=1:sizeImages(2)
                    %This is to use the template generator
                    [acp,map2] = imread(imagesInAxes(ii).imagePath);
                    imSize = size(acp);
                    axSize = [imagesInAxes(ii).width, imagesInAxes(ii).height];
                    % xSize/ySize; axes has x first, image has y first!
                    imRatio = imSize(1)/imSize(2);
                    axRatio = axSize(2)/axSize(1);
                    %check ratios of both and adapt size to prevent
                    %distortion
                    if axRatio >imRatio
                        %we need to change the height
                        imagesInAxes(ii).height = axSize(2)*imRatio/axRatio;
                    else
                        %we need to change the width
                        newWidth = axSize(1)*axRatio/imRatio;
                        deltaWidth = imagesInAxes(ii).width - newWidth;
                        imagesInAxes(ii).width = newWidth;
                        % and to align to the right
                        imagesInAxes(ii).x = imagesInAxes(ii).x+deltaWidth;
                    end
                    
                    myPos = UtilPlot.getNewAxesPosition(imagesInAxes(ii).width, imagesInAxes(ii).height, imagesInAxes(ii).x, imagesInAxes(ii).y, globalConfig);
                    
                    axesProperties(totalAxes).pos = myPos;
                    
                    if totalAxes == 1
                        hDummy = axes('outerpos',axesProperties(totalAxes).pos);
                    end;
                    
                    allAxesPos(nCount)= axes('outerpos',axesProperties(totalAxes).pos);
                    tempStructAxes = imagesInAxes(ii);
                    tempStructAxes.pos = axesProperties(totalAxes).pos;
                    tempStructAxes = rmfield(tempStructAxes, 'imagePath');
                    allAxes(nCount) = tempStructAxes;
                    
                    image(acp, 'Parent', allAxesPos(nCount));
                    
                    nCount = nCount + 1;
                    totalAxes = totalAxes + 1;
                    
                    axis off;
                end;
            end;
        end;
        
        function [imageAxes, imageAxesPos, hDummy] = setImageInTemplateNew(imagesInAxes, globalConfig)
            %set image in the current figure according to the template generator
            %TESTING
            hDummy    = [];
            imageAxes = [];
            imageAxesPos = [];
            sizeImages = size(imagesInAxes);
            %plot and fix the image size in the template
            if isempty(imagesInAxes)
                return;
            end;
            
            if ~isempty(fieldnames(imagesInAxes))
                for ii=1:sizeImages(2)
                    %This is to use the template generator
                    [acp,map2] = imread(imagesInAxes(ii).imagePath);
                    imSize     = size(acp);
                    axSize     = [imagesInAxes(ii).width, imagesInAxes(ii).height];
                    % xSize/ySize; axes has x first, image has y first!
                    imRatio = imSize(1)/imSize(2);
                    axRatio = axSize(2)/axSize(1);
                    %check ratios of both and adapt size to prevent
                    %distortion
                    if axRatio >imRatio
                        %we need to change the height
                        imagesInAxes(ii).height = axSize(2)*imRatio/axRatio;
                    else
                        %we need to change the width
                        newWidth   = axSize(1)*axRatio/imRatio;
                        deltaWidth = imagesInAxes(ii).width - newWidth;
                        imagesInAxes(ii).width = newWidth;
                        % and to align to the right
                        imagesInAxes(ii).x = imagesInAxes(ii).x+deltaWidth;
                    end
                    
                    myPos = UtilPlot.getNewAxesPosition(imagesInAxes(ii).width, imagesInAxes(ii).height, imagesInAxes(ii).x, imagesInAxes(ii).y, globalConfig);
                    
                    axesProperties(ii).pos = myPos;
                    
                    if ii == 1
                        hDummy = axes('outerpos',axesProperties(ii).pos);
                    end;
                    
                    imageAxesPos(ii)   = axes('outerpos',axesProperties(ii).pos);
                    tempStructAxes     = imagesInAxes(ii);
                    tempStructAxes.pos = axesProperties(ii).pos;
                    tempStructAxes     = rmfield(tempStructAxes, 'imagePath');
                    
                    %return the struct with the image axes
                    imageAxes = [imageAxes tempStructAxes];
                    
                    image(acp, 'Parent', imageAxesPos(ii));
                    
                    axis off;
                end;
            end;
        end;
        
        function setRectanglesInTemplate(rectanglesInAxes, maxWidth, maxHeight, globalConfig)
            sizeRectangles = size(rectanglesInAxes);
            conf = Configuration;
            if ~isempty(fieldnames(rectanglesInAxes))
                for ii=1:sizeRectangles(2)
                    %TODO: apply the patch to use the function UtilPlot.getNewAxesPosition
                    realWidth = (rectanglesInAxes(ii).width/conf.GRID_SIZE);
                    realHeight = (rectanglesInAxes(ii).height/conf.GRID_SIZE );
                    realXpos = rectanglesInAxes(ii).x;
                    realYpos = rectanglesInAxes(ii).y;
                    
                    if rectanglesInAxes(ii).x ~= 1
                        realXpos = (rectanglesInAxes(ii).x/conf.GRID_SIZE) + 1;
                    end;
                    if rectanglesInAxes(ii).y ~= 1
                        realYpos = (rectanglesInAxes(ii).y/conf.GRID_SIZE) +1;
                    end
                    myPos = UtilPlot.getNewAxesPosition(realWidth, realHeight, realXpos, realYpos, globalConfig);
                    
                    %fix the values to draw the line in the limits of the
                    %figure
                    if myPos(1) == 0
                        myPos(1) = 0.001;
                    end
                    if myPos(3) == 1
                        myPos(3) = 0.998;
                    end
                    
                    %myPos calculation is different for the rectangles
                    annotation('rectangle', myPos);
                end;
            end
        end;
        
        function setRectanglesInTemplateNew(rectanglesInAxes, globalConfig)
            if isempty(rectanglesInAxes)
                return;
            end;
            
            sizeRectangles = size(rectanglesInAxes);
            conf = Configuration;
            if ~isempty(fieldnames(rectanglesInAxes))
                for ii=1:sizeRectangles(2)
                    realWidth = (rectanglesInAxes(ii).width/conf.GRID_SIZE);
                    realHeight = (rectanglesInAxes(ii).height/conf.GRID_SIZE );
                    realXpos = rectanglesInAxes(ii).x;
                    realYpos = rectanglesInAxes(ii).y;
                    
                    if rectanglesInAxes(ii).x ~= 1
                        realXpos = (rectanglesInAxes(ii).x/conf.GRID_SIZE) + 1;
                    end;
                    if rectanglesInAxes(ii).y ~= 1
                        realYpos = (rectanglesInAxes(ii).y/conf.GRID_SIZE) +1;
                    end
                    myPos = UtilPlot.getNewAxesPosition(realWidth, realHeight, realXpos, realYpos, globalConfig);
                    
                    %fix the values to draw the line in the limits of the
                    %figure
                    if myPos(1) == 0
                        myPos(1) = 0.001;
                    end
                    if myPos(3) == 1
                        myPos(3) = 0.998;
                    end
                    
                    annotation('rectangle', myPos);
                end;
            end
        end;
        
        function setTableInTemplate(tablesInAxes, globalConfig)
            %Function to draw tables with annotation, it use the rectangle
            %annotation but in "one dimension"
            try
                width  = tablesInAxes.width;
                height = tablesInAxes.height;
                x      = tablesInAxes.x;
                y      = tablesInAxes.y;
                
                nrCols   = tablesInAxes.nrCols;
                nrRows   = tablesInAxes.nrRows;
                rowSpace = height/nrRows;
                
                %external table border
                myPos = UtilPlot.getNewAxesPosition(width, height, x, y, globalConfig);
                annotation('rectangle', myPos);
                
                %draw each rows in the table
                for i=1:nrRows-1
                    myPos = UtilPlot.getNewAxesPosition(width, height, x, (y)-rowSpace*i, globalConfig);
                    annotation('rectangle', [myPos(1) myPos(2) myPos(3) 0]);
                end;
                
                %draw each columns in the table
                colSpace = width/nrCols;
                for i=1:nrCols
                    myPos = UtilPlot.getNewAxesPosition(width, height, x+i*colSpace, y, globalConfig);
                    annotation('rectangle', [myPos(1) myPos(2) 0 myPos(4)]);
                end;
            catch
                sct = lasterror;
                error(['Error. The table could not be done. ' sct.message]);
            end
        end;
        
        function setTextInTemplate(textsInAxes, globalConfig)
            %Apply the texts in your figure according to the template generator.
            if isempty(textsInAxes)
                return;
            end;
            
            sizeTexts = size(textsInAxes);
            if ~isempty(fieldnames(textsInAxes))
                for ii=1:sizeTexts(2)
                    myPos = UtilPlot.getNewAxesPosition(textsInAxes(ii).width, textsInAxes(ii).height, textsInAxes(ii).x, textsInAxes(ii).y,globalConfig);
                    annotation('textbox', myPos, 'String', textsInAxes(ii).text, 'lineStyle', 'none', 'fontSize', textsInAxes(ii).fontSize, 'fontWeight', textsInAxes(ii).fontWeight, 'horizontalAlignment', textsInAxes(ii).horizontalAlignment, 'fontAngle', textsInAxes(ii).fontAngle);
                end;
            end;
        end;
        
    end
end