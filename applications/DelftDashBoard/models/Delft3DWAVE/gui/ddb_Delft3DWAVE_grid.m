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
nrgrids = handles.Model(md).Input.nrgrids+1;
filename = handles.Model(md).Input.newgrid;
[pathstr,name,ext] = fileparts(filename);
% Set grid values in handles
handles.Model(md).Input.nrgrids = nrgrids;
handles.Model(md).Input.domains=ddb_initializeDelft3DWAVEDomain(handles.Model(md).Input.domainss,nrgrids);
handles.Model(md).Input.gridnames{nrgrids}=name;
handles.activeWaveGrid=nrgrids;
OPT.option = 'read'; OPT.filename = filename;
handles = ddb_generateGridDelft3DWAVE(handles,nrgrids,OPT);
% Set NestGrids
if handles.Model(md).Input.nrgrids>1
   handles.Model(md).Input.domains(nrgrids).nestgrid=handles.Model(md).Input.gridnames{1};
else
    handles.Model(md).Input.domains(nrgrids).nestgrid='';
end
handles = ddb_Delft3DWAVE_setNestGrids(handles);
% Plot new domain
handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);
setHandles(handles);
% Refresh all domains
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);

%%
function deleteGrid

handles=getHandles;
for ii=1:handles.Model(md).Input.nrgrids
    nestgrids{ii} = handles.Model(md).Input.domains(ii).nestgrid;
end
if ~isempty(strmatch(handles.Model(md).Input.domains(awg).gridname,nestgrids,'exact'))
    ddb_giveWarning('text','Cannot delete grid because other grid is nested in it')
    return
else
    % Delete domain from map
    handles=ddb_Delft3DWAVE_plotGrid(handles,'delete','wavedomain',awg,'active',1);
    % Delete domain from struct
    handles.Model(md).Input.domains = removeFromStruc(handles.Model(md).Input.domains, awg);
    handles.Model(md).Input.nrgrids=length(handles.Model(md).Input.domains);
    handles.Model(md).Input.gridnames={''};
    for jj=1:length(handles.Model(md).Input.domains)
        handles.Model(md).Input.gridnames{jj}=handles.Model(md).Input.domains(jj).gridname;
    end
    handles.activeWaveGrid=min(handles.Model(md).Input.nrgrids,awg);
    % Initialize Domain if isempty
    if isempty(handles.Model(md).Input.domains)
        handles.Model(md).Input.nrgrids = 0;
        handles.activeWaveGrid=1;
        handles.Model(md).Input.gridnames={''};
        handles.Model(md).Input.domains=ddb_initializeDelft3DWAVEDomain(handles.Model(md).Input.domains,1);
    end
    % Set NestGrids    
    handles = ddb_Delft3DWAVE_setNestGrids(handles);
    setHandles(handles);
    % Refresh all domains
    ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
end
%%
function selectGrid
% Set NestGrids
handles = getHandles;
handles = ddb_Delft3DWAVE_setNestGrids(handles);
setHandles(handles);
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
