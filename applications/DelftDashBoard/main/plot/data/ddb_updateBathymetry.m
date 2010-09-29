function handles=ddb_updateBathymetry(handles)

xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

% Bathymetry

% BathyCoord.Name='WGS 84';
% BathyCoord.Type='Geographic';

iac=strmatch(lower(handles.ScreenParameters.BackgroundBathymetry),lower(handles.Bathymetry.Datasets),'exact');
BathyCoord.Name=handles.Bathymetry.Dataset(iac).HorizontalCoordinateSystem.Name;
BathyCoord.Type=handles.Bathymetry.Dataset(iac).HorizontalCoordinateSystem.Type;

% if strcmpi(handles.ScreenParameters.BackgroundBathymetry,'vaklodingen')
%     BathyCoord.Name='Amersfoort / RD New';
%     BathyCoord.Type='Cartesian';
% end

Coord=handles.ScreenParameters.CoordinateSystem;

dx=(xl(2)-xl(1))/20;
dy=(yl(2)-yl(1))/20;

if ~strcmpi(Coord.Name,BathyCoord.Name) || ~strcmpi(Coord.Type,BathyCoord.Type)
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,Coord,BathyCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=[xl(1)-dx xl(2)+dx];
    yl0=[yl(1)-dy yl(2)+dy];
%    [xl0,yl0]=ddb_coordConvert(xl,yl,Coord,BathyCoord);
end

clear xtmp ytmp xtmp2 ytmp2

pos=get(handles.GUIHandles.mapAxis,'Position');
% res=(xl0(2)-xl0(1))/(pos(3));

% Get bathymetry
[x0,y0,z,ok]=ddb_getBathy(handles,xl0,yl0);

if ok

    res=(xl(2)-xl(1))/(1*pos(3));

    if ~strcmpi(Coord.Name,BathyCoord.Name) || ~strcmpi(Coord.Type,BathyCoord.Type)
        % Interpolate on rectangular grid
        [x11,y11]=meshgrid(xl(1)-dx:res:xl(2)+dx,yl(1)-dy:res:yl(2)+dy);
        tic
        disp('Converting coordinates ...');
        [x2,y2]=ddb_coordConvert(x11,y11,Coord,BathyCoord);
        toc
        tic
        disp('Interpolating data ...');
        z11=interp2(x0,y0,z,x2,y2);
        toc
    else
        x11=x0;
        y11=y0;
        z11=z;
    end

    handles.GUIData.x=x11;
    handles.GUIData.y=y11;
    handles.GUIData.z=z11;

    ddb_plotBackgroundBathymetry(handles);

end
