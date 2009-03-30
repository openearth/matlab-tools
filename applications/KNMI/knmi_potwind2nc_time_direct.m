% function knmi_potwind2nc_time_direct(varargin)
%KNMI_POTWIND2NC_TIME_DIRECT  This is a first test to get wind timeseries into NetCDF
%
%  Timeseries data, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788
%
% In this example time is both a dimension and a variables.
% The datenum values do not show up as a parameter in ncBrowse.
%
%See also: KNMI_POTWIND2NC_TIME_INDIRECT, SNCTOOLS, KNMI_POTWIND, SEDIMENTATLAS_KORREL2NC

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

%% Initialize
%------------------

   OPT.fillvalue     = 0; % NaNs do not work in netcdf API
   OPT.dump          = 0;
   OPT.directory.raw = 'F:\checkouts\OpenEarthRawData\knmi\potwind\raw\';
   OPT.directory.nc  = 'F:\checkouts\OpenEarthRawData\knmi\potwind\nc\';
   OPT.files         = dir([OPT.directory.raw filesep 'potwind*']);
   
for ifile=1:length(OPT.files)  

   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)  )])

   OPT.filename = [OPT.directory.raw, filesep, OPT.files(ifile).name]; % e.g. 'potwind_210_1981'

%% 0 Read raw data
%------------------

   D             = knmi_potwind(OPT.filename,'variables',OPT.fillvalue);

%% 1a Create file
%------------------

   outputfile    = [OPT.directory.nc filesep  filename(D.filename),'_time_direct.nc'];
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'        , '');
   nc_attput(outputfile, nc_global, 'institution'  , 'KNMI');
   nc_attput(outputfile, nc_global, 'source'       , 'surface observation');
   nc_attput(outputfile, nc_global, 'history'      , ['Original filename: ',D.filename,' version:',D.version,...
                                                      ' tranformed to NetCDF by G.J. de Boer <g.j.deboer@deltares.nl>, ',datestr(now,31),' by: $HeadURL$ $Revision$ $Date$ $Author$']);
   nc_attput(outputfile, nc_global, 'references'   , '<http://www.knmi.nl/samenw/hydra>,<http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/>');
   nc_attput(outputfile, nc_global, 'comment'      , '');
   nc_attput(outputfile, nc_global, 'version'      , D.version);
						   
   nc_attput(outputfile, nc_global, 'Conventions'  , 'CF-1.4');
   
   nc_attput(outputfile, nc_global, 'stationnumber', D.stationnumber);
   nc_attput(outputfile, nc_global, 'stationname'  , D.stationname);
   nc_attput(outputfile, nc_global, 'over'         , D.over);
   nc_attput(outputfile, nc_global, 'height'       , num2str(D.height));
   nc_attput(outputfile, nc_global, 'timezone'     , 'GMT');

%% 2 Create dimensions
%------------------

   nc_add_dimension(outputfile, 'time'     , length(D.datenum))
   nc_add_dimension(outputfile, 'locations', 1)

%% 3 Create variables
%------------------

   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
   %------------------

   %% Longitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   %------------------
   
   nc.lon = struct(...
   'Name'     , 'lon', ...
   'Nctype'   , 'float', ...
   'Dimension', {{'locations'}});
   nc.lon.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc.lon.Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc.lon.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   %------------------
   
   nc.lat = struct(...
   'Name'     , 'lat', ...
   'Nctype'   , 'float', ...
   'Dimension', {{'locations'}});
   nc.lat.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc.lat.Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc.lat.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   %------------------
   
   nc.time = struct(...
       'Name'     , 'time', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.time.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc.time.Attribute(2) = struct('Name', 'units'          ,'Value', 'days since 0000-1-1 0:0:0'); % matlab datenumber convention
   nc.time.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc.time.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   
   %% Parameter
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   %------------------

   nc.wind_speed = struct(...
       'Name'     , 'wind_speed', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.wind_speed.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wind speed');
   nc.wind_speed.Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc.wind_speed.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc.wind_speed.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

   nc.wind_to_direction = struct(... % wind_from_direction
       'Name'     , 'wind_to_direction', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.wind_to_direction.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'nautical wind direction');
   nc.wind_to_direction.Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees');
   nc.wind_to_direction.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_to_direction');
   nc.wind_to_direction.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

   %% Add
   %------------------

   fldnames = fieldnames(nc);
   for ifld=1:length(fldnames)
      fldname = fldnames{ifld};
      nc_addvar(outputfile, nc.(fldname));   
   end

%% 4 Create attibutes
%------------------

   % already done with creation of variables.
   % This is more efficient.
   
%% 5 Fill variables
%------------------

   nc_varput(outputfile, 'lon'               , D.lon);
   nc_varput(outputfile, 'lat'               , D.lat);
   nc_varput(outputfile, 'time'              , D.datenum);
   nc_varput(outputfile, 'wind_speed'        , D.UP);
   nc_varput(outputfile, 'wind_to_direction' , D.DD); % does not work with NaNs.
   
%% 6 Check
%------------------

   if OPT.dump
   nc_dump(outputfile);
   end
   
end %for ifile=1:length(OPT.files)   
   
%% EOF