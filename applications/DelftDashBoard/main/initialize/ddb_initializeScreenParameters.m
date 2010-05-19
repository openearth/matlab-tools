function handles=ddb_initializeScreenParameters(handles)

handles.ScreenParameters.XMaxRange=[-180 180];
handles.ScreenParameters.YMaxRange=[-90 90];
handles.ScreenParameters.BackgroundBathymetry='gebco';

handles.ScreenParameters.CoordinateSystem.Name='WGS 84';
handles.ScreenParameters.CoordinateSystem.Type='Geographic';
handles.ScreenParameters.OldCoordinateSystem.Name='WGS 84';
handles.ScreenParameters.OldCoordinateSystem.Type='Geographic';
handles.ScreenParameters.UTMZone={31,'U'};
