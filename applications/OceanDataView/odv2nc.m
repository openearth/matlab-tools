function odv2nc
%ODV2NC  transforms directory of ODV CTD casts into directory of netCDF files
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

   OPT.dump              = 0;
   OPT.disp              = 1;
   OPT.pause             = 0;
   OPT.stationTimeSeries = 0; % coordinates attribute

   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % lunix  datenumber convention
   OPT.fillvalue         = nan; % NaNs do work in netcdf API
   
%% File loop

   OPT.directory_raw     = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-260409_result\'];
   OPT.directory_nc      = [fileparts(mfilename('fullpath')),filesep,'usergd30d98-data_centre630-260409_result\'];
   OPT.prefix            = 'result_CTDCAST';
   OPT.mask              = '*.txt';

%% Keyword,value

   OPT = setProperty(OPT,varargin{:});

%% File loop

   OPT.files     = dir([OPT.directory_raw,filesep,OPT.prefix,'*',OPT.mask]);
   
%% 0 Read raw data

   for ifile=1:length(OPT.files)
      
      OPT.filename = OPT.files(ifile).name;
   	
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])
   
      R(ifile)   = odvread([OPT.directory_raw,filesep,OPT.filename]);
      
   end
   
   %-%disp('saving mat of R ...'); % slow, and bigger than D
   %-%save('usergd30d98-data_centre630-260409_result.mat','R')
   %-%load('usergd30d98-data_centre630-260409_result.mat','R')
   
%% 0 Transform raw data

   D          = odvread_struct2matrix(R);
   D.version  = '0';
   D.timezone = 'GMT';
   
   %-%disp('saving mat of D ...')
   %-%save('usergd30d98-data_centre630-260409_result_matrix.mat','D');
   %-%load('usergd30d98-data_centre630-260409_result_matrix.mat','D');
   
   D.cruise           = char(D.cruise) ;
   D.station          = char(D.station); 
   D.type             = char(D.type)   ;
   D.LOCAL_CDI_ID     = char(D.LOCAL_CDI_ID);
   D.EDMO_code        = char(D.EDMO_code);

%% 1a Create netCDF file

   outputfile    = [OPT.directory_nc filesep OPT.prefix,'.nc'];
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   % ------------------

   nc_attput(outputfile, nc_global, 'title'         , 'CTD casts');
   nc_attput(outputfile, nc_global, 'institution'   , 'NIOZ');
   nc_attput(outputfile, nc_global, 'source'        , 'CTD cast');
   nc_attput(outputfile, nc_global, 'history'       , ['Tranformation to NetCDF: $HeadURL$']);
   nc_attput(outputfile, nc_global, 'references'    , '<http://www.nioz.nl>,<http://www.nodc.nl>,<http://www.seadatanet.org>');
   nc_attput(outputfile, nc_global, 'email'         , '');
   
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , D.version);
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType', '');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   						    
   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: NIOZ.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   nc_add_dimension(outputfile, 'time'                  , D.number_of_observations)
   nc_add_dimension(outputfile, 'number_of_levels'      , D.number_of_levels)

   nc_add_dimension(outputfile, 'cruise_str'            , size(D.cruise       ,2));
   nc_add_dimension(outputfile, 'station_str'           , size(D.station      ,2));
   nc_add_dimension(outputfile, 'type_str'              , size(D.type         ,2));
   nc_add_dimension(outputfile, 'LOCAL_CDI_ID_str'      , size(D.LOCAL_CDI_ID ,2));
   nc_add_dimension(outputfile, 'EDMO_code_str'         , size(D.EDMO_code    ,2));

%% 3 Create variables
   
   clear nc
   ifld = 0;

   %% Cruise number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'cruise_id';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'time','cruise_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'cruise identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'cruise_id');

   %% Station number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'station_id';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'time','station_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');

   %% Type
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'type';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'time','type_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'type of observation');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', 'B for bottle or C for CTD, XBT or stations with >250 samples');

   %% LOCAL_CDI_ID
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'LOCAL_CDI_ID';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'time','LOCAL_CDI_ID_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'LOCAL_CDI_ID_str');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', ' ');

   %% EDMO_code
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'EDMO_code';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'time','EDMO_code_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'EDMO_code_str');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', ' ');

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
   nc(ifld).Dimension    = {'time'};
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
   nc(ifld).Dimension    = {'time'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
    
   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'time'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');
    
   %% Bottom depth
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'bot_depth';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'time'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'bottom depth');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'meter');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '');

   %% Parameters with standard names
   %  * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

      ifld = ifld + 1;
   nc(ifld).Name         = 'pressure';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','number_of_levels'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'pressure');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'pressure');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1;
   nc(ifld).Name         = 'temperature';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','number_of_levels'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1;
   nc(ifld).Name         = 'salinity';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','number_of_levels'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water salinity');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '1e-3');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_salinity');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end

      ifld = ifld + 1;
   nc(ifld).Name         = 'fluorescence';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','number_of_levels'}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea water fluorescence');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'ug/l');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_water_fluorescence');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   if OPT.stationTimeSeries
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
   end
   
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
   nc_varput(outputfile, 'bot_depth'    , D.bot_depth);

   nc_varput(outputfile, 'pressure'     , D.sea_water_pressure);
   nc_varput(outputfile, 'temperature'  , D.sea_water_temperature);
   nc_varput(outputfile, 'salinity'     , D.sea_water_salinity);
   nc_varput(outputfile, 'fluorescence' , D.sea_water_fluorescence);
   
   nc_varput(outputfile, 'LOCAL_CDI_ID' , D.LOCAL_CDI_ID);
   nc_varput(outputfile, 'EDMO_code'    , D.EDMO_code);

%% 6 Check

   if OPT.dump
   nc_dump(outputfile);
   end
   
%% EOF
   