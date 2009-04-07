% function knmi_potwind2nc_time_direct(varargin)

%KNMI_POTWIND2NC_TIME_DIRECT  This is a first test to get wind timeseries into NetCDF
%
%  Timeseries data, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788
%
% In this example time is both a dimension and a variables.
% The datenum values do not show up as a parameter in ncBrowse.
%
%See also: KNMI_POTWIND, SNCTOOLS, KNMI_POTWIND_GET_URL, KNMI_ETMGEG2NC_TIME_DIRECT

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

%% Initialize
%------------------

   OPT.fillvalue     = nan; % NaNs do work in netcdf API
   OPT.dump          = 0;
   OPT.directory.raw = 'F:\checkouts\OpenEarthRawData\knmi\potwind\raw\';
   OPT.directory.nc  = 'F:\checkouts\OpenEarthRawData\knmi\potwind\nc\';
   OPT.files         = dir([OPT.directory.raw filesep 'potwind*']);
   
for ifile=1:length(OPT.files)  

   OPT.filename = [OPT.directory.raw, filesep, OPT.files(ifile).name]; % e.g. 'potwind_210_1981'

   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

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

   nc_attput(outputfile, nc_global, 'title'         , '');
   nc_attput(outputfile, nc_global, 'institution'   , 'KNMI');
   nc_attput(outputfile, nc_global, 'source'        , 'surface observation');
   nc_attput(outputfile, nc_global, 'history'       , ['Original filename: ',filename(D.filename),...
                                                       ', version:',D.version,...
                                                       ', filedate:',D.filedate,...
                                                       ', tranformation to NetCDF: $HeadURL$ $Revision$ $Date$ $Author$']);
   nc_attput(outputfile, nc_global, 'references'    , '<http://www.knmi.nl/samenw/hydra>,<http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/>,<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , '<klimaatdesk@knmi.nl>');
   
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , D.version);
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType', 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   						    
   nc_attput(outputfile, nc_global, 'stationnumber' , D.stationnumber);
   nc_attput(outputfile, nc_global, 'stationname'   , D.stationname);
   nc_attput(outputfile, nc_global, 'over'          , D.over);
   nc_attput(outputfile, nc_global, 'height'        , num2str(D.height));
   
   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions
%------------------

   nc_add_dimension(outputfile, 'time'     , length(D.datenum))
   nc_add_dimension(outputfile, 'locations', 1)
  %nc_add_dimension(outputfile, 'stringlength', ) % to add station long_name array

%% 3 Create variables
%------------------

   clear nc
   
   %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file
   %------------------
   
     ifld = 1;
   nc(ifld).Name         = 'id';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');

   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
   %------------------

   %% Longitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   %------------------
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   %------------------
   
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
   %------------------
   
   OPT.timezone = timezone_code2iso(D.timezone);

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since 0000-1-1 00:00:00 ',OPT.timezone]); % matlab datenumber convention
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   %------------------

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_speed';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(6) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(7) = struct('Name', 'cell_bounds'    ,'Value', 'point');

   %------------------

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_from_direction';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'nautical wind direction');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_true');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_from_direction');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(6) = struct('Name', 'KNMI_name'      ,'Value', 'DD');
   nc(ifld).Attribute(7) = struct('Name', 'cell_bounds'    ,'Value', 'point');

   %% Parameters without standard names
   %------------------

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_speed_quality';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'quality code wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(3) = struct('Name', 'comment'        ,'Value',['-1 = no data,',...
                                                                                  '0   = valid data,',...
                                                                                  '2   = data taken from WIKLI-archives,',...
                                                                                  '3   = wind direction in degrees computed from points of the compass,',...
                                                                                  '6   = added data,',...
                                                                                  '7   = missing data,',...
                                                                                  '100 = suspected data']);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'QUP');
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');

   %------------------

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_from_direction_quality';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'quality code nautical wind direction');
   nc(ifld).Attribute(2) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(3) = struct('Name', 'comment'        ,'Value',['-1 = no data,',...
                                                                                         '0   = valid data,',...
                                                                                         '2   = data taken from WIKLI-archives,',...
                                                                                         '3   = wind direction in degrees computed from points of the compass,',...
                                                                                         '6   = added data,',...
                                                                                         '7   = missing data,',...
                                                                                         '100 = suspected data']);
   nc(ifld).Attribute(4) = struct('Name', 'KNMI_name'      ,'Value', 'QQD');
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');

%% 4 Create variables with attibutes
%------------------

   for ifld=1:length(nc)
      nc_addvar(outputfile, nc(ifld));   


   end

%% 5 Fill variables
%------------------

   nc_varput(outputfile, 'lon'                        , D.lon);
   nc_varput(outputfile, 'lat'                        , D.lat);
   nc_varput(outputfile, 'id'                         , str2num(D.stationnumber));
   nc_varput(outputfile, 'time'                       , D.datenum);
   nc_varput(outputfile, 'wind_speed'                 , D.UP);
   nc_varput(outputfile, 'wind_from_direction'        , D.DD); % does not work with NaNs.
   nc_varput(outputfile, 'wind_speed_quality'         , int8(D.QUP));
   nc_varput(outputfile, 'wind_from_direction_quality', int8(D.QQD));
   
%% 6 Check
%------------------

   if OPT.dump
   nc_dump(outputfile);
   end
   
end %for ifile=1:length(OPT.files)   
   
%% EOF
