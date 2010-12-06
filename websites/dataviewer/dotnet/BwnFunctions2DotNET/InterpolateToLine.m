function outputPng = InterpolateToLine(ncfile,ncVariable,Centre,Vertex,varargin)
%% specify possible ncVariable names for longitude, latitude
par_lon = {'longitude','lon','longitude_cen','x','X'};
par_lat = {'latitude','lat','latitude_cen','y','Y'};

outputPng = generateoutputpngname(varargin{:});

%% Load netcdf data
resolution = 100; % Specify the resolution of the output data (in m)

try
    % try loading longitude
    lon = retrievecoordinates(ncfile,par_lon);
        
    % try loading latitude
    lat = retrievecoordinates(ncfile,par_lat);
        
    % try loading z
    z = nc_varget(ncfile,ncVariable);
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
print(f,'-dpng','-r120',outputPng);
close(f);

end

function outvar = retrievecoordinates(ncfile,par_names)
    outvar = [];
    for ii = 1:length(par_names)
        try
            outvar = nc_varget(ncfile,par_names{ii});
        catch me
            % dont worry
        end
        if ~isempty(outvar)
            break;
        end
    end
    if isempty(outvar)
        error('InterpolateToLine:NoCoordinate','Output coordinate not defined');
    end
end