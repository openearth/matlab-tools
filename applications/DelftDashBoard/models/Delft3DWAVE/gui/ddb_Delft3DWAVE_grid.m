function ddb_Delft3DWAVE_grid(varargin)

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addGrid;
        case{'delete'}
            deleteGrid;
        case{'selectgrid'}
            selectGrid;
    end
end

%%
function addGrid

handles=getHandles;
nrgrids = handles.Model(md).Input(ad).NrComputationalGrids+1;
filename = handles.Model(md).Input(ad).newGrid;
[pathstr,name,ext] = fileparts(filename);
% Set grid values in handles
handles.Model(md).Input(ad).NrComputationalGrids = nrgrids;
handles=ddb_initializeDelft3DWAVEDomain(handles,md,ad,nrgrids);
handles.Model(md).Input.ComputationalGrids{nrgrids}=name;
handles.activeWaveGrid=nrgrids;
OPT.option = 'read'; OPT.filename = filename;
handles = ddb_generateGridDelft3DWAVE(handles,nrgrids,OPT);
% Set NestGrids
if handles.Model(md).Input(ad).NrComputationalGrids>1
   handles.Model(md).Input.Domain(nrgrids).NestGrid=handles.Model(md).Input(ad).ComputationalGrids{1};
else
    handles.Model(md).Input.Domain(nrgrids).NestGrid='';
end
handles = ddb_setNestGridsDelft3DWAVE(handles);
% Plot new domain
handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);
setHandles(handles);
% Refresh all domains
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);

%%
function deleteGrid

handles=getHandles;
for ii=1:handles.Model(md).Input(ad).NrComputationalGrids
    nestGrids{ii} = handles.Model(md).Input(ad).Domain(ii).NestGrid;
end
if ~isempty(strmatch(handles.Model(md).Input(ad).Domain(awg).GridName,nestGrids,'exact'))
    ddb_giveWarning('text','Cannot delete grid because other grid is nested in it')
    return
else
    % Delete domain from map
    handles=ddb_Delft3DWAVE_plotGrid(handles,'delete','wavedomain',awg,'active',1);
    % Delete domain from struct
    handles.Model(md).Input(ad).Domain = removeFromStruc(handles.Model(md).Input(ad).Domain, awg);
    handles.Model(md).Input(ad).NrComputationalGrids=length(handles.Model(md).Input(ad).Domain);
    handles.Model(md).Input(ad).ComputationalGrids={''};
    for jj=1:length(handles.Model(md).Input(ad).Domain)
        [pathstr,name,ext] = fileparts(handles.Model(md).Input(ad).Domain(jj).GridFile);
        handles.Model(md).Input(ad).ComputationalGrids{jj}=name;
    end
    handles.activeWaveGrid=min(handles.Model(md).Input(ad).NrComputationalGrids,awg);
    % Initialize Domain if isempty
    if isempty(handles.Model(md).Input(ad).Domain)
        handles.Model(md).Input(ad).NrComputationalGrids = 0;
        handles.activeWaveGrid=1;
        handles.Model(md).Input(ad).ComputationalGrids={''};
        handles=ddb_initializeDelft3DWAVEDomain(handles,md,ad,1);
    end
    % Set NestGrids    
    handles = ddb_setNestGridsDelft3DWAVE(handles);    
    setHandles(handles);
    % Refresh all domains
    ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
end
%%
function selectGrid
% Set NestGrids
handles = getHandles;
handles = ddb_setNestGridsDelft3DWAVE(handles);
setHandles(handles);
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);