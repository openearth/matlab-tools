function handles=ddb_initializeBathymetry(handles,varargin)

ii=strmatch('Bathymetry',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Bathymetry';
            return
    end
end

% handles=ddb_readTiledBathymetries(handles);
% handles.Bathymetry.Dataset=[];
% handles.Bathymetry.Datasets={'GEBCO','Etopo2','SRTM'};
% handles.Bathymetry.NrDatasets=3;
handles.Toolbox(ii).ActiveDataset=1;
handles.Bathymetry.ActiveDataset=1;

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

handles.Toolbox(ii).UsedDataset=[];
handles.Toolbox(ii).UsedDatasets={''};
handles.Toolbox(ii).NrUsedDatasets=0;
handles.Toolbox(ii).ActiveUsedDataset=1;

handles.Toolbox(ii).NewDataset.XMin=0;
handles.Toolbox(ii).NewDataset.XMax=0;
handles.Toolbox(ii).NewDataset.dX=0;
handles.Toolbox(ii).NewDataset.YMin=0;
handles.Toolbox(ii).NewDataset.YMax=0;
handles.Toolbox(ii).NewDataset.dY=0;

handles.Bathymetry.NewDataset.AutoLimits=1;
