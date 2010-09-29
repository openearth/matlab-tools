function ddb_initializeScreenParameters

handles=getHandles;

handles.ScreenParameters.XMaxRange=[-180 180];
handles.ScreenParameters.YMaxRange=[-90 90];

for i=1:handles.Bathymetry.NrDatasets
    if handles.Bathymetry.Dataset(i).isAvailable
        handles.ScreenParameters.BackgroundBathymetry=handles.Bathymetry.Dataset(i).longName;
        break
    end
end

for i=1:handles.Shorelines.nrShorelines
    if handles.Shorelines.Shoreline(i).isAvailable
        handles.ScreenParameters.Shoreline=handles.Shorelines.Shoreline(i).longName;
        break
    end
end

handles.ScreenParameters.CoordinateSystem.Name='WGS 84';
handles.ScreenParameters.CoordinateSystem.Type='Geographic';
handles.ScreenParameters.OldCoordinateSystem.Name='WGS 84';
handles.ScreenParameters.OldCoordinateSystem.Type='Geographic';
handles.ScreenParameters.UTMZone={31,'U'};

handles.ScreenParameters.CMin=-10000;
handles.ScreenParameters.CMax=10000;
handles.ScreenParameters.AutomaticColorLimits=1;
handles.ScreenParameters.ColorMap='Earth';

handles.ScreenParameters.XLim=[-180 180];
handles.ScreenParameters.YLim=[-90 90];

handles.ScreenParameters.ActiveTab='Toolbox';
handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;

setHandles(handles);
