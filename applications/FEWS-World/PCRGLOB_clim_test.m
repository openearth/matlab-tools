% function PCRGLOB_clim(lat_range, lon_range, var)
lat_range = [0 30];
lon_range = [0 60];
nc_file = '';
nryears = 20;
% Bereken assen

for t = 1:1
    rasters = zeros(nrrows,nrcols,nryears);
    for y = 1:20
        rasters(..,..(y-1)*12+t-1);
    end
    out_raster = mean(rasters,3);
    imagesc(out_raster)
end
