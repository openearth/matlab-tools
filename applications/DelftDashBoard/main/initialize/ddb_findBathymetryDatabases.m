function handles=ddb_findBathymetryDatabases(handles)

handles=ddb_readTiledBathymetries(handles);

for i=1:handles.Bathymetry.NrDatasets
    switch lower(handles.Bathymetry.Dataset(i).Type)
        case{'netcdftiles'}

            if strcmpi(handles.Bathymetry.Dataset(i).URL(1:4),'http')
                % OpenDAP
%                 str=[handles.Bathymetry.Dataset(i).URL '/' handles.Bathymetry.Dataset(i).Name '.xml'];
                str=[handles.Bathymetry.Dataset(i).URL '/' handles.Bathymetry.Dataset(i).Name '.nc'];
            else
                % Local
%                 str=[handles.Bathymetry.Dataset(i).URL '\' handles.Bathymetry.Dataset(i).Name '.xml'];
                str=[handles.Bathymetry.Dataset(i).URL '\' handles.Bathymetry.Dataset(i).Name '.nc'];
            end
%            s=xml_load(str);

            x0=nc_varget(str,'x0');
            y0=nc_varget(str,'y0');
            nx=nc_varget(str,'nx');
            ny=nc_varget(str,'ny');
            ntilesx=nc_varget(str,'ntilesx');
            ntilesy=nc_varget(str,'ntilesy');
            dx=nc_varget(str,'grid_size_x');
            dy=nc_varget(str,'grid_size_y');
            
%             handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Name=s.coordinatesystem.horizontal.name;
%             handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type=s.coordinatesystem.horizontal.type;
%             handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name=s.coordinatesystem.vertical.name;
%             handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=str2double(s.coordinatesystem.vertical.level);
%             handles.Bathymetry.Dataset(i).NrZoomLevels=length(s.zoomlevels);
%             for k=1:length(s.zoomlevels)
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).x0=str2double(s.zoomlevels(k).zoomlevel.x0);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).y0=str2double(s.zoomlevels(k).zoomlevel.y0);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).nx=str2double(s.zoomlevels(k).zoomlevel.nx);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).ny=str2double(s.zoomlevels(k).zoomlevel.ny);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesx=str2double(s.zoomlevels(k).zoomlevel.ntilesx);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesy=str2double(s.zoomlevels(k).zoomlevel.ntilesy);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).dx=str2double(s.zoomlevels(k).zoomlevel.dx);
%                 handles.Bathymetry.Dataset(i).ZoomLevel(k).dy=str2double(s.zoomlevels(k).zoomlevel.dy);
%             end
            handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Name='WGS 84';
            handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type='geographic';
            handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name='Mean Sea Level';
            handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=0;
            handles.Bathymetry.Dataset(i).NrZoomLevels=length(x0);
            for k=1:handles.Bathymetry.Dataset(i).NrZoomLevels
                handles.Bathymetry.Dataset(i).ZoomLevel(k).x0=x0(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).y0=y0(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).nx=nx(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).ny=ny(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesx=ntilesx(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesy=ntilesy(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).dx=dx(k);
                handles.Bathymetry.Dataset(i).ZoomLevel(k).dy=dy(k);
            end
    end
end
