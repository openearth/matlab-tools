function OPT = ncgentools_surface_kml(varargin)

%% defaults and input parsing
OPT                 = KMLcolorbar;
OPT.path_netcdf     = '';
OPT.path_kml        = '';
OPT.fileName        = 'Surface_overlay.kml';
OPT.colorMap        = @(m) colormap_cpt('bathymetry_vaklodingen',m);
OPT.colorSteps      = 256;
OPT.cLim            = [-50 25];
OPT.var_name        = 'z';
OPT.log             = 0;
OPT.dim             = 256;
OPT.dimExt          = 16;
OPT.dateStrStyle    = 'yyyy-mm-dd';
OPT.filledInTime    = true;
OPT.descriptivename = 'Surface overlay';
OPT.description     = ['generated: ' datestr(now())];
OPT.colorbar        = true;
OPT.highestLevel    = 1;
OPT.lowestLevel     = 15;
OPT.z_scale_factor  = 1;
OPT.lighting_effects = true;
OPT.bgcolor          = [100 155 100];
OPT.debug = 1;
OPT.timerange       = [-inf inf];%[now-7 now];
OPT.continue_from_last = true;

if nargin==0
    return
end

OPT = setproperty(OPT,varargin);

%% Part 0: index all netcdf files
netcdf_index = ncgentools_get_data_in_box(OPT.path_netcdf);

%% Part 1: generate tiles
generate_tiles(OPT,netcdf_index)

%% Part 2: merge tiles at lower levels
merge_tiles(OPT)

%% Part 3: write KML
dataBounds.E = max(netcdf_index.geospatialCoverage_eastwest(:));
dataBounds.W = min(netcdf_index.geospatialCoverage_eastwest(:));
dataBounds.N = max(netcdf_index.geospatialCoverage_northsouth(:));
dataBounds.S = min(netcdf_index.geospatialCoverage_northsouth(:));
write_kml(OPT,dataBounds);

function generate_tiles(OPT,netcdf_index)
% create output directory if it doesn't exist yet
if ~exist(OPT.path_kml,'dir')
    mkpath(OPT.path_kml)
end

%% get all unique times
times = [];
for ii = 1:length(netcdf_index.urlPath)
    times = [times; ncread_cf_time(netcdf_index.urlPath{ii},netcdf_index.var_t)];
end
times = unique(times);
times(times < OPT.timerange(1) | times > OPT.timerange(2)) = [];


%% determine timesteps already completed, and skip those
% if 0.png exists in folder, than it is complete
D = dir2(OPT.path_kml,'file_incl','^0\.png$','dir_excl','colorbar','depth',1);
D = D([D.isdir]);
D([D.bytes] == 0) = [];
if ~isempty({D(2:end).name})
    completed_dates = datenum({D(2:end).name},OPT.dateStrStyle);
else
    completed_dates = [];
end
times(ismember(times,completed_dates)) = [];

if isempty(times)
    return
end

time_str = datestr(times,OPT.dateStrStyle);

for ii = 1:length(times)
    dirname = fullfile(OPT.path_kml,time_str(ii,:));
    if ~exist(dirname,'dir')
        mkpath(dirname)
    end
end

%% previous files
% build index of all previously made files
% find the newest tile made before the timerange

tile_folders = dir2(OPT.path_kml,'file_excl','.*','depth',0,'dir_excl','colorbar');
tile_folders(1) = []; % remove basedir
for ii = 1:length(tile_folders)
    tile_folders(ii).folderdate = datenum(tile_folders(ii).name,OPT.dateStrStyle);
end
tile_folders([tile_folders.folderdate] > min(times)) = [];
[~,ind] = sort([tile_folders.folderdate]); %newest last
tile_folders = tile_folders(ind);
previous_tiles = struct('name',{},'date',{},'bytes',{},'isdir',{},'datenum',{},'pathname',{},'folderdate',{});
for ii = 1:length(tile_folders)
    previous_tiles_tmp = dir2([tile_folders(ii).pathname tile_folders(ii).name],'file_incl',['^[0-9]{' num2str(OPT.lowestLevel) '}\.png$'],'no_dirs',1,'depth',0);
    if isempty(previous_tiles_tmp)
        continue
    end
    [previous_tiles_tmp.folderdate] = deal(tile_folders(ii).folderdate);
    previous_tiles = [previous_tiles; previous_tiles_tmp];
