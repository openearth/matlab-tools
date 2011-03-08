function handles=ddb_coordConvertObservationStations(handles)

ii=strmatch('ObservationStations',{handles.Toolbox(:).Name},'exact');

h=findobj(gcf,'Tag','ObservationStations');
if ~isempty(h)
    x=handles.Toolbox(ii).Input.observationStations.x;
    y=handles.Toolbox(ii).Input.observationStations.y;
    cs.Name=handles.Toolbox(ii).Input.observationStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).Input.observationStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    handles.Toolbox(ii).Input.observationStations.xy=[x y];
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveObservationeStation');
if ~isempty(h)
    n=handles.Toolbox(ii).Input.ActiveObservationStation;
    x=handles.Toolbox(ii).Input.observationStations.x(n);
    y=handles.Toolbox(ii).Input.observationtations.y(n);
    cs.Name=handles.Toolbox(ii).Input.observationStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).Input.observationStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.coordinateSystem);
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end
