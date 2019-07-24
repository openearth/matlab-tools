function varargout=EHY_getMapModelData_interactive
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
varNames={'Water level','wl';...
    'Water depth','wd';...
    'Velocities','uv';...
    'Salinity','sal';
    'Temperature','tem'};
option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
    varNames(:,1),'ListSize',[300 100]);
if isempty(option); disp('EHY_getMapModelData_interactive was stopped by user');return; end
OPT.varName=varNames{option,2};

% layer
gridInfo=EHY_getGridInfo(outputfile,'no_layers');
if ~ismember(OPT.varName,{'wl','wd'}) && gridInfo.no_layers>1
    option=listdlg('PromptString',{['Want to load data from a specific layer? nr of layers=' num2str(gridInfo.no_layers) ],...
        '(Default is, in case of 3D-model, all layers)'},'SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 50]);
    if option==1
        OPT.layer = cell2mat(inputdlg('Layer nr:',' ',1,cellstr(num2str(gridInfo.no_layers))));
    end
end

% t0 and tend
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

% mergePartitions
if strcmp(modelType,'dfm') && strcmp(outputfile(end-6:end),'_map.nc') && ~isempty(str2num(outputfile(end-10:end-7)))
    option=listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 100]);
    if option==1
        OPT.mergePartitions=1;
    end
end

if strcmp(OPT.varName,'wl')
    OPT=rmfield(OPT,'varName');
end
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
Data.face_nodes_y=gridInfo.face_nodes_x;

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getMapModelData_interactive')
%% output
if nargout==1
    Data.OPT.outputfile=outputfile;
    varargout{1}=Data;
end

