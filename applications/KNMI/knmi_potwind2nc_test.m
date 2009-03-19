%KNMI_POTWIND2NC_TEST  This is a first test to get wind timeseries into NetCDF
%
%  Timeseries data, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788
%
%See also: SNCTOOLS, KNMI_POTWIND, SEDIMENTATLAS_KORREL2NC

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

OPT.fillvalue = 0; % NaNs do not work in netcdf API

%% 0 Read raw data
%------------------
   D             = knmi_potwind('potwind_210_1981.txt','variables',OPT.fillvalue)

%% 1a Create file
%------------------

   outputfile    = [filename(D.filename),'.nc'];
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'      , '');
   nc_attput(outputfile, nc_global, 'institution', 'KNMI');
   nc_attput(outputfile, nc_global, 'source'     , 'surface observation');
   nc_attput(outputfile, nc_global, 'history'    , ['Tranformed to NetCDF by G.J. de Boer <g.j.deboer@deltares.nl>, ',datestr(now,31),' by: ',mfilename]);
   nc_attput(outputfile, nc_global, 'references' , '');
   nc_attput(outputfile, nc_global, 'comment'    , '');

   nc_attput(outputfile, nc_global, 'Conventions', 'CF-1.4');

%% 2 Create dimensions
%------------------

   nc_add_dimension(outputfile, 'time', length(D.datenum))

%% 3 Create variables
%------------------

   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
   %------------------

   % time is a dimensions
   % so the variable name needs the same as the dimension!
   
   nc.time = struct(...
       'Name'     , 'time', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.time.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc.time.Attribute(2) = struct('Name', 'units'          ,'Value', 'days since 0000-1-1 0:0:0'); % matlab datenumber convention
   nc.time.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc.time.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc.time.Attribute(4) = struct('Name', 'coordinates'    , 'Value', 'time'); % y first

   nc.wind_speed = struct(...
       'Name'     , 'wind_speed', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.wind_speed.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wind speed');
   nc.wind_speed.Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc.wind_speed.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc.wind_speed.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc.wind_speed.Attribute(4) = struct('Name', 'coordinates'    , 'Value', 'time'); % y first

   nc.wind_to_direction = struct(...
       'Name'     , 'wind_to_direction', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc.wind_to_direction.Attribute(1) = struct('Name', 'long_name'      ,'Value', 'nautical wind direction');
   nc.wind_to_direction.Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees');
   nc.wind_to_direction.Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_to_direction');
   nc.wind_to_direction.Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc.wind_to_direction.Attribute(4) = struct('Name', 'coordinates'    , 'Value', 'time'); % y first

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

   nc_varput(outputfile, 'time'              , D.datenum);
   nc_varput(outputfile, 'wind_speed'        , D.UP);
   nc_varput(outputfile, 'wind_to_direction' , D.DD); % does not work with NaNs.
   
%% 6 Check
%------------------

   nc_dump(outputfile);

%% EOF