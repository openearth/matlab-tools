% function getWaterbase2nc_time_direct(OPT.standard_name,directory.raw,directory.nc)

%WATERBASE2NC  rewrite text file with timeseries from from watrbase.nl into NetCDF
%
%  Timeseries data, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788
%
% In this example time is both a dimension and a variables.
% The datenum values do not show up as a parameter in ncBrowse.
%
%See also: GETWATERBASEDATA, DONAR_READ

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

%% Initialize
%------------------

   OPT.standard_name = 'sea_surface_height'; % http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   OPT.long_name     = 'sea surface height';
   OPT.fillvalue     = 0; % NaNs do not work in netcdf API
   OPT.dump          = 0;
   OPT.directory.raw = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\';
   OPT.directory.nc  = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\nc\';
   OPT.files         = dir([OPT.directory.raw filesep 'id*.txt']);

for ifile=3:length(OPT.files)  

   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)  )])

   OPT.filename = [OPT.directory.raw, filesep, OPT.files(ifile).name]; % e.g. 'potwind_210_1981'

%% 0 Read raw data
%------------------

   if exist([OPT.filename,'.mat'])
   D = load([OPT.filename,'.mat']);
   else
   D             = donar_read(OPT.filename,'locationcode',1,...
                                              'fieldname',OPT.standard_name,...
                                         'fieldnamescale',100,...
                                                 'method','fgetl');
                                                 
   save([OPT.filename,'.mat'],'-struct','D'); % to save time 2nd attempt
   end
   
%% 1a Create file
%------------------

   outputfile    = [OPT.directory.nc filesep  filename(OPT.filename),'_time_direct.nc'];

   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'           , '');
   nc_attput(outputfile, nc_global, 'institution'     , 'Rijkswaterstaat');
   nc_attput(outputfile, nc_global, 'source'          , 'www.waterbase.nl');
   nc_attput(outputfile, nc_global, 'history'         , ['Original filename: ',filenameext(OPT.filename),...%' version:',D.version,...
                                                       ' tranformed to NetCDF by G.J. de Boer <g.j.deboer@deltares.nl>, ',datestr(now,31),' by: $HeadURL$ $Revision$ $Date$ $Author$']);
   nc_attput(outputfile, nc_global, 'references'      , '<http://www.waterbase.nl>');
   nc_attput(outputfile, nc_global, 'comment'         , '');
						   
   nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
   
   nc_attput(outputfile, nc_global, 'timezone'        , 'GMT+1');

   nc_attput(outputfile, nc_global, 'stationname'     , D.data.location);
   nc_attput(outputfile, nc_global, 'location'        , D.data.location);
   nc_attput(outputfile, nc_global, 'donar_code'      , D.data.locationcode);
   nc_attput(outputfile, nc_global, 'locationcode'    , D.data.locationcode);

   nc_attput(outputfile, nc_global, 'waarnemingssoort', D.meta1.waarnemingssoort);
   nc_attput(outputfile, nc_global, 'reference_level' , D.meta1.what);

%% 2 Create dimensions
%------------------

   nc_add_dimension(outputfile, 'time'     , length(D.data.datenum))
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
   
   nc(ifld) = struct(...
   'Name'     , 'lon', ...
   'Nctype'   , 'float', ...
   'Dimension', {{'locations'}});
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   %------------------
   
   nc(ifld) = struct(...
   'Name'     , 'lat', ...
   'Nctype'   , 'float', ...
   'Dimension', {{'locations'}});
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
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
   
   nc(ifld) = struct(...
       'Name'     , 'time', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'days since 0000-1-1 0:0:0'); % matlab datenumber convention
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   
   %% Parameter
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   %------------------

   nc(ifld) = struct(...
       'Name'     , 'sea_surface_height', ...
       'Nctype'   , 'float', ...
       'Dimension', {{'time'}});
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', OPT.long_name);
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

   %% Add
   %------------------

   for ifld=1:length(nc)
      nc_addvar(outputfile, nc(ifld));   
   end

%% 4 Create attibutes
%------------------

   % already done with creation of variables.
   % This is more efficient.
   
%% 5 Fill variables
%------------------

   nc_varput(outputfile, 'lon'               , unique(D.data.lon));
   nc_varput(outputfile, 'lat'               , unique(D.data.lat));
   nc_varput(outputfile, 'time'              , D.data.datenum);
   nc_varput(outputfile, 'sea_surface_height', D.data.(OPT.standard_name));
   
%% 6 Check
%------------------

   if OPT.dump
   nc_dump(outputfile);
   end

end %for ifile=1:length(OPT.files)   

%% EOF