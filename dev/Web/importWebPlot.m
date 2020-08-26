function [dataToLoad options axesProperties textInAxes imagesInAxes rectanglesInAxes globalConfig] = importWebPlot(jsonFile)
%read the json file
elements = loadjson(jsonFile);

myPlots    = elements{1}.axes;
dataToLoad = [];
nrAxes     = 0;
for ii = 1:length(myPlots)
    %get the data for each plot
    axesName   = strcat('axes', num2str(ii-1));
    dataInAxes = [];
    realPlots  = myPlots{ii}.plot;
    for jj=1:length(realPlots)
        dataInAxesName = strcat('dataInPlot', num2str(jj-1));        
        %read the dataset json
        newDataset = loadjson(realPlots{jj}.dataset);
        dataInAxes.(dataInAxesName) = realPlots{jj};
        %set the rigth dataset value
        dataInAxes.(dataInAxesName).dataset = newDataset{1};
    end;
    %set the plot data in the dataToLoadStuct
    dataToLoad.(axesName) = dataInAxes;
end;

%get the options
myOptions = elements{1}.options;
for ii=1:length(myOptions)
    options(ii).options = myOptions{ii};
    
    %add some additional options
    if options(ii).options.hideAxis == 0
        options(ii).options.axisVisible = 'on';
    else
        options(ii).options.axisVisible = 'off';
    end;
end;

tempAxes = elements{2};

%get the axes properties
axesProperties = [];
for ii=1:length(tempAxes)
    %get the plots
    if strcmpi(tempAxes{ii}.type, 'plot')
        aux = tempAxes{ii};
        aux = rmfield(aux, 'plotId');
        aux = rmfield(aux, 'type');
        aux.id = [];
        axesProperties = [axesProperties aux];
        
        continue
    end;
end;

tempAxes = elements{3};
textInAxes = [];
%get the text
for ii=1:length(tempAxes)
    %get the texts
    if strcmpi(tempAxes{ii}.type, 'text')
        tempTextInAxes    = tempAxes{ii};
        tempTextInAxes.id = [];
        tempTextInAxes.textId = [];
        tempTextInAxes = rmfield(tempTextInAxes, 'type');
        textProperties    = loadjson(tempAxes{ii}.properties);
        %merge the struct adding the other properties
        allPropTextInAxes = catstruct(tempTextInAxes,textProperties);
        textInAxes        = [textInAxes allPropTextInAxes];
    end;
end;

tempAxes     = elements{4};
imagesInAxes = [];

%get the images
for ii=1:length(tempAxes)
    %get the images
    if strcmpi(tempAxes{ii}.type, 'image')
        tempImagesInAxes   = tempAxes{ii};
        tempImagesInAxes   = rmfield(tempImagesInAxes, 'imageId');
        tempImagesInAxes   = rmfield(tempImagesInAxes, 'type');
        tempImagesInAxes.id = [];
        imageProperties    = loadjson(tempAxes{ii}.properties);
        %merge the struct adding the other properties
        allPropImageInAxes = catstruct(tempImagesInAxes,imageProperties);
        imagesInAxes       = [imagesInAxes allPropImageInAxes];
    end;
end;

%get rectangles
tempRectangles = elements{5};
rectanglesInAxes = [];
for ii=1:length(tempRectangles)
    %get the rectangles
    rectanglesInAxes = [rectanglesInAxes tempRectangles{ii}];
end;

%get globalconfig
tempGlobalConfig = elements{6};
globalConfig     = tempGlobalConfig;

%validate the data, if empty data return empty struct;
if ~isa(rectanglesInAxes, 'struct')
    rectanglesInAxes = struct;
end;
if ~isa(imagesInAxes, 'struct')
    imagesInAxes = struct;
end;
if ~isa(textInAxes, 'struct')
    textInAxes = struct;
end;

executePloWithTemplate(dataToLoad, options, axesProperties, textInAxes, rectanglesInAxes, imagesInAxes, globalConfig, [], 0);