end
[~,ind] = unique({previous_tiles.name},'last');
previous_tiles = previous_tiles(ind);

%% generate list of files to print
tiles = findAllTiles(netcdf_index,OPT.lowestLevel,[min(times) max(times)]);

%% other preparations
fig = make_figure(...
    OPT.cLim,...
    OPT.colorMap(OPT.colorSteps),...
    OPT.lighting_effects,...
    OPT.dim,...
    OPT.dimExt,...
    OPT.bgcolor,...
    OPT.lowestLevel);

% determine ranges of figures
delta = 360 / 2^(OPT.lowestLevel-1) / OPT.dim * OPT.dimExt; % the delta is needed to make sure there are no ugly edge effects
lon_range = [[tiles.W]'-delta [tiles.E]'+delta];
lat_range = [[tiles.S]'-delta [tiles.N]'+delta];
[x_range,y_range] = convertCoordinates(lon_range,lat_range,'persistent','CS1.code',4326,'CS2.code',netcdf_index.epsg_code);
delta = [-1 1]* delta;

multiWaitbar('Generating tiles','reset','color',[.6 0 .2])
%% start loop
for ii = 1:length(tiles)
    multiWaitbar('Generating tiles',(ii-1) / length(tiles),'label',sprintf('Generating tile: %s',tiles(ii).code))
    try
        data = ncgentools_get_data_in_box(netcdf_index,...
            't_range',[min(times) max(times)],...
            'x_range',x_range(ii,:),...
            'y_range',y_range(ii,:),...
            'x_stride',1,...
            'y_stride',1,...
            'include_latlon',true,...
            't_method','all_in_range');
        data.z = data.z * OPT.z_scale_factor;
    catch
        wtf=true
    end
    if all(isnan(data.z(:)))
        returnmessage(OPT.debug,'Skipped %d\n',ii)
        continue
    else
        data.lat = data.lat - tiles(ii).S;
        data.lon = data.lon - tiles(ii).W;
        set(fig.ha,'YLim',[0 tiles(ii).N-tiles(ii).S]+delta,'XLim',[0 tiles(ii).E-tiles(ii).W]+delta,'zlim',[min(data.z(:))-1 max(data.z(:))+1])
        
        % look for a the newest previously made tile with that name
        % otherwise make a fully transparent background image to start from
        previous_tiles_ind = strcmp({previous_tiles.name},[tiles(ii).code '.png']);
        if any(previous_tiles_ind)
            [im,~,alpha] = imread([previous_tiles(previous_tiles_ind).pathname previous_tiles(previous_tiles_ind).name]);
            mask = repmat(alpha==0,[1 1 3]);
        else
            im   = zeros(OPT.dim,OPT.dim,3,'uint8');
            mask = true(OPT.dim,OPT.dim,3);
        end
        
        for iTime = find(~squeeze(all(all(isnan(data.z),1))))'
            set(fig.hp,'ZData',data.z(:,:,iTime),'XData',data.lon,'YData',data.lat)
            % print tile
            try
                [im,mask] = print_tile(fig,OPT.dim,OPT.dimExt,...
                    fullfile(OPT.path_kml,time_str(times==data.t(iTime),:),[tiles(ii).code '.png']),...
                    OPT.bgcolor,OPT.filledInTime,im,mask,OPT.debug);
            catch
                wtf=true;
            end
        end
    end
end
multiWaitbar('Generating tiles',1)

function merge_tiles(OPT)

