function d3d2dflowfm_grd2net(filgrd,fildep,filmdu)

% d3d2dflowfm_grd2net : Converts d3d-flow grid file to D-Flow FM net file
%                       (Based upon grd2net from Wim van Balen, however UI dependencies removed)

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

tmp(:,1) = reshape(xh,[M.*N 1]);
tmp(:,2) = reshape(yh,[M.*N 1]);
tmp(:,3) = reshape(zh,[M.*N 1]);

nonan          = ~isnan(tmp(:,1));

LINE.DATA = num2cell(tmp(nonan,:));

% write to unstruc xyz file
dflowfm_io_xydata('write',samfile,LINE)

% Write netCDF-file
net2cdf;
