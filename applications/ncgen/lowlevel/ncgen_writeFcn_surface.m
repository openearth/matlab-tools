function varargout = ncgen_writeFcn_surface(OPT,data)

if nargin == 0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.write.schema        = struct([]); %nccreateSchema(dimstruct,varstruct);
    OPT.write.filenameFcn   = @(x,y) sprintf('x%07.0fy%07.0f.nc',min(x),min(y));
    OPT.write.timeDependant = true;
    varargout               = {OPT.write};
    return
else
    if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
        % version 2011a and older
        error(nargchk(2,2,nargin))
    else
        % version 2011b and newer
        narginchk(2,2)
    end
end


%% check input
required_fields = {'x','y','time','z','source_file_hash'};

assert(isstruct(data)                                 ,'data input must be a struture');
assert(all(ismember(required_fields,fieldnames(data))),'data input must contain all these fields: %s',str2line(required_fields,'s',', '));

%% make nc file if it does not exist
ncfile = fullfile(OPT.main.path_netcdf,OPT.write.filenameFcn(data.x,data.y));
if ~exist(ncfile,'file')
    ncwriteschema(ncfile,OPT.write.schema);
    
    % update actual range
    ncwrite(ncfile,'x',data.x)
    ncwrite(ncfile,'y',data.y)
    
    % update actual range
    ncwriteatt(ncfile,'x','actual_range',[min(data.x) max(data.x)])
    ncwriteatt(ncfile,'y','actual_range',[min(data.y) max(data.y)])
    
    % update geospatial attributes
    ncwriteatt(ncfile,'/','projectionCoverage_x',[min(data.x) max(data.x)] + [-.5 .5]*OPT.schema.grid_cellsize(1))
    ncwriteatt(ncfile,'/','projectionCoverage_y',[min(data.y) max(data.y)] + [-.5 .5]*OPT.schema.grid_cellsize(end))
    
    [y,x] = meshgrid(data.y,data.x); % reverse y and x to keep dimension order x,y
    if ~isempty(OPT.schema.EPSGcode)
        ncwrite(ncfile,'crs',OPT.schema.EPSGcode);
        if OPT.schema.includeLatLon
            % calculate lat and lon
            [lon,lat] = convertCoordinates(x,y,'persistent','CS1.code',OPT.schema.EPSGcode,'CS2.code',4326);
            
            % write variables
            ncwrite(ncfile,'lat',lat);
            ncwrite(ncfile,'lon',lon);
            
            % write attributes
            %  first calculate coordinates of corner points of bounding box (half cell size larger than min/max coordinates)
            [x_bounds,y_bounds]     = meshgrid(ncreadatt(ncfile,'/','projectionCoverage_x'),ncreadatt(ncfile,'/','projectionCoverage_y'));
            [lon_bounds,lat_bounds] = convertCoordinates(x_bounds,y_bounds,'persistent','CS1.code',OPT.schema.EPSGcode,'CS2.code',4326);
            
            % write attributes
            ncwriteatt(ncfile,'/','geospatialCoverage_northsouth',[min(lat_bounds(:)) max(lat_bounds(:))]);
            ncwriteatt(ncfile,'/','geospatialCoverage_eastwest'  ,[min(lon_bounds(:)) max(lon_bounds(:))]);
        end
    end
end

%% get already available timesteps in nc file
    timestamps_in_nc = [];
    time_info = ncinfo(ncfile, 'time');
    if time_info.Size > 0
        timestamps_in_nc  = ncread(ncfile,'time');
    end

%% add time if it is not already in nc file and determine index
   if any(timestamps_in_nc == data.time)
       iTimestamp = find(timestamps_in_nc == data.time,1);
       existing_z = true;
   else
       iTimestamp = length(timestamps_in_nc)+1;
       ncwrite(ncfile,'time',data.time,iTimestamp);
       existing_z = false;
       
       % update actual range of time
       ncwriteatt(ncfile,'time','actual_range',[min([data.time; timestamps_in_nc]) max([data.time; timestamps_in_nc])])
        
       % write timeCoverage in yyyy-mm-ddTHH:MM:SS Timezone 
       [dates,zone] = nc_cf_time(ncfile,'time');
       ncwriteatt(ncfile,'/','timeCoverage',sprintf('%s%s - %s%s',...
           datestr(min(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1},...
           datestr(min(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1}));
   end

%% Merge Z data with existing data if it exists
if existing_z % then existing nc file already has data
    % read Z data
    z0       = ncread(ncfile,'z',[1 1 iTimestamp],[inf inf 1]);
    zNotnan  = ~isnan(data.z);
    z0Notnan = ~isnan(z0);
    notnan   = zNotnan&z0Notnan;
    % check if data will be overwritten
    if any(notnan) % some values are not nan in both existing and new data
        if isequal(z0(notnan),data.z(notnan))
            % this is ok
            returnmessage(1,'in %s, NOTICE: %d values are overwritten by identical values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        else 
            % this is (most likely) not ok   
            returnmessage(2,'in %s, WARNING: %d values are overwritten by identical values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        end
    end
    z0(zNotnan) = data.z(zNotnan);
    data.z = z0;
end

%% Write z data
   ncwrite(ncfile,'z',data.z,[1 1 iTimestamp]);

%% add source file path and hash
if OPT.main.hash_source
    source_file_hash = [];
    source_file_hash_info = ncinfo(ncfile,'source_file_hash');
    if source_file_hash_info.Size(2) > 0
        source_file_hash = ncread(ncfile,'source_file_hash')';
    end
    source_file_hash = unique([source_file_hash; data.source_file_hash],'rows');
    ncwrite(ncfile,'source_file_hash',source_file_hash');
end

