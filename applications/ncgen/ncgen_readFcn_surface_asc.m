function varargout = ncgen_readFcn_surface_asc(OPT,writeFcn,fns)
% OPT is a struct with fields
%     nc.tilesize
%     nc.offset
%     nc.gridspacing
%     path_ncf_loc
%
% fns is a struct with the following fields:
%     name
%     date
%     bytes
%     isdir
%     datenum
%     pathname
%     date_from_filename
%     hash
%
% ncschema is schema created by either ncinfo or nccreateSchema

if nargin==0
    % return OPT structure with options specific to this function
    OPT.block_size          = 1e6;
    OPT.zfactor             = 1; %scale factor of z values to metres altitude
    
    varargout = {OPT};
    return
end

multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fns.name))

fid = fopen([fns.pathname fns.name]);
WB.todo = fns.bytes*2;
WB.done = 0;
WB.tic  = tic;

s = textscan(fid,'%s %f',6);

ncols        = s{2}(strcmpi(s{1},'ncols'        ));
nrows        = s{2}(strcmpi(s{1},'nrows'        ));
xllcorner    = s{2}(strcmpi(s{1},'xllcorner'    ));
yllcorner    = s{2}(strcmpi(s{1},'yllcorner'    ));
cellsize     = s{2}(strcmpi(s{1},'cellsize'     ));
nodata_value = s{2}(strcmpi(s{1},'nodata_value' ));
if isempty(ncols)||isempty(nrows)||isempty(xllcorner)||isempty(yllcorner)||isempty(cellsize)||isempty(nodata_value)
    error('reading asc file')
end

%% read file chunkwise

kk = 0;
while ~feof(fid)
    % read the file
    kk       = kk+1;
    D{kk}    = textscan(fid,'%f64',floor(OPT.block_size/ncols)*ncols,'CollectOutput',true); %#ok<AGROW>
    D{kk}{1} = reshape(D{kk}{1},ncols,[])'; %#ok<AGROW>
    if all(abs(D{kk}{1}(:) - nodata_value) < OPT.eps)
        D{kk}{1} = nan; %#ok<AGROW>
    else
        D{kk}{1}(abs(D{kk}{1}-nodata_value) < OPT.eps) = nan; %#ok<AGROW>
    end
end
fclose(fid);

if ~(cellsize == OPT.gridsizex && ...
        cellsize == OPT.gridsizey ) % gridsizey==gridsizey already checked above
    error('cellsizex~=cellsizey')
end

if ~(mod(xllcorner,cellsize)==0)
    error(['xllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
end

if ~(mod(yllcorner,cellsize)==0)
    error(['yllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
end

%% calculate x,y of cell CENTRES, by adding half a grid cell
%  to the cell CORNERS. From now on we only use x and y where data reside
%  i.e. the centers [xllcenter +/- cellsize,yllcorner +/- cellsize]

xllcenter = xllcorner+cellsize/2;
yllcorner = yllcorner+cellsize/2;

%% write data to nc files

multiWaitbar('nc_writing',0,'label',sprintf('Writing: %s...', (fns_unzipped(ii).name)))
% set the extent of the fixed maps (decide according to desired nc filesize)

minx    = xllcenter;
miny    = yllcorner;
maxx    = xllcenter + cellsize.*(ncols-1);
maxy    = yllcorner + cellsize.*(nrows-1);
minx    = floor(minx/OPT.mapsizex)*OPT.mapsizex + OPT.xoffset;
miny    = floor(miny/OPT.mapsizey)*OPT.mapsizey + OPT.yoffset;

% determine steps for waitbar
WB.steps = numel(minx : mapsize : maxx) * numel(miny : mapsize : maxy);
WB.read  = ftell(fid) - WB.read;
WB.done  = WB.done + WB.read;
multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fns.name));
for x0      = minx : mapsize : maxx
    for y0  = miny : mapsize : maxy
        ix = find(x     >=x0            ,1,'first'):find(x     <x0+OPT.mapsizex,1,'last');
        iy = find(y(:,1)<y0+OPT.mapsizey,1,'first'):find(y(:,1)>=y0            ,1,'last');
        
        z = nan(length(iy),length(ix));
        for iD = unique(y(iy,2))'
            if ~(numel(D{iD}{1})==1&&isnan(D{iD}{1}(1)))
                z(y(iy,2)==iD,:) = D{iD}{1}(y(iy(y(iy,2)==iD),3),ix)*OPT.zfactor;
            end
        end
        
        % generate X,Y,Z
        x_vector = x0 + (0:(OPT.mapsizex/OPT.gridsizex)-1) * OPT.gridsizex;
        y_vector = y0 + (0:(OPT.mapsizey/OPT.gridsizey)-1) * OPT.gridsizey;
        
        [X,Y]    = meshgrid(x_vector,y_vector);
        Z = nan(size(X));
        Z(...
            find(y_vector  <=y(iy(1),1),1,'last' ):-1:find(y_vector  >=y(iy(end),1),1,'first'),...
            find(x_vector  >=x(ix(1)  ),1,'first'):+1:find(x_vector  <=x(ix(end)  ),1,'last' )) = z;
        
        data.x = x;
        data.y = Y;
        data.t = time;
        data.z = Z;
        
        writeFcn(OPT,data,meta)
                        end
                        nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z'
        
        
        % set the name for the nc file
        ncfile = fullfile(OPT.path_ncf_loc,sprintf('x%07dy%07d.nc',x0,y0));
        

    
        
        write_data(ncfile,fns,zi)
    end
end

% update waitbar
WB.done = WB.done + WB.read/WB.steps;
if toc(WB.tic) > 0.2
    multiWaitbar('Processing file',WB.done/WB.todo);
    WB.tic = tic;
end


fclose(fid);

function write_data(ncfile,fns,zi)
%% get already available timesteps in nc file
data_timestamp = fns.date_from_filename;
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


