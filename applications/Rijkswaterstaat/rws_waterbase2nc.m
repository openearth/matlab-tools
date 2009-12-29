function rws_waterbase2nc(varargin)
%RWS_WATERBASE2NC  rewrite zipped txt files from waterbase.nl timeseries to NetCDF files
%
%     rws_waterbase2nc(<keyword,value>)
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
%  rws_waterbase2nc('directory_raw','P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\',...
%                   'directory_nc', 'P:\mcdata\opendap\rijkswaterstaat\waterbase\')
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: RWS_WATERBASE_GET_URL, RWS_WATERBASE_READ, SNCTOOLS
%          NC_CF_STATIONTIMESERIES2META, NC_CF_STATIONTIMESERIES

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO: Add x,y in addition to lat,lon
% TO DO: save mat and nc files with (i) actual start and end dates or (ii) with no dates at all, but not as currently with the time search window in the filename
% TO DO: ... or better: remove time extension, onyl include station name
% TO DO: add search/retrieve/discovery info to global attributes
% TO DO: add link to site-specific waterbase url as in getWaterbaseData

%% Choose parameter
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/
%  keep name shorter than namelengthmax (=63)

   OPT.names = ...
      {'sea_surface_height',... % takes 36 hours
       'concentration_of_suspended_matter_in_sea_water',...
       'sea_surface_temperature',...
       'sea_surface_salinity',...
       'sea_surface_wave_significant_height',...
       'sea_surface_wave_from_direction',...
       'sea_surface_wind_wave_mean_period_Tm02',...
       'concentration_of_chlorophyll_in_sea_water',...
       'water_volume_transport_into_sea_water_from_rivers'}; % keep shorter than 63 characters = limitation matlab field names (namelengthmax)
   
   OPT.standard_names = ...
      {'sea_surface_height',...
       'concentration_of_suspended_matter_in_sea_water',...
       'sea_surface_temperature',...
       'sea_surface_salinity',...
       'sea_surface_wave_significant_height',...
       'sea_surface_wave_from_direction',...
       'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
       'concentration_of_chlorophyll_in_sea_water',...
       'water_volume_transport_into_sea_water_from_rivers'}; % to long for matlab struct field name
   
   OPT.long_names = ...
      {'sea surface height',...
       'concentration of suspended matter in sea water',...
       'sea surface temperature',...
       'sea surface salinity',...
       'H_s',...
       'sea surface wave from direction',...
       'T_{m0,2}',...
       'concentration of chlorophyll in sea water',...
       'River dicharge'};
       
   OPT.unitss = ...
      {'m',... % unit conversion to m is done below
       'kg/m^3',...
       'degree_Celsius',...
       '1e-3',...
       'm',...% unit conversion to m is done below
       'degree_true',...
       's',...
       'microg/l',... % ug/l is not in UDunits
       'm^3/s'}; % ug/l is not in UDunits
   
   OPT.parameter          = 0; %[9]; % 0=all or select index from OPT.names above

%% Initialize

   OPT.dump               = 0;
   OPT.disp               = 0;
   OPT.pause              = 0;
   
   OPT.refdatenum         = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum         = datenum(1970,1,1); % lunix  datenumber convention
   OPT.fillvalue          = nan; % NaNs do work in netcdf API
   
   OPT.stationTimeSeries  = 0; % last items to adhere to for upcoming convenction, but not yet supported by QuickPlot

%% File loop

   OPT.directory_raw      = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';        % [];%
   OPT.directory_raw      = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';
   OPT.directory_nc       = 'P:\mcdata\opendap\rijkswaterstaat\waterbase\';                       % [];%
   OPT.directory_nc       = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\processed\'; % [];%
   OPT.ext                = '';
   OPT.mask               = 'id*.txt';
   OPT.mask               = 'id*.zip';
   OPT.unzip              = 1; % process only zipped files: unzip them, and delete if afterwards
   OPT.load               = 1; % load slow *.txt file

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

   %OPT.directory_raw1 = [OPT.directory_raw,filesep,OPT.standard_name,filesep];%'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\raw\'
   %OPT.directory_nc1  = [OPT.directory_nc ,filesep,OPT.standard_name,filesep];%'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\nc\'

    mkpath(OPT.directory_nc);

    %% File loop of all files in a directory
    
    OPT.files          = dir([OPT.directory_raw,filesep,OPT.mask]);
    
    for ifile=1:length(OPT.files)

        OPT.filename = fullfile(OPT.directory_raw, OPT.files(ifile).name(1:end-4)); % id1-AMRGBVN-196101010000-200801010000.txt

        disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

        %% 0 Read raw data

        if exist([OPT.filename,'.mat'],'file')==2
            D = load([OPT.filename,'.mat']);% speeds up considerably

                %quick fix of previous errors in units
                %if strcmpi(D.meta1.units,'cm t.o.v. Mean Sea Level') % id54
                %   D.data.(OPT.name) = D.data.(OPT.name)./100;
                %end

        else
            if OPT.unzip
                OPT.zipname  = [OPT.filename,'.zip'];
                unzip(OPT.zipname,filepathstr(OPT.filename))
            end

            if OPT.load
                D = rws_waterbase_read([OPT.filename],...% ,'.txt'
                      'locationcode',1,... 
                         'fieldname',OPT.name,...
                    'fieldnamescale',1,...
                            'method','fgetl');

                %% Unit conversion
                % make units meters for waterlevels and wave heights
                % for waterlevels 'cm t.o.v. NAP' is used
                % for wave heights 'cm' is used
                % both strings need to be compared
                if strcmpi(D.meta1.units(1:2),'cm')
                   % strcmpi(D.meta1.units,'cm t.o.v. NAP') || ...     % id1
                   % strcmpi(D.meta1.units,'cm t.o.v. Mean Sea Level') % id54
                   D.data.(OPT.name) = D.data.(OPT.name)./100;
                end
            end

            if OPT.unzip
                delete([OPT.filename]);%,'.txt'
            end

            save([OPT.filename,'.mat'],'-struct','D'); % to save time 2nd attempt

        end % exist([OPT.filename,'.mat'])

        D.version     = '';

        %% 0 Create file

        ind           = strfind (OPT.files(ifile).name,'-');
        outputfile    = fullfile(OPT.directory_nc,[ OPT.files(ifile).name(1:ind(2)-1),OPT.ext,'.nc']); % id1-AMRGBVN*

        nc_create_empty (outputfile)

        %% 1 Add global meta-info to file
        % Add overall meta info:
        % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

        nc_attput(outputfile, nc_global, 'title'           , '');
        nc_attput(outputfile, nc_global, 'institution'     , 'Rijkswaterstaat');
        nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
        nc_attput(outputfile, nc_global, 'history'         , ['Original filename: ',filename(OPT.filename),...
            ', version:' ,D.version,...
            ', filedate:',D.date,...
            ', tranformation to netCDF: $HeadURL$ $Revision$ $Date$ $Author$']);
        nc_attput(outputfile, nc_global, 'references'      , '<http://www.waterbase.nl>,<http://openearth.deltares.nl>');
        nc_attput(outputfile, nc_global, 'email'           , '<servicedesk-data@rws.nl>');

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
        
        if isfield(D.data,'hoedanigheid')
        if  length(D.data.hoedanigheid)==1;nc_attput(outputfile, nc_global, 'hoedanigheid' , D.data.hoedanigheid);end
        end
        if isfield(D.data,'anamet')
        if  length(D.data.anamet      )==1;nc_attput(outputfile, nc_global, 'anamet'       , D.data.anamet      );end
        end
        if isfield(D.data,'ogi')
        if  length(D.data.ogi         )==1;nc_attput(outputfile, nc_global, 'ogi'          , D.data.ogi         );end
        end
        if isfield(D.data,'vat')
        if  length(D.data.vat         )==1;nc_attput(outputfile, nc_global, 'vat'          , D.data.vat         );end
        end


%% Add discovery information (test):

        %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html

        nc_attput(outputfile, nc_global, 'geospatial_lat_min'         , min(D.data.lat));
        nc_attput(outputfile, nc_global, 'geospatial_lat_max'         , max(D.data.lat));
        nc_attput(outputfile, nc_global, 'geospatial_lon_min'         , min(D.data.lon));
        nc_attput(outputfile, nc_global, 'geospatial_lon_max'         , max(D.data.lon));
        nc_attput(outputfile, nc_global, 'time_coverage_start'        , datestr(D.data.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
        nc_attput(outputfile, nc_global, 'time_coverage_end'          , datestr(D.data.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
        nc_attput(outputfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
        nc_attput(outputfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );

        %% 2 Create dimensions

        nc_add_dimension(outputfile, 'time'        , length(D.data.datenum))
        nc_add_dimension(outputfile, 'locations'   , 1);
        nc_add_dimension(outputfile, 'name_strlen1', length(D.data.locationcode)); % for multiple stations get max length
        nc_add_dimension(outputfile, 'name_strlen2', length(D.data.location    )); % for multiple stations get max length

        %% 3 Create variables

        clear nc
        ifld = 0;

        % Station number: allows for exactly same variables when multiple
        % timeseries in one netCDF file (future extension)

        ifld = ifld + 1;
        nc(ifld).Name         = 'station_id';
        nc(ifld).Nctype       = 'char';
        nc(ifld).Dimension    = {'locations','name_strlen1'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification code');
        nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id'); % standard name

        % Station long name

        ifld = ifld + 1;
        nc(ifld).Name         = 'station_name';
        nc(ifld).Nctype       = 'char';
        nc(ifld).Dimension    = {'locations','name_strlen2'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station name');

        % Define dimensions in this order:
        % [time,z,y,x]
        %
        % For standard names see:
        % http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
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
        nc(ifld).Attribute(5) = struct('Name', 'cell_methods'   ,'Value', 'time: point area: point');
        if OPT.stationTimeSeries
        nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
        end

        %% 4 Create variables with attibutes
        % When variable definitons are created before actually writing the
        % data in the next cell, netCDF can nicely fit all data into the
        % file without the need to relocate any info.

        for ifld=1:length(nc)
            if OPT.disp;disp([num2str(ifld),' ',nc(ifld).Name]);end
            nc_addvar(outputfile, nc(ifld));
        end

        %% 5 Fill variables

        nc_varput(outputfile, 'station_id'  , D.data.locationcode);
        nc_varput(outputfile, 'station_name', D.data.location);
        nc_varput(outputfile, 'lon'         , unique(D.data.lon));
        nc_varput(outputfile, 'lat'         , unique(D.data.lat));
        nc_varput(outputfile, 'time'        , D.data.datenum' - OPT.refdatenum);
        nc_varput(outputfile, OPT.name      , D.data.(OPT.name));

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