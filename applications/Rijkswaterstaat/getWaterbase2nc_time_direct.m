%WATERBASE2NC  rewrite text files with timeseries from from waterbase.nl into NetCDF files
%
%  Timeseries data definition, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: GETWATERBASEDATA, DONAR_READ, SNCTOOLS

% function getWaterbase2nc_time_direct(OPT.standard_name,directory.raw,directory.nc)

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

%% Choose parameter
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
%------------------

   OPT.names          = {'sea_surface_height',...
                         'concentration_of_suspended_matter_in_sea_water',...
                         'sea_surface_temperature',...
                         'sea_surface_salinity',...
                         'sea_surface_wave_significant_height',...
                         'sea_surface_wave_from_direction',...
                         'sea_surface_wind_wave_mean_period_Tm02'}; % keep shorter than 63 characters = limitation matlab field names
   OPT.standard_names = {'sea_surface_height',...
                         'concentration_of_suspended_matter_in_sea_water',...
                         'sea_surface_temperature',...
                         'sea_surface_salinity',...
                         'sea_surface_wave_significant_height',...
                         'sea_surface_wave_from_direction',...
                         'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'}; % to long for matlab struct field name
   OPT.long_names     = {'sea surface height',...
                         'concentration of suspended matter in sea water',...
                         'sea surface temperature',...
                         'sea surface salinity',...
                         'H_s',...
                         'sea surface wave from direction',...
                         'T_{m0,2}'};
   OPT.unitss         = {'m',...
                         'kg/m^3',...
                         'degree_Celsius',...
                         '1e-3',...
                         'm',...
                         'degree_true',...
                         's'};

%% Initialize
%------------------

   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   OPT.dump           = 0;

   OPT.load           = 1; % load slow *.txt file

   OPT.unzip          = 1; % process only zipped files: unzip them, and delete if afterwards
   OPT.pause          = 1;
   
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention
      
%% Parameter loop
%------------------

for ivar=[5 7]; %1:length(OPT.names)

   OPT.name           = OPT.names{ivar};
   OPT.standard_name  = OPT.standard_names{ivar};
   OPT.long_name      = OPT.long_names{ivar};
   OPT.units          = OPT.unitss{ivar};
   
   OPT.directory.raw  = ['F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\',OPT.standard_name,'\'];
   OPT.directory.nc   = ['F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\nc\' ,OPT.standard_name,'\'];
   
   mkpath(OPT.directory.nc)

   OPT.files          = dir([OPT.directory.raw filesep 'id*.txt']);
   OPT.files          = dir([OPT.directory.raw filesep 'id*.zip']);

   for ifile=1:length(OPT.files)  
   
      OPT.filename = ([OPT.directory.raw, filesep, OPT.files(ifile).name(1:end-4)]); % id1-AMRGBVN-196101010000-200801010000.txt
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])
      
   %% 0 Read raw data
   %------------------
   
      if    exist([OPT.filename,'.mat'])==2
         D = load([OPT.filename,'.mat']);% speeds up considerably
      else
         if OPT.unzip
            OPT.zipname  = [OPT.filename,'.zip'];
            unzip(OPT.zipname,filepathstr(OPT.filename))
         end
         
         if OPT.load
         D = donar_read(OPT.filename,'locationcode',1,...
                                        'fieldname',OPT.name,...
                                   'fieldnamescale',1,...
                                           'method','fgetl');
                                           
         % make units meters for waterlevels and wave heights
         if strcmpi(D.meta1.units,'cm')
            D.data.(OPT.name) = D.data.(OPT.name)./100;
         end
         end
         
         if OPT.unzip
         delete(OPT.filename);
         end
                                                       
         save([OPT.filename,'.mat'],'-struct','D'); % to save time 2nd attempt
      
      end % exist([OPT.filename,'.mat'])
      
      D.version = '';
      
   %% 1a Create file
   %------------------
   
      outputfile    = [OPT.directory.nc filesep  filename(OPT.filename),'_time_direct.nc'];
   
      nc_create_empty (outputfile)
   
      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
      nc_attput(outputfile, nc_global, 'title'           , '');
      nc_attput(outputfile, nc_global, 'institution'     , 'Rijkswaterstaat');
      nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
      nc_attput(outputfile, nc_global, 'history'       , ['Original filename: ',filename(OPT.filename),...
                                                          ', version:' ,D.version,...
                                                          ', filedate:',D.date,...
                                                          ', tranformation to NetCDF: $HeadURL$ $Revision$ $Date$ $Author$']);
      nc_attput(outputfile, nc_global, 'references'      , '<http://www.waterbase.nl>,<http://openearth.deltares.nl>');
      nc_attput(outputfile, nc_global, 'email'         , '<servicedesk-data@rws.nl>');
   
      nc_attput(outputfile, nc_global, 'comment'         , '');
      nc_attput(outputfile, nc_global, 'version'         , D.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType'  , 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: Rijkswaterstaat.');
      nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
      
      nc_attput(outputfile, nc_global, 'stationname'     , D.data.location);
      nc_attput(outputfile, nc_global, 'location'        , D.data.location);
      nc_attput(outputfile, nc_global, 'donar_code'      , D.data.locationcode);
      nc_attput(outputfile, nc_global, 'locationcode'    , D.data.locationcode);
   
      nc_attput(outputfile, nc_global, 'waarnemingssoort', D.meta1.waarnemingssoort);
      nc_attput(outputfile, nc_global, 'reference_level' , D.meta1.what);
   
   %% 2 Create dimensions
   %------------------
   
      nc_add_dimension(outputfile, 'time'       , length(D.data.datenum))
      nc_add_dimension(outputfile, 'locations'  , 1)
      nc_add_dimension(outputfile, 'name_strlen', length(D.data.locationcode)); % for multiple stations get max length
   
   %% 3 Create variables
   %------------------
   
      clear nc
      ifld = 0;
   
      %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file
      %------------------
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'id';
      nc(ifld).Nctype       = 'char';
      nc(ifld).Dimension    = {'locations','name_strlen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification code');
      nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id'); % standard name
   
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
      
      OPT.timezone = timezone_code2iso('MET');
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'time';
      nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
      nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
     %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
      
      %% Parameters with standard names
      % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
      %------------------
   
        ifld = ifld + 1;
      nc(ifld).Name         = OPT.name;
      nc(ifld).Nctype       = 'float'; % no double needed
      nc(ifld).Dimension    = {'locations','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', OPT.long_name);
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', OPT.units);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
      nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');
   
   %% 4 Create variables with attibutes
   %------------------
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
   %% 5 Fill variables
   %------------------
   
      nc_varput(outputfile, 'id'     , D.data.locationcode);
      nc_varput(outputfile, 'lon'    , unique(D.data.lon));
      nc_varput(outputfile, 'lat'    , unique(D.data.lat));
      nc_varput(outputfile, 'time'   , D.data.datenum' - OPT.refdatenum);
      nc_varput(outputfile, OPT.name , D.data.(OPT.name));
      
   %% 6 Check
   %------------------
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
   %% Pause
   %------------------
   
      if OPT.pause
         pausedisp
      end
      
   end %for ifile=1:length(OPT.files)   

end % for ivar=1:length(OPT.codes)

%% EOF