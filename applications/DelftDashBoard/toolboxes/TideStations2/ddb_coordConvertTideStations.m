function handles=ddb_coordConvertTideDatabase(handles)

ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');

h=findobj(gcf,'Tag','TideStations');
if ~isempty(h)
    x=handles.Toolbox(ii).Input.tideStations.x;
    y=handles.Toolbox(ii).Input.tideStations.y;
    cs.name=handles.Toolbox(ii).Input.tideStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).Input.tideStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    handles.Toolbox(ii).Input.tideStations.xy=[x y];
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end

h=findobj(gca,'Tag','ActiveTideStation');
if ~isempty(h)
    n=handles.Toolbox(ii).Input.activeTideStation;
    x=handles.Toolbox(ii).Input.tideStations.x(n);
    y=handles.Toolbox(ii).Input.tideStations.y(n);
    cs.name=handles.Toolbox(ii).tideStations.coordinateSystem;
    cs.Type=handles.Toolbox(ii).tideStations.coordinateSystemType;
    [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
    z=zeros(size(x))+500;
    set(h,'XData',x,'YData',y,'ZData',z);
end
