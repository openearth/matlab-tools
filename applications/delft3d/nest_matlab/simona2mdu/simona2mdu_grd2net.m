function simona2mdu_grd2net(filgrd,fildep,filmdu)

% simona2mdu_grd2net : Converts d3d-flow grid file to dfm net file
%                      (Based upon grd2net from Wim van Balen, however UI dependencies removed)

netfile       = [filmdu '_net.nc'];
samfile       = [filmdu '.xyz'];

% Read the grid
G           = delft3d_io_grd('read',filgrd,'Enclosure',false);
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
exist          = ~isnan(xsamp);

LINE.DATA{:,1} = xsamp(exist);
LINE.DATA{:,2} = ysamp(exist);
LINE.DATA{:,3} = zsamp(exist);

unstruc_io_xydata('write',samfile,LINE)

% Write netCDF-file

net2cdf;
