function handles=ddb_coordConvertTideStations(handles)

ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');

ddb_plotTideStations('delete');
handles.Toolbox(ii).Input.tideStationHandle=[];
handles.Toolbox(ii).Input.ActiveTideStationHandle=[];

for iac=1:length(handles.Toolbox(ii).Input.databases)
    x=handles.Toolbox(ii).Input.database(iac).x;
    y=handles.Toolbox(ii).Input.database(iac).y;
    cs.name=handles.Toolbox(ii).Input.database(iac).coordinateSystem;
    cs.type=handles.Toolbox(ii).Input.database(iac).coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    handles.Toolbox(ii).Input.database(iac).xLoc=x;
    handles.Toolbox(ii).Input.database(iac).yLoc=y;
end
