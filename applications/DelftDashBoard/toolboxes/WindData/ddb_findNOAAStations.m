function [x,y,id,name]=ddb_findNOAAStations(maxlat,minlat,maxlon,minlon);

% NOAA Weather data station locator
stationInfo=ddb_getTableFromWeb(['http://data.nssl.noaa.gov/dataselect/nssl_result.php?datatype=sf&sdate=2009-05-24&outputtype=stnlist&area=worldwide&minlon='...
    num2str(minlon) '&maxlat=' num2str(maxlat) '&maxlon=' num2str(maxlon) '&minlat=' num2str(minlat)],2);
id=stationInfo(2:end,1);
name=stationInfo(2:end,3);
x=str2lon(stationInfo(2:end,5));
y=str2lat(stationInfo(2:end,6));

%%
function lon=str2lon(lonStr);
[deg, mi]=cellfun(@strtok,lonStr,'UniformOutput',false);
deg=cellfun(@str2num,deg);
minutes=cellfun(@str2num,cellfun(@(x) x(1:end-1),mi,'UniformOutput',false));
hemisphere=cellfun(@(x) x(end),mi);
lon=deg+minutes/60;
hs=zeros(size(hemisphere));
hs(findstr(hemisphere','E'))=1;
hs(findstr(hemisphere','W'))=-1;
lon=hs.*lon;

%%
function lat=str2lat(latStr);
[deg, mi]=cellfun(@strtok,latStr,'UniformOutput',false);
deg=cellfun(@str2num,deg);
minutes=cellfun(@str2num,cellfun(@(x) x(1:end-1),mi,'UniformOutput',false));
hemisphere=cellfun(@(x) x(end),mi);
lat=deg+minutes/60;
hs=zeros(size(hemisphere));
hs(findstr(hemisphere','N'))=1;
hs(findstr(hemisphere','S'))=-1;
lat=hs.*lat;

