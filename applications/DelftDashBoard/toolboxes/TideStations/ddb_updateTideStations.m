function ddb_updateTideStations

handles=getHandles;

h=findobj(gcf,'Tag','TideStations');

disp('Getting Tide Stations ...');

x=get(h,'XData');
y=get(h,'YData');

tideCoord.name='WGS 84';
tideCoord.type='Geographic';

Coord=handles.screenParameters.coordinateSystem;

if ~strcmpi(coord.name,tideCoord.name)
    if ~isempty(h)
        [x,y]=ddb_coordConvert(x,y,tideCoord,coord);
        set(h,'XData',x,'YData',y);
    end
end
