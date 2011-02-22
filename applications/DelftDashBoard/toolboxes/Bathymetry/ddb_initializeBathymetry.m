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
handles.Toolbox(ii).activeDataset=1;
handles.Bathymetry.activeDataset=1;

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

handles.Toolbox(ii).usedDataset=[];
handles.Toolbox(ii).usedDatasets={''};
handles.Toolbox(ii).nrUsedDatasets=0;
handles.Toolbox(ii).activeUsedDataset=1;

handles.Toolbox(ii).newDataset.xmin=0;
handles.Toolbox(ii).newDataset.xmax=0;
handles.Toolbox(ii).newDataset.dx=0;
handles.Toolbox(ii).newDataset.ymin=0;
handles.Toolbox(ii).newDataset.ymax=0;
handles.Toolbox(ii).newDataset.dy=0;

handles.bathymetry.newDataset.autoLimits=1;
