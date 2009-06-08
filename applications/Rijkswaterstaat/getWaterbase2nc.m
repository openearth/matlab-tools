function getWaterbase2nc(varargin)
%WATERBASE2NC  rewrite zipped txt files from waterbase.nl timeseries into NetCDF files
%
%     WATERBASE2NC(<keyword,value>)
%
%  where the following <keyword,value> pairs have been implemented:
%
%   * fillvalue      (default nan)
%   * dump           whether to check nc_dump on matlab command line after writing file (default 0)
%   * directory_raw  directory where to get the raw data from (default [])
%   * directory_nc   directory where to put the nc data to (default [])
%   * mask           file mask (default 'id*.zip')
%   * refdatenum     default (datenum(1970,1,1))
%   * ext            extension to add to the files before *.nc (default '')
%   * pause          pause between files (default 0)
%
% Example:
%  getWaterbase2nc('directory_raw','P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\',...
%                  'directory_nc', 'P:\mcdata\opendap\rijkswaterstaat\waterbase\')
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: GETWATERBASEDATA, DONAR_READ, SNCTOOLS
%          NC_CF_STATIONTIMESERIES2META, NC_CF_STATIONTIMESERIES

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Choose parameter
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/

OPT.names = ...
   {'sea_surface_height',...
    'concentration_of_suspended_matter_in_sea_water',...
    'sea_surface_temperature',...
    'sea_surface_salinity',...
    'sea_surface_wave_significant_height',...
    'sea_surface_wave_from_direction',...
    'sea_surface_wind_wave_mean_period_Tm02',...
    'concentration_of_chlorophyll_in_sea_water'}; % keep shorter than 63 characters = limitation matlab field names
OPT.standard_names = ...
   {'sea_surface_height',...
    'concentration_of_suspended_matter_in_sea_water',...
    'sea_surface_temperature',...
    'sea_surface_salinity',...
    'sea_surface_wave_significant_height',...
    'sea_surface_wave_from_direction',...
    'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
    'concentration_of_chlorophyll_in_sea_water'}; % to long for matlab struct field name
OPT.long_names = ...
   {'sea surface height',...
    'concentration of suspended matter in sea water',...
    'sea surface temperature',...
    'sea surface salinity',...
    'H_s',...
    'sea surface wave from direction',...
    'T_{m0,2}',...
    'concentration of chlorophyll in sea water'};
OPT.unitss = ...
   {'m',... % unit conversion to m is done below
    'kg/m^3',...
    'degree_Celsius',...
    '1e-3',...
    'm',...% unit conversion to m is done below
    'degree_true',...
    's',...
    'microg/l'}; % ug/l is not in UDunits

%% Initialize

OPT.fillvalue      = nan; % NaNs do work in netcdf API
OPT.dump           = 0;

OPT.mask           = 'id*.txt';
OPT.mask           = 'id*.zip';
OPT.unzip          = 1; % process only zipped files: unzip them, and delete if afterwards

OPT.load           = 1; % load slow *.txt file

OPT.pause          = 0;

OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention

OPT.directory_raw  = [];%'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\'
OPT.directory_nc   = [];%'P:\mcdata\opendap\rijkswaterstaat\waterbase\';
OPT.ext            = ''; % to add to output file name before *.nc

OPT.parameter      = 8; % one from OPT.names above

%% Keyword,value

OPT = setProperty(OPT,varargin{:});

%% Parameter loop

if  OPT.parameter==0
    OPT.parameter = 1:length(OPT.names);
end

for ivar=[OPT.parameter]

    OPT.name           = OPT.names{ivar};
    OPT.standard_name  = OPT.standard_names{ivar};
    OPT.long_name      = OPT.long_names{ivar};
    OPT.units          = OPT.unitss{ivar};

    OPT.directory_raw1 = [OPT.directory_raw,filesep,OPT.standard_name,filesep];%'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\'
    OPT.directory_nc1  = [OPT.directory_nc ,filesep,OPT.standard_name,filesep];%'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\nc\'

    mkpath(OPT.directory_nc1);

    %% File loop of all files in a directory
    
    OPT.files          = dir([OPT.directory_raw1,filesep,OPT.mask]);
    
    for ifile=1:length(OPT.files)

        OPT.filename = fullfile(OPT.directory_raw1, OPT.files(ifile).name(1:end-4)); % id1-AMRGBVN-196101010000-200801010000.txt

        disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

        %% 0 Read raw data

        if exist([OPT.filename,'.mat'],'file')==2
            D = load([OPT.filename,'.mat']);% speeds up considerably
        else
            if OPT.unzip
                OPT.zipname  = [OPT.filename,'.zip'];
                unzip(OPT.zipname,filepathstr(OPT.filename))
            end

            if OPT.load
                D = donar_read([OPT.filename],...% ,'.txt'
                      'locationcode',1,... 
                         'fieldname',OPT.name,...
                    'fieldnamescale',1,...
                            'method','fgetl');

                %% Unit conversion
                % make units meters for waterlevels and wave heights
                % for waterlevels 'cm t.o.v. NAP' is used
                % for wave heights 'cm' is used
                % both strings need to be compared
                if strcmpi(D.meta1.units,'cm') || strcmpi(D.meta1.units,'cm t.o.v. NAP')
                    D.data.(OPT.name) = D.data.(OPT.name)./100;
                end
            end

            if OPT.unzip
                delete([OPT.filename]);%,'.txt'
            end

            save([OPT.filename,'.mat'],'-struct','D'); % to save time 2nd attempt

        end % exist([OPT.filename,'.mat'])

        D.version = '';

        %% 0 Create file

        outputfile    = fullfile(OPT.directory_nc1,[filename(OPT.filename),OPT.ext,'.nc']);

        nc_create_empty (outputfile)

        %% 1 Add global meta-info to file
        % Add overall meta info:
        % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

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

        nc_add_dimension(outputfile, 'time'       , length(D.data.datenum))
        nc_add_dimension(outputfile, 'locations'  , 1); % Delft3D Quickplot cannot handle this!
        nc_add_dimension(outputfile, 'name_strlen', length(D.data.locationcode)); % for multiple stations get max length

        %% 3 Create variables

        clear nc
        ifld = 0;

        % Station number: allows for exactly same variables when multiple
        % timeseries in one netCDF file (future extension)

        ifld = ifld + 1;
        nc(ifld).Name         = 'id';
        nc(ifld).Nctype       = 'char';
        nc(ifld).Dimension    = {'locations','name_strlen'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification code');
        nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id'); % standard name

        % Define dimensions in this order:
        % [time,z,y,x]
        %
        % For standard names see:
        % http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
        %------------------
        % Longitude:
        % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

        ifld = ifld + 1;
        nc(ifld).Name         = 'lon';
        nc(ifld).Nctype       = 'float'; % no double needed
        nc(ifld).Dimension    = {'locations'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
        nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
        nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');

        % Latitude:
        % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

        ifld = ifld + 1;
        nc(ifld).Name         = 'lat';
        nc(ifld).Nctype       = 'float'; % no double needed
        nc(ifld).Dimension    = {'locations'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
        nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
        nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

        % Time:
        % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
        % time is a dimension, so there are two options:
        % * the variable name needs the same as the dimension:
        %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
        % * there needs to be an indirect mapping through the coordinates attribute:
        %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605

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

        % Parameters with standard names:
        % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/

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
        % When variable definitons are created before actually writing the
        % data in the next cell, netCDF can nicely fit all data into the
        % file without the need to relocate any info.

        for ifld=1:length(nc)
            nc_addvar(outputfile, nc(ifld));
        end

        %% 5 Fill variables

        nc_varput(outputfile, 'id'     , D.data.locationcode);
        nc_varput(outputfile, 'lon'    , unique(D.data.lon));
        nc_varput(outputfile, 'lat'    , unique(D.data.lat));
        nc_varput(outputfile, 'time'   , D.data.datenum' - OPT.refdatenum);
        nc_varput(outputfile, OPT.name , D.data.(OPT.name));

        %% 6 Check

        if OPT.dump
            nc_dump(outputfile);
        end

        %% Pause

        if OPT.pause
            pausedisp
        end

    end %file loop % for ifile=1:length(OPT.files)

end %variable loop % for ivar=1:length(OPT.codes)

%% EOF