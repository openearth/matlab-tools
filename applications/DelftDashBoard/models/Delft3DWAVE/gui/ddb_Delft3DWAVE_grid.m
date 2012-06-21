function ddb_Delft3DWAVE_grid(varargin)

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dwave.grids.gridpanel.grid');
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
tmp = handles.Model(md).Input(ad).NrComputationalGrids+1;
handles=ddb_initializeDelft3DWAVEDomain(handles,md,ad,tmp);
[pathstr,name,ext] = fileparts(handles.Model(md).Input(ad).newGrd);
handles.Model(md).Input(ad).ComputationalGrids{tmp} = name;
handles.Model(md).Input(ad).Domain(tmp).GrdFile = handles.Model(md).Input(ad).newGrd;
handles.Model(md).Input(ad).NrComputationalGrids = tmp;
fid = fopen(handles.Model(md).Input(ad).Domain(tmp).GrdFile,'r');
[Temp,Rest] = strtok(fgetl(fid),'=');
fclose(fid);
handles.Model(md).Input(ad).Domain(tmp).Coordsyst = Rest(3:end);
handles.Model(md).Input(ad).Domain(tmp).EncFile   = [name '.enc'];
setHandles(handles);

%%
function deleteGrid

handles=getHandles;
handles.Model(md).Input(ad).Domain = removeFromStruc(handles.Model(md).Input(ad).Domain, awg);
handles.Model(md).Input(ad).NrComputationalGrids=length(handles.Model(md).Input(ad).Domain);
handles.Model(md).Input(ad).ComputationalGrids={''};
for jj=1:length(handles.Model(md).Input(ad).Domain)
    [pathstr,name,ext] = fileparts(handles.Model(md).Input(ad).Domain(jj).GrdFile);
    handles.Model(md).Input(ad).ComputationalGrids{jj}=name;
end
if isempty(handles.Model(md).Input(ad).Domain)
    handles.Model(md).Input(ad).NrComputationalGrids = 0;
    handles.Model(md).Input(ad).ComputationalGrids={''};
    handles=ddb_initializeDelft3DWAVEDomain(handles,md,ad,1);
end
setHandles(handles);

%%
function selectGrid
ddb_plotDelft3DWAVE('update','domain',0,'active',1);
