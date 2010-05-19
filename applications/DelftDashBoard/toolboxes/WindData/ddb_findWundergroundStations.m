function [lon,lat,id,name]=ddb_findWundergroundStations(maxlat,minlat,maxlon,minlon,stationType);

% FINDWUNDERGROUNDSTATIONS - Find wunderground (Weather Underground) stations within certain area
if nargin<4
    maxlat=90;
    minlat=-90;
    maxlon=180;
    minlon=-180;
end

if nargin<5
    stationType=[];
end

lat=[];
lon=[];
id=[];
name=[];

tic;
while toc<3 % look during t seconds for stations
    s=urlread(['http://stationdata.wunderground.com/cgi-bin/stationdata?maxlat=' num2str(maxlat) '&minlat=' num2str(minlat) '&maxlon=' num2str(maxlon) '&minlon=' num2str(minlon) '&iframe=1&module=1']);
    ss=strread(s,'%s','delimiter',';');

    idStation=find(~cellfun('isempty',regexp(ss,'\[''id''\]')));
    idLat=find(~cellfun('isempty',regexp(ss,'\[''lat''\]')));
    idLon=find(~cellfun('isempty',regexp(ss,'\[''lon''\]')));
    idType=find(~cellfun('isempty',regexp(ss,'\[''type''\]')));
    idName=find(~cellfun('isempty',regexp(ss,'\[''adm1''\]')));

    lat2=regexprep(ss(idLat),'t\[''lat''\]="','');
    lat2=regexprep(lat2,'"','');
    lat2=str2num(strvcat(lat2{:}));

    lon2=regexprep(ss(idLon),'t\[''lon''\]="','');
    lon2=regexprep(lon2,'"','');
    lon2=str2num(strvcat(lon2{:}));

    id2=regexprep(ss(idStation),'t\[''id''\]="','');
    id2=regexprep(id2,'"','');
    
    name2=regexprep(ss(idName),'t\[''adm1''\]="','');
    name2=regexprep(name2,'"','');
    
    type=regexprep(ss(idType),'t\[''type''\]="','');
    type=regexprep(type,'"','');

    if ~isempty(stationType)
        filterId=find(~cellfun('isempty',regexp(type,stationType)));
        lon=[lon; lon2(filterId)];
        lat=[lat; lat2(filterId)];
        name=[name; name2(filterId)];
        id=[id; id2(filterId)];
        [id, i]=unique(id);
        lon=lon(i);
        lat=lat(i);
        name=name(i);
    end
end
