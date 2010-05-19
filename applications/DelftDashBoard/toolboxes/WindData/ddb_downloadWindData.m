function handles=ddb_downloadWindData(handles,startDate,numOfDays);

ii=get(handles.GUIHandles.ListStations,'Value');
stations=handles.Toolbox(tb).Input.WindDataStations.id;
if isempty(stations)
    giveWarning([],'No station selected!');  
    return 
end
outputFile=[getenv('temp') filesep 'WindData_' stations{ii} '.txt'];

switch handles.Toolbox(tb).Input.Source
    case 'Weather Underground'
        stationID = ['/airport/' stations{ii} '/'];
        windData=ddb_getOnlineWindDataEngine(stationID,startDate,numOfDays,outputFile,'No');
    case 'NOAA'
        windData=ddb_getNOAAWindData(stations{ii},startDate,numOfDays,outputFile);
end
if ~isempty(windData)
    handles.Toolbox(tb).Input.windData=windData;
end
