function varargout = EHY_getMapModelData_interactive
%% EHY_getMapModelData_interactive
%
% Interactive retrieval of model data using EHY_getMapModelData
% Example: Data = EHY_getMapModelData_interactive
%
% created by Julien Groenenboom, October 2018
%
%%

% outputFile
disp('Open the model output file')
[filename, pathname] = uigetfile('*.*','Open the model output file');
if isnumeric(filename); disp('EHY_getMapModelData_interactive stopped by user.'); return; end

% outputfile
outputfile = [pathname filename];
modelType = EHY_getModelType(outputfile);
if isempty(modelType)
    % Automatic procedure failed
    disp('Automatic procedure failed. Please provide input manually.')
    % modelType
    modelTypes = {'Delft3D-FM / D-FLOW FM','dfm';...
        'Delft3D 4','d3d';...
        'SIMONA','simona'};
    option = listdlg('PromptString','Choose model type:','SelectionMode','single','ListString',...
        modelTypes(:,1),'ListSize',[300 100]);
    if isempty(option); disp('EHY_getMapModelData_interactive was stopped by user');return; end
    modelType = modelTypes{option,2};
end

% varName
varNames = {'Water level','waterlevel';
    'Water depth','waterdepth';
    'x,y-velocity','uv';
    'Salinity','salinity';
    'Temperature','temperature'};
if strcmp(modelType,'dfm');    varNames{end+1,1} = 'Other info from .nc-file';    end
if strcmp(modelType,'delwaq'); varNames{end+1,1} = 'Other info from delwaq-file'; end
option = listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
    varNames(:,1),'ListSize',[300 150]);
if isempty(option); disp('EHY_getMapModelData_interactive was stopped by user');return; end
OPT.varName = varNames{option,2};

% Option = Other info from .nc-file
if ismember(modelType,{'dfm','delwaq'}) && option == length(varNames)
    if strcmp(modelType,'dfm')
        infonc           = ncinfo(outputfile);
        variablesOnFile  = {infonc.Variables.Name};
        variablesOnFileInclAttr = variablesOnFile;
        cellFaceDataInd  = [];
        for iV = 1:length(variablesOnFile)
            % add attribute info - long_name
            indAttr =  strmatch('long_name',{infonc.Variables(iV).Attributes.Name},'exact');
            if ~isempty(indAttr)
                variablesOnFileInclAttr{iV} = strcat(variablesOnFile{iV},' [', infonc.Variables(iV).Attributes(indAttr).Value,']');
            end
            
            % keep variables that have cell face data
            if numel(infonc.Variables(iV).Dimensions)>0 && any(ismember({infonc.Variables(iV).Dimensions.Name},{'nmesh2d_face','nFlowElem','mesh2d_nFaces'}))
                cellFaceDataInd = [cellFaceDataInd; iV];
            end
        end
        variablesOnFile         = variablesOnFile(cellFaceDataInd);
        variablesOnFileInclAttr = variablesOnFileInclAttr(cellFaceDataInd);
    elseif strcmp(modelType,'delwaq')
        dw = delwaq('open',outputfile);
        variablesOnFile = dw.SubsName;
        variablesOnFileInclAttr = variablesOnFile;
    end
    
    if isempty(variablesOnFileInclAttr)
        error('There is no cell face data available to plot in this file')
    end
    option = listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
        variablesOnFileInclAttr,'ListSize',[600 300]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    OPT.varName = variablesOnFile{option};
end

[OPT.varName,varNameInput] = EHY_nameOnFile(outputfile,OPT.varName);
if strcmp(OPT.varName,'noMatchFound')
    error(['Requested variable (' varNameInput ') not available in model output'])
end

%% gridFile for DELWAQ
gridFile = '';
if strcmp(modelType,'delwaq')
    disp('Open (if you think it is needed, otherwise cancel) the corresponding grid file (*.lga, *.cco, *.nc)')
    [filename, pathname] = uigetfile({'*.lga;*.cco', 'Structured grid files';
        '*.nc',  'Unstructured grid files'},'Open (if you think it is needed, otherwise cancel) the corresponding grid file (*.lga, *.cco, *.nc)');
    if ~isnumeric(filename)
        gridFile = [pathname filename];
        OPT.gridFile = gridFile; % use this in feedback script-line
    end
end

%% check which dimensions/info is needed from user
[dims,dimsInd] = EHY_getDimsInfo(outputfile,OPT,modelType);

%% get required input from user
if ~isempty(dimsInd.time)
    datenums = EHY_getmodeldata_getDatenumsFromOutputfile(outputfile);
    if length(datenums)>1
        option = inputdlg({['Want to specifiy a certain output period? (Default: all data)' newline newline 'Start date [dd-mmm-yyyy HH:MM]'],'End date   [dd-mmm-yyyy HH:MM]'},'Specify output period',1,...
            {datestr(datenums(1)),datestr(datenums(end))});
        if ~isempty(option)
            if ~strcmp(datestr(datenums(1)),option{1}) || ~strcmp(datestr(datenums(end)),option{2})
                OPT.t0 = option{1};
                OPT.tend = option{2};
            end
        else
            disp('EHY_getMapModelData_interactive was stopped by user');return;
        end
    end
