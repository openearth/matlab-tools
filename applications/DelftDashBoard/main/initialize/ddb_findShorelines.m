function ddb_findShorelines

handles=getHandles;

handles=ddb_readShorelines(handles);

for i=1:handles.Shorelines.nrShorelines

    handles.Shorelines.Shoreline(i).isAvailable=1;
    
    switch lower(handles.Shorelines.Shoreline(i).Type)
        case{'netcdftiles'}
            
            if strcmpi(handles.Shorelines.Shoreline(i).URL(1:4),'http')
                % OpenDAP
                fname=[handles.Shorelines.Shoreline(i).URL '/' handles.Shorelines.Shoreline(i).Name '.nc'];
                if handles.Shorelines.Shoreline(i).useCache
                    % First copy meta data file to local cache
                    localdir = [handles.ShorelineDir handles.Shorelines.Shoreline(i).Name filesep];
                    try
                        if ~exist(localdir,'dir')
                            mkdir(localdir);
                        end
                        % Try to copy nc meta file
                        urlwrite(fname,[localdir 'temp.nc']);
                        if exist([localdir 'temp.nc'],'file')
                            movefile([localdir 'temp.nc'],[localdir handles.Shorelines.Shoreline(i).Name '.nc']);
                        end
                        fname = [handles.ShorelineDir handles.Shorelines.Shoreline(i).Name filesep handles.Shorelines.Shoreline(i).Name '.nc'];
                    catch
                        % If no access to openDAP server possible, check
                        % whether meta data file is already available in
                        % cache
                        disp(['Connection to OpenDAP server could not be made for shoreline ' handles.Shorelines.Shoreline(i).longName ' - try using cached data instead']);
                        fname = [handles.ShorelineDir handles.Shorelines.Shoreline(i).Name filesep handles.Shorelines.Shoreline(i).Name '.nc'];
                        if exist(fname,'file')
                            % File already exists, continue
                        else
                            % File does not exist, this should produce a
                            % warning
                            disp(['Shoreline ' handles.Shorelines.Shoreline(i).longName ' not available!']);
                            handles.Shorelines.Shoreline(i).isAvailable=0;
                        end
                    end
                else
                    % Read meta data from openDAP server
                end
            else
                % Local
                fname=[handles.Shorelines.Shoreline(i).URL filesep handles.Shorelines.Shoreline(i).Name '.nc'];
                if exist(fname,'file')
                    % File already exists, continue
                else
                    % File does not exist, this should produce a
                    % warning
                    disp(['Bathymetry dataset ' handles.Shorelines.Shoreline(i).longName ' not available!']);
                    handles.Shorelines.Shoreline(i).isAvailable=0;
                end
            end
            
            if handles.Shorelines.Shoreline(i).isAvailable
                
                x0=nc_varget(fname,'origin_x');
                y0=nc_varget(fname,'origin_y');
                ntilesx=nc_varget(fname,'number_of_tiles_x');
                ntilesy=nc_varget(fname,'number_of_tiles_y');
                dx=nc_varget(fname,'tile_size_x');
                dy=nc_varget(fname,'tile_size_y');
                scale=nc_varget(fname,'scale');
                zoomstrings=nc_varget(fname,'zoom_level_string');

                for k=1:length(x0)
                    iav{k}=nc_varget(fname,['iavailable' num2str(k)]);
                    jav{k}=nc_varget(fname,['javailable' num2str(k)]);
                    zoomstr{k}=deblank(zoomstrings(k,:));
                end
                
                handles.Shorelines.Shoreline(i).HorizontalCoordinateSystem.Name=nc_attget(fname,'crs','coord_ref_sys_name');
                tp=nc_attget(fname,'crs','coord_ref_sys_kind');
                switch lower(tp)
                    case{'projected','proj','projection','xy','cartesian','cart'}
                        handles.Shorelines.Shoreline(i).HorizontalCoordinateSystem.Type='Cartesian';
                    case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
                        handles.Shorelines.Shoreline(i).HorizontalCoordinateSystem.Type='Geographic';
                end
                
                handles.Shorelines.Shoreline(i).nrZoomLevels=length(x0);
                for k=1:handles.Shorelines.Shoreline(i).nrZoomLevels
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).x0=double(x0(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).y0=double(y0(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).ntilesx=double(ntilesx(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).ntilesy=double(ntilesy(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).dx=double(dx(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).dy=double(dy(k));
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).iAvailable=double(iav{k});
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).jAvailable=double(jav{k});
                    handles.Shorelines.Shoreline(i).ZoomLevel(k).zoomString=zoomstr{k};
                    handles.Shorelines.Shoreline(i).Scale(k)=double(scale(k));
                end
            end
    end    
end

setHandles(handles);
