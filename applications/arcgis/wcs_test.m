%WCS_test test for wcs
%
% test using these servers:
% 
% With dimensions
%   1.1.0 4326=?? DescribeCoverage=1 http://geodata.nationaalgeoregister.nl/ahn1/wcs?service=WCS&version=1.0.0&request=GetCapabilities
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

warning('implement checks for: crs, resx, resy, interpolation')

server = 'http://geodata.nationaalgeoregister.nl/ahn1/wcs?';
[url,OPT,lims] = wcs('server',server,'coverage','ahn1:ahn1_5m','crs','epsg:28992','axis',[94000 466000 96000 468000],'resx',5,'resy',5)

urlwrite(url,['tmp']);
% Kaag: water and land, with train through it and some high buildings (loodsen)
% http://geodata.nationaalgeoregister.nl/ahn1/wcs?&service=wcs&version=1.0.0&request=GetCoverage&bbox=94000,466000,96000,468000&coverage=ahn1:ahn1_5m&format=GeoTIFF&crs=epsg:28992&resx=5&resy=5

a = imread(['tmp']);
a(a==-32768)=nan;
pcolorcorcen(OPT.x,OPT.y,double(a))