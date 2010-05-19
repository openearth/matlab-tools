function handles=ddb_coordConvertObservationsDatabase(handles)

ii=strmatch('ObservationsDatabase',{handles.Toolbox(:).Name},'exact');

h=findall(gcf,'Tag','ObservationStations');
if ~isempty(h)
    x=handles.Toolbox(ii).ObservationStations.x;
    y=handles.Toolbox(ii).ObservationStations.y;
    cs.Name=handles.Toolbox(ii).ObservationStations.CoordinateSystem;
    cs.Type=handles.Toolbox(ii).ObservationStations.CoordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    handles.Toolbox(ii).ObservationStations.xy=[x y];
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findall(gca,'Tag','ActiveObservationeStation');
if ~isempty(h)
    n=handles.Toolbox(ii).ActiveObservationStation;
    x=handles.Toolbox(ii).ObservationStations.x(n);
    y=handles.Toolbox(ii).Observationtations.y(n);
    cs.Name=handles.Toolbox(ii).ObservationStations.CoordinateSystem;
    cs.Type=handles.Toolbox(ii).ObservationStations.CoordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end
