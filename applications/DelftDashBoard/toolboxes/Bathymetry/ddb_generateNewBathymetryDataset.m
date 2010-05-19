function handles=ddb_generateNewBathymetryDataset(handles)

Coord=handles.ScreenParameters.CoordinateSystem;

if handles.Bathymetry.NewDataset.AutoLimits
    
    ii=handles.Bathymetry.ActiveUsedDataset;
    k=strmatch(handles.Bathymetry.UsedDataset(ii).Name,handles.Bathymetry.Datasets,'exact');
    data=handles.Bathymetry.Dataset(k);

    BathyCoord.Name=handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Name;
    BathyCoord.Type=handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Type;

    xlim(1)=min(min(data.x));
    xlim(2)=max(max(data.x));
    ylim(1)=min(min(data.y));
    ylim(2)=max(max(data.y));

    dx=handles.Bathymetry.NewDataset.dX;
    dy=handles.Bathymetry.NewDataset.dY;

    if strcmpi(Coord.Name,BathyCoord.Name)
        xl=xlim;
        yl=ylim;
    else
        [xl,yl]=ddb_coordConvert(xlim,ylim,BathyCoord,Coord);    
    end
xl
yl
    xl(1)=dx*floor(xl(1)/dx);
    xl(2)=dx*ceil(xl(2)/dx);
    yl(1)=dy*floor(yl(1)/dy);
    yl(2)=dy*ceil(yl(2)/dy);

else
    
    xl(1)=handles.Bathymetry.NewDataset.XMin;
    xl(2)=handles.Bathymetry.NewDataset.XMax;
    yl(1)=handles.Bathymetry.NewDataset.YMin;
    yl(2)=handles.Bathymetry.NewDataset.YMax;

end

% xl and yl are the limits of the new coordinate system

x1=xl(1):dx:xl(2);
y1=yl(1):dy:yl(2);

[xg,yg]=meshgrid(x1,y1);
[xg,yg]=ddb_coordConvert(xg,yg,Coord,BathyCoord);

x0=data.x;
y0=data.y;
z0=data.z;

z1=interp2(x0,y0,z0,xg,yg);

name='NewDataset';
handles.Bathymetry.NrDatasets=handles.Bathymetry.NrDatasets+1;
ii=handles.Bathymetry.NrDatasets;
handles.Bathymetry.ActiveDataset=ii;
handles.Bathymetry.Datasets{ii}=name;
handles.Bathymetry.Dataset(ii).Name=name;
handles.Bathymetry.Dataset(ii).FileName='';
handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Name=Coord.Name;
handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type=Coord.Type;
handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Name='Mean Sea Level';
handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Level=0;
handles.Bathymetry.Dataset(ii).Edit=1;
handles.Bathymetry.Dataset(ii).Comments={'none'};
handles.Bathymetry.Dataset(ii).Type='gridded';
handles.Bathymetry.Dataset(ii).x=x1;
handles.Bathymetry.Dataset(ii).y=y1;
handles.Bathymetry.Dataset(ii).z=z1;

