clear;
% 2 lines different axes;
% jsonFile = 'D:\Downloads\download (9).sql';

% 2 lines different axes;
% jsonFile = 'D:\Downloads\download (9) - Copy.sql';

% 1 contoru;
% jsonFile = 'D:\Downloads\download (11).sql';

% 1 contour bottom layer, 1 line up;
jsonFile = 'D:\Downloads\download (12).sql';

% 2 files
jsonFile = 'D:\Downloads\download (14).sql';

% jsonFile = 'D:\Downloads\plot (72).json';

% 1 model quiver;
% jsonFile = 'D:\Downloads\plot (72) - Copy.json';


%bar
% jsonFile = 'D:\Downloads\plot (75).json';

%vicent template 3plots
% jsonFile = 'D:\Downloads\plot (76).json';

%no template 1 plot
% jsonFile = 'D:\Downloads\plot (77).json';

%no template 2 plot
% jsonFile = 'D:\Downloads\plot (79).json';

% jsonFile = 'D:\Downloads\plot (80).json';


% jsonFile = 'D:\Downloads\plot (88).json';
% jsonFile = 'D:\Downloads\plot (89).json';
% jsonFile = 'D:\Downloads\plot (90).json';


% jsonFile = 'D:\Downloads\plot (91).json';


% jsonFile = 'D:\Downloads\plot (92).json';


% jsonFile = 'D:\Downloads\plot (98).json';
% 


% jsonFile = 'D:\Downloads\plot.json101.json';

%telemac
% jsonFile = 'D:\Downloads\plot.json105.json';

%BAD
% jsonFile = 'D:\Downloads\plot.json106.json';

% jsonFile = 'D:\Downloads\plot.json107.json';

%if I use a model and other kind of selection it duplicates one figure
jsonFile = 'D:\Downloads\plot.json108.json';

jsonFile = 'D:\Downloads\plot.json110.json';

