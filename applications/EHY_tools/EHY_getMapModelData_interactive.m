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
[filename, pathname]=uigetfile('*.*','Open the model output file');
if isnumeric(filename); disp('EHY_getMapModelData_interactive stopped by user.'); return; end

% outputfile
outputfile=[pathname filename];
modelType=EHY_getModelType(outputfile);
if isempty(modelType)
    % Automatic procedure failed
    disp('Automatic procedure failed. Please provide input manually.')
    % modelType
    modelTypes={'Delft3D-FM / D-FLOW FM','dfm';...
        'Delft3D 4','d3d';...
        'SIMONA','simona'};
    option=listdlg('PromptString','Choose model type:','SelectionMode','single','ListString',...
        modelTypes(:,1),'ListSize',[300 100]);
    if isempty(option); disp('EHY_getMapModelData_interactive was stopped by user');return; end
    modelType=modelTypes{option,2};
end

% varName
varNames={'Water level','waterlevel';
    'Water depth','waterdepth';
    'x,y-velocity','uv';
    'Salinity','salinity';
    'Temperature','temperature'};
if strcmp(modelType,'dfm'); varNames{end+1,1}='Other info from .nc-file'; end
option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
    varNames(:,1),'ListSize',[300 150]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
OPT.varName=varNames{option,2};

% Option=Other info from .nc-file
if strcmp(modelType,'dfm') && option==length(varNames)
    infonc           = ncinfo(outputfile);
    variablesOnFile0 = {infonc.Variables.Name};
    variablesOnFile  = variablesOnFile0;
    for iV=1:length(variablesOnFile)
        indAttr =  strmatch('long_name',{infonc.Variables(iV).Attributes.Name},'exact');
        if ~isempty(indAttr)
            variablesOnFile{iV}=strcat(variablesOnFile{iV},' [', infonc.Variables(iV).Attributes(indAttr).Value,']');
        end
    end
    option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
        variablesOnFile,'ListSize',[600 300]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    OPT.varName=variablesOnFile0{option};
end

OPT.varName = EHY_nameOnFile(outputfile,OPT.varName);

%% check which dimensions/info is needed from user
dims = EHY_getDimsInfo(outputfile,OPT.varName);
stationsInd = [strmatch('stations',{dims(:).name}); strmatch('cross_section',{dims(:).name}); strmatch('general_structures',{dims(:).name}) ];
if ~isempty(stationsInd)
    stationNames = cellstr(EHY_getStationNames(outputfile,modelType,'varName',OPT.varName));
    option=listdlg('PromptString','From which station would you like you to load the data? (Use CTRL to select multiple stations)','ListString',...
        stationNames,'ListSize',[500 200]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    stat_name=stationNames(option);
else
    stat_name='';
end

%% get required input from user
laydimInd = strmatch('laydim',{dims(:).name});
if ~isempty(laydimInd) && ~strcmp(OPT.varName,'waterlevel')
    gridInfo = EHY_getGridInfo(outputfile,{'no_layers'});
    option=listdlg('PromptString',{'Want to load data from a specific layer?','(Default is, in case of 3D-model, all layers)'},'SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 50]);
    if isempty(option)
        disp('EHY_getmodeldata_interactive was stopped by user');return;
    elseif option==1
        OPT.layer = cell2mat(inputdlg('Layer nr:','',1,{num2str(gridInfo.no_layers)}));
    end
end

timeInd = strmatch('time',{dims(:).name});
if ~isempty(timeInd)
    datenums=EHY_getmodeldata_getDatenumsFromOutputfile(outputfile);
    if length(datenums)>1
        option=inputdlg({['Want to specifiy a certain output period? (Default: all data)' char(10) char(10) 'Start date [dd-mmm-yyyy HH:MM]'],'End date   [dd-mmm-yyyy HH:MM]'},'Specify output period',1,...
            {datestr(datenums(1)),datestr(datenums(end))});
        if ~isempty(option)
            if ~strcmp(datestr(datenums(1)),option{1}) || ~strcmp(datestr(datenums(end)),option{2})
                OPT.t0 = option{1};
                OPT.tend = option{2};
            end
        end
    end
end

% mergePartitions
if EHY_isPartitioned(outputfile,modelType)
    option=listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 100]);
    if option==1
        OPT.mergePartitions=1;
    end
end

%%
extraText='';
if exist('OPT','var')
    fn=fieldnames(OPT);
    for iF=1:length(fn)
        if ischar(OPT.(fn{iF}))
            extraText=[extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
        elseif isnumeric(OPT.(fn{iF}))
            extraText=[extraText ',''' fn{iF} ''',' num2str(OPT.(fn{iF}))];
        end
    end
end

disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['Data = EHY_getMapModelData(''' outputfile '''' extraText ');' ])

disp('start retrieving the data...')
gridInfo=EHY_getGridInfo(outputfile,{'face_nodes_xy'},'mergePartitions',OPT.mergePartitions);
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getMapModelData(outputfile);
else
    Data = EHY_getMapModelData(outputfile,OPT);
end
% add xy data of face_nodes
Data.face_nodes_x=gridInfo.face_nodes_x;
Data.face_nodes_y=gridInfo.face_nodes_y;

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getMapModelData_interactive')

%% output
if nargout==1
    Data.OPT.outputfile=outputfile;
    varargout{1}=Data;
end
