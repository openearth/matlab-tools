function handles=ddb_initializeScreenParameters(handles)

handles.ScreenParameters.XMaxRange=[-180 180];
handles.ScreenParameters.YMaxRange=[-90 90];
for i=1:handles.Bathymetry.NrDatasets
    if handles.Bathymetry.Dataset(i).isAvailable
        handles.ScreenParameters.BackgroundBathymetry=handles.Bathymetry.Dataset(i).longName;
        break
    end
end

handles.ScreenParameters.CoordinateSystem.Name='WGS 84';
handles.ScreenParameters.CoordinateSystem.Type='Geographic';
handles.ScreenParameters.OldCoordinateSystem.Name='WGS 84';
handles.ScreenParameters.OldCoordinateSystem.Type='Geographic';
handles.ScreenParameters.UTMZone={31,'U'};
