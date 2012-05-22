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
    ncwrite(ncfile,'x',data.x);
    ncwrite(ncfile,'y',data.y);
    [x,y] = meshgrid(data.x,data.y);
    if ~isempty(OPT.schema.EPSGcode)
        ncwrite(ncfile,'crs',OPT.schema.EPSGcode);
        if OPT.schema.includeLatLon
            [lon,lat] = convertCoordinates(x,y,'persistent','CS1.code',OPT.schema.EPSGcode,'CS2.code',4326);
            ncwrite(ncfile,'lat',lat);
            ncwrite(ncfile,'lon',lon);
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
   end

%% Merge Z data with existing data if it exists
if existing_z % then existing nc file already has data
    % read Z data
    z0       = ncread(ncfile,'z',[1 1 iTimestamp],[inf inf 1]);
    zNotnan  = ~isnan(data.z);
    z0Notnan = ~isnan(z0);
    notnan   = zNotnan&z0Notnan;
    % check if data will be overwritten
    if any(notnan) % values are not nan in both existing and new data
        if isequal(z0(notnan),data.z(notnan))
            % this is ok
%             error
            %fprintf(1,'in %s, WARNING: %d values are overwritten by identical values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        else 
            % this is (most likely) not ok   
%             error
            % fprintf(2,'in %s, ERROR: %d values are overwritten by different values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        end
    end
    z0(zNotnan) = data.z(zNotnan);
    data.z = z0;
end

%% Write z data
   ncwrite(ncfile,'z',data.z,[1 1 iTimestamp]);

%% add source file path and hash
source_file_hash = [];
source_file_hash_info = ncinfo(ncfile,'source_file_hash');
if source_file_hash_info.Size(2) > 0
    source_file_hash = ncread(ncfile,'source_file_hash')';
end
source_file_hash = unique([source_file_hash; data.source_file_hash],'rows');
ncwrite(ncfile,'source_file_hash',source_file_hash');


