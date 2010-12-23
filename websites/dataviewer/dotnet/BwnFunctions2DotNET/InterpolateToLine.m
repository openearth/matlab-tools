function outputPng = InterpolateToLine(ncfile,ncVariable,Centre,Vertex,varargin)

outputPng = generateoutputpngname(varargin{:});

%% Calculate coordinates of line
lonL = Vertex(2);
latL = Vertex(1);

lonL (2) = lonL + 2 * (Centre(2) - Vertex(2));
latL (2) = latL + 2 * (Centre(1) - Vertex(1));

%% Load netcdf data
resolution = 100; % Specify the resolution of the output data (in m)

lonVar = nc_varfind(ncfile, 'attributename','standard_name','attributevalue','longitude');
latVar = nc_varfind(ncfile, 'attributename','standard_name','attributevalue','latitude');

try
    % try loading longitude and latitude
    [lon, lat,start,count] = nc_varget_range2d(ncfile,{lonVar,latVar},[lonL' latL']);
    
    % try loading z
    z = nc_varget(ncfile,ncVariable,start,count);
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

%% convert coordinates to UTM
[x,y] = convertCoordinates(lon, lat,'CS1.code',4326,'CS2.code',32631);
[xl, yl] = convertCoordinates(lonL, latL,'CS1.code',4326,'CS2.code',32631);

%% create line with specified resolution
lineLength = sqrt(diff(xl)^2 + diff(yl)^2);
numOfSegments = round(lineLength/resolution);
if numOfSegments > 1
    xl = xl(1):diff(xl)/numOfSegments:xl(2);
    yl = yl(1):diff(yl)/numOfSegments:yl(2);
end
dist = pathdistance(xl,yl);

%% interpolate data to line
zl = griddata(x,y,z,xl,yl);

%% Plot time series
f=figure('visible','off');
plot(dist,zl,'k');
ylabel(ncVariable);
xlabel('distance [m]');
grid on;

%% Print to file
print(f,'-dpng','-r120',outputPng);
close(f);

end