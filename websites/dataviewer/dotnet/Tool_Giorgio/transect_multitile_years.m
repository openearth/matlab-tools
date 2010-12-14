function filename = transect_multitile_years(Vertex,Centre)
% TRANSECT_MULTITILE_YEARS just a kml line for the vaklodingen 
%
% transect_multitile_years(lat1,lon1,lat2,lon2,<keyword,value>)
%
% (lat1,lon1): coordinates of the starting point
% (lat2,lon2): coordinates of the ending point
%
% coordinates (lat1,lon1,lat2,lon2) are in decimal degrees 
%   LON is converted to a value in the range -180..180)
%   LAT must be in the range -90..90
% 
% This program creates a KML file for the Vaklodingen. Bathymetric
% profiles are drawn at the Earth surface connecting the defined
% coordinates.
% Transects of the Western Scheldt have been defined manually on 
% GoogleEarth and then saved on "myplaces".
% The function KMLline is called to create the lines in Google Earth
% The function convertCoordinates is called to change coordinate 
% system.
%
% --------------------------------------------------------------------
% Copyright (C) 2010 Deltares
%       Giorgio Santinelli
%    
%       Giorgio.Santinelli@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
% See also: KMLline, convertCoordinates, googlePlot
% --------------------------------------------------------------------
%% settings
if exist('d:\Repositories\oetools\python\applications\openearthtest\openearthtest\public\test.kml')
   delete('d:\Repositories\oetools\python\applications\openearthtest\openearthtest\public\test.kml');
end
OPT.fileName = 'd:\Repositories\oetools\python\applications\openearthtest\openearthtest\public\test.kml';
%OPT.fileName = '//dtvirt13/bwn/optie_compiled/test.kml';

% Calculate coordinates of line
lon1 = Vertex(2);
lat1 = Vertex(1);

lon2 = lon1 + 2 * (Centre(2) - Vertex(2));
lat2 = lat1 + 2 * (Centre(1) - Vertex(1));


%% Read the path from the opendap
ncpath = 'http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/DienstZeeland/catalog.html'; % DienstZeeland data
% ncpath = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.html'; % Rijkswaterstaat data
fns = opendap_catalog(ncpath);

%% 1D Resolution of transect
stepsize = 5; % metres

%% Convert coordinate system 
% from 'WGS 84' (code:4326) to 'Amersfoort / RD New' (code:28992)
[x1, y1] = convertCoordinates(lon1, lat1, 'CS1.code', '4326', 'CS2.code', '28992');
[x2, y2] = convertCoordinates(lon2, lat2, 'CS1.code', '4326', 'CS2.code', '28992');

%% Define distances (dx, dy), length, number of steps (based on stepsize),
% transect points in 'WGS 84' (X_0, Y_0) and 'Amersfoort / RD New' (lon_0, lat_0)
dx = x2-x1; dy = y2-y1;
len = sqrt(dx^2+dy^2);
nstep = len/stepsize;
stepsize_x = dx/nstep; stepsize_y = dy/nstep;
X_0 = x1:stepsize_x:x1+((nstep)-1)*stepsize_x;
Y_0 = y1:stepsize_y:y1+((nstep)-1)*stepsize_y;
[lon_0, lat_0] = convertCoordinates(X_0, Y_0, 'CS1.code', '28992', 'CS2.code', '4326');

%% Find related KB (urlcross) and date of measurement (date_KB)
i_KB = 1;
date_KB = [];
for i = 1:length(fns)
    url = fns{i};
    lon = nc_varget(url, 'lon');
    lat = nc_varget(url, 'lat');   

    if ismember(true, ((min(lon1,lon2)<lon)&(max(lon1,lon2)>lon))) &&...
            ismember(true, ((min(lat1,lat2)<lat)&(max(lat1,lat2)>lat)));
        urlcross{i_KB} = url;
        date{i_KB} = nc_cf_time(url, 'time');
        date_i = date{i_KB};
        date_KB = union(date_KB, date_i);
        i_KB = i_KB+1;
    end
end

%% Read bathymetry for the related KB, for every year
dumX_0 = 0:stepsize:((nstep)-1)*stepsize;
for k = 1:length(date_KB) % Cycle of dates of measurement
    z_0{k} = [];
    x_0{k} = [];
    
    for i = 1:(i_KB-1) % Cycle of the related KB
        [tf_date n_year] = ismember(date_KB, date{i});
        
        if tf_date(k) % Make it if, in date_KB, the related KB (urlcross) has data.
            Z{i} = nc_varget(urlcross{i}, 'z', [n_year(k)-1,0,0], [1,-1,-1]);
            y{i} = nc_varget(urlcross{i}, 'y');
            x{i} = nc_varget(urlcross{i}, 'x');
            [X{i} Y{i}] = meshgrid(x{i}, y{i}); % Create the grid for interp2
            
            xline{i} = 0:stepsize:((nstep)-1)*stepsize;
            zline{i} = interp2(X{i}, Y{i}, Z{i}, X_0, Y_0);
        
            dumz = (zline{i})';
            z_0{k} = vertcat(z_0{k}, dumz);
            dumx = (xline{i})';
            x_0{k} = vertcat(x_0{k}, dumx); 
        end
    end
    
    z_nnan{k} = nan(size(z_0{k}));
    x_nnan{k} = nan(size(z_0{k}));
    
    if ~isempty(z_0{k}(~isnan(z_0{k})))
        z_nnan{k} = z_0{k}(~isnan(z_0{k}));
        x_nnan{k} = x_0{k}(~isnan(z_0{k}));
        z_kml{k} = interp1(x_nnan{k}, z_nnan{k}, dumX_0); % the cell variable of the bathymetry along the defined transect
    else
        z_kml{k} = nan(size(dumX_0));       
    end
    
end
clear dumX_0 dumx dumz

%% Define timeIn and timeOut for Google Earth
timeIn = date_KB;
timeOut = date_KB(2:end);
timeOut(end+1,1) = date_KB(end)+1;

%% Create matrix z_KML for KMLline
for k = 1:length(date_KB)
    z_KML(k,:) = z_kml{k};
end

%% Create matrixes lat_0 and lon_0 for KMLline
lat_0 = repmat(lat_0, size(z_KML,1), 1);
lon_0 = repmat(lon_0, size(z_KML,1), 1);

%% Make KML file
KMLline(lat_0', lon_0', z_KML','timeIn',timeIn,'timeOut',timeOut,...
    'fileName', OPT.fileName, 'lineColor',jet(size(z_KML,1)),'lineWidth',2,...
    'fillColor',jet(size(z_KML,1)),'zScaleFun', @(z_KML)(z_KML+60)*10);
filename = OPT.fileName;
clear z_KML
%varargout = {};

%% EOF