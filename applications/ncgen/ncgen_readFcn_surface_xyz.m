function varargout = ncgen_readFcn_surface_xyz(OPT,writeFcn,fns)
% OPT are properties specific to this function
% OPT2 are properties copied from the calling function
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

if nargin == 0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.format              = '%f%f%f';
    OPT.xid                 = 1;
    OPT.yid                 = 2;
    OPT.zid                 = 3;
    OPT.delimiter           = ' ';
    OPT.headerlines         = 0;
    OPT.multipleDelimsAsOne = true;
    OPT.block_size          = 1e6;
    OPT.gridFcn             = @(x,y,z,xi,yi) griddata_remap(x,y,z,xi,yi);
    OPT.zfactor             = 1; %scale factor of z values to metres altitude
        
    varargout               = {OPT};
    return
else
    narginchk(2,2)
end

%%
multiWaitbar('Processing file','reset','label',sprintf('Processing %s', fns.name))

headerlines = OPT.headerlines;
fid = fopen([fns.pathname fns.name]);
WB.todo = fns.bytes*2;
WB.done = 0;
WB.tic  = tic;
while ~feof(fid)   
    WB.read = ftell(fid);
    multiWaitbar('Processing file','increment',0,'label',sprintf('Processing %s; reading data', fns.name));   %  fns.bytesftell(fid)/2
    D     = textscan(fid,OPT.format,OPT.block_size,...
        'delimiter',OPT.delimiter,...
        'headerlines',headerlines,...
        'MultipleDelimsAsOne',OPT.multipleDelimsAsOne);
    headerlines     = 0; % only skip headerlines on first read
    
    % each variable read in D must have same length
    if numel(unique(cellfun(@numel,D))) ~= 1
        error('error reading file: %s',[fns.pathname fns.name]);
    end
    
    %% loop through data
    % find min and max
    
    minx    = min(D{OPT.xid});
    miny    = min(D{OPT.yid});
    maxx    = max(D{OPT.xid});
    maxy    = max(D{OPT.yid});
    mapsize = OPTcontrolloop.gridspacing * OPTcontrolloop.tilesize;
    minx    = floor(minx/mapsize)*mapsize + OPTcontrolloop.offset;
    miny    = floor(miny/mapsize)*mapsize + OPTcontrolloop.offset;
    
    % determine steps for waitbar
    WB.steps = numel(minx : mapsize : maxx) * numel(miny : mapsize : maxy);
    WB.read  = ftell(fid) - WB.read;
    WB.done  = WB.done + WB.read;
    multiWaitbar('Processing file',WB.done/WB.todo,'label',sprintf('Processing %s; writing data', fns.name));
    for x0      = minx : mapsize : maxx
        xrange      = [x0-OPTcontrolloop.gridspacing x0+mapsize];
        ids_x_range = find(D{OPT.xid}>min(xrange) & D{OPT.xid}<max(xrange));
        
        for y0  = miny : mapsize : maxy
            yrange       = [y0-OPTcontrolloop.gridspacing y0+mapsize];
            ids_xy_range = ids_x_range(D{OPT.yid}(ids_x_range)>min(yrange) & D{OPT.yid}(ids_x_range)<max(yrange));

            if ~isempty(ids_xy_range)>0
                x   =  D{OPT.xid}(ids_xy_range);
                y   =  D{OPT.yid}(ids_xy_range);
                z   =  D{OPT.zid}(ids_xy_range)*OPT.zfactor;
                
                % generate X,Y,Z
                x_vector =        x0 + (0:(OPTcontrolloop.tilesize)-1) * OPTcontrolloop.gridspacing;
                y_vector = fliplr(y0 + (0:(OPTcontrolloop.tilesize)-1) * OPTcontrolloop.gridspacing);
                [xi,yi]  = meshgrid(x_vector,y_vector);
                
                % place xyz data on XY matrices
                zi = OPT.gridFcn(x,y,z,xi,yi);
                
                if any(~isnan(zi(:))) % if a non trivial Z matrix is returned write the data to a nc file
                    % set the name for the nc file
                    data.x = x_vector;
                    data.y = y_vetor;
                    data.t = fns.date_from_filename;
                    data.z = zi;
                    writeFcn(OPT,data,meta);
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