function handles = ddb_fixtimestepDelft3DFLOW(handles, id)
%ddb_fixtimestepDelft3DFLOW  One line description goes here.

%% 0. Fixed
timestepmodel = handles.model.delft3dflow.domain(id).timeStep;

% 1. Stop time multiple with timestep of model
durationold = (handles.model.delft3dflow.domain(id).stopTime - handles.model.delft3dflow.domain(id).startTime)*24*60;
durationnew = (round(durationold/timestepmodel))*timestepmodel;
handles.model.delft3dflow.domain(id).stopTime = handles.model.delft3dflow.domain(id).startTime + durationnew/24/60;

% 2. Fix all stop times
ddb_updateOutputTimesDelft3DFLOW
handles.model.delft3dflow.domain(id).comStopTime=handles.model.delft3dflow.domain(id).stopTime;
handles.model.delft3dflow.domain(id).mapStartTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).mapStopTime=handles.model.delft3dflow.domain(id).stopTime;
handles.model.delft3dflow.domain(id).comStartTime=handles.model.delft3dflow.domain(id).startTime;
handles.model.delft3dflow.domain(id).comStopTime=handles.model.delft3dflow.domain(id).stopTime;

% 3. Map interval
val1a =  handles.model.delft3dflow.domain(id).mapInterval/timestepmodel;
val1a = round(val1a);
handles.model.delft3dflow.domain(id).mapInterval = val1a*timestepmodel;
val1a =  handles.model.delft3dflow.domain(id).mapInterval/timestepmodel;

val1b =  durationnew/handles.model.delft3dflow.domain(id).mapInterval
val1b = round(val1b);
handles.model.delft3dflow.domain(id).mapInterval = durationnew/val1b;
val1b =  durationnew/handles.model.delft3dflow.domain(id).mapInterval

while ~(val1a == round(val1a)) || ~(val1b == round(val1b));
    val1a = round(val1a)-1;
    handles.model.delft3dflow.domain(id).mapInterval = val1a*timestepmodel;
    val1a =  handles.model.delft3dflow.domain(id).mapInterval/timestepmodel;
    val1b =  durationnew/handles.model.delft3dflow.domain(id).mapInterval;
    handles.model.delft3dflow.domain(id).mapInterval = durationnew/val1b;
end

% 4. History interval
val1a =  handles.model.delft3dflow.domain(id).hisInterval/timestepmodel;
val1a = round(val1a);
handles.model.delft3dflow.domain(id).hisInterval = val1a*timestepmodel;
val1a =  handles.model.delft3dflow.domain(id).hisInterval/timestepmodel;

val1b =  durationnew/handles.model.delft3dflow.domain(id).hisInterval
val1b = round(val1b);
handles.model.delft3dflow.domain(id).hisInterval = durationnew/val1b;
val1b =  durationnew/handles.model.delft3dflow.domain(id).hisInterval;

while ~(val1a == round(val1a)) || ~(val1b == round(val1b));
    val1a = round(val1a)-1;
    handles.model.delft3dflow.domain(id).hisInterval = val1a*timestepmodel;
    val1a =  handles.model.delft3dflow.domain(id).hisInterval/timestepmodel;
    val1b =  durationnew/handles.model.delft3dflow.domain(id).hisInterval;
    handles.model.delft3dflow.domain(id).hisInterval = durationnew/val1b;
end

% 5. Smoothing time
val3 = round(handles.model.delft3dflow.domain(id).smoothingTime / timestepmodel);
handles.model.delft3dflow.domain(id).smoothingTime = val3*timestepmodel;
