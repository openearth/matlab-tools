function ddb_findShorelines

handles=getHandles;

handles=ddb_readShorelines(handles);

for i=1:handles.shorelines.nrShorelines

    handles.shorelines.shoreline(i).isAvailable=1;
    
    switch lower(handles.shorelines.shoreline(i).type)
        case{'netcdftiles'}
            
            if strcmpi(handles.shorelines.shoreline(i).URL(1:4),'http')
                % OpenDAP
                fname=[handles.shorelines.shoreline(i).URL '/' handles.shorelines.shoreline(i).name '.nc'];
                if handles.shorelines.shoreline(i).useCache
                    % First copy meta data file to local cache
                    localdir = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep];
                    if exist([localdir 'temp.nc'],'file')
                        try
                            delete([localdir 'temp.nc']);
                        end
                    end
                    try
                        if ~exist(localdir,'dir')
                            mkdir(localdir);
                        end
                        % Try to copy nc meta file
                        urlwrite(fname,[localdir 'temp.nc']);
                        if exist([localdir 'temp.nc'],'file')
                            x0=nc_varget([localdir 'temp.nc'],'x0');
                            movefile([localdir 'temp.nc'],[localdir handles.shorelines.shoreline(i).name '.nc']);
                        end
                        fname = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep handles.shorelines.shoreline(i).name '.nc'];
                    catch
                        % If no access to openDAP server possible, check
                        % whether meta data file is already available in
                        % cache
                        if exist([localdir 'temp.nc'],'file')
                            try
                                delete([localdir 'temp.nc']);
                            end
                        end
                        disp(['Connection to OpenDAP server could not be made for shoreline ' handles.shorelines.shoreline(i).longName ' - try using cached data instead']);
                        fname = [handles.shorelineDir handles.shorelines.shoreline(i).name filesep handles.shorelines.shoreline(i).name '.nc'];
                        if exist(fname,'file')
                            % File already exists, continue
                        else
                            % File does not exist, this should produce a
                            % warning
                            disp(['Shoreline ' handles.shorelines.shoreline(i).longName ' not available!']);
                            handles.shorelines.shoreline(i).isAvailable=0;
                        end
                    end
                else
                    % Read meta data from openDAP server
                end
            else
                % Local
                fname=[handles.shorelines.shoreline(i).URL filesep handles.shorelines.shoreline(i).name '.nc'];
                if exist(fname,'file')
                    % File already exists, continue
                else
                    % File does not exist, this should produce a
                    % warning
                    disp(['Bathymetry dataset ' handles.shorelines.shoreline(i).longName ' not available!']);
                    handles.shorelines.shoreline(i).isAvailable=0;
                end
            end
            
            if handles.shorelines.shoreline(i).isAvailable
                
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
                
                handles.shorelines.shoreline(i).horizontalCoordinateSystem.name=nc_attget(fname,'crs','coord_ref_sys_name');
                tp=nc_attget(fname,'crs','coord_ref_sys_kind');
                switch lower(tp)
                    case{'projected','proj','projection','xy','cartesian','cart'}
                        handles.shorelines.shoreline(i).horizontalCoordinateSystem.type='Cartesian';
                    case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
                        handles.shorelines.shoreline(i).horizontalCoordinateSystem.type='Geographic';
                end
                
                handles.shorelines.shoreline(i).nrZoomLevels=length(x0);
                for k=1:handles.shorelines.shoreline(i).nrZoomLevels
                    handles.shorelines.shoreline(i).zoomLevel(k).x0=double(x0(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).y0=double(y0(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).ntilesx=double(ntilesx(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).ntilesy=double(ntilesy(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).dx=double(dx(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).dy=double(dy(k));
                    handles.shorelines.shoreline(i).zoomLevel(k).iAvailable=double(iav{k});
                    handles.shorelines.shoreline(i).zoomLevel(k).jAvailable=double(jav{k});
                    handles.shorelines.shoreline(i).zoomLevel(k).zoomString=zoomstr{k};
                    handles.shorelines.shoreline(i).scale(k)=double(scale(k));
                end
            end
    end    
end

disp([num2str(handles.shorelines.nrShorelines) ' shoreline found!']);

setHandles(handles);
