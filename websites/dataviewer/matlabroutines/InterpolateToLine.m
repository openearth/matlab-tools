function output = InterpolateToLine(ncfile,parameter,Centre,Vertex)

%% Add java shit
% Add java paths for snc tools
% pth=fullfile(ctfroot,'checkout','OpenEarthTools','trunk','matlab','io','netcdf','toolsUI-4.1.jar');
pth = fullfile('C:\Inetpub\wwwroot\ZMMatlab\Resources\toolsUI-4.1.jar');
if ~exist(pth,'file')
    warning('InterpolateToLine:NoJava',['Could not find path to java library: "' pth '". Try searching for the file']);
    pth = which('toolsUI-4.1.jar');
    if isempty(pth)
        error('could not find java library');
    end
end

if ~any(ismember(javaclasspath,pth))
    javaaddpath(pth);
end

if ~any(ismember(javaclasspath,pth))
    error(['Java library was not added', char(10),...
        'At this moment we only know:', char(10),...
        javaclasspath]);
end

setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse

%% specify possible parameter names for longitude, latitude
par_lon = {'longitude','lon','longitude_cen','x','X'};
par_lat = {'latitude','lat','latitude_cen','y','Y'};

%% Load netcdf data
resolution = 100; % Specify the resolution of the output data (in m)

try
    % try loading longitude
    lon = [];
    ii = 1;
    while isempty(lon)
        try
            if ii <= length(par_lon)
                lon = nc_varget(ncfile,par_lon{ii});
            else
                lon = nan;
                return;
            end
        catch
            ii = ii + 1;
        end
    end
    
    % try loading latitude
    lat = [];
    ii = 1;
    while isempty(lat)
        try
            if ii <= length(par_lat)
                lat = nc_varget(ncfile,par_lat{ii});
            else
                lat = nan;
                return;
            end
        catch
            ii = ii + 1;
        end
    end
    
    % try loading z
    z = nc_varget(ncfile,parameter);
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

% Calculate coordinates of line
lonl = Vertex(2);
latl = Vertex(1);

lonl (2) = lonl + 2 * (Centre(2) - Vertex(2));
latl (2) = latl + 2 * (Centre(1) - Vertex(1));

%% convert coordinates to UTM
[x,y] = convertCoordinates(lon, lat,'CS1.code',4326,'CS2.code',32631);
[xl, yl] = convertCoordinates(lonl, latl,'CS1.code',4326,'CS2.code',32631);

%% create line with specified resolution
lineLength = sqrt(diff(xl)^2 + diff(yl)^2);
numOfSegments = round(lineLength/resolution);
if numOfSegments > 1
    xl = xl(1):diff(xl)/numOfSegments:xl(2);
    yl = yl(1):diff(yl)/numOfSegments:yl(2);
end
dist = pathdistance(xl,yl);

%% interpolate data to line (first limit bathy data to area around line +/- 5%)
xlim = [xl(1) xl(end)];
xlim = [xlim(1)-0.05*diff(xlim) xlim(2)+0.05*diff(xlim)];
ylim = [yl(1) yl(end)];
ylim = [ylim(1)-0.05*diff(ylim) ylim(2)+0.05*diff(ylim)];

id = find(x>min(xlim)&x<max(xlim)&y>min(ylim)&y<max(ylim));
zl = griddata(x(id),y(id),z(id),xl,yl);

%% Plot time series
f=figure('visible','off');
plot(dist,zl,'k');
ylabel('z [m NAP]');
xlabel('distance [m]');
grid on;

%% Print to file
outputPng = [tempname '.png'];
print(f,'-dpng','-r120',outputPng);
close(f);

%% Generate output
ouput.dist = dist;
output.zl = zl;
outputpng = outputPng;