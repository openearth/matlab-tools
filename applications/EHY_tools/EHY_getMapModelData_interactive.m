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
[variables,varAndDescr] = EHY_variablesOnFile(outputfile,modelType);

if strcmp(modelType,'dfm')
    % For now, ONLY keep variables that have cell face data
    cellFaceDataInd = [];
    for iV = 1:length(variables)
        infonc = ncinfo(outputfile,variables{iV});
        if numel(infonc.Dimensions)>0 && any(ismember({infonc.Dimensions.Name},{'nmesh2d_face','nFlowElem','mesh2d_nFaces','longitude','dim_x','x'}))
            cellFaceDataInd = [cellFaceDataInd; iV];
        end
    end
    variables   = variables(cellFaceDataInd);
    varAndDescr = varAndDescr(cellFaceDataInd);
end

option=listdlg('PromptString','What kind of data do you want to load?','SelectionMode','single','ListString',...
    varAndDescr,'ListSize',[500 600]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
OPT.varName = variables{option};

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
[~,dimsInd] = EHY_getDimsInfo(outputfile,OPT,modelType);

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
    gridInfo = EHY_getGridInfo(outputfile,{'no_layers'},'gridFile',gridFile,'disp',0);
    if gridInfo.no_layers>1
        optionTxt = {'All 3D-data','From 1 specific model layer','At a certain reference level (horizontal slice)','Data along transect (vertical slice)'};
        typeOfModelFile = EHY_getTypeOfModelFile(outputfile);
        if strcmp(typeOfModelFile,'nc_griddata'); optionTxt(end)=[]; end
        option = listdlg('PromptString',{'Do you want to load:'},'SelectionMode','single','ListString',...
            optionTxt,'ListSize',[300 100]);
        if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
        elseif option == 1 % all 3D-data
            OPT.layer = 0;
        elseif option == 2 % Specific model layer
            nol = num2str(gridInfo.no_layers);
            OPT.layer = cell2mat(inputdlg(['Layer nr (1-' nol '):'],'',1,{nol}));
        elseif option == 3 % Certain reference level
            option = listdlg('PromptString',{'Referenced to:'},'SelectionMode','single','ListString',...
                {'Model reference level','Water level','Bed level'},'ListSize',[300 50]);
            if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
            elseif option == 2 % Water level
                OPT.zRef = 'wl';
            elseif option == 3 % Bed level
                OPT.zRef = 'bed';
            end
            OPT.z = cell2mat(inputdlg('height (m) from ref. level (pos. up)','',1,{'0'}));
        elseif option == 4 % Along transect (vertical slice)
            OPT.mergePartitions = 1;
            OPT.pliFile = makePliFileForSlice(outputfile,OPT);
        end
    end
end

if ~isempty(dimsInd.m) && ~(exist('OPT','var') && isfield(OPT,'pliFile'))
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
if strcmp(modelType,'dfm') && EHY_isPartitioned(outputfile,modelType) && ~(exist('OPT','var') && isfield(OPT,'pliFile'))
        option = listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
            {'Yes','No'},'ListSize',[300 100]);
        if option == 1
            OPT.mergePartitions = 1;
        else
            OPT.mergePartitions = 0;
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
if isfield(OPT,'pliFile')
    disp(['<strong>[Data,gridInfo] = EHY_getMapModelData(''' outputfile '''' extraText ');</strong>' ])
else
    disp(['<strong>Data = EHY_getMapModelData(''' outputfile '''' extraText ');</strong>' ])
end

disp('start retrieving the data...')
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getMapModelData(outputfile);
else
    if isfield(OPT,'pliFile')
        [Data,gridInfo] = EHY_getMapModelData(outputfile,OPT);
    else
        Data = EHY_getMapModelData(outputfile,OPT);
    end
end

% load and add grid information
% (forward this example line to EHY_plotMapModelData if needed)
if exist('OPT','var') && isfield(OPT,'pliFile')
    EHY_getGridInfo_line = '';
else
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
if isempty(EHY_getGridInfo_line)
    assignin('base','gridInfo',gridInfo);
    disp('Variable ''gridInfo'' created by EHY_getMapModelData_interactive')
end

%% output
if nargout > 0
    Data.OPT.outputfile = outputfile;
    varargout{1} = Data;
    if nargout > 1
        varargout{2} = EHY_getGridInfo_line;
    end
end
end

function pliFile = makePliFileForSlice(outputfile,OPT)
figure('units','normalized','outerposition',[0 0 1 1])
title('Click traject using left-mouse-clicks. To stop, press any other button.')
hold on
gridInfo = EHY_getGridInfo(outputfile,'grid','mergePartitions',OPT.mergePartitions);
plot(gridInfo.grid(:,1),gridInfo.grid(:,2))
traject = [];
loop = 1;
while loop == 1
    [x,y,button] = ginput(1);
    if button == 1 % left-mouse-click
        traject = [traject; x y];
        plot(traject(:,1),traject(:,2),'-ob','linewidth',1)
    else
        loop = 0;
    end
end
close
disp('Save traject as ... ');
[filename, pathname] = uiputfile('*.pli','Save traject as ... ');
pliFile = [pathname filename];
landboundary('write',pliFile,traject)
end
