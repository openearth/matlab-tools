%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Mosaic of the tiles of a raster inside a window. The tiles of a raster may
%overlap, so a cell is read only once and a tile without data does not
%erase the data of an overlapping tile.
%
%INPUT
%   - tile = tile index of the raster, as given by <raster_tile_index>.
%   - lim_x = lower and upper limit of the window in x-direction.
%   - lim_y = lower and upper limit of the window in y-direction.
%
%OUTPUT
%   - I = structure with the window:
%       - I.x = x-vector of the centre of the cells
%       - I.y = y-vector of the centre of the cells
%       - I.z = z-matrix, NaN where there is no data
%
%E.G.
%
% I=raster_window_grid(raster_tile_index(fpath_tif),[1.75e5,1.77e5],[3.19e5,3.21e5]);

function I=raster_window_grid(tile,lim_x,lim_y)

%% CONSTANTS

%fraction of a cell that the tiles may be off the common lattice
tol_lattice=1e-6;

%% CALC

dx=tile(1).dx;
dy=tile(1).dy;

%the lattice of the mosaic is anchored to the lattice of the tiles
x0=tile(1).image_info.ModelTiepointTag(4);
y0=tile(1).image_info.ModelTiepointTag(5);

col_ini=floor((lim_x(1)-x0)/dx);
col_fin= ceil((lim_x(2)-x0)/dx);
row_ini=floor((y0-lim_y(2))/dy);
row_fin= ceil((y0-lim_y(1))/dy);

I.x=x0+(col_ini:col_fin)*dx;
I.y=y0-(row_ini:row_fin)*dy;
I.z=NaN(numel(I.y),numel(I.x));

for kk=1:numel(tile)
    %<readgeotiff> discards coordinates that coincide with the limits, so
    %the window is widened by one cell
    lim_x_loc=lim_x+[-1,1]*dx;
    lim_y_loc=lim_y+[-1,1]*dy;

    if tile(kk).MinX>lim_x_loc(2) || tile(kk).MaxX<lim_x_loc(1) || ...
       tile(kk).MinY>lim_y_loc(2) || tile(kk).MaxY<lim_y_loc(1)
        continue
    end

    I_loc=readgeotiff(tile(kk).Filename,'x_limits',lim_x_loc,'y_limits',lim_y_loc, ...
        'image_info',tile(kk).image_info);
    if isempty(I_loc.x) || isempty(I_loc.y)
        continue
    end

    idx_c=(I_loc.x-I.x(1))/dx;
    idx_r=(I.y(1)-I_loc.y)/dy;
    if any(abs(idx_c-round(idx_c))>tol_lattice) || any(abs(idx_r-round(idx_r))>tol_lattice)
        error('Tile is not on the same lattice as the first tile: %s',tile(kk).Filename)
    end
    idx_c=round(idx_c)+1;
    idx_r=round(idx_r)+1;

    bol_c=idx_c>=1 & idx_c<=numel(I.x);
    bol_r=idx_r>=1 & idx_r<=numel(I.y);
    if ~any(bol_c) || ~any(bol_r)
        continue
    end

    blk=double(I_loc.z(bol_r,bol_c));
    sub=I.z(idx_r(bol_r),idx_c(bol_c));

    %a tile without data must not erase the data of an overlapping tile
    bol_val=~isnan(blk);
    sub(bol_val)=blk(bol_val);

    I.z(idx_r(bol_r),idx_c(bol_c))=sub;
end

%<readgeotiff> gives the coordinates of the upper left corner of every cell
I.x=I.x+dx/2;
I.y=I.y-dy/2;

end %function
