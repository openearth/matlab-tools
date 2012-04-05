function varargout = ncgen_writeFcn_xyt(OPT,data,meta)
if nargin == 0 || isempty(OPT)
    
%         dimstruct        = nccreateDimstruct('Name','x','Length',100);
%         dimstruct(end+1) = nccreateDimstruct('Name','y','Length',100);
%         dimstruct(end+1) = nccreateDimstruct('Name','time','Unlimited',true);
%         dimstruct(end+1) = nccreateDimstruct('Name','dim16','Length',16);
%         dimstruct(end+1) = nccreateDimstruct('Name','nSourcefiles','Unlimited',true,'Length',inf);
%         varstruct        = nccreateVarstruct_standardnames_cf('projection_x_coordinate',...
%             'Name','x',...
%             'Dimensions',{'x'});
%         varstruct(end+1) = nccreateVarstruct_standardnames_cf('projection_y_coordinate',...
%             'Name','y',...
%             'Dimensions',{'y'});
%         varstruct(end+1) = nccreateVarstruct_standardnames_cf('altitude',...
%             'Name','z',...
%             'Dimensions',{'x','y','time'},...
%             'DeflateLevel',1,...
%             'Datatype','double',...
%             'scale_factor',[],...
%             'add_offset',[]);
%         varstruct(end+1) = nccreateVarstruct_standardnames_cf('time',...
%             'Name','time',...
%             'Dimensions',{'time'},...
%             'add_offset',datenum('1970-01-01 00:00:00'),...
%             'Datatype','uint16',...
%             'units',sprintf('days since %s ',datestr(0,31)));
%         varstruct(end+1) = nccreateVarstruct(...
%             'Name','source_file_hash',...
%             'Datatype','uint16',...
%             'Dimensions',{'dim16','nSourcefiles'},...
%             'Attributes',{'definition', 'MD5 hash of source files from which netcdf is generated'});
%     
   OPT.schema = struct %nccreateSchema(dimstruct,varstruct);
    % return OPT structure with options specific to this function
    OPT.formatstring             = 1; %scale factor of z values to metres altitude
    OPT.filenameFormat = 'x%07dy%07d.nc';
    OPT.timeDependant = true;
    varargout               = {OPT};
    return
else
    narginchk(3,2)
end

data.x
data.y
data.t
data.z


meta

    ncfilename = fullfile(OPT.main.path_ncf_loc,sprintf(OPT.write.filenameformat,min(data.x),min(data.y)));
    
    
%% get already available timesteps in nc file
   timestamps_in_nc  = ncread(ncfile,'time');

%% add time if it is not already in nc file and determine index
   if any(timestamps_in_nc == data_timestamp)
       iTimestamp = find(timestamps_in_nc == data_timestamp,1);
       existing_z = true;
   else
       iTimestamp = length(timestamps_in_nc)+1;
       ncwrite(ncfile,'time',data_timestamp,iTimestamp);
       existing_z = false;
   end

%% Merge Z data with existing data if it exists
if existing_z % then existing nc file already has data
    % read Z data
    z0       = ncread(ncfile,'z',[1 1 iTimestamp],[inf inf 1]);
    zNotnan  = ~isnan(zi);
    z0Notnan = ~isnan(z0);
    notnan   = zNotnan&z0Notnan;
    % check if data will be overwritten
    if any(notnan) % values are not nan in both existing and new data
        if isequal(z0(notnan),zi(notnan))
            % this is ok
            error
            %fprintf(1,'in %s, WARNING: %d values are overwritten by identical values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        else 
            % this is (most likely) not ok   
            error
            % fprintf(2,'in %s, ERROR: %d values are overwritten by different values from a different source at %s \n',ncfile,sum(notnan(:)),datestr(date,'YYYYMMDD'))
        end
    end
    z0(zNotnan) = zi(zNotnan);
    zi = z0;
end

%% Write z data
   ncwrite(ncfile,'z',zi,[1 1 iTimestamp]);

%% add source file path and hash

source_file_hash = ncread(ncfile,'source_file_hash')';
source_file_hash = unique([source_file_hash; fns.hash],'rows');
ncwrite(ncfile,'source_file_hash',source_file_hash');