tile_folders = dir2(OPT.path_kml,'file_incl','^0\.png$','dir_excl','colorbar','depth',1);
tile_folders = tile_folders([tile_folders.isdir]);  % remove files
tile_folders(1) = []; % remove basedir
if isempty(tile_folders)
    return
end
for ii = 1:length(tile_folders)
    tile_folders(ii).folderdate = datenum(tile_folders(ii).name,OPT.dateStrStyle);
end
[~,ind] = sort([tile_folders.folderdate]); % newest last
tile_folders = tile_folders(ind);

tiles_this_level = struct('name',{},'date',{},'bytes',{},'isdir',{},'datenum',{},'pathname',{},'folderdate',{});
for ii = 1:length(tile_folders)
    tiles_this_level_tmp = dir2([tile_folders(ii).pathname tile_folders(ii).name],'file_incl',['^[0-9]{' num2str(OPT.lowestLevel) '}\.png$'],'no_dirs',1,'depth',0);
    if isempty(tiles_this_level_tmp)
        continue
    end
    [tiles_this_level_tmp.folderdate] = deal(tile_folders(ii).folderdate);
    tiles_this_level = [tiles_this_level; tiles_this_level_tmp];
end


while length(tiles_this_level(1).name) > 5
    tiles_next_level = struct('name',{},'date',{},'bytes',{},'isdir',{},'datenum',{},'pathname',{},'folderdate',{});
    potential_tiles_to_make = tiles_this_level;
    for jj = 1:length(potential_tiles_to_make)
        potential_tiles_to_make(jj).name = potential_tiles_to_make(jj).name([1:end-5 end-3:end]);
    end
    
    for ii = 1:length(tile_folders)
        % determine which files to make
        ind1 = find([tiles_this_level.folderdate] == tile_folders(ii).folderdate);
        [~,ind2] = unique({potential_tiles_to_make(ind1).name});
        tiles_to_make = potential_tiles_to_make(ind1(ind2));
        % but only actualy make the tiles for folders that don't already contain a 0.png file
        if tile_folders(ii).bytes == 0 
            ind3 = find([tiles_this_level.folderdate] <= tile_folders(ii).folderdate);
            for jj = 1:length(tiles_to_make)
                % ind4 are all tiles that can be used of all dates
                ind4 = find(strcmpi(tiles_to_make(jj).name,{potential_tiles_to_make(ind3).name}));
                % find the newest tiles of all tiles not newer that the tile to
                % be made
                [~,ind5] = unique({tiles_this_level(ind3(ind4)).name},'last');
                merge_a_tile(tiles_this_level(ind3(ind4(ind5))),tiles_to_make(jj),OPT.dim)
            end
        end
        tiles_next_level = [tiles_next_level; tiles_to_make];
    end
    tiles_this_level = tiles_next_level;
end

