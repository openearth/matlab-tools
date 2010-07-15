function handles=ddb_readTiledBathymetries(handles)

txt=ReadTextFile([handles.BathyDir '\tiledbathymetries.def']);

k=0;
j=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'bathymetrydataset'}
            k=k+1;
            j=0;
            handles.Bathymetry.NrDatasets=k;
            handles.Bathymetry.Datasets{k}=txt{i+1};
            handles.Bathymetry.Dataset(k).Name=txt{i+1};
            handles.Bathymetry.Dataset(k).Type='tiles';
            handles.Bathymetry.Dataset(k).Edit=0;
        case{'horizontalcoordinatesystemname'}
            handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Name=txt{i+1};
        case{'horizontalcoordinatesystemtype'}
            handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Type=txt{i+1};
        case{'verticalcoordinatesystemname'}
            handles.Bathymetry.Dataset(k).VerticalCoordinateSystem.Name=txt{i+1};
        case{'verticalcoordinatesystemlevel'}
            handles.Bathymetry.Dataset(k).VerticalCoordinateSystem.Level=str2double(txt{i+1});
        case{'type'}
            handles.Bathymetry.Dataset(k).Type=txt{i+1};
        case{'name'}
            handles.Bathymetry.Dataset(k).Name=txt{i+1};
        case{'url'}
            handles.Bathymetry.Dataset(k).URL=txt{i+1};
        case{'zoomlevel'}
            j=j+1;
            handles.Bathymetry.Dataset(k).NrZoomLevels=j;
        case{'directoryname'}
            if j>0
                handles.Bathymetry.Dataset(k).ZoomLevel(j).DirectoryName=txt{i+1};
            else
                handles.Bathymetry.Dataset(k).DirectoryName=txt{i+1};
            end
        case{'filename'}
            handles.Bathymetry.Dataset(k).ZoomLevel(j).FileName=txt{i+1};
        case{'tilesize'}
            if strcmpi(handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Type,'geographic')
                handles.Bathymetry.Dataset(k).ZoomLevel(j).TileSize(1)=str2double(txt{i+1});
                handles.Bathymetry.Dataset(k).ZoomLevel(j).TileSize(2)=str2double(txt{i+2});
                handles.Bathymetry.Dataset(k).ZoomLevel(j).TileSize(3)=str2double(txt{i+3});
            else
                handles.Bathymetry.Dataset(k).ZoomLevel(j).TileSize=str2double(txt{i+1});
            end                
        case{'gridcellsize'}
            if strcmpi(handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Type,'geographic')
                handles.Bathymetry.Dataset(k).ZoomLevel(j).GridCellSize(1)=str2double(txt{i+1});
                handles.Bathymetry.Dataset(k).ZoomLevel(j).GridCellSize(2)=str2double(txt{i+2});
                handles.Bathymetry.Dataset(k).ZoomLevel(j).GridCellSize(3)=str2double(txt{i+3});
            else
                handles.Bathymetry.Dataset(k).ZoomLevel(j).GridCellSize=str2double(txt{i+1});
            end                
        case{'zoomlimits'}
                handles.Bathymetry.Dataset(k).ZoomLevel(j).ZoomLimits(1)=str2double(txt{i+1});
                handles.Bathymetry.Dataset(k).ZoomLevel(j).ZoomLimits(2)=str2double(txt{i+2});
        case{'nrzoomlevels'}
                handles.Bathymetry.Dataset(k).NrZoomLevels=str2double(txt{i+1});
        case{'xorigin'}
                handles.Bathymetry.Dataset(k).XOrigin=str2double(txt{i+1});
        case{'yorigin'}
                handles.Bathymetry.Dataset(k).YOrigin=str2double(txt{i+1});
        case{'dx'}
                handles.Bathymetry.Dataset(k).dX=str2double(txt{i+1});
        case{'dy'}
                handles.Bathymetry.Dataset(k).dY=str2double(txt{i+1});
        case{'maxtilesize'}
                handles.Bathymetry.Dataset(k).MaxTileSize=str2double(txt{i+1});
        case{'nrcells'}
                handles.Bathymetry.Dataset(k).NrCells=str2double(txt{i+1});
        case{'refinementfac'}
                handles.Bathymetry.Dataset(k).RefinementFactor=str2double(txt{i+1});
    end
end
