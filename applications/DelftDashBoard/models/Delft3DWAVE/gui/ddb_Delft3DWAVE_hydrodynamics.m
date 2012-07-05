function ddb_Delft3DWAVE_hydrodynamics(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'sethydrodynamics'}
            setHydrodynamics;
        case{'checkwaterlevel'}
            checkWaterLevel;
        case{'checkbedlevel'}
            checkBedLevel;
        case{'checkcurrent'}
            checkCurrent;
        case{'checkwind'}
            checkWind;
        case{'useddbflow'}
            useDDBFlow;
    end
end

%%
function useDDBFlow
handles=getHandles;
handles.Model(md).Input.referencedate=handles.Model(1).Input(1).itDate;
handles.Model(md).Input.mapwriteinterval=handles.Model(1).Input(1).mapInterval;
handles.Model(md).Input.comwriteinterval=handles.Model(1).Input(1).comInterval;
handles.Model(md).Input.writecom=1;
handles.Model(md).Input.coupling='ddbonline';
handles.Model(md).Input.mdffile=handles.Model(1).Input(1).mdfFile;
handles.Model(md).Input.domains(1).flowbedlevel=1;
handles.Model(md).Input.domains(1).flowwaterlevel=1;
handles.Model(md).Input.domains(1).flowvelocity=1;
if handles.Model(1).Input(1).wind
    handles.Model(md).Input.domains(1).flowwind=1;
else
    handles.Model(md).Input.domains(1).flowwind=0;
end
handles.Model(1).Input(1).waves=1;
handles.Model(1).Input(1).onlineWave=1;
if handles.Model(1).Input(1).comInterval==0 || handles.Model(1).Input(1).comStartTime==handles.Model(1).Input(1).comStopTime
    ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!');
end
setHandles(handles);

%%
function setHydrodynamics

handles=getHandles;

ButtonName = questdlg('Couple with Delft3D-FLOW model?', ...
    'Couple with flow', ...
    'Cancel', 'No', 'Yes', 'Yes');
switch ButtonName,
    case 'Cancel',
        return;
    case 'No',
        couplewithflow=0;
    case 'Yes',
        couplewithflow=1;
end

if couplewithflow == 1
   if handles.Model(1).Input(1).comInterval==0 || handles.Model(1).Input(1).comStartTime==handles.Model(1).Input(1).comStopTime
      ddb_giveWarning('text','Please make sure to set the communication file times in Delft3D-FLOW model!'); 
   end
%   handles.Model(md).Input.coupledwithflow=1;
   handles.Model(1).Input(1).waves=1;
   handles.Model(1).Input(1).onlineWave=1;
end

% TODO : change coordsyst
if strcmp(handles.Model(md).Input.flowtype,'ddb')
    handles.Model(md).Input.referencedate=handles.Model(1).Input(1).itDate;
    handles.Model(md).Input.mapwriteinterval=handles.Model(1).Input(1).mapInterval;
    handles.Model(md).Input.comwriteinterval=handles.Model(1).Input(1).comInterval;
    handles.Model(md).Input.writecom=1;
    handles.Model(md).Input.mdffile=handles.Model(1).Input(1).mdfFile;
else
    MDF=ddb_readMDFText(handles.Model(md).Input.mdffile);
    handles.Model(md).Input.referencedate=datenum(MDF.itdate,'yyyy-mm-dd');
    handles.Model(md).Input.mapwriteinterval=MDF.flmap(2);
    handles.Model(md).Input.comwriteinterval=MDF.flpp(2);
    handles.Model(md).Input.writecom=1;
end

%startTime=handles.Model(md).Input.referencedate+MDF.tstart/1440.0;
%stopTime=handles.Model(md).Input.referencedate+MDF.tstop/1440.0;
%timeStep=MDF.dt;
%timeZone=MDF.tzone;

setHandles(handles);


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