function merge_a_tile(tiles_to_merge,merged_tile,dimension)
imL = zeros(dimension*2,dimension*2,3);         % image Large (composed of up to 4 smaller images
aaL = uint8(zeros(dimension*2,dimension*2));    % alpha data of large image

for nn = 1:length(tiles_to_merge);
    switch tiles_to_merge(nn).name(end-4)
        case '0'; ii = 1; jj = 1;
        case '1'; ii = 1; jj = 2;
        case '2'; ii = 2; jj = 1;
        case '3'; ii = 2; jj = 2;
    end
    tilename = [tiles_to_merge(nn).pathname tiles_to_merge(nn).name];
    % add data to
    [imL((ii-1)*dimension+1:ii*dimension,...
        (jj-1)*dimension+1:jj*dimension,1:3),...
        ~,...
        aaL((ii-1)*dimension+1:ii*dimension,...
        (jj-1)*dimension+1:jj*dimension)] = imread(tilename);
end

tmpL = +(aaL>0);
tmpS =...
    tmpL(1:2:dimension*2,1:2:dimension*2)+...
    tmpL(2:2:dimension*2,2:2:dimension*2)+...
    tmpL(1:2:dimension*2,2:2:dimension*2)+...
    tmpL(2:2:dimension*2,1:2:dimension*2);
tmpS(tmpS==0) = 1;

mask = reshape(repmat(aaL==0,1,3),size(imL));
imL(mask) = 0;

imS = ...
    imL(1:2:dimension*2,1:2:dimension*2,1:3)+...
    imL(2:2:dimension*2,2:2:dimension*2,1:3)+...
    imL(1:2:dimension*2,2:2:dimension*2,1:3)+...
    imL(2:2:dimension*2,1:2:dimension*2,1:3);

imS(:,:,1) = imS(:,:,1)./tmpS;
imS(:,:,2) = imS(:,:,2)./tmpS;
imS(:,:,3) = imS(:,:,3)./tmpS;

imS = uint8(imS);

aaS = ...
    aaL(1:2:dimension*2,1:2:dimension*2)/4+...
    aaL(2:2:dimension*2,2:2:dimension*2)/4+...
    aaL(1:2:dimension*2,2:2:dimension*2)/4+...
    aaL(2:2:dimension*2,1:2:dimension*2)/4;

mask = reshape(repmat(aaS==0,1,3),size(imS));

% now move image around to color transparent pixels with the value of the
% nearest neighbour.

im2 = imS;
im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
    bsxfun(@max,im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
imS(mask) = im2(mask);

PNGfileName = [merged_tile.pathname merged_tile.name];
imwrite(imS,PNGfileName,'Alpha',aaS ,...
    'Author','$HeadURL$');

function tiles = findAllTiles(netcdf_index,lowestLevel,time_range)
tiles = struct('N',{},'S',{},'W',{},'E',{},'code',{});

for ii = 1:length(netcdf_index.urlPath)
    % determine if covergae in in time range
    c = textscan(netcdf_index.timeCoverage{ii},'%s - %s');
    in_timerange = ...
        time_range(1) < datenum(c{2},'yyyy-mm-ddTHH:MM:SS') && ...
        time_range(2) > datenum(c{1},'yyyy-mm-ddTHH:MM:SS');
    
    if in_timerange
        % determine all tiles within the dataBounds
        dataBounds.E = max(netcdf_index.geospatialCoverage_eastwest(ii,:));
        dataBounds.W = min(netcdf_index.geospatialCoverage_eastwest(ii,:));
        dataBounds.N = max(netcdf_index.geospatialCoverage_northsouth(ii,:));
        dataBounds.S = min(netcdf_index.geospatialCoverage_northsouth(ii,:));
        tileBounds.N =  180;
        tileBounds.S = -180;
        tileBounds.W = -180;
        tileBounds.E =  180;
        tiles = [tiles findTiles('0',lowestLevel,dataBounds,tileBounds)];
    end
end

[~,ind] = unique({tiles.code});
tiles = tiles(ind);

function tiles = findTiles(code,lowestLevel,dataBounds,tileBounds)
tiles = struct('N',{},'S',{},'W',{},'E',{},'code',{});
for addCode = ['0','1','2','3']
    nextCode = [code addCode];
    level = length(nextCode);
    nextTileBounds = tileBounds;
    switch addCode
        case '0'
            nextTileBounds.S = tileBounds.S + (tileBounds.N-tileBounds.S)/2;
            nextTileBounds.E = tileBounds.E + (tileBounds.W-tileBounds.E)/2;
        case '1'
            nextTileBounds.S = tileBounds.S + (tileBounds.N-tileBounds.S)/2;
            nextTileBounds.W = tileBounds.W + (tileBounds.E-tileBounds.W)/2;
        case '2'
            nextTileBounds.N = tileBounds.N + (tileBounds.S-tileBounds.N)/2;
            nextTileBounds.E = tileBounds.E + (tileBounds.W-tileBounds.E)/2;
        case '3'
            nextTileBounds.N = tileBounds.N + (tileBounds.S-tileBounds.N)/2;
            nextTileBounds.W = tileBounds.W + (tileBounds.E-tileBounds.W)/2;
    end
    if ((dataBounds.E > nextTileBounds.W &&...
            dataBounds.W < nextTileBounds.E   )&&...
            (dataBounds.N > nextTileBounds.S &&...
            dataBounds.S < nextTileBounds.N  ))
        if level == lowestLevel
            nextTileBounds.code = nextCode;
            tiles(end+1) = nextTileBounds;
        else
            tiles = [tiles findTiles(nextCode,lowestLevel,dataBounds,nextTileBounds)];
        end
    end
end

function fig = make_figure(cLim,cMap,lighting_effects,dim,dimExt,bgcolor,level)
level = 20;
fig.hf = figure('visible','off');
fig.ha = axes('parent',fig.hf,'position',[0 0 1 1]);
colormap(cMap)
% scale x to lot/lon range
x = linspace(0,360 / (2^level),90);
z = peaks(90) +cos(peaks(90))+cos(magic(90))/5;
% scale z to color limits
z = (z - min(z(:))) / (max(z(:))-min(z(:))) * (cLim(2)-cLim(1)) + cLim(1);

fig.hp  = surf(fig.ha,x,x,z);
set(fig.ha,'CLim',cLim)
set(fig.hf,'PaperUnits', 'inches','PaperPosition',...
    [0 0 dim+2*dimExt dim+2*dimExt],...
    'color',bgcolor/255,'InvertHardcopy','off');

shading interp;axis off;
axis tight;view(0,90);
set(fig.ha,'DataAspectRatioMode','manual')
if lighting_effects
    fig.hl = light;
    
    %           %ka     %kd     %ks     %n      %sc
    % 'Shiny',	0.3,	0.6,	0.9,	20,		1.0
    % 'Dull',	0.3,	0.8,	0.0,	10,		1.0
    % 'Metal',	0.3,	0.3,	1.0,	25,		.5
    material([0.3,	0.7,	0.5,	15,		1.0]);
    lighting phong;
    lightangle(fig.hl,180,60);
    get(fig.hl)
else
    fig.hl = [];
end

function [im,mask] = print_tile(fig,dim,dimExt,PNGfileName,bgcolor,mergeExistingTiles,prevIm,prevMask,debug)
if exist(PNGfileName,'file')
    returnmessage(debug,'%s skipped\n',PNGfileName);
    % read that image so to be able to merge it with the next
    [im,~,alpha] = imread(PNGfileName);
    mask = repmat(alpha==0,[1 1 3]);
    return
else
    returnmessage(debug,'%s added\n',PNGfileName);
end
% TO DO error when gca has no data at moment of plotting
print(fig.hf,'-dpng','-r1',PNGfileName);

im   = imread(PNGfileName);
im   = im(dimExt+1:dimExt+dim,dimExt+1:dimExt+dim,:);
mask = bsxfun(@eq,im,reshape(bgcolor,1,1,3));
mask = repmat(all(mask,3),[1 1 3]);
im(mask) = 0;

if all(mask(:))
    % return if no data is present in tile
    delete(PNGfileName)
    im = prevIm;
    mask = prevMask;
    return
else
    % merge data from different tiles
    if mergeExistingTiles
        im(mask) = prevIm(mask);
        mask = mask & prevMask;
    end
end

% now move image around to color transparent pixels with the value of the
% nearest neighbour.
im2       = im;
im2(mask) = 0;
im2 = bsxfun(@max,bsxfun(@max,im2([1 1:end-1],[1 1:end-1],1:3),im2([2:end end],[1 1:end-1],1:3)),...
    bsxfun(@max,            im2([2:end end],[2:end end],1:3),im2([1 1:end-1],[2:end end],1:3)));
im(mask) = im2(mask);
% Also move alpha channel around to color
% transparent pixels
imwrite(im,PNGfileName,'Alpha',ones(size(mask(:,:,1))).*(1-double(all(mask,3))),...
    'Author','$HeadURL$'); % NOT 'Transparency' as non-existent pixels have alpha = 0

function write_kml(OPT,dataBounds)
%% new style
tile_folders = dir2(OPT.path_kml,'file_excl','.*','depth',0,'dir_excl','colorbar');
tile_folders(1) = []; % remove basedir
for ii = 1:length(tile_folders)
    tile_folders(ii).folderdatenum = datenum(tile_folders(ii).name,OPT.dateStrStyle);
end
[~,ind] = sort([tile_folders.folderdatenum]); %newest last
tile_folders = tile_folders(ind);
tiles = struct('name',{},'date',{},'bytes',{},'isdir',{},'datenum',{},'pathname',{},'folderdatestr',{},'folderdatenum',{});
for ii = 1:length(tile_folders)
    tiles_tmp = dir2([tile_folders(ii).pathname tile_folders(ii).name],'file_incl',['^[0-9]{1,' num2str(OPT.lowestLevel) '}\.png$'],'no_dirs',1,'depth',0);
    if isempty(tiles_tmp)
        continue
    end
    [tiles_tmp.folderdatestr] = deal(tile_folders(ii).name);
    [tiles_tmp.folderdatenum] = deal(tile_folders(ii).folderdatenum);
    tiles = [tiles; tiles_tmp];
end
for ii = 1:length(tiles)
    tiles(ii).level = length(tiles(ii).name) - 4;
end

% generate a kml file per folder
for ii = 1:length(tile_folders)
    ind1 = find([tiles.folderdatenum] <= tile_folders(ii).folderdatenum); % all available tiles
    [~,ind2] = unique({tiles(ind1).name},'last');
    kml_static(tiles(ind1(ind2)),OPT.dim,[tile_folders(ii).pathname tile_folders(ii).name],tile_folders(ii).name,tile_folders(ii).folderdatenum)
end

% generate the dynamic kml file
kml_dynamic(OPT.path_kml,tiles,OPT.dim)

%% Write overview kml
OPT_header = struct(...
    'kmlName',       OPT.descriptivename,...
    'open',          1,...
    'description',   OPT.description,...
    'cameralon',    mean([dataBounds.E dataBounds.W]),...
    'cameralat',    mean([dataBounds.N dataBounds.S]),...
    'cameraz',      5e4);

datenums = datenum({tile_folders.name});
if length(datenums) == 1;
    OPT_header.timeIn  = min(datenums);
elseif OPT.filledInTime
    OPT_header.timeIn  = max(datenums);
elseif length(datenums) < 3
    OPT_header.timeIn  = min(datenums);
    OPT_header.timeOut = max(datenums);
else
    OPT_header.timeIn  =  min(datenums(end-2:end));
    OPT_header.timeOut =  max(datenums);
end

output = KML_header(OPT_header);

% start KML folder
output = [output sprintf([...
    '<Folder>\n'...
    '<name>overlay</name>'...
    '<open>1</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>radioFolder</listItemType>\n'...
    '</ListStyle></Style>\n'])];

% create link to dynamic kml
output = [output sprintf([...
    '<NetworkLink>\n'...
    '<name>Time animated</name>'...   % name
    '<open>0</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>checkHideChildren</listItemType>\n'...
    '</ListStyle></Style>\n'...
    '<Link><href>0.kmz</href></Link>'...
    '</NetworkLink>\n'])];

% create link to static kml's
output = [output sprintf([...
    '<Folder>\n'...
    '<name>Static</name>'...
    '<visibility>0</visibility>',...
    '<open>1</open>\n'...
    '<Style><ListStyle>\n'...
    '  <listItemType>radioFolder</listItemType>\n'...
    '</ListStyle></Style>\n'])];

for ii = 1:length(tile_folders)
    output = [output sprintf([...
        '<NetworkLink>'...
        '<name>%s</name>'...
        '<visibility>0</visibility>',...
        '<Style><ListStyle>\n'...
        '  <listItemType>checkHideChildren</listItemType>\n'...
        '</ListStyle></Style>\n',...
        '<Link><href>%s</href></Link>'... % link
        '</NetworkLink>\n'],...
        tile_folders(ii).name,...
        [tile_folders(ii).name '/0.kmz'])];
end
output = [output '</Folder>'];
output = [output '</Folder>'];

% COLORBAR

if OPT.colorbar
    if exist(fullfile(OPT.path_kml,'colorbar'),'dir')
        % nothing
    else
        mkdir(fullfile(OPT.path_kml,'colorbar'));
    end
    clrbarstring = KMLcolorbar(...
        'CBcLim',               OPT.cLim,...
        'CBfileName',           fullfile(OPT.path_kml,'colorbar','colorbar') ,...
        'CBcolorMap',           OPT.colorMap,...
        'CBcolorSteps',         OPT.colorSteps,...
        'CBcolorbarlocation',   OPT.CBcolorbarlocation,...
        'CBcolorTick',          OPT.CBcolorTick,...
        'CBfontrgb',            OPT.CBfontrgb,...
        'CBbgcolor',            OPT.CBbgcolor,...
        'CBcolorTitle',         OPT.CBcolorTitle,...
        'CBframergb',           OPT.CBframergb,...
        'CBalpha',              OPT.CBalpha,...
        'CBtemplateHor',        OPT.CBtemplateHor,...
        'CBtemplateVer',        OPT.CBtemplateVer);
    clrbarstring = strrep(clrbarstring, '<Icon><href>colorbar_', '<Icon><href>colorbar/colorbar_');
    output = [output clrbarstring];
end

% FOOTER

output = [output KML_footer];

fid = fopen(fullfile(OPT.path_kml,OPT.fileName),'w');
fprintf(fid,'%s',output);
fclose(fid);

function kml_static(tiles,dimension,destPath,dateFolder,drawOrder)

kmlname = fullfile(destPath,'0.kml');
kmzname = fullfile(destPath,'0.kmz');
% skip writing kml if it already exists
if exist(kmzname,'file')
    return
end

highestLevel = min([tiles.level]);
lowestLevel  = max([tiles.level]);
OPT.minLod0        =     -1;
OPT.maxLod0        =     -1;
OPT.minLod         = round(dimension*2);
OPT.maxLod         = round(3*dimension*2);
name = '';

output = '';
for ii = 1:length(tiles)
    B = KML_figure_tiler_code2boundary(tiles(ii).name(1:end-4));
    if B.level == highestLevel; minLod = OPT.minLod0; else minLod = OPT.minLod; end
    if B.level ==  lowestLevel; maxLod = OPT.maxLod0; else maxLod = OPT.maxLod; end
    
    [~,subPath] = fileparts(tiles(ii).pathname(1:end-1));
    if strcmp(dateFolder,subPath)
        subPath = '';
    else
        subPath = ['../' subPath '/'];
    end
    output = [output sprintf([...
        '<Folder>\n'...
        '<Region>\n'...
        '<Lod><minLodPixels>%0.0f</minLodPixels><maxLodPixels>%0.0f</maxLodPixels></Lod>\n'...minLod,maxLod
        '<LatLonAltBox><north>%3.10f</north><south>%3.10f</south><west>%3.10f</west><east>%3.10f</east></LatLonAltBox>\n' ...N,S,W,E
        '</Region>\n'...
        '<GroundOverlay>\n'...
        '<name>%s</name>\n'...kml_id
        '<drawOrder>%0.0f</drawOrder>\n'...drawOrder
        '<Icon><href>%s%s</href></Icon>\n'...%image_link
        '<LatLonAltBox><north>%3.10f</north><south>%3.10f</south><west>%3.10f</west><east>%3.10f</east></LatLonAltBox>\n' ...N,S,W,E
        '</GroundOverlay>\n'...
        '</Folder>\n'],...
        minLod,maxLod,B.N,B.S,B.W,B.E,...
        tiles(ii).name,...
        drawOrder+B.level,...
        subPath,tiles(ii).name,...
        B.N,B.S,B.W,B.E)];
end
fid=fopen(kmlname,'w');
OPT_header = struct(...
    'name',name,...
    'open',0);
output = [KML_header(OPT_header) output];

% FOOTER
output = [output KML_footer]; %#ok<*AGROW>
fprintf(fid,'%s',output);

% close KML
fclose(fid);

zip     (kmzname,kmlname);
delete  (kmlname)
movefile([kmzname,'.zip'],kmzname);
       
function kml_dynamic(destPath,tiles,dimension)
[~,ind1]     = max([tiles.folderdatenum]);
timeOutStrMax = tiles(ind1).folderdatestr;
highestLevel = min([tiles.level]);
lowestLevel  = max([tiles.level]);
OPT.minLod0        =     -1;
OPT.maxLod0        =     -1;
OPT.minLod         = round(dimension*2);
OPT.maxLod         = round(3*dimension*2);
name = '';

output = '';

% find all unique tile codes
[names,~,ind1] = unique({tiles.name});
[names,ind2] = sort(names);
for ii = 1:length(names)
    B = KML_figure_tiler_code2boundary(names{ii}(1:end-4));
    if B.level == highestLevel; minLod = OPT.minLod0; else minLod = OPT.minLod; end
    if B.level ==  lowestLevel; maxLod = OPT.maxLod0; else maxLod = OPT.maxLod; end
    
    [~,subPath] = fileparts(tiles(ii).pathname(1:end-1));
    
    overlay = '';
    % find all tiles with that name
    ind3 = find(ind2(ind1) == ii);
    [~,ind4] = sort([tiles(ind3).folderdatenum]);
    for jj = 1:length(ind3)
        drawOrder = tiles(ind3(ind4(jj))).folderdatenum;
        timeInStr = tiles(ind3(ind4(jj))).folderdatestr;
        if jj == length(ind3);
            timeOutStr = timeOutStrMax;
        else
            timeOutStr = tiles(ind3(ind4(jj+1))).folderdatestr;
        end
        overlay = [overlay sprintf([...
            '<GroundOverlay>\n'...
            '<name>%s</name>\n'...kml_id
            '<drawOrder>%0.0f</drawOrder>\n'...drawOrder
            '<Icon><href>%s/%s</href></Icon>\n'...%image_link
            '<LatLonAltBox><north>%3.10f</north><south>%3.10f</south><west>%3.10f</west><east>%3.10f</east></LatLonAltBox>\n' ...N,S,W,E
            '<TimeSpan><begin>%s</begin><end>%s</end></TimeSpan>\n',...
            '</GroundOverlay>\n'],...
            tiles(ind3(ind4(jj))).folderdatestr,...
            drawOrder+B.level,...
            tiles(ind3(ind4(jj))).folderdatestr,tiles(ind3(ind4(jj))).name,...
            B.N,B.S,B.W,B.E,...
            timeInStr,timeOutStr)];
    end
    
    output = [output sprintf([...
        '<Folder>\n'...
        '<Region>\n'...
        '<Lod><minLodPixels>%0.0f</minLodPixels><maxLodPixels>%0.0f</maxLodPixels></Lod>\n'...minLod,maxLod
        '<LatLonAltBox><north>%3.10f</north><south>%3.10f</south><west>%3.10f</west><east>%3.10f</east></LatLonAltBox>\n' ...N,S,W,E
        '</Region>\n'...
        '%s',... Overlays
        '</Folder>\n'],...
        minLod,maxLod,B.N,B.S,B.W,B.E,...
        overlay)];
end
kmlname = fullfile(destPath,'0.kml');
kmzname = fullfile(destPath,'0.kmz');
fid=fopen(kmlname,'w');
OPT_header = struct(...
    'name',name,...
    'open',0);
output = [KML_header(OPT_header) output];

% FOOTER
output = [output KML_footer]; %#ok<*AGROW>
fprintf(fid,'%s',output);

% close KML
fclose(fid);

zip     (kmzname,kmlname);
delete  (kmlname)
movefile([kmzname,'.zip'],kmzname);