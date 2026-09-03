%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Index of the tif-files that make up a raster, with the information needed
%to read windows out of them.
%
%INPUT
%   - fpath_tif = path to a tif-file or to a vrt-file pointing at a set of
%       tif-files.
%
%OUTPUT
%   - tile = struct array with one entry per tif-file:
%       - Filename = path resolved for the local operating system
%       - MinX, MaxX, MinY, MaxY = bounding box
%       - dx, dy = cell size
%       - image_info = output of <imfinfo>, so that <readgeotiff> does not
%           have to parse the header at every window read
%
%E.G.
%
% tile=raster_tile_index(fpath_tif);
% I=readgeotiff(tile(1).Filename,'x_limits',x_lim,'y_limits',y_lim,'image_info',tile(1).image_info);

function tile=raster_tile_index(fpath_tif)

%% CALC

fpath_tif=adapt_path_local_machine(fpath_tif);

if exist(fpath_tif,'file')~=2
    error('Raster does not exist: %s',fpath_tif)
end

[fdir,~,ext]=fileparts(fpath_tif);

switch lower(ext)
    case '.vrt'
        tile=VRT_bounding_boxes(fpath_tif);
    case {'.tif','.tiff'}
        tile=TIF_bounding_boxes(fpath_tif);
    otherwise
        error('Unsupported raster extension <%s>: %s',ext,fpath_tif)
end

%the tif-files are referenced relative to the folder of the vrt-file and
%with the separator of the operating system the vrt-file was written on
for kk=1:numel(tile)
    if is_absolute_path(tile(kk).Filename)
        tile(kk).Filename=adapt_path_local_machine(tile(kk).Filename);
    else
        fname_loc=strrep(strrep(tile(kk).Filename,'\',filesep),'/',filesep);
        tile(kk).Filename=fullfile(fdir,fname_loc);
    end
    if exist(tile(kk).Filename,'file')~=2
        error('Tile does not exist: %s',tile(kk).Filename)
    end
end

%all tiles of a vrt-file share the same resolution
image_info=TIF_info(tile(1).Filename);
dxy=image_info.ModelPixelScaleTag(1:2);
for kk=1:numel(tile)
    tile(kk).dx=dxy(1);
    tile(kk).dy=dxy(2);

    %parsing the header of a tif-file is expensive and every window read
    %needs it, so it is parsed once per tile
    if kk==1
        tile(kk).image_info=image_info;
    else
        tile(kk).image_info=TIF_info(tile(kk).Filename);
    end
end

end %function

%% 
%% FUNCTIONS
%% 

%%
%% IS_ABSOLUTE_PATH
%%

function bol=is_absolute_path(fpath)

bol=(numel(fpath)>=2 && strcmp(fpath(2),':')) || ... %windows drive
    (~isempty(fpath) && (strcmp(fpath(1),'/') || strcmp(fpath(1),'\')));

end %function
