function structured_xyz_to_tiff(xyz, fpath_output_tif, epsg_code, varargin)
%STRUCTURED_XYZ_TO_TIFF Write structured XYZ points to a GeoTIFF raster.
%
% structured_xyz_to_tiff(xyz, fpath_output_tif, epsg_code)
% structured_xyz_to_tiff(..., 'DuplicatePolicy', 'error'|'last'|'mean')
% structured_xyz_to_tiff(..., 'NoDataValue', value)
% structured_xyz_to_tiff(..., 'SplitTiles', true)
% structured_xyz_to_tiff(..., 'TileSize', [nRows nCols])
%
% Inputs:
%   xyz             - N x 3 numeric array [x, y, z], structured on a grid.
%                     Missing grid cells are allowed.
%   fpath_output_tif- Output GeoTIFF path.
%   epsg_code       - EPSG integer for projected coordinate system.
%
% Name-value options:
%   DuplicatePolicy - How to handle duplicate (x,y) points:
%                     'error' (default), 'last', or 'mean'.
%   NoDataValue     - Optional numeric value to replace NaN before writing.
%                     If omitted, NaN values are kept.
%   SplitTiles      - When true, split output into multiple TIFF tiles.
%                     Default: false.
%   TileSize        - Tile size [nRows nCols] for SplitTiles=true.
%                     Default: [3139 2390] (size of sample reference TIFF).

p = inputParser;
p.FunctionName = mfilename;
addRequired(p, 'xyz', @(v) isnumeric(v) && ismatrix(v) && size(v, 2) == 3 && ~isempty(v));
addRequired(p, 'fpath_output_tif', @(v) (ischar(v) || isstring(v)) && strlength(string(v)) > 0);
addRequired(p, 'epsg_code', @(v) isnumeric(v) && isscalar(v) && isfinite(v) && v > 0 && mod(v,1) == 0);
addParameter(p, 'DuplicatePolicy', 'error', @(v) any(strcmpi(string(v), ["error", "last", "mean"])));
addParameter(p, 'NoDataValue', [], @(v) isempty(v) || (isnumeric(v) && isscalar(v) && isfinite(v)));
addParameter(p, 'SplitTiles', false, @(v) islogical(v) || isnumeric(v));
addParameter(p, 'TileSize', [3139, 2390], @(v) isnumeric(v) && numel(v) == 2 && all(isfinite(v)) && all(v > 0));
parse(p, xyz, fpath_output_tif, epsg_code, varargin{:});

