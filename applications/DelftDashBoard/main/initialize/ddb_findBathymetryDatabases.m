function handles=ddb_findBathymetryDatabases(handles)

handles=ddb_readTiledBathymetries(handles);

for i=1:handles.Bathymetry.NrDatasets
    handles.Bathymetry.Dataset(i).isAvailable=1;
    switch lower(handles.Bathymetry.Dataset(i).Type)
        case{'netcdftiles'}
            
            if strcmpi(handles.Bathymetry.Dataset(i).URL(1:4),'http')
                % OpenDAP
                fname=[handles.Bathymetry.Dataset(i).URL '/' handles.Bathymetry.Dataset(i).Name '.nc'];
                if handles.Bathymetry.Dataset(i).useCache
                    % First copy meta data file to local cache
                    localdir = [handles.BathyDir handles.Bathymetry.Dataset(i).Name filesep];
                    try
                        if ~exist(localdir,'dir')
                            mkdir(localdir);
                        end
                        % Try to copy nc meta file
                        urlwrite(fname,[localdir 'temp.nc']);
                        if exist([localdir 'temp.nc'],'file')
                            movefile([localdir 'temp.nc'],[localdir handles.Bathymetry.Dataset(i).Name '.nc']);
                        end
                        fname = [handles.BathyDir handles.Bathymetry.Dataset(i).Name filesep handles.Bathymetry.Dataset(i).Name '.nc'];
                    catch
                        % If no access to openDAP server possible, check
                        % whether meta data file is already available in
                        % cache
                        disp(['Connection to OpenDAP server could not be made for bathymetry dataset ' handles.Bathymetry.Dataset(i).longName ' - try using cached data instead']);
                        fname = [handles.BathyDir handles.Bathymetry.Dataset(i).Name filesep handles.Bathymetry.Dataset(i).Name '.nc'];
                        if exist(fname,'file')
                            % File already exists, continue
                        else
                            % File does not exist, this should produce a
                            % warning
                            disp(['Bathymetry dataset ' handles.Bathymetry.Dataset(i).longName ' not available!']);
                            handles.Bathymetry.Dataset(i).isAvailable=0;
                        end
                    end
                else
                    % Read meta data from openDAP server
                end
            else
                % Local
                fname=[handles.Bathymetry.Dataset(i).URL filesep handles.Bathymetry.Dataset(i).Name '.nc'];
                if exist(fname,'file')
                    % File already exists, continue
                else
                    % File does not exist, this should produce a
                    % warning
                    disp(['Bathymetry dataset ' handles.Bathymetry.Dataset(i).longName ' not available!']);
                    handles.Bathymetry.Dataset(i).isAvailable=0;
                end
            end

            if handles.Bathymetry.Dataset(i).isAvailable
                
                x0=nc_varget(fname,'x0');
                y0=nc_varget(fname,'y0');
                nx=nc_varget(fname,'nx');
                ny=nc_varget(fname,'ny');
                ntilesx=nc_varget(fname,'ntilesx');
                ntilesy=nc_varget(fname,'ntilesy');
                dx=nc_varget(fname,'grid_size_x');
                dy=nc_varget(fname,'grid_size_y');
                for k=1:length(x0)
                    iav{k}=nc_varget(fname,['iavailable' num2str(k)]);
                    jav{k}=nc_varget(fname,['javailable' num2str(k)]);
                end
                
                handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Name=nc_attget(fname,'crs','coord_ref_sys_name');
                tp=nc_attget(fname,'crs','coord_ref_sys_kind');
                switch lower(tp)
                    case{'projected','proj','projection','xy','cartesian','cart'}
                        handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type='Cartesian';
                    case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
                        handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type='Geographic';
                end
                
                try
                    handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name=nc_attget(fname,'crs','vertical_reference_level');
                catch
                    handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name='unknown';
                end
                
                try
                    handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=nc_attget(fname,'crs','difference_with_msl');
                catch
                    handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=0;
                end
                
                handles.Bathymetry.Dataset(i).NrZoomLevels=length(x0);
                for k=1:handles.Bathymetry.Dataset(i).NrZoomLevels
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).x0=double(x0(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).y0=double(y0(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).nx=double(nx(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).ny=double(ny(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesx=double(ntilesx(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).ntilesy=double(ntilesy(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).dx=double(dx(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).dy=double(dy(k));
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).iAvailable=double(iav{k});
                    handles.Bathymetry.Dataset(i).ZoomLevel(k).jAvailable=double(jav{k});
                end
            end     
    end
end
