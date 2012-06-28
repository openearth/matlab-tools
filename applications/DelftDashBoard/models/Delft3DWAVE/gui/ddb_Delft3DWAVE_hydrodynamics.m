function ddb_Delft3DWAVE_hydrodynamics(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'checkwaterlevel'}
            checkWaterLevel;
        case{'checkbedlevel'}
            checkBedLevel;
        case{'checkcurrent'}
            checkCurrent;
        case{'checkwind'}
            checkWind;
    end
end

%%
function checkWaterLevel
handles=getHandles;
val=handles.Model(md).Input.domains(awg).flowwaterlevel;
iac=handles.Model(md).Input.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.domains(n).flowwaterlevel=val;
end
setHandles(handles);

%%
function checkBedLevel
handles=getHandles;
val=handles.Model(md).Input.domains(awg).flowbedlevel;
iac=handles.Model(md).Input.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.domains(n).flowbedlevel=val;
end
setHandles(handles);

%%
function checkCurrent
handles=getHandles;
val=handles.Model(md).Input.domains(awg).flowvelocity;
iac=handles.Model(md).Input.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.domains(n).flowvelocity=val;
end
setHandles(handles);

%%
function checkWind
handles=getHandles;
val=handles.Model(md).Input.domains(awg).flowwind;
iac=handles.Model(md).Input.activegrids;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.domains(n).flowwind=val;
end
setHandles(handles);
