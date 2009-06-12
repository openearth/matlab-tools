function knmi_etmgeg2nc_time_direct(varargin)
%KNMI_ETMGEG2NC_TIME_DIRECT  transforms directory of etmgeg ASCII files into directory of NetCDF files
%
%     KNMI_ETMGEG2NC_TIME_DIRECT(<keyword,value>) 
%
%  where the following <keyword,value> pairs have been implemented:
%
%   * fillvalue      (default nan)
%   * dump           whether to check nc_dump on matlab command line after writing file (default 0)
%   * directory_raw  directory where to get the raw data from (default [])
%   * directory_nc   directory where to put the nc data to (default [])
%   * mask           file mask (default 'potwind*')
%   * refdatenum     default (datenum(1970,1,1))
%   * ext            extension to add to the files before *.nc (default '')
%   * pause          pause between files (default 0)
%
% Example:
%  knmi_etmgeg2nc_time_direct ('directory_raw','P:\mcdata\OpenEarthRawData\knmi\etmgeg\raw\',...
%                              'directory_nc', 'P:\mcdata\opendap\knmi\etmgeg\')
%
%  Timeseries data definition:
%   * https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions (full definition)
%   * http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788 (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: KNMI_ETMGEG, SNCTOOLS, KNMI_ETMGEG_GET_URL, KNMI_POTWIND2NC_TIME_DIRECT

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;

   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % lunix  datenumber convention
   OPT.fillvalue         = nan; % NaNs do work in netcdf API
   
   OPT.stationTimeSeries = 0; % last items to adhere to for upcoming convenction, but not yet supported by QuickPlot

%% File loop

   OPT.directory_raw     = 'P:\mcdata\OpenEarthRawData\knmi\etmgeg\raw\';%[]; %
   OPT.directory_nc      = 'P:\mcdata\opendap\knmi\etmgeg\';             %[]; %
   OPT.mask              = 'etmgeg*';
   OPT.ext               = '';
   
%% Keyword,value

   OPT = setProperty(OPT,varargin{:});

%% File loop

   OPT.files         = dir([OPT.directory_raw,filesep,OPT.mask]);

for ifile=1:length(OPT.files)  

   OPT.filename = [OPT.directory_raw, filesep, OPT.files(ifile).name]; % e.g. 'etmgeg_273.txt'

   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

%% 0 Read raw data


   D                                = knmi_etmgeg(OPT.filename);
   D.version                        = '';

%% 1a get station meta-info

   [D.code,D.long_name,D.lon,D.lat] = KNMI_etmgeg_stations(unique(D.data.STN));
   
%% 1a Create file

   outputfile    = [OPT.directory_nc filesep  filename(D.filename),OPT.ext,'.nc'];
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'        , '');
   nc_attput(outputfile, nc_global, 'institution'  , 'KNMI');
   nc_attput(outputfile, nc_global, 'source'       , 'surface observation');
   nc_attput(outputfile, nc_global, 'history'      , ['Original filename: ',filename(D.filename),...
                                                      ', version:',D.version,...
                                                      ', filedate:',D.filedate,...
                                                      ', tranformation to NetCDF: $HeadURL$ $Revision$ $Date$ $Author$']);
   nc_attput(outputfile, nc_global, 'references'   , '<http://www.knmi.nl/klimatologie/daggegevens/download.html>,<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , 'http://www.knmi.nl/contact/emailformulier.htm?klimaatdesk');
   nc_attput(outputfile, nc_global, 'comment'      , '');
   nc_attput(outputfile, nc_global, 'version'      , D.version);
						   
   nc_attput(outputfile, nc_global, 'Conventions'  , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType', 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
   nc_attput(outputfile, nc_global, 'stationnumber', unique(D.data.STN));
   nc_attput(outputfile, nc_global, 'stationname'  , D.long_name);

   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   nc_add_dimension(outputfile, 'time'        , length(D.data.datenum))
   nc_add_dimension(outputfile, 'locations'   , 1)
   nc_add_dimension(outputfile, 'name_strlen1', length(D.long_name)); % for multiple stations get max length

%% 3 Create variables
   clear nc
   ifld = 0;

   %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file

     ifld = ifld + 1;
   nc(ifld).Name         = 'station_id';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');

   % Station long name

      ifld = ifld + 1;
   nc(ifld).Name         = 'station_name';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {'locations','name_strlen1'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station name');

   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table

   %% Longitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
   OPT.timezone = timezone_code2iso('GMT');

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   if OPT.stationTimeSeries
   nc(ifld).Dimension    = {'locations','time'}; % QuickPlot error: plots dimensions instead of datestr
   else
   nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
   end
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
      ifld = ifld + 1; % 03
   nc(ifld).Name         = 'wind_from_direction_mean';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily prevaling wind direction');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_true');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_from_direction');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'DDVEC');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   nc(ifld).Attribute(7) = struct('Name', 'cell_comment'   ,'Value', 'prevailing');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(8) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 04
   nc(ifld).Name         = 'wind_speed_mean';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily mean wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'FG');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 05
   nc(ifld).Name         = 'wind_speed_maximum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'FHX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 06
   nc(ifld).Name         = 'wind_speed_minimum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'FHN');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'minimum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 07
   nc(ifld).Name         = 'wind_speed_maximum_gust';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum wind speed gust');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'FX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   nc(ifld).Attribute(7) = struct('Name', 'cell_comment'   ,'Value', 'max. gust');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(8) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 08
   nc(ifld).Name         = 'temperature';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily mean air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'TG');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 09
   nc(ifld).Name         = 'temperature_mimimum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'TN');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'minimum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 10
   nc(ifld).Name         = 'temperature_maximum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum mean air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'TX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 11
   nc(ifld).Name         = 'temperature_minimum_surface';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum surface air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'T10N');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   nc(ifld).Attribute(7) = struct('Name', 'cell_comment'   ,'Value', 'at a heigth of 10 cm');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(8) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 12
   nc(ifld).Name         = 'duration_of_sunshine';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily duration of sunshine');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'hour');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'duration_of_sunshine');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'SQ');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'sum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 13
   nc(ifld).Name         = 'percentage_maximum_possible_duration_of_sunshine';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily percentage of maximum possible sunshine duration');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'percent');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'duration_of_sunshine');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'SP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 14
   nc(ifld).Name         = 'global_radiation';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily global radiation');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'J/cm^2');
  %nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '?'); % <<<<<<<<<<<< standard_name
   nc(ifld).Attribute(3) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'Q');
   nc(ifld).Attribute(5) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 15
   nc(ifld).Name         = 'duration_of_precipitation';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily duration of precipitation');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'hour');
  %nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '?'); % <<<<<<<<<<<< standard_name
   nc(ifld).Attribute(3) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'DR');
   nc(ifld).Attribute(5) = struct('Name', 'cell_methods'   ,'Value', 'sum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 16
   nc(ifld).Name         = 'precipitation_amount';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily precipitation amount');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'mm');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'precipitation_amount');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'RH');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'sum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 17
   nc(ifld).Name         = 'surface_air_pressure';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily mean surface air pressure');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'hPa');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'surface_air_pressure');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'PG');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 18
   nc(ifld).Name         = 'surface_air_pressure_maximum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum surface air pressure');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'hPa');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'surface_air_pressure');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'PGX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 19
   nc(ifld).Name         = 'surface_air_pressure_minimum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum surface air pressure');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'hPa');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'surface_air_pressure');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'PGN');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'minimum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 20
   nc(ifld).Name         = 'visibility_in_air_minimum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum visibility in air');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'visibility_in_air');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'VVN');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'minimum');
   nc(ifld).Attribute(7) = struct('Name', 'units_comment'  ,'Value', '0=less than 100m, 1=100-200m, 2=200-300m,..., 49=4900-5000m, 50=5-6km, 56=6-7km, 57=7-8km,..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=more than 70km');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(8) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 21
   nc(ifld).Name         = 'visibility_in_air_maximum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum visibility in air');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'visibility_in_air');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'VVX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   nc(ifld).Attribute(7) = struct('Name', 'units_comment'  ,'Value', '0=less than 100m, 1=100-200m, 2=200-300m,..., 49=4900-5000m, 50=5-6km, 56=6-7km, 57=7-8km,..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=more than 70km');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(8) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 22
   nc(ifld).Name         = 'cloud_cover';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily mean cloud cover');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'octant');
  %nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '?'); % <<<<<<<<<<<< standard_name
   nc(ifld).Attribute(3) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'NG');
   nc(ifld).Attribute(5) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 23
   nc(ifld).Name         = 'relative_humidity_mean';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum relative humidity');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'percent');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'relative_humidity');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UG');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'mean');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 24
   nc(ifld).Name         = 'relative_humidity_minimum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily minimum relative humidity');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'percent');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'relative_humidity');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UX');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'minimum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 25
   nc(ifld).Name         = 'relative_humidity_maximum';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'daily maximum relative humidity');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'percent');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'relative_humidity');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UN');
   nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'maximum');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1; % 26
   nc(ifld).Name         = 'potential_evapotranspiration';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Potential evapotranspiration (Makkink)');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'percent');
  %nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value',  '?'); % <<<<<<<<<<<< standard_name
   nc(ifld).Attribute(3) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'UX');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

