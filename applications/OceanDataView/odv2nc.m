function odv2nc(varargin)
%ODV2NC  transforms one ODV CTD casts into one netCDF file
%
%     odv2nc(<keyword,value>) 
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
%  odv2nc('directory_raw','F:\foo\raw',...
%         'directory_nc', 'F:\foo\processed')
%
%See also: OceanDataView

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL
% $Keywords:

%% Initialize

   OPT.dump              = 1;
   OPT.disp              = 1;
   OPT.pause             = 1;
   OPT.stationTimeSeries = 0; % coordinates attribute

   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % lunix  datenumber convention
   OPT.fillvalue         = nan; % NaNs do work in netcdf API
   
%% File loop

   OPT.directory_raw     = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-270409_result',filesep];
   OPT.directory_nc      = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-270409_result',filesep];
   OPT.prefix            = 'result_CTDCAST';
   OPT.mask              = '*.txt';

%% Keyword,value

   OPT = setProperty(OPT,varargin{:})

%% File loop

   OPT.files     = dir([OPT.directory_raw,filesep,OPT.prefix,'*',OPT.mask]);
   
for ifile=1:length(OPT.files)
   
   OPT.filename = OPT.files(ifile).name;
      
   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

%% 0 Read all raw data

   D = odvread([OPT.directory_raw,filesep,OPT.filename])
   
   if D.cast==0
      error('only ODV profile data can be written to netCDF yet, timeseries and trajectories not yet.')
   end

   D.version          = last_subdir([OPT.directory_raw])
   D.timezone         = 'GMT';

%% 1a Create netCDF file

   outputfile    = [OPT.directory_nc filesep filename(OPT.filename) '.nc'];
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   % ------------------

   nc_attput(outputfile, nc_global, 'title'          , 'CTD cast');
   nc_attput(outputfile, nc_global, 'institution'    , 'NIOZ');
   nc_attput(outputfile, nc_global, 'source'         , '');
   nc_attput(outputfile, nc_global, 'history'        , ['Tranformation to NetCDF: $HeadURL$']);
   nc_attput(outputfile, nc_global, 'references'     , 'data:<http://www.nioz.nl>, distribution:<http://www.nodc.nl>,<http://www.seadatanet.org>, netCDF conversion:<http://www.openearth.eu>');
   nc_attput(outputfile, nc_global, 'email'          , '');
   
   nc_attput(outputfile, nc_global, 'comment'        , 'There is no SeaDataNet netCDF convention yet, this is a trial.');
   nc_attput(outputfile, nc_global, 'version'        , D.version);
						    
   nc_attput(outputfile, nc_global, 'Conventions'    , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType' , '');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   						    
   nc_attput(outputfile, nc_global, 'terms_for_use'  , 'These data can be used freely for research purposes provided that the following source is acknowledged: NIOZ.');
   nc_attput(outputfile, nc_global, 'disclaimer'     , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   %% Add SeaDataNet attrbutes: this allows only one ODV file per netCDF file !!!
   
   nc_attput(outputfile, nc_global, 'SDN_LOCAL_CDI_ID',D.LOCAL_CDI_ID);
   nc_attput(outputfile, nc_global, 'SDN_EDMO_code'   ,D.EDMO_code);

%% 2 Create dimensions

   nc_add_dimension(outputfile, 'station', 1) % a CTD/bottle cast has one time per station
   nc_add_dimension(outputfile, 'z'      , length(D.data.sea_water_pressure))

   nc_add_dimension(outputfile, 'cruise_str'            , size(D.cruise       ,2));
   nc_add_dimension(outputfile, 'station_str'           , size(D.station      ,2));
   nc_add_dimension(outputfile, 'type_str'              , size(D.type         ,2));
   nc_add_dimension(outputfile, 'LOCAL_CDI_ID_str'      , size(D.LOCAL_CDI_ID ,2));

%% 3 Create variables: SDN meta-info
   
   clear nc
   ifld = 0;

   %% Cruise number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'cruise_id';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'station','cruise_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'cruise identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'cruise_id');

   %% Station number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'station_id';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'station','station_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');

   %% Type
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'type';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'station','type_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'type of observation');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', 'B for bottle or C for CTD, XBT or stations with >250 samples');
   
   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
   OPT.timezone = timezone_code2iso(D.timezone);

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {'station'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'station'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'station'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

   %% LOCAL_CDI_ID
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'LOCAL_CDI_ID';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'station','LOCAL_CDI_ID_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'LOCAL_CDI_ID_str');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', ' ');

   %% EDMO_code
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'EDMO_code';
   nc(ifld).Nctype       = 'int'; % no double needed
   nc(ifld).Dimension    = {'station'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'EDMO_code_str');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', ' ');
   
   %% Bottom depth
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'bot_depth';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'station'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'bottom depth');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'meter');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '');
   nc(ifld).Attribute(4) = struct('Name', 'positive'       ,'Value', 'down');
   
%% 3 Create variables: SDN data

   %% Parameters with standard names
   %  * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

      ifld = ifld + 1;
   nc(ifld).Name         = 'pressure';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'station','z'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'pressure');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'dbar');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'pressure');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');


      ifld = ifld + 1;
   nc(ifld).Name         = 'temperature';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'station','z'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');


      ifld = ifld + 1;
   nc(ifld).Name         = 'salinity';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'station','z'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water salinity');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '1e-3');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_salinity');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');


      ifld = ifld + 1;
   nc(ifld).Name         = 'fluorescence';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'station','z'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water fluorescence');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'ug/l');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_fluorescence');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'cell_bounds'    ,'Value', 'point');

   
%% 4 Create variables with attibutes
%    When variable definitons are created before actually writing the
%    data in the next cell, netCDF can nicely fit all data into the
%    file without the need to relocate any info.

   for ifld=1:length(nc)
      if OPT.disp;disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);end
      nc_addvar(outputfile, nc(ifld));   
   end

%% 5 Fill variables

   nc_varput(outputfile, 'cruise_id'    , D.cruise);
   nc_varput(outputfile, 'station_id'   , D.station);
   nc_varput(outputfile, 'type'         , D.type);
   nc_varput(outputfile, 'time'         , D.datenum-OPT.refdatenum);
   nc_varput(outputfile, 'lon'          , D.longitude);
   nc_varput(outputfile, 'lat'          , D.latitude);
   nc_varput(outputfile, 'LOCAL_CDI_ID' , D.LOCAL_CDI_ID);
   nc_varput(outputfile, 'EDMO_code'    , D.EDMO_code);
   nc_varput(outputfile, 'bot_depth'    , D.bot_depth);

   nc_varput(outputfile, 'pressure'     , D.data.sea_water_pressure);
   nc_varput(outputfile, 'temperature'  , D.data.sea_water_temperature);
   nc_varput(outputfile, 'salinity'     , D.data.sea_water_salinity);
   nc_varput(outputfile, 'fluorescence' , D.data.sea_water_fluorescence);
   

%% 6 Check

   if OPT.dump
   nc_dump(outputfile);
   end
   
   if OPT.pause
      pausedisp
   end
   
end   
   
%% EOF
   