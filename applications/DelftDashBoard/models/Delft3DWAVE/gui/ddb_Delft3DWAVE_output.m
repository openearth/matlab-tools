function ddb_Delft3DWAVE_output(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'checkoutput'}
            checkOutputGrid;
    end
end

%%
function selectGrid
handles = getHandles;
handles = ddb_Delft3DWAVE_setNestGrids(handles);
setHandles(handles);
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);

%%
function checkOutputGrid
handles=getHandles;
val=handles.Model(md).Input.domains(awg).output;
iac=handles.Model(md).Input.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.domains(n).output=val;
end
setHandles(handles);
