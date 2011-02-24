function handles=ddb_readTiledBathymetries(handles)

if exist([handles.bathyDir '\tiledbathymetries.def'])==2
    txt=ReadTextFile([handles.bathyDir '\tiledbathymetries.def']);
else
    error(['Bathymetry defintion file ''' [handles.bathyDir '\tiledbathymetries.def'] ''' not found!']);
end

k=0;
j=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'bathymetrydataset'}
            k=k+1;
            j=0;
            handles.bathymetry.nrDatasets=k;
            handles.bathymetry.datasets{k}=txt{i+1};
            handles.bathymetry.dataset(k).longName=txt{i+1};
            handles.bathymetry.dataset(k).type='tiles';
            handles.bathymetry.dataset(k).edit=0;
            handles.bathymetry.dataset(k).useCache=1;
        case{'horizontalcoordinatesystemname'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.name=txt{i+1};
        case{'horizontalcoordinatesystemtype'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.type=txt{i+1};
        case{'verticalcoordinatesystemname'}
            handles.bathymetry.dataset(k).verticalCoordinateSystem.name=txt{i+1};
        case{'verticalcoordinatesystemlevel'}
            handles.bathymetry.dataset(k).verticalCoordinateSystem.level=str2double(txt{i+1});
        case{'type'}
            handles.bathymetry.dataset(k).type=txt{i+1};
        case{'name'}
            handles.bathymetry.dataset(k).name=txt{i+1};
        case{'url'}
            handles.bathymetry.dataset(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.bathymetry.dataset(k).useCache=1;
            else
                handles.bathymetry.dataset(k).useCache=0;
            end
        case{'zoomlevel'}
            j=j+1;
            handles.bathymetry.dataset(k).nrZoomLevels=j;
        case{'directoryname'}
            if j>0
                handles.bathymetry.dataset(k).zoomLevel(j).directoryName=txt{i+1};
            else
                handles.bathymetry.dataset(k).directoryName=txt{i+1};
            end
        case{'filename'}
            handles.bathymetry.dataset(k).zoomLevel(j).fileName=txt{i+1};
        case{'tilesize'}
            if strcmpi(handles.bathymetry.dataset(k).horizontalCoordinateSystem.Type,'geographic')
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(1)=str2double(txt{i+1});
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(2)=str2double(txt{i+2});
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(3)=str2double(txt{i+3});
            else
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize=str2double(txt{i+1});
            end                
        case{'gridcellsize'}
            if strcmpi(handles.bathymetry.dataset(k).horizontalCoordinateSystem.Type,'geographic')
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(1)=str2double(txt{i+1});
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(2)=str2double(txt{i+2});
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(3)=str2double(txt{i+3});
            else
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize=str2double(txt{i+1});
            end                
        case{'zoomlimits'}
                handles.bathymetry.dataset(k).zoomLevel(j).zoomLimits(1)=str2double(txt{i+1});
                handles.bathymetry.dataset(k).zoomLevel(j).zoomLimits(2)=str2double(txt{i+2});
        case{'nrzoomlevels'}
                handles.bathymetry.dataset(k).nrZoomLevels=str2double(txt{i+1});
        case{'xorigin'}
                handles.bathymetry.dataset(k).xOrigin=str2double(txt{i+1});
        case{'yorigin'}
                handles.bathymetry.dataset(k).yOrigin=str2double(txt{i+1});
        case{'dx'}
                handles.bathymetry.dataset(k).dX=str2double(txt{i+1});
        case{'dy'}
                handles.bathymetry.dataset(k).dY=str2double(txt{i+1});
        case{'maxtilesize'}
                handles.bathymetry.dataset(k).maxTileSize=str2double(txt{i+1});
        case{'nrcells'}
                handles.bathymetry.dataset(k).nrCells=str2double(txt{i+1});
        case{'refinementfac'}
                handles.bathymetry.dataset(k).refinementFactor=str2double(txt{i+1});
    end
end
