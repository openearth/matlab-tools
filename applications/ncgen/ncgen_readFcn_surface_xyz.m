function varargout = ncgen_readFcn_surface_xyz(OPT,writeFcn,fns)
% OPT are properties specific to this function
% OPT2 are properties copied from the calling function
%     nc.grid_tilesize
%     nc.grid_offset  
%     nc.grid_spacing
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

if nargin == 0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.read.format              = '%f%f%f';
    OPT.read.xid                 = 1;
    OPT.read.yid                 = 2;
    OPT.read.zid                 = 3;
    OPT.read.delimiter           = ' ';
    OPT.read.headerlines         = 0;
    OPT.read.multipleDelimsAsOne = true;
    OPT.read.block_size          = 1e6;
    OPT.read.gridFcn             = @(x,y,z,xi,yi) griddata_remap(x,y,z,xi,yi);
    OPT.read.zfactor             = 1; %scale factor of z values to metres altitude
        
    varargout               = {OPT.read};
    return
else
    narginchk(3,3)
end

%%
multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fns.name))

headerlines = OPT.read.headerlines;
fid = fopen([fns.pathname fns.name]);
WB.todo = fns.bytes*2;
WB.done = 0;
WB.tic  = tic;
while ~feof(fid)   
    WB.read = ftell(fid);
    multiWaitbar('Processing file','increment',0,'label',sprintf('Processing %s; reading data', fns.name));   %  fns.bytesftell(fid)/2
    D     = textscan(fid,OPT.read.format,OPT.read.block_size,...
        'delimiter',OPT.read.delimiter,...
        'headerlines',headerlines,...
        'MultipleDelimsAsOne',OPT.read.multipleDelimsAsOne);
    headerlines     = 0; % only skip headerlines on first read
    
    % each variable read in D must have same length
    if numel(unique(cellfun(@numel,D))) ~= 1
        error('error reading file: %s',[fns.pathname fns.name]);
    end
    
    %% loop through data
    % find min and max

    minx    = min(D{OPT.read.xid});
    miny    = min(D{OPT.read.yid});
    maxx    = max(D{OPT.read.xid});
    maxy    = max(D{OPT.read.yid});
    mapsize = OPT.schema.grid_spacing * OPT.schema.grid_tilesize;
    minx    = floor(minx/mapsize)*mapsize + OPT.schema.grid_offset;
    miny    = floor(miny/mapsize)*mapsize + OPT.schema.grid_offset;
    
    % determine steps for waitbar
    WB.steps = numel(minx : mapsize : maxx) * numel(miny : mapsize : maxy);
    WB.read  = ftell(fid) - WB.read;
    WB.done  = WB.done + WB.read;
    multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fns.name));
    for x0      = minx : mapsize : maxx
        xrange      = [x0-OPT.schema.grid_spacing x0+mapsize];
        ids_x_range = find(D{OPT.read.xid}>min(xrange) & D{OPT.read.xid}<max(xrange));
        
        for y0  = miny : mapsize : maxy
            yrange       = [y0-OPT.schema.grid_spacing y0+mapsize];
            ids_xy_range = ids_x_range(D{OPT.read.yid}(ids_x_range)>min(yrange) & D{OPT.read.yid}(ids_x_range)<max(yrange));

            if ~isempty(ids_xy_range)>0
                x = D{OPT.read.xid}(ids_xy_range);
                y = D{OPT.read.yid}(ids_xy_range);
                z = D{OPT.read.zid}(ids_xy_range)*OPT.read.zfactor;
                
                % generate X,Y,Z
                data.x  =        x0 + (0:(OPT.schema.grid_tilesize)-1) * OPT.schema.grid_spacing;
                data.y  = fliplr(y0 + (0:(OPT.schema.grid_tilesize)-1) * OPT.schema.grid_spacing);
                [xi,yi] = meshgrid(data.x,data.y);
                
                % place xyz data on XY matrices
                data.z = OPT.read.gridFcn(x,y,z,xi,yi);
                
                if any(~isnan(data.z(:))) % if a non trivial Z matrix is returned write the data to a nc file
                    % set the name for the nc file
                    data.time             = fns.date_from_filename;
                    data.source_file_hash = fns.hash;
                    writeFcn(OPT,data);
                end
            end
            
            % update waitbar
            WB.done = WB.done + WB.read/WB.steps;
            if toc(WB.tic) > 0.2
                multiWaitbar('Processing file',WB.done/WB.todo);
                WB.tic = tic;
            end
        end
    end
end
fclose(fid);