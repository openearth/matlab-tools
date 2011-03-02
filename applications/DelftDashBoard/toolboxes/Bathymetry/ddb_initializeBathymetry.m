function handles=ddb_initializeBathymetry(handles,varargin)

ii=strmatch('Bathymetry',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Bathymetry';
            return
    end
end

% handles=ddb_readTiledBathymetries(handles);
% handles.Bathymetry.Dataset=[];
% handles.Bathymetry.Datasets={'GEBCO','Etopo2','SRTM'};
% handles.Bathymetry.NrDatasets=3;
handles.Toolbox(ii).Input.activeDataset=1;
handles.Toolbox(ii).Input.polyLength=0;
handles.Toolbox(ii).Input.polygonFile='';

handles.Toolbox(ii).Input.activeZoomLevel=1;
handles.Toolbox(ii).Input.zoomLevelText={'1'};
handles.Toolbox(ii).Input.resolutionText='1';

handles.Toolbox(ii).Input.exportTypes={'xyz'};
handles.Toolbox(ii).Input.activeExportType='xyz';

handles.Toolbox(ii).Input.activeDirection='up';

%handles.Bathymetry.activeDataset=1;

% for i=1:3
%     handles.Bathymetry.Dataset(i).Name=handles.Bathymetry.Datasets{i};
%     handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Name='WGS 84';
%     handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type='Geographic';
%     handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name='Mean Sea Level';
%     handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=0;
%     handles.Bathymetry.Dataset(i).Type='tiles';
%     handles.Bathymetry.Dataset(i).Edit=0;
%     handles.Bathymetry.Dataset(i).FileName='';
% end

handles.Toolbox(ii).Input.usedDataset=[];
handles.Toolbox(ii).Input.usedDatasets={''};
handles.Toolbox(ii).Input.nrUsedDatasets=0;
handles.Toolbox(ii).Input.activeUsedDataset=1;

handles.Toolbox(ii).Input.newDataset.xmin=0;
handles.Toolbox(ii).Input.newDataset.xmax=0;
handles.Toolbox(ii).Input.newDataset.dx=0;
handles.Toolbox(ii).Input.newDataset.ymin=0;
handles.Toolbox(ii).Input.newDataset.ymax=0;
handles.Toolbox(ii).Input.newDataset.dy=0;

%handles.bathymetry.newDataset.autoLimits=1;

