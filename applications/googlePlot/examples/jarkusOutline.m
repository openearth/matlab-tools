
%% example 1
clear all
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
contents = opendap_folder_contents(url);
EPSG = load('EPSGnew');
for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x   = nc_varget(contents{ii},   'x');
    y   = nc_varget(contents{ii},   'y');
    x2 = [x(1) x(end) x(end) x(1) x(1)];
    y2 = [y(1) y(1) y(end) y(end) y(1)];
    [lon2(:,ii),lat2(:,ii)] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    text{ii} = fname;
end
KMLline(lat2,lon2,'fileName','jarkusOutlineDisco.kml','text',text,'lineColor',jet(length(lat2(1,:))))
KMLline(lat2,lon2,'fileName','jarkusOutline.kml'     ,'text',text,'lineColor',[0 0 0])


%% example 2
clear all
url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/grids';
contents = openDapFolderContents(url);
EPSG = load('EPSGnew');
for ii = 1:length(contents);
    [path, fname] = fileparts(contents{ii});
    x    = nc_varget(contents{ii},   'x');
    y    = nc_varget(contents{ii},   'y');
    time = nc_varget(contents{ii},'time');
    z    = nc_varget(contents{ii},   'z', [length(time)-1,0,0],[1,-1,-1]);
    z(z>100) = nan;
    x2 = [x(1:end-1);repmat(x(end),size(y));x(end-1:-1:2);repmat(x(1),size(y))];
    y2 = [repmat(y(1),size(x));y(2:end-1);repmat(y(end),size(x));y(end-1:-1:1)];
    z2(:,ii) = [z(1,:)';z(1:end,end);z(end,end:-1:1)';z(end:-1:1,1);z(1,1)];
    [lon2(:,ii),lat2(:,ii)] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
end
z2(isnan(z2))=-50;
KMLline3(lat2,lon2,(z2+50)*10,'fileName','jarkusOutline2.kml','lineWidth',0,'extrude',1)