end

if ~isempty(dimsInd.layers)
    gridInfo = EHY_getGridInfo(outputfile,{'no_layers'},'gridFile',gridFile);
    if gridInfo.no_layers>1
        option = listdlg('PromptString',{'Want to load data from a specific layer or','at a certain reference level?'},'SelectionMode','single','ListString',...
            {'Specific model layer','Certain reference level'},'ListSize',[300 50]);
        if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
        elseif option == 1 % Specific model layer
            nol = num2str(gridInfo.no_layers);
            OPT.layer = cell2mat(inputdlg(['Layer nr (1-' nol '):'],'',1,{nol}));
        elseif option == 2 % Certain reference level
            option = listdlg('PromptString',{'Referenced to:'},'SelectionMode','single','ListString',...
                {'Model reference level','Water level','Bed level'},'ListSize',[300 50]);
            if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
            elseif option == 2 % Water level
                OPT.zRef = 'wl';
            elseif option == 3 % Bed level
                OPT.zRef = 'bed';
            end
            OPT.z = cell2mat(inputdlg('height (m) from ref. level (pos. up)','',1,{'0'}));
        end
    end
end

if ~isempty(dimsInd.m)
    gridInfo = EHY_getGridInfo(outputfile,{'dimensions'},'gridFile',gridFile);
    option = inputdlg({['Want to specifiy a certain [m,n]-domain? (Default: 0 [all data])' newline newline 'm-range [1:' num2str(gridInfo.MNKmax(1)) ']'],...
        ['n-range [1:' num2str(gridInfo.MNKmax(2)) ']']},'Specify domain',1,{'0','0'});
    if isempty(option)
        disp('EHY_getMapModelData_interactive was stopped by user');return;
    else
        OPT.m = option{1};
        OPT.n = option{2};
    end
end

% mergePartitions
if strcmp(modelType,'dfm')
    if EHY_isPartitioned(outputfile,modelType)
        option = listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
            {'Yes','No'},'ListSize',[300 100]);
        if option == 1
            OPT.mergePartitions = 1;
        else
            OPT.mergePartitions = 0;
        end
    end
end

%%
extraText = '';
if exist('OPT','var')
    fn = fieldnames(OPT);
    for iF = 1:length(fn)
        if ischar(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
        elseif isnumeric(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',' num2str(OPT.(fn{iF}))];
        end
    end
end

disp([newline 'Note that next time you want to get this data, you can also use:'])
disp(['<strong>Data = EHY_getMapModelData(''' outputfile '''' extraText ');</strong>' ])

disp('start retrieving the data...')
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getMapModelData(outputfile);
else
    Data = EHY_getMapModelData(outputfile,OPT);
end

% load and add grid information
% (forward this example line to EHY_plotMapModelData if needed)
if strcmp(modelType,'dfm')
    if isfield(OPT,'mergePartitions') && OPT.mergePartitions==0
        EHY_getGridInfo_line = ['gridInfo = EHY_getGridInfo(''' outputfile ''',{''face_nodes_xy''},''mergePartitions'',0);'];
    else
        EHY_getGridInfo_line = ['gridInfo = EHY_getGridInfo(''' outputfile ''',{''face_nodes_xy''});'];
    end
elseif strcmp(modelType,'d3d')
    EHY_getGridInfo_line = ['gridInfo = EHY_getGridInfo(''' outputfile ''',{''XYcor''},''m'',OPT.m,''n'',OPT.n);'];
elseif strcmp(modelType,'delwaq')
    [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(gridFile);
    if strcmp(typeOfModelFileDetail,'nc')
        EHY_getGridInfo_line = ['gridInfo = EHY_getGridInfo(''' gridFile ''',{''face_nodes_xy''});'];
    elseif ismember(typeOfModelFileDetail,{'lga','cco'})
        EHY_getGridInfo_line = ['gridInfo = EHY_getGridInfo(''' gridFile ''',{''XYcor''},''m'',OPT.m,''n'',OPT.n);'];
    end
end
eval(EHY_getGridInfo_line);

% add grid data
if isfield(gridInfo,'face_nodes_x')
    Data.face_nodes_x = gridInfo.face_nodes_x;
    Data.face_nodes_y = gridInfo.face_nodes_y;
elseif isfield(gridInfo,'Xcor')
    Data.Xcor = gridInfo.Xcor;
    Data.Ycor = gridInfo.Ycor;
end

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getMapModelData_interactive')

%% output
if nargout > 0
    Data.OPT.outputfile = outputfile;
    varargout{1} = Data;
    if nargout > 1
         varargout{2} = EHY_getGridInfo_line;
    end
end