%% 4 Create variables with attibutes

   for ifld=1:length(nc)
      if OPT.disp;disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);end
      nc_addvar(outputfile, nc(ifld));   
   end

%% 5 Fill variables

   nc_varput(outputfile, 'lon'                                             , D.lon);
   nc_varput(outputfile, 'lat'                                             , D.lat);
   nc_varput(outputfile, 'station_id'                                      , unique(D.data.STN)); %  1
   nc_varput(outputfile, 'station_name'                                    , D.long_name);
   nc_varput(outputfile, 'time'                                            , D.data.datenum - OPT.refdatenum);     %  2
   nc_varput(outputfile, 'wind_from_direction_mean'                        , D.data.DDVEC(:)'); %  3 
   nc_varput(outputfile, 'wind_speed_mean'                                 , D.data.FG   (:)'); %  4
   nc_varput(outputfile, 'wind_speed_maximum'                              , D.data.FHX  (:)'); %  5
   nc_varput(outputfile, 'wind_speed_minimum'                              , D.data.FHN  (:)'); %  6
   nc_varput(outputfile, 'wind_speed_maximum_gust'                         , D.data.FX   (:)'); %  7
   nc_varput(outputfile, 'temperature'                                     , D.data.TG   (:)'); %  8
   nc_varput(outputfile, 'temperature_mimimum'                             , D.data.TN   (:)'); %  9
   nc_varput(outputfile, 'temperature_maximum'                             , D.data.TX   (:)'); % 10
   nc_varput(outputfile, 'temperature_minimum_surface'                     , D.data.T10N (:)'); % 11
   nc_varput(outputfile, 'duration_of_sunshine'                            , D.data.SQ   (:)'); % 12
   nc_varput(outputfile, 'percentage_maximum_possible_duration_of_sunshine', D.data.SP   (:)'); % 13
   nc_varput(outputfile, 'global_radiation'                                , D.data.Q    (:)'); % 14
   nc_varput(outputfile, 'duration_of_precipitation'                       , D.data.DR   (:)'); % 15
   nc_varput(outputfile, 'precipitation_amount'                            , D.data.RH   (:)'); % 16
   nc_varput(outputfile, 'surface_air_pressure'                            , D.data.PG   (:)'); % 17
   nc_varput(outputfile, 'surface_air_pressure_maximum'                    , D.data.PGX  (:)'); % 18
   nc_varput(outputfile, 'surface_air_pressure_minimum'                    , D.data.PGN  (:)'); % 19
   nc_varput(outputfile, 'visibility_in_air_minimum'                       , D.data.VVN  (:)'); % 20
   nc_varput(outputfile, 'visibility_in_air_maximum'                       , D.data.VVX  (:)'); % 21
   nc_varput(outputfile, 'cloud_cover'                                     , D.data.NG   (:)'); % 22
   nc_varput(outputfile, 'relative_humidity_mean'                          , D.data.UG   (:)'); % 23
   nc_varput(outputfile, 'relative_humidity_minimum'                       , D.data.UX   (:)'); % 24
   nc_varput(outputfile, 'relative_humidity_maximum'                       , D.data.UN   (:)'); % 25
   nc_varput(outputfile, 'potential_evapotranspiration'                    , D.data.EV24 (:)'); % 26

%% 6 Check

   if OPT.dump
   nc_dump(outputfile);
   end
   
%% Pause

   if OPT.pause
      pausedisp
   end

end %for ifile=1:length(OPT.files)   
   
%% EOF
