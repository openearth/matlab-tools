function handles=ddb_initializeObservationStations(handles,varargin)

ii=strmatch('ObservationStations',{handles.Toolbox(:).name},'exact');

lst=dir([handles.toolBoxDir 'observationsdatabase\*.mat']);

for i=1:length(lst)

    disp(['Loading observations database ' lst(i).name(1:end-4) ' ...']);

    load([handles.toolBoxDir 'observationsdatabase\' lst(i).name(1:end-4) '.mat']);

    handles.Toolbox(ii).Input.databases{i}=s.DatabaseName;
    handles.Toolbox(ii).Input.database(i).shortName=lst(i).name(1:end-4);

    handles.Toolbox(ii).Input.database(i).databaseName=s.DatabaseName;
    handles.Toolbox(ii).Input.database(i).institution=s.Institution;
    handles.Toolbox(ii).Input.database(i).coordinateSystem=s.CoordinateSystem;
    handles.Toolbox(ii).Input.database(i).coordinateSystemType=s.CoordinateSystemType;
    handles.Toolbox(ii).Input.database(i).serverType=s.ServerType;
    handles.Toolbox(ii).Input.database(i).URL=s.URL;
    handles.Toolbox(ii).Input.database(i).stationNames=s.Name;
    handles.Toolbox(ii).Input.database(i).idCodes=s.IDCode;
    handles.Toolbox(ii).Input.database(i).parameters=s.Parameters;
    handles.Toolbox(ii).Input.database(i).x=s.x;
    handles.Toolbox(ii).Input.database(i).y=s.y;
    handles.Toolbox(ii).Input.database(i).xLoc=s.x;
    handles.Toolbox(ii).Input.database(i).yLoc=s.y;

end

handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.stopTime=floor(now)+30;
handles.Toolbox(ii).Input.timeStep=10.0;

handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeObservationStation=1;

handles.Toolbox(ii).Input.observationStationHandle=[];
handles.Toolbox(ii).Input.activeObservationStationHandle=[];

handles.Toolbox(ii).Input.radio01=-1;
handles.Toolbox(ii).Input.radio02=0;
handles.Toolbox(ii).Input.radio03=0;
handles.Toolbox(ii).Input.radio04=0;
handles.Toolbox(ii).Input.radio05=0;
handles.Toolbox(ii).Input.radio06=0;
handles.Toolbox(ii).Input.radio07=0;
handles.Toolbox(ii).Input.radio08=0;
handles.Toolbox(ii).Input.radio09=0;
handles.Toolbox(ii).Input.radio10=0;
handles.Toolbox(ii).Input.radio11=0;
handles.Toolbox(ii).Input.radio12=0;
handles.Toolbox(ii).Input.radio13=0;
handles.Toolbox(ii).Input.radio14=0;
handles.Toolbox(ii).Input.radio15=0;
