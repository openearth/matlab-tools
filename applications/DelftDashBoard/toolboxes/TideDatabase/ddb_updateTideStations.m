function ddb_updateTideStations

handles=getHandles;

h=findobj(gcf,'Tag','TideStations');

disp('Getting Tide Stations ...');

x=get(h,'XData');
y=get(h,'YData');

TideCoord.Name='WGS 84';
TideCoord.Type='Geographic';

Coord=handles.ScreenParameters.CoordinateSystem;

if ~strcmpi(Coord.Name,TideCoord.Name)
    if ~isempty(h)
        [x,y]=ddb_coordConvert(x,y,TideCoord,Coord);
        set(h,'XData',x,'YData',y);
    end
end
