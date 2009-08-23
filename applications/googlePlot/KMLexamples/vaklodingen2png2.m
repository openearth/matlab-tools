%VAKLODINGEN2PNG   make kml files with vaklodingen as georeferenced pngs
%
%See also: jarkusgrids2png, vaklodingen2kml, vaklodingen_overview

outputDir      = 'D:\Thijs\Desktop\vaklodingen2';
url            = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen';
contents       = opendap_folder_contents(url);
EPSG           = load('EPSG');

colormap(colormapbathymetry(128));
clim([-20 20]);

for ii = length(contents):-1:1;
    [path, fname] = fileparts(contents{ii});
    x    = nc_varget(contents{ii},   'x');
    y    = nc_varget(contents{ii},   'y');
    time = nc_varget(contents{ii},'time');

    % expand x and y 10 m in each direction
    x = [x(1) + (x(1)-x(2))/2; x; x(end) + (x(end)-x(end-1))/2];
    y = [y(1) + (y(1)-y(2))/2; y; y(end) + (y(end)-y(end-1))/2];
    % coordinates:
    [X,Y] = meshgrid(x,y);
    [lon,lat] = convertCoordinates(X,Y,...
        EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');

    % convert time to years
    time = time+datenum(1970,1,1);
    date = datestr(time,'yyyy-mm-dd');
    date(end+1,:) = datestr(now,'yyyy-mm-dd');

    if size(time,1)>0
        for jj = size(time,1);
            if ~exist([outputDir filesep fname '_' date(jj,:) '.kml'],'file')

                % display progress
                disp([num2str(ii) '/' num2str(length(contents)) ' ' fname ' ' date(jj,:)]);
                % load z data
                z = nc_varget(contents{ii},'z',[jj-1,0,0],[1,-1,-1]);

                % expand z
                z = z([1 1:end end],:);
                z = z(:,[1 1:end end]);
                z(z>500) = nan;
                h = surf(lon,lat,-z);%camlight right;
                camlight(-40,20,'infinite')
                colormap(flipud(colormapbathymetry(17)));
                clim([-20 20]);
                shading interp;material([.7 .3 0.2]);lighting phong
                axis off;axis tight;view(0,90);
                KMLfig2png(h,'levels',5,'timeIn',date(jj,:),'timeOut',date(jj+1,:),...
                    'fileName',[outputDir filesep fname '_' date(jj,:) '.kml'],...
                    'drawOrder',str2double(datestr(time(jj),'yyyy'))*10,...
                    'alpha',1,'maxLod',256,'minLod',64,'dim',128);
            else
                disp([num2str(ii) '/' num2str(length(contents)) ' ' fname ' ' date(jj,:) ' already created']);
            end
        end
    end
end