xyz = p.Results.xyz;
fpath_output_tif = char(p.Results.fpath_output_tif);
epsg_code = double(p.Results.epsg_code);
duplicate_policy = lower(string(p.Results.DuplicatePolicy));
nodata_value = p.Results.NoDataValue;
split_tiles = logical(p.Results.SplitTiles);
tile_size = round(double(p.Results.TileSize(:)'));

if ~endsWith(lower(fpath_output_tif), '.tif') && ~endsWith(lower(fpath_output_tif), '.tiff')
    [fdir, fname] = fileparts(fpath_output_tif);
    fpath_output_tif = fullfile(fdir, [fname, '.tif']);
end

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);

if any(~isfinite(x)) || any(~isfinite(y))
    error('structured_xyz_to_tiff:InvalidXY', 'x and y must be finite numeric values.');
end
if ~isnumeric(z)
    error('structured_xyz_to_tiff:InvalidZ', 'z must be numeric.');
end

x_u = unique(x);
y_u = unique(y);

if numel(x_u) < 2 || numel(y_u) < 2
    error('structured_xyz_to_tiff:NotEnoughGridPoints', ...
        'At least two unique x values and two unique y values are required.');
end

% Validate (near) uniform spacing to ensure a proper cell raster.
dx_all = diff(x_u);
dy_all = diff(y_u);
dx = median(dx_all);
dy = median(dy_all);

if dx <= 0 || dy <= 0
    error('structured_xyz_to_tiff:InvalidResolution', 'Non-positive grid resolution detected.');
end

tol_x = max(1e-9, 1e-6 * max(abs(x_u)));
tol_y = max(1e-9, 1e-6 * max(abs(y_u)));
if any(abs(dx_all - dx) > tol_x)
    error('structured_xyz_to_tiff:NonUniformX', ...
        'x spacing is not uniform within tolerance.');
end
if any(abs(dy_all - dy) > tol_y)
    error('structured_xyz_to_tiff:NonUniformY', ...
        'y spacing is not uniform within tolerance.');
end

ncols = numel(x_u);
nrows = numel(y_u);
Z = nan(nrows, ncols);

col = round((x - x_u(1)) ./ dx) + 1;
row_south = round((y - y_u(1)) ./ dy) + 1;

if any(col < 1 | col > ncols) || any(row_south < 1 | row_south > nrows)
    error('structured_xyz_to_tiff:IndexingError', 'Point indexing fell outside raster bounds.');
end

x_snap = x_u(1) + (col - 1) .* dx;
y_snap = y_u(1) + (row_south - 1) .* dy;
if any(abs(x - x_snap) > tol_x) || any(abs(y - y_snap) > tol_y)
    error('structured_xyz_to_tiff:OffGridPoints', ...
        'Some points do not align with the inferred structured grid.');
end

% North-up raster: first row corresponds to max(y).
row = nrows - row_south + 1;
lin = sub2ind([nrows, ncols], row, col);

switch duplicate_policy
    case "error"
        if numel(unique(lin)) ~= numel(lin)
            error('structured_xyz_to_tiff:DuplicateXY', ...
                ['Duplicate (x,y) points found. Use DuplicatePolicy ''last'' ', ...
                 'or ''mean'' if duplicates are expected.']);
        end
        Z(lin) = z;

    case "last"
        % Last sample wins for duplicate cells.
        Z(lin) = z;

    case "mean"
        [lin_u, ~, ic] = unique(lin);
        z_mean = accumarray(ic, z, [], @mean);
        Z(lin_u) = z_mean;

    otherwise
        error('structured_xyz_to_tiff:UnsupportedDuplicatePolicy', 'Unsupported duplicate policy.');
end

x_limits = [x_u(1) - 0.5 * dx, x_u(end) + 0.5 * dx];
y_limits = [y_u(1) - 0.5 * dy, y_u(end) + 0.5 * dy];

if ~split_tiles
    n_valid = sum(~isnan(Z), 'all');
    if n_valid == 0
        fprintf('Skipping TIFF write (no valid data): %s\n', fpath_output_tif);
        return
    end

    Z_write = Z;
    if ~isempty(nodata_value)
        Z_write(isnan(Z_write)) = nodata_value;
    end

    write_one_tif(fpath_output_tif, Z_write, x_limits, y_limits, dx, dy, epsg_code);

    n_total = numel(Z);
    fill_pct = 100 * n_valid / n_total;
    fprintf('GeoTIFF written: %s\n', fpath_output_tif);
    fprintf('Raster size     : %d rows x %d cols\n', nrows, ncols);
    fprintf('Resolution      : dx = %.6f, dy = %.6f\n', dx, dy);
    fprintf('Extent          : [%.3f %.3f] x [%.3f %.3f]\n', x_limits(1), x_limits(2), y_limits(1), y_limits(2));
    fprintf('Filled cells    : %d / %d (%.2f%%)\n', n_valid, n_total, fill_pct);
    return
end

tile_rows = tile_size(1);
tile_cols = tile_size(2);
if tile_rows <= 0 || tile_cols <= 0
    error('structured_xyz_to_tiff:InvalidTileSize', 'TileSize must contain positive values.');
end

[fdir_out, fname_out, fext_out] = fileparts(fpath_output_tif);
if isempty(fext_out)
    fext_out = '.tif';
end

n_written = 0;
for r0 = 1:tile_rows:nrows
    r1 = min(r0 + tile_rows - 1, nrows);
    for c0 = 1:tile_cols:ncols
        c1 = min(c0 + tile_cols - 1, ncols);

        Z_tile = Z(r0:r1, c0:c1);
        if ~any(~isnan(Z_tile), 'all')
            continue
        end

        x_tile_left = x_limits(1) + (c0 - 1) * dx;
        x_tile_right = x_limits(1) + c1 * dx;
        y_tile_top = y_limits(2) - (r0 - 1) * dy;
        y_tile_bottom = y_limits(2) - r1 * dy;

        x_limits_tile = [x_tile_left, x_tile_right];
        y_limits_tile = [y_tile_bottom, y_tile_top];

        if ~isempty(nodata_value)
            Z_tile(isnan(Z_tile)) = nodata_value;
        end

        tile_name = sprintf('%s_r%05d_c%05d%s', fname_out, r0, c0, fext_out);
        fpath_tile = fullfile(fdir_out, tile_name);
        write_one_tif(fpath_tile, Z_tile, x_limits_tile, y_limits_tile, dx, dy, epsg_code);
        n_written = n_written + 1;
    end
end

if n_written == 0
    fprintf('No TIFF tiles written (all tiles empty): %s\n', fpath_output_tif);
else
    fprintf('Wrote %d TIFF tile(s) from raster size %d x %d using tile size %d x %d.\n', ...
        n_written, nrows, ncols, tile_rows, tile_cols);
end

end

function write_one_tif(fpath_output_tif, Z_write, x_limits, y_limits, dx, dy, epsg_code)

if exist('geotiffwrite', 'file') ~= 2
    error('structured_xyz_to_tiff:MissingGeoTiffWriter', ...
        ['No geotiffwrite function found on MATLAB path. Add OET path ', ...
         'or install Mapping Toolbox.']);
end

% Try Mapping Toolbox API first, then fallback to OET's standalone writer.
try
    if exist('maprefcells', 'file') == 2
        R = maprefcells(x_limits, y_limits, size(Z_write), 'ColumnsStartFrom', 'north');
    else
        % Referencing matrix fallback for older/newer MATLAB variants.
        x11 = x_limits(1) + 0.5 * dx;
        y11 = y_limits(2) - 0.5 * dy;
        R = [dx, 0; 0, -dy; x11 - dx, y11 + dy];
    end
    geotiffwrite(fpath_output_tif, Z_write, R, 'CoordRefSysCode', epsg_code);
catch me_map
    try
        option = struct();
        option.GTModelTypeGeoKey = 1;       % Projected
        option.GTRasterTypeGeoKey = 1;      % RasterPixelIsArea
        option.ProjectedCSTypeGeoKey = epsg_code;
        option.ProjLinearUnitsGeoKey = 9001; % metre
        option.ModelPixelScaleTag = [dx; dy; 0];
        option.ModelTiepointTag = [0; 0; 0; x_limits(1); y_limits(2); 0];
        geotiffwrite(fpath_output_tif, [], single(Z_write), 32, option);
    catch me_oet
        error('structured_xyz_to_tiff:GeoTiffWriteFailed', ...
            ['GeoTIFF writing failed with both APIs. Mapping-style error: %s | ', ...
             'OET-style error: %s'], me_map.message, me_oet.message);
    end
end

end
