function simona2mdu_grd2net(filgrd,fildep,filmdu)

% simona2mdu_grd2net : Converts d3d-flow grid file to dfm net file
%                      (Based upon grd2net from Wim van Balen, however UI dependencies removed)

netfile       = [filmdu '_net.nc'];
samfile       = [filmdu '.xyz'];

% Read the grid
G           = delft3d_io_grd('read',filgrd);
xh          = G.cor.x;
yh          = G.cor.y;
M           = size(xh,1);
N           = size(xh,2);

% Check coordinate system

if strcmp(G.CoordinateSystem,'Spherical');
    spher   = 1;
else
    spher   = 0;
end

depthdat     = wldep('read',fildep,[M+1 N+1],'multiple');
zh           = depthdat.Data;
zh(zh==-999) = NaN;
zh           = -zh;
zh(end,:  )  = [];
zh(:  ,end)  = [];

% Make file with bathymetry samples

xsamp          = reshape(xh,[M.*N 1]);
ysamp          = reshape(yh,[M.*N 1]);
zsamp          = reshape(zh,[M.*N 1]);

irow = 0;
for isamp = 1: length(xsamp)
    if ~isnan(xsamp(isamp))
        irow = irow + 1;
        LINE.DATA{irow,1} = xsamp(isamp);
        LINE.DATA{irow,2} = ysamp(isamp);
        LINE.DATA{irow,3} = zsamp(isamp);
    end
end

unstruc_io_xydata('write',samfile,LINE)

% Write netCDF-file

net2cdf;
