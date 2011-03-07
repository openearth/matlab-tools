function ddb_initializeScreenParameters

handles=getHandles;

handles.screenParameters.xMaxRange=[-180 180];
handles.screenParameters.yMaxRange=[-90 90];

handles.GUIData.backgroundImageType='bathymetry';

for i=1:handles.bathymetry.nrDatasets
    if handles.bathymetry.dataset(i).isAvailable
        handles.screenParameters.backgroundBathymetry=handles.bathymetry.dataset(i).longName;
        break
    end
end

for i=1:handles.shorelines.nrShorelines
    if handles.shorelines.shoreline(i).isAvailable
        handles.screenParameters.shoreline=handles.shorelines.shoreline(i).longName;
        break
    end
end

handles.screenParameters.satelliteImageType='aerial';

handles.screenParameters.coordinateSystem.name='WGS 84';
handles.screenParameters.coordinateSystem.type='Geographic';
handles.screenParameters.oldCoordinateSystem.name='WGS 84';
handles.screenParameters.oldCoordinateSystem.type='Geographic';
handles.screenParameters.UTMZone={31,'U'};

handles.screenParameters.cMin=-10000;
handles.screenParameters.cMax=10000;
handles.screenParameters.automaticColorLimits=1;
handles.screenParameters.colorMap='Earth';

handles.screenParameters.xLim=[-180 180];
handles.screenParameters.yLim=[-90 90];

handles.screenParameters.activeTab='Toolbox';
handles.activeToolbox.name='ModelMaker';
handles.activeToolbox.nr=1;

setHandles(handles);
