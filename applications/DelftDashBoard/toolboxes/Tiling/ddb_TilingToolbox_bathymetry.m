function ddb_TilingToolbox_bathymetry(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('bathymetrypanel.export');
%    ddb_plotBathymetry('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'selectcs'}
            selectCS;
        case{'editattributes'}
            editAttributes;
        case{'generatetiles'}
            generateTiles;
    end    
end

%%
function selectDataset

handles=getHandles;

[ncols,nrows,x0,y0,cellsz]=readArcInfo(handles.Toolbox(tb).Input.bathymetry.fileName,'info');

% Determine default values for this dataset

handles.Toolbox(tb).Input.bathymetry.x0=x0;
handles.Toolbox(tb).Input.bathymetry.y0=y0;

if ncols>500 && nrows>500
    handles.Toolbox(tb).Input.bathymetry.nx=300;
    handles.Toolbox(tb).Input.bathymetry.ny=300;
    zm=1:50;
    nnx=ncols./(handles.Toolbox(tb).Input.bathymetry.nx.*2.^(zm-1));
    nny=nrows./(handles.Toolbox(tb).Input.bathymetry.ny.*2.^(zm-1));
    iix=find(nnx>1,1,'last');
    iiy=find(nny>1,1,'last');
    handles.Toolbox(tb).Input.bathymetry.nrZoom=max(iix,iiy);
else
    % Small dataset, no tiling required
    handles.Toolbox(tb).Input.bathymetry.nx=ncols;
    handles.Toolbox(tb).Input.bathymetry.ny=nrows;
    handles.Toolbox(tb).Input.bathymetry.nrZoom=1;
end

setUIElement('tilingpanel.bathymetry.editnx');
setUIElement('tilingpanel.bathymetry.editny');
setUIElement('tilingpanel.bathymetry.editnrzoom');
setUIElement('tilingpanel.bathymetry.editx0');
setUIElement('tilingpanel.bathymetry.edity0');

setHandles(handles);

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',handles.Toolbox(tb).Input.bathymetry.EPSGname,'type','both','defaulttype',handles.Toolbox(tb).Input.bathymetry.EPSGtype);

if ok
    handles.Toolbox(tb).Input.bathymetry.EPSGname=cs;
    handles.Toolbox(tb).Input.bathymetry.EPSGtype=type;
    handles.Toolbox(tb).Input.bathymetry.EPSGcode=nr;
    
    switch lower(handles.Toolbox(tb).Input.bathymetry.EPSGtype)
        case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
            handles.Toolbox(tb).Input.bathymetry.radioGeo=1;
            handles.Toolbox(tb).Input.bathymetry.radioProj=0;
        otherwise
            handles.Toolbox(tb).Input.bathymetry.radioGeo=0;
            handles.Toolbox(tb).Input.bathymetry.radioProj=1;
    end
    setHandles(handles);
    
    setUIElement('tilingpanel.bathymetry.radiogeo');
    setUIElement('tilingpanel.bathymetry.radioproj');
    setUIElement('tilingpanel.bathymetry.cstext');
    
end

%%
function editAttributes
handles=getHandles;
attr=handles.Toolbox(tb).Input.bathymetry.attributes;
attr=ddb_editTilingAttributes(attr);
handles.Toolbox(tb).Input.bathymetry.attributes=attr;
setHandles(handles);

%%
function generateTiles

handles=getHandles;

OPT.EPSGcode                     = handles.Toolbox(tb).Input.bathymetry.EPSGcode;
OPT.EPSGname                     = handles.Toolbox(tb).Input.bathymetry.EPSGname;
OPT.EPSGtype                     = handles.Toolbox(tb).Input.bathymetry.EPSGtype;
OPT.VertCoordName                = handles.Toolbox(tb).Input.bathymetry.VertCoordName;
OPT.VertCoordLevel               = handles.Toolbox(tb).Input.bathymetry.VertCoordLevel;
OPT.nc_library                   = handles.Toolbox(tb).Input.bathymetry.nc_library;
OPT.tp                           = handles.Toolbox(tb).Input.bathymetry.type;

f=fieldnames(handles.Toolbox(tb).Input.bathymetry.attributes);

for i=1:length(f);
    OPT.(f{i})=handles.Toolbox(tb).Input.bathymetry.attributes.(f{i});
end

fname=handles.Toolbox(tb).Input.bathymetry.fileName;
dr=[handles.Toolbox(tb).Input.bathymetry.dataDir filesep handles.Toolbox(tb).Input.bathymetry.dataName filesep];
dataname=handles.Toolbox(tb).Input.bathymetry.dataName;
nrzoom=handles.Toolbox(tb).Input.bathymetry.nrZoom;
nx=handles.Toolbox(tb).Input.bathymetry.nx;
ny=handles.Toolbox(tb).Input.bathymetry.ny;

wb = waitbox('Generating Tiles ...'); 
makeNCBathyTiles(fname,dr,dataname,nrzoom,nx,ny,OPT);
close(wb);
