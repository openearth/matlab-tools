%WCS_test test for wcs
%
% test using these servers:
% 
% With dimensions
%   1.1.0 4326=?? DescribeCoverage=1 http://geodata.nationaalgeoregister.nl/ahn1/wcs?service=WCS&version=1.0.0&request=GetCapabilities
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

warning('implement checks for: crs, resx, resy, interpolation')

%% get url and data
% AHN2 http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|f20e948e-9e22-4b5a-96a1-f3cc1d16b808
% http://www.nationaalgeoregister.nl/geonetwork/srv/dut/search#|94e5b115-bece-4140-99ed-93b8f363948e

server = 'http://geodata.nationaalgeoregister.nl/ahn2/wms?';
[url,OPT,lim] = wcs('server',server,...
    'coverage','ahn2:ahn2_5m',... % shoudl not work: GeoTIFF (case)
    'format','GeoTiff',...
    'crs','epsg:4326',...
    'axis',[94000 466000 96000 468000],...
    'resx',5,'resy',5);

% server = 'http://geodata.nationaalgeoregister.nl/ahn1/wcs?';
% [url,OPT,lim] = wcs('server',server,...
%     'coverage','ahn1:ahn1_5m',...
%     'crs','epsg:4326',...
%     'axis',[94000 466000 96000 468000],...
%     'resx',5,'resy',5)

cachename = [OPT.cachedir,mkvar(OPT.coverage),OPT.format];
urlwrite(url,cachename);

%% plot data
% Kaag: water and land, with train through it and some high buildings (loodsen)
% http://geodata.nationaalgeoregister.nl/ahn1/wcs?&service=wcs&version=1.0.0&request=GetCoverage&bbox=94000,466000,96000,468000&coverage=ahn1:ahn1_5m&format=GeoTIFF&crs=epsg:28992&resx=5&resy=5

a = imread(cachename);
a(a<-3.402e+38)=nan;  % ahn2
%a(a==-32768)=nan;    % ahn1
pcolorcorcen(OPT.x,OPT.y,double(a))
tickmap('xy')
print2screensize([filepathstrname(cachename),'.png'])