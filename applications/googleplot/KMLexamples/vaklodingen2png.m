%VAKLODINGEN2PNG   make kml files with vaklodingen as georeferenced pngs
%
%See also: jarkusgrids2png, vaklodingen2kml, vaklodingen_overview

outputDir               = 'D:\KML\Vaklodingen';
url                     = vaklodingen_url;
EPSG                    = load('EPSG');
time_at_starting_script = datenum('2009-12-14');%datestr(now,'yyyy-mm-dd');

for ii = 1:length(url);
    [path, fname] = fileparts(url{ii});
    x    = nc_varget(url{ii},   'x');
    y    = nc_varget(url{ii},   'y');
    time = nc_varget(url{ii},'time');
    
    % expand x and y 15 m in each direction to create some overlap
    x = [x(1) + (x(1)-x(2))*.75; x; x(end) + (x(end)-x(end-1))*.75];
    y = [y(1) + (y(1)-y(2))*.75; y; y(end) + (y(end)-y(end-1))*.75];
    % coordinates:
    [X,Y] = meshgrid(x,y);
    [lon,lat] = convertCoordinates(X,Y,...
        EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    
    % convert time to years
    time          = time+datenum(1970,1,1);
    date          = time;
    date(end+1,:) = time_at_starting_script;
    
    for jj = size(time,1):-1:1%size(time,1)+1 - min(size(time,1),3)   ;
        fileName = [outputDir filesep fname '_' datestr(date(jj),29) '.kml'];
        if ~exist(fileName,'file')
            % display progress
            disp([num2str(ii) '/' num2str(length(url)) ' ' fname ' ' datestr(date(jj),29)]);
            % load z data
            z = nc_varget(url{ii},'z',[jj-1,0,0],[1,-1,-1]);
            z(z>500) = nan;
            if ~all(all(isnan(z)))
                disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%'])
                % expand z
                z = z([1 1:end end],:);
                z = z(:,[1 1:end end]);
                h = surf(lon,lat,z);
                lightangle(-180,60)
                shading interp;material([.9 0.08 .07]);lighting phong
                axis off;axis tight;view(0,90);
                colormap(colormap_cpt('bathymetry_vaklodingen',500));clim([-50 25]);
                KMLfig2png(h,'levels',[-2 3], 'scaleableLight',true,...
                    'timeIn',date(jj),'timeOut',date(jj+1),...
                    'fileName',fileName,...
                    'drawOrder',str2double(datestr(time(jj),'yyyy'))*10);
            else
                disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%, no file created'])
            end
        else
            disp([fileName ' already created']);
        end
    end
end