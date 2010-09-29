function ddb_loadMapData

% Loading some additional map data
handles=getHandles;

% Earth colormap
load([handles.SettingsDir 'colormaps\earth.mat']);
handles.mapData.colorMaps.earth=earth;

% World coastline
load([handles.SettingsDir 'geo\worldcoastline.mat']);
handles.mapData.worldCoastLine5000000(:,1)=wclx;
handles.mapData.worldCoastLine5000000(:,2)=wcly;

% Cities
c=load([handles.SettingsDir 'geo\cities.mat']);
for i=1:length(c.cities)
    handles.mapData.cities.lon(i)=c.cities(i).Lon;
    handles.mapData.cities.lat(i)=c.cities(i).Lat;
    handles.mapData.cities.name{i}=c.cities(i).Name;
end

setHandles(handles);