%read the json file
% elements = loadjson(jsonFile);
% %initialize the configuration class
% conf = Configuration;
% 
% %get the axes info
% myAxes  = elements{1}.axes;
% allOptions = elements{1}.options;
% 
% %get the axes properties
% tempAxes = elements{2};
% 
% axesProperties = [];
% for ii=1:length(tempAxes)
%     %get the plots
%     if strcmpi(tempAxes{ii}.type, 'plot')
%         aux = tempAxes{ii};
%         aux = rmfield(aux, 'plotId'); %clean the structure
%         aux = rmfield(aux, 'type');
% 
%         aux.id = [];
%         axesProperties = [axesProperties aux];
%         continue
%     end;
% end;
% 
% 
% tempAxes = elements{3};
% textInAxes = [];
% %get the text
% for ii=1:length(tempAxes)
%     %get the texts
%     if strcmpi(tempAxes{ii}.type, 'text')
%         tempTextInAxes        = tempAxes{ii};
%         tempTextInAxes.id     = [];
%         tempTextInAxes.textId = [];
%         tempTextInAxes        = rmfield(tempTextInAxes, 'type');
% 
%         %read the aditional properties
%         textProperties        = loadjson(tempAxes{ii}.properties);
%         %convert from string to number
%         textProperties = Util.setDefaultNumberField(textProperties, 'fontSize');
% 
%         %merge the struct adding the other properties
%         allPropTextInAxes = catstruct(tempTextInAxes,textProperties);
%         textInAxes        = [textInAxes allPropTextInAxes];
%     end;
% end;
% 
% tempAxes     = elements{4};
% imagesInAxes = [];
% 
% %get the images
% for ii=1:length(tempAxes)
%     %get the images
%     if strcmpi(tempAxes{ii}.type, 'image')
%         tempImagesInAxes    = tempAxes{ii};
%         tempImagesInAxes    = rmfield(tempImagesInAxes, 'imageId');
%         tempImagesInAxes    = rmfield(tempImagesInAxes, 'type');
%         tempImagesInAxes.id = [];
% 
%         %read the aditional properties
%         imageProperties    = loadjson(tempAxes{ii}.properties);
%         %merge the struct adding the other properties
%         allPropImageInAxes = catstruct(tempImagesInAxes,imageProperties);
%         imagesInAxes       = [imagesInAxes allPropImageInAxes];
%     end;
% end;
% 
% %get rectangles
% tempRectangles   = elements{5};
% rectanglesInAxes = [];
% for ii=1:length(tempRectangles)
%     %convert from string to number
%     tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'height');
%     tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'width');
%     tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'x');
%     tempRectangles{ii} = Util.setDefaultNumberField(tempRectangles{ii}, 'y');
% 
%     %get the rectangles
%     rectanglesInAxes = [rectanglesInAxes tempRectangles{ii}];
% end;
% 
% %get globalconfig
% tempGlobalConfig = elements{6};
% if isempty(tempGlobalConfig)
%     globalConfig.pageWidth = 600;
%     globalConfig.pageHeight = 849;
% else
%     globalConfig     = tempGlobalConfig;
%     
%     globalConfig.pageWidth = str2double(globalConfig.pageWidth);
%     globalConfig.pageHeight = str2double(globalConfig.pageHeight);
% end;
% 
% saveOptions = elements{7};
% if ~isempty(saveOptions)
%     saveOptions = saveOptions{1};
% end;
% 
% allAxesInfo    = struct;
% loadedSubsets  = {};
% loadSubsetData = {};
% loadedFile     = {};
% loadedFileData = {};
% 
% 
% %read get the list of the selected files and subset
% listSelectedFiles = {};
% for ii=1:length(myAxes)
%     axesToPlot  = myAxes{ii}.plot;
%     currentAxes = {};
%     for jj=1:length(axesToPlot)
%         axesInfo = struct;
%         plotInfo = axesToPlot{jj};
% 
%         %if is a layer
%         if isfield(plotInfo, 'plot')
%             axesInfo = plotInfo.plot{1};
%         else
%             axesInfo = plotInfo;
%         end;
% 
%         filesSelected = regexp(axesInfo.filesSelected,'%','split');
% 
%         for nrFile=1:length(filesSelected)
%             listSelectedFiles{nrFile} = filesSelected{nrFile};
%         end;
%     end;
% end;
% 
% 
% %get complete axes info
% nrAxes    = 1;
% allSubsetSelections = [];
% optPos = 1;
% 
% %loop over all selected files to get the data
% for nrFile=1:length(listSelectedFiles)
%     for ii=1:length(myAxes)
%         axesToPlot  = myAxes{ii}.plot;
%         
%         %assging the right options according to the axes config
%         if length(allOptions{ii}) > 1
%             nrPlotPerAxe = 1;
%         else
%             nrPlotPerAxe = size(axesToPlot);
%             nrPlotPerAxe = nrPlotPerAxe(2);
%         end
%         
%         options = allOptions;
%         
%         if ii==1
%             currentOpt = options(optPos:nrPlotPerAxe);
%         else
%             currentOpt = options(optPos:optPos+nrPlotPerAxe-1);
%         end;
%         
%         optPos = optPos + nrPlotPerAxe;
%         
%         if length(currentOpt) > 1
%             optionsAxes = currentOpt;
%         else
%             optionsAxes = currentOpt{1};
%         end;
%         %end option assignation
% 
%         currentAxes = {};
%         for jj=1:length(axesToPlot)
%             axesInfo = struct;
%             plotInfo = axesToPlot{jj};
%             
%             if isa(optionsAxes, 'cell')
%                 sizeOpt = size(optionsAxes);
%                 if isa(optionsAxes{jj}, 'cell')
%                     currentOptions = optionsAxes{jj}{1};
%                 else
%                     currentOptions = optionsAxes{jj};
%                 end;
%             else
%                 currentOptions = optionsAxes;
%             end;
% 
%             %if is a layer
%             if isfield(plotInfo, 'plot')
%                 axesInfo = plotInfo.plot{1};
%             else
%                 axesInfo = plotInfo;
%             end;
% 
%             axesInfo.options = currentOptions;
%             %End add options
% 
%             %get the source information
%             sourceInfo = loadjson(axesInfo.dataset);
% 
%             %set the current file according the user selection: MODEL, FILE OR FOLDER
%             if strcmpi(sourceInfo{1}.sourceType, 'folder')
%                 %get the file
%                 currentFile = listSelectedFiles{nrFile};
%                 axesInfo.filesSelected = currentFile;
%             elseif strcmpi(sourceInfo{1}.sourceType, 'model')
%                 currentFile = sourceInfo{1}.sourcePath;
%             else
%                 currentFile = axesInfo.filesSelected;
%             end;
% 
%             if exist(currentFile, 'file')
%                 %check if the subset file was already loaded
%                 indexFile       = strfind(loadedFile, currentFile);
%                 indexLoadedFile = find(not(cellfun('isempty', indexFile)));
% 
%                 if isempty(indexLoadedFile)
%                     %if the source is a model
%                     if strcmpi(sourceInfo{1}.sourceType, 'model')
%                         %replace with the selected file.
%                         currentTimeStep = 1;
%                         %read model source
%                         [dataset loadOk] = WebDataset.loadModelData(sourceInfo{1}, currentTimeStep);
%                     else
%                         %read the file / only metadata
%                         [dataset loadOk] = Dataset.loadData(currentFile,false);
%                     end;
% 
%                     if ~loadOk
%                         errordlg('Error to read the source file. Please verify the format.');
%                         return;
%                     end;
% 
%                     %add fields only metadata
%                     dataset = Dataset.addFields(dataset, false);
% 
%                     %add the dataset to the whole struct.
%                     axesInfo.myData.dataset = dataset;
% 
%                     %add the name of the file loaded
%                     loadedFile{length(loadedFile)+1} = currentFile;
% 
%                     %add the loadsubset data to avoid load multiple times.
%                     loadedFileData{length(loadedFileData)+1} = dataset;
%                 else
%                     %add the dataset to the whole struct.
%                     axesInfo.myData.dataset = loadedFileData{indexLoadedFile};
%                 end;
% 
%                 %get all the "variables" in the plot interface
%                 fieldsAxesInfo = fieldnames(axesInfo);
%                 for kk=1:length(fieldsAxesInfo)
%                     if any(strcmpi(fieldsAxesInfo{kk},{'xVar', 'yVar', 'zVar', 'uVar', 'vVar', 'connectionVar'}))
%                         axesInfo.myData.selection.(fieldsAxesInfo{kk}) = axesInfo.(fieldsAxesInfo{kk});
%                     end;
%                 end;
%             else
%                 errordlg('Error. The selected file does not exist!!!.');
%                 return;
%             end;
% 
%             %add the subset to myData struct
%             if isfield(axesInfo, 'subset')
%                 if ~isempty(axesInfo.subset)
%                     pathSubset = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER '\' axesInfo.subset];
% 
%                     if exist(pathSubset, 'file')
% 
%                         %find the subset of the current file.
%                         subsetsCurrentFile = WebDataset.getSubsetFromDataset(currentFile);
%                         for nrSubFile=1:length(subsetsCurrentFile)
%                             tempSubsetName   = subsetsCurrentFile(nrSubFile).subsetName;
%                             [~, sName, sExt] = fileparts(tempSubsetName);
% 
%                             %check if the name match with the selected
%                             %subset
%                             indexPoint = strfind(sName, '.');
%                             if isempty(indexPoint)
%                                 indexPoint = length(sName);
%                             else
%                                 indexPoint = indexPoint(end);
%                             end;
% 
%                             %check if it is the real subset
%                             if ~regexp(axesInfo.subset, sName(1:indexPoint-1))
%                                 continue;
%                             end;
% 
%                             axesInfo.subset = [sName sExt];
% 
%                             break; %if find the real subset
%                         end;
% 
%                         %check if the subset file was already loaded
%                         indexSubset       = strfind(loadedSubsets, axesInfo.subset);
%                         indexLoadedSubset = find(not(cellfun('isempty', indexSubset)));
% 
%                         if isempty(indexLoadedSubset)
%                             %load the selected subset
%                             load(pathSubset);
% 
%                             %add the load subsetdata to the whole struct
%                             axesInfo.myData.subset = subset;
% 
%                             %add the name of the subset loaded
%                             loadedSubsets{length(loadedSubsets)+1} = axesInfo.subset;
% 
%                             %add the loadsubset data to avoid load multiple times.
%                             loadSubsetData{length(loadSubsetData)+1} = subset;
%                         else
%                             %add the load subsetdata to the whole struct
%                             axesInfo.myData.subset = loadSubsetData{indexLoadedSubset};
%                         end;
%                     end;
% 
%                 end;
%             end;
% 
%             %store the subset selection to determine the number of figures
%             axesInfo.subsetSelected = str2num(axesInfo.subsetSelected);
%             allSubsetSelections     = [allSubsetSelections;length(axesInfo.subsetSelected)];
% 
%             %clean the information of the axes and return the other fields/opts
%             axesInfo = UtilPlot.mergePlotOptions(axesInfo);
% 
%             currentAxes{jj} = axesInfo;
%             nrAxes = nrAxes + 1;
%         end;
% 
%         %add the info to the big structure
%         allAxesInfo(ii).axes = currentAxes;
% 
%     end;
%     %add the info to the current file info
%     allInfoPerFile(nrFile).info = allAxesInfo;
% 
% end;%end loop file
% 
% %determine the number of figures based on the number of subset selected
% noSubsetSelected = find(allSubsetSelections == 0, 1); %check if the user select subset
% if ~isempty(noSubsetSelected)
%     nrFigures = 1;
% else
%     nrFigures = min(allSubsetSelections(allSubsetSelections>1));
%     if isempty(nrFigures)
%         nrFigures = 1;
%     end;
% 
%     oneSubsetSelected = find(allSubsetSelections == 1);
% 
%     %duplicate the selected subsets
%     for i=1:length(oneSubsetSelected)
%         nrAxes = 0;
%         for k=1:length(allInfoPerFile.info)
%             temp = allInfoPerFile.info(k);
%             for j=1:length(temp.axes)
%                 nrAxes = nrAxes + 1;
%                 %find the selection
%                 if nrAxes == oneSubsetSelected(i)
%                     %replicate the subset selected.
%                     newSubSelection = repmat(allInfoPerFile.info(k).axes{j}.subsetSelected, 1, nrFigures);
%                     %update the old sub selection with the new one.
%                     allInfoPerFile.info(k).axes{j}.subsetSelected = newSubSelection;
% 
%                     break;
%                 end;
% 
%             end;
%         end
%     end;
% end;
% %end data preparation to plot
% 
% 
% 
% 
% 
% 
% %loop over all files
% for nrFile=1:length(allInfoPerFile)
% 
%     %loop over all figures (subsets)
%     for jj=1:nrFigures
% 
%         %Create figure and get all the axes in the figure
%         [allAxesHandles,allAxesPos1,allAxes1] = WebPlot.getAxisFromTemplate(axesProperties, globalConfig, length(allInfoPerFile.info));
% 
%         sctColors   = [];
%         allAxesInfo = allInfoPerFile(nrFile).info;
% 
%         %loop over all axes
%         for ii=1:length(allAxesInfo)
%             %get the entire axes
%             tempAxes = allAxesInfo(ii).axes;
%             %loop over all plots in axes
%             for kk=1:length(tempAxes)
%                 currentAxes = tempAxes{kk};
% 
%                 %if the axis is a layer, create a new axes with the same
%                 %position
%                 if strcmpi(currentAxes.options.isLayer,'true')
%                     set(gcf,'CurrentAxes',allAxesHandles(ii).axes);
%                     set(gca,'visible','off');
% 
%                     pos   = allAxesHandles(ii).position;
%                     hPlot = axes('pos',pos);
% 
%                     set(gcf,'CurrentAxes',hPlot);
%                     currentAxHandle = gca;
%                 else
%                     if strcmpi(currentAxes.options.axisEqual, 'true')
%                         axis equal;
%                     end;
% 
%                     set(gcf,'CurrentAxes',allAxesHandles(ii).axes);
%                     currentAxHandle = allAxesHandles(ii).axes;
%                 end;
% 
%                 %check if the user select subset
%                 if isfield(currentAxes.myData, 'subset')
%                     currentAxes.myData.subset.currentIndex = currentAxes.subsetSelected(jj);
%                 end;
% 
%                 hold on;
%                 %check the plot type
%                 switch currentAxes.options.plotType
%                     case 'line'
%                         [aPlot, xData, yData] = plotLinesNew(currentAxHandle, currentAxes.myData, currentAxes.options);
% 
%                     case 'bar'
%                         [xData, yData] = getDataPlotBar(currentAxes.myData);
%                         %set different color to each bar.
%                         barColors = {'b', 'r', 'g', 'm', 'k'};
%                         plotOptions.barColor = barColors{kk};
% 
%                         %Plot the bar
%                         aPlot = Plot.plotBar(currentAxHandle, xData, yData, plotOptions);
% 
%                     case 'contour'
%                         %prepare the data to plot
%                         [xData, yData, zData] = getDataContourFigure(currentAxes.myData, currentAxes.options);
% 
%                         %make the plot
%                         [hContour, hColorBar, posAxesBeforeColorbar] = contourFigure(currentAxHandle, xData, yData, zData, currentAxes.options);
%                         aPlot = gca; %update the last plot axes
% 
%                         %TODO: check this because if you have multiple layers
%                         %at top, the plots could be larger than the contour
%                         %set(aPlot, 'position', posAxesBeforeColorbar);
% 
%                         %apply external patch
%                         freezeColors;
%                         sctColors{length(sctColors) + 1} = freezeColorbar(hColorBar);
% 
%                     case 'scale_quiver'
%                         [xData, yData, uData, vData] = getDataScaleQuiver(currentAxes.myData, currentAxes.options);
% 
%                         aPlot = Plot.scaleQuiver(xData, yData, uData, vData, currentAxes.options);
% 
%                     case 'color_quiver'
%                         [xData, yData, uData, vData, nrColors, colorScale] = getDataColorQuiver(currentAxes.myData, currentAxes.options);
% 
%                         [aPlot,hColorBar] = Plot.colorQuiver(xData, yData, uData, vData, nrColors, colorScale, plotOptions);
% 
%                         %apply external patch
%                         freezeColors;
%                         sctColors{length(sctColors) + 1} = freezeColorbar(hColorBar);
% 
%                     case 'triangle'
%                         [xData, yData, zData,connections] = getDataPlotTriangle(currentAxes.myData);
% 
%                         aPlot = Plot.plotTriangle(xData, yData, zData, connections, plotOptions);
%                         
%                     case 'vertical_line'
%                         %get data
%                         [xData, yData] = getDataPlotVerticalLine(currentAxes.myData);
%                         %make plot
%                         aPlot = Plot.plotVerticalLine(xData, yData, currentAxes.myData.selection.xVar, currentAxes.myData.selection.yVar, currentAxes.options);
%                         
%                     case 'horizontal_line'
%                         %get data
%                         [xData, yData] = getDataPlotHorizontalLine(currentAxes.myData);
%                         %make plot
%                         aPlot = Plot.plotHorizontalLine(xData, yData, currentAxes.myData.selection.xVar, currentAxes.myData.selection.yVar, currentAxes.options);
%                     
%                     case 'polar'
%                         %get the data
%                         [xData, yData] = getDataPlotPolar(currentAxes.myData);
%                         %make the plot
%                         aPlot = Plot.plotPolar(xData, yData, plotOptions);
%                 end
% 
%                 %guarantee it is the real first layer in the plot
%                 if kk == 1
%                     hFirstLayer = aPlot;
%                 end;
% 
%                 currentAxes.options.hFirstLayer = hFirstLayer;
% 
%                 %Update the options struct with the ploted data
%                 xVar = currentAxes.myData.selection.xVar;
%                 yVar = currentAxes.myData.selection.yVar;
% 
%                 currentAxes.options.xVarInfo      = currentAxes.myData.dataset.(xVar);
%                 currentAxes.options.xVarInfo.data = xData;
% 
%                 currentAxes.options.yVarInfo      = currentAxes.myData.dataset.(yVar);
%                 currentAxes.options.yVarInfo.data = yData;
% 
%                 if isfield(currentAxes.myData.selection, 'zVar')
%                     zVar = currentAxes.myData.selection.yVar;
%                     currentAxes.options.zVarInfo = currentAxes.myData.dataset.(zVar);
%                 end;
% 
%                 %Apply all the options to the plot
%                 setPlotOptions(currentAxHandle, currentAxes.options);
% 
%                 %update the first layers with all the properties
%                 if kk == 1
%                     hFirstLayer = gca;
%                 end;
% 
%                 %if there is a new layer -> Link axes
%                 if currentAxHandle ~= allAxesHandles(ii).axes
%                     %compare if the current varible is the same as the
%                     %firstlayer
%                     if strcmpi(tempAxes{1}.myData.selection.xVar, currentAxes.myData.selection.xVar) && strcmpi(tempAxes{1}.myData.selection.yVar, currentAxes.myData.selection.yVar)
%                         linkaxes([hFirstLayer; currentAxHandle], 'xy')
%                     elseif strcmp(tempAxes{1}.myData.selection.xVar, currentAxes.myData.selection.xVar)
%                         linkaxes([hFirstLayer; currentAxHandle], 'x')
%                     elseif strcmp(tempAxes{1}.myData.selection.yVar, currentAxes.myData.selection.yVar)
%                         linkaxes([hFirstLayer; currentAxHandle], 'y')
%                     end
%                 end
% 
%                 %put the background "invisible" to see the plot
%                 if strcmp(currentAxes.options.isLayer,'true')
%                     set(currentAxHandle,'visible','off');
%                     set(currentAxHandle,'color','none')
%                 end;
%             end;
% 
%             %by default always show the bottom layer
%             set(hFirstLayer,'visible','on');
% 
%         end;
% 
%         %Fix the colorbarcolor
%         if length(sctColors) > 1
%             for pp=(length(sctColors)-1):-1:1
%                 UtilPlot.freezeColorbarApply(sctColors{pp}); %apply color correction to all colorbars
%             end;
%         end;
% 
%         %complete the template; put texts, tectangles and images
%         WebPlot.completeTemplate(textInAxes, rectanglesInAxes, imagesInAxes, globalConfig);
%     end;
% end;


[myAxes options axesProperties textInAxes imagesInAxes rectanglesInAxes globalConfig saveOptions] = UtilPlot.readTemplateFile(jsonFile);

listSelectedFiles = UtilPlot.getFileList(myAxes);

[allInfoPerFile nrFigures] = WebPlot.loadTemplateData(listSelectedFiles, myAxes, options);

WebPlot.plotTemplate(allInfoPerFile, nrFigures, axesProperties, textInAxes, imagesInAxes, rectanglesInAxes, globalConfig, saveOptions)

