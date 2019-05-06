function EHY_getmodeldata_interactive
%% EHY_getmodeldata_interactive
%
% Interactive retrieval of model data using EHY_getmodeldata
% Example: Data = EHY_getmodeldata_interactive
%
% created by Julien Groenenboom, January 2018
%
%%

% outputFile
disp('Open the model output file')
[filename, pathname]=uigetfile('*.*','Open the model output file');
if isnumeric(filename); disp('EHY_getmodeldata_interactive stopped by user.'); return; end

% outputfile
outputfile=[pathname filename];
modelType=EHY_getModelType(outputfile);
if isempty(modelType)
    % Automatic procedure failed
    disp('Automatic procedure failed. Please provide input manually.')
    % modelType
    modelTypes={'Delft3D-FM / D-FLOW FM','dflowfm';...
        'Delft3D 4','delft3d4';...
        'SIMONA','simona';...
        'SOBEK3','sobek3';...
        'SOBEK3_new','sobek3_new';...
        'IMPLIC','implic'};
    option=listdlg('PromptString','Choose model type:','SelectionMode','single','ListString',...
        modelTypes(:,1),'ListSize',[300 100]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    modelType=modelTypes{option,2};
end

% varName
varNames={'Water level','waterlevel';
    'Water depth','waterdepth';
    'x-velocity','x_velocity';
    'y-velocity','y_velocity';
    'Salinity','salinity';
    'Temperature','temperature';
    'z-coordinates (pos. up) of cell centers','Zcen';
    'z-coordinates (pos. up) of cell interfaces','Zint'};
if strcmp(modelType,'dfm'); varNames{end+1,1}='Other info from .nc-file'; end
option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
    varNames(:,1),'ListSize',[300 150]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
OPT.varName=varNames{option,2};

% Option=Other info from .nc-file
if strcmp(modelType,'dfm') && option==length(varNames)
    infonc          = ncinfo(outputfile);
    variablesOnFile = {infonc.Variables.Name};
    option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
        variablesOnFile,'ListSize',[300 150]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    OPT.varName=variablesOnFile{option};
end

%% check which dimensions/info is needed from user
if strcmp(modelType,'dfm')
    infonc = ncinfo(outputfile);
    nr_var = find(strcmp(OPT.varName,{infonc.Variables.Name}) == 1,1);
    dimNames={infonc.Variables(nr_var).Dimensions.Name};
    dimLengths=[infonc.Variables(nr_var).Dimensions.Length];
end

if ~strcmp(modelType,'dfm') || ismember('stations',dimNames) || ismember('cross_section',dimNames) % stat_name
    stationNames = cellstr(EHY_getStationNames(outputfile,modelType,'varName',OPT.varName));
    option=listdlg('PromptString','From which station would you like you to load the data? (Use CTRL to select multiple stations)','ListString',...
        stationNames,'ListSize',[500 200]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    stat_name=stationNames(option);
else
    stat_name='';
end

if ~strcmp(modelType,'dfm') || ismember('laydim',dimNames) % layer
    gridInfo=EHY_getGridInfo(outputfile,'no_layers');
    if ~strcmp(OPT.varName,'wl') && gridInfo.no_layers>1
        option=listdlg('PromptString',{'Want to load data from a specific layer?','(Default is, in case of 3D-model, all layers)'},'SelectionMode','single','ListString',...
            {'Yes','No'},'ListSize',[300 50]);
        if isempty(option)
            disp('EHY_getmodeldata_interactive was stopped by user');return;
        elseif option==1
            OPT.layer = cell2mat(inputdlg('Layer nr:','',1,{num2str(gridInfo.no_layers)}));
        end
    end
end

if ~strcmp(modelType,'dfm') || ismember('time',dimNames) % t0 and tend
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

%%
extraText='';
if exist('OPT','var')
    fn=fieldnames(OPT);
    for iF=1:length(fn)
        extraText=[extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
    end
end

if ~isempty(stat_name)
    stations=strtrim(sprintf('''%s'',',stat_name{:}));
    stations=['{' stations(1:end-1) '}'];
else
    stations='''''';
end

disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['Data = EHY_getmodeldata(''' outputfile ''',' stations ',''' modelType '''' extraText ');' ])

disp('start retrieving the data...')
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getmodeldata(outputfile,stat_name,modelType);
else
    Data = EHY_getmodeldata(outputfile,stat_name,modelType,OPT);
end

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getmodeldata_interactive')
