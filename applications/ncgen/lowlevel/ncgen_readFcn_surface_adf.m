function varargout = ncgen_readFcn_surface_adf(OPT,writeFcn,fns)
% OPT is a struct with fields
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

if nargin==0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.block_size          = 1e6;
    OPT.z_scalefactor       = 1; %scale factor of z values to metres altitude
    varargout = {OPT};
    return
else
    if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
        % version 2011a and older
        error(nargchk(3,3,nargin))
    else
        % version 2011b and newer
        narginchk(3,3)
    end
end

multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fullfile(fns.pathname, fns.name)))

WB.tic = tic;

[X,Y,D,M] = arc_info_binary(fns.pathname,'debug',0,'warning',0);

% fid = fopen([fns.pathname fns.name]);
WB.todo = fns.bytes*2;
WB.done = 0;
% WB.tic  = tic;
% 
% s = textscan(fid,'%s %f',6);
% 
ncols = length(X);
nrows = length(Y);
% ncols        = s{2}(strcmpi(s{1},'ncols'       ));
% nrows        = s{2}(strcmpi(s{1},'nrows'       ));
% xllcorner    = s{2}(strcmpi(s{1},'xllcorner'   ));
% yllcorner    = s{2}(strcmpi(s{1},'yllcorner'   ));

% make sure X is sorted in ascending order
if ~issorted(X)
    [X ix] = sort(X);
    D = D(:,ix);
end

% given that X is ascending, diff will always give a positive result
cellsizex = unique(diff(X));
if ~isscalar(cellsizex)
    error('cellsize in x direction is not constant')
end

% make sure Y is sorted in ascending order
if ~issorted(Y)
    [Y iy] = sort(Y);
    D = D(iy,:);
end

% given that Y is ascending, diff will always give a positive result
cellsizey = unique(diff(Y));
if ~isscalar(cellsizey)
    error('cellsize in y direction is not constant')
end

if cellsizex == cellsizey
    cellsize = cellsizex;
else
    error('cellsizes in x and y direction are different')
end
% cellsize     = s{2}(strcmpi(s{1},'cellsize'    ));
% nodata_value = s{2}(strcmpi(s{1},'nodata_value'));
% if isempty(ncols)||isempty(nrows)||isempty(xllcorner)||isempty(yllcorner)||isempty(cellsize)||isempty(nodata_value)
%     error('reading asc file')
% end

%% read file chunkwise
% WB.tic = tic;
% small_number  = 1e-16;

% kk = 0;
% while ~feof(fid)
%     % read the file
%     kk       = kk+1;
%     D{kk}    = textscan(fid,'%f64',floor(OPT.read.block_size/ncols)*ncols,'CollectOutput',true); %#ok<AGROW>
%     D{kk}{1} = reshape(D{kk}{1},ncols,[])'; %#ok<AGROW>
%     if all(abs(D{kk}{1}(:) - nodata_value) < small_number)
%         D{kk}{1} = nan; %#ok<AGROW>
%     else
%         D{kk}{1}(abs(D{kk}{1}-nodata_value) < small_number) = nan; %#ok<AGROW>
%     end
%     if toc(WB.tic) > 0.2
%         multiWaitbar('Processing file',ftell(fid)/fns.bytes/2,'label',sprintf('Processing %s; reading data', fns.name));
%         WB.tic = tic;
%     end
% end
% fclose(fid);
if ~(cellsize == OPT.schema.grid_cellsize) % gridsizex==gridsizey already checked above
    error('cellsize ~= OPT.schema.grid_cellsize')
end
% 
% if ~(mod(xllcorner,cellsize)==0)
%     error(['xllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
% end
% 
% if ~(mod(yllcorner,cellsize)==0)
%     error(['yllcorner has offset: ',num2str(mod(xllcorner,cellsize))])
% end

%% calculate x,y of cell CENTRES, by adding half a grid cell
%  to the cell CORNERS. From now on we only use x and y where data reside
%  i.e. the centers [xllcenter +/- cellsize,yllcorner +/- cellsize]

xllcenter = min(X);
yllcenter = min(Y);

%% write data to nc files

minx    = xllcenter;
miny    = yllcenter;
maxx    = max(X);
maxy    = max(Y);
% grid_spacing, grid_tilesize and grid_offset can be either scalars or
% 2-element vectors indicating equal respectively seperately specified x
% and y direction values.
[grid_spacingx  grid_spacingy ] = deal(OPT.schema.grid_cellsize(1), OPT.schema.grid_cellsize(end));
[grid_tilesizex grid_tilesizey] = deal(OPT.schema.grid_tilesize(1), OPT.schema.grid_tilesize(end));
mapsizex = grid_spacingx * grid_tilesizex;
mapsizey = grid_spacingy * grid_tilesizey;
minx    = floor(minx/mapsizex)*mapsizex + OPT.schema.grid_offset(1);
miny    = floor(miny/mapsizey)*mapsizey + OPT.schema.grid_offset(end);

x       =         xllcenter:cellsize:xllcenter + cellsize*(ncols-1);
y       =         yllcenter:cellsize:yllcenter + cellsize*(nrows-1);

multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fns.name));
WB.n     = 0;
WB.steps = length(minx : mapsizex : maxx) * length(miny : mapsizey : maxy);

for x0      = minx : mapsizex : maxx % loop over tiles in x direction within data range
    for y0  = miny : mapsizey : maxy % loop over tiles in y direction within data range
        % isolate data within current tile
        ix = find(x     >=x0            ,1,'first'):find(x     <x0+mapsizex,1,'last');
        iy = find(y     >=y0            ,1,'first'):find(y     <y0+mapsizey,1,'last');

        z = D(iy,ix) * OPT.read.z_scalefactor;

        if any(~isnan(z(:)))
            data.x = x0 + (0:grid_tilesizex-1) * grid_spacingx;
            data.y = y0 + (0:grid_tilesizey-1) * grid_spacingy;
            
            data.z = nan(grid_tilesizex, grid_tilesizey);
            data.z(...
                find(data.x  >=x(ix(1)  ),1,'first'):+1:find(data.x  <=x(ix(end)  ),1,'last' ),...
                find(data.y  <=y(iy(1)),1,'last' ):+1:find(data.y  >=y(iy(end)),1,'first')) = z';
            
            data.time             = fns.date_from_filename;
            data.source_file_hash = fns.hash;
            
            writeFcn(OPT,data)
        end
        
        WB.n = WB.n+1;
        if toc(WB.tic) > 0.2
            multiWaitbar('Processing file',0.5+WB.n/WB.steps/2);
            WB.tic = tic;
        end
    end
end
multiWaitbar('Processing file',1);


