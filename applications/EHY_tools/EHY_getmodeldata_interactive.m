function EHY_getmodeldata_interactive
%% EHY_getmodeldata_interactive
%
% Interactive retrieval of model data using EHY_getmodeldata
% Example: Data = EHY_getmodeldata_interactive
% 
% created by Julien Groenenboom, January 2018
%
EHYs(mfilename);
%%
try % Automatic procedure
    % outputFile
    disp('Open the model output file')
    [filename, pathname]=uigetfile('*.*','Open the model output file');
    outputFile=[pathname filename];
    
    % modelType
    [modelType,mdFile]=EHY_getModelType(outputFile);
    
    % sim_dir
    sim_dir=fileparts(mdFile);
    
    % runid
    switch modelType
        case 'mdu'
            [~,runid]=fileparts(mdFile);
        case 'mdf'
            expression = 'trih-(\w+).dat';
            [runid,~] = regexp(outputFile,expression,'tokens','match');
            runid=char(runid{1});
        case 'siminp'
            expression = 'SDS-(\w+)';
            [runid,~] = regexp(outputFile,expression,'tokens','match');
            runid=char(runid{1});
    end
catch % Automatic procedure failed
    disp('Automatic procedure failed. Please provide input manually.')
    disp('1) Specify the simulation directory')
    % sim_dir
    sim_dir=uigetdir('*.*','Open the simulation directory');
    if isnumeric(sim_dir); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    
    % runid
    disp('2) Specify the run id')
    runid = inputdlg('Specify the run id:');
    runid=runid{1};
    if isempty(runid); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    
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
varNames={'Water level','wl';...
    'Velocities','uv';
    'Salinity','sal';
    'Temperature','tem'};
option=listdlg('PromptString','What kind of time series do you want to load?','SelectionMode','single','ListString',...
    varNames(:,1),'ListSize',[300 100]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
OPT.varName=varNames{option,2};

% stat_name
stationNames = cellstr(EHY_getStationNames(sim_dir,runid,modelType));
option=listdlg('PromptString','From which station would you like you to load the data? (Use CTRL to select multiple stations)','ListString',...
    stationNames,'ListSize',[500 200]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
stat_name=stationNames(option);

% layer
if ~strcmp(OPT.varName,'wl')
    option=listdlg('PromptString',{'Want to load data from a specific layer?','(Default is, in case of 3D-model, all layers)'},'SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 50]);
    if option==1
        OPT.layer = cell2mat(inputdlg('Layer nr:'));
    end
end
% t0 and tend
[refdate,tunit,tstart,tstop]=getTimeInfoFromMdFile(mdFile);
t0=datestr(refdate+tstart*timeFactor(tunit,'d'));
tend=datestr(refdate+tstop*timeFactor(tunit,'d'));
option=inputdlg({['Want to specifiy a certain output period? (Default: all data)' char(10) char(10) 'Start date [dd-mmm-yyyy HH:MM]'],'End date   [dd-mmm-yyyy HH:MM]'},'Specify output period',1,...
    {t0,tend});
if ~isempty(option)
    if ~strcmp(t0,option{1}) || ~strcmp(tend,option{2})
        OPT.t0 = option{1};
        OPT.tend = option{2};
    end
end

if strcmp(OPT.varName,'wl')
    OPT=rmfield(OPT,'varName');
end
extraText='';
if exist('OPT','var')
    fn=fieldnames(OPT);
    for iF=1:length(fn)
        extraText=[extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
    end
end

stats=strtrim(sprintf('''%s'',',stat_name{:}));
stats2=['{' stats(1:end-1) '}'];
disp('start retrieving the data...')
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getmodeldata(sim_dir,runid,stat_name,modelType);
else
    Data = EHY_getmodeldata(sim_dir,runid,stat_name,modelType,OPT);
end

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getmodeldata_interactive')

disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['Data = EHY_getmodeldata(''' sim_dir ''',''' runid ''',' stats2 ',''' modelType '''' extraText ')' ])

