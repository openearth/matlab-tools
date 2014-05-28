function jarkus_grid2netcdf(filename, grid, varargin)
%JARKUS_GRID2NETCDF  converts Jarkus grid struct to netCDF-CF file
%
%    jarkus_grid2netcdf(filename, grid)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

OPT = struct(...
    'username', getenv('USERNAME'),...
    'historyatt', '$HeadURL$ $Id$',...
    'origins', 1:5,...
    'processing_level', 'preliminary');

OPT = setproperty(OPT, varargin);

datefmt = 'yyyy-mm-ddTHH:MMZ'; % date format
tzoffset = java.util.Date().getTimezoneOffset()/60/24; % time zone offset [days]
utcnow = now+tzoffset;

STRINGSIZE = 100;
%% Create file    
%     make sure there's enough space for headers. This will speed up
%     putting attributes

    nc_create_empty(filename)
    nc_padheader ( filename, 400000 );   

    origin_codes = 1:5;
    origins = OPT.origins;
    origin_descriptions = {'beach_only' 'beach_overlap' 'interpolation' 'sea_overlap' 'sea_only'};
    
%% Put global attributes    
    nc_attput( filename, nc_global, 'naming_authority', 'deltares.nl') % based on reverse DNS lookup (http://remote.12dt.com/)
    nc_attput( filename, nc_global, 'id', sprintf('JarKus_release%s_origins%s', datestr(now, 'yyyymmdd'), sprintf('%i', OPT.origins)))
    nc_attput( filename, nc_global, 'Metadata_Conventions', 'Unidata Dataset Discovery v1.0')
    nc_attput( filename, nc_global, 'title', 'JarKus Data (cross-shore transects)');
    nc_attput( filename, nc_global, 'summary', 'Cross-shore yearly transect bathymetry measurements along the Dutch coast since 1965');
    nc_attput( filename, nc_global, 'keywords', 'Bathymetry, JarKus, Dutch coast');
	nc_attput( filename, nc_global, 'keywords_vocabulary', 'http://www.eionet.europa.eu/gemet');
	nc_attput( filename, nc_global, 'standard_name_vocabulary', 'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/');
    nc_attput( filename, nc_global, 'history', OPT.historyatt);
    nc_attput( filename, nc_global, 'comment', sprintf('The transects in this file are a combination of origins:%s (%s )\n%s', sprintf(' %i', OPT.origins), sprintf(' %s', origin_descriptions{OPT.origins}), OPT.msg));
    nc_attput( filename, nc_global, 'institution', 'Rijkswaterstaat');
    nc_attput( filename, nc_global, 'source'     , 'on shore and off shore measurements');
    nc_attput( filename, nc_global, 'references' , 'Original source: http://www.watermarkt.nl/kustenzeebodem/');
    nc_attput( filename, nc_global, 'Conventions', 'CF-1.6');
    % Creator Search attributes
    nc_attput( filename, nc_global, 'creator_name', 'Rijkswaterstaat');
    nc_attput( filename, nc_global, 'creator_url', 'http://www.rijkswaterstaat.nl');
    nc_attput( filename, nc_global, 'creator_email', 'info@rijkswaterstaat.nl');
    nc_attput( filename, nc_global, 'date_created', datestr(nowutc, datefmt))
    nc_attput( filename, nc_global, 'date_modified', datestr(nowutc, datefmt))
    nc_attput( filename, nc_global, 'date_issued', datestr(nowutc, datefmt))
    % Publisher Search attributes
    nc_attput( filename, nc_global, 'publisher_name', OPT.username);
    nc_attput( filename, nc_global, 'publisher_url', 'http://www.deltares.nl');
    nc_attput( filename, nc_global, 'publisher_email', 'Kees.denHeijer@deltares.nl');
    % Extent Search attributes
%     % these attributes will be added in jarkus_transect2netcdf.m
%     nc_attput( filename, nc_global, 'geospatial_vertical_min', NaN)
%     nc_attput( filename, nc_global, 'geospatial_vertical_max', NaN)
    % Other Extent Information attributes
    nc_attput( filename, nc_global, 'geospatial_vertical_units', 'm')
    nc_attput( filename, nc_global, 'geospatial_vertical_resolution', .01)
    nc_attput( filename, nc_global, 'geospatial_vertical_positive', 'up')
    % Other attributes
	nc_attput( filename, nc_global, 'processing_level', OPT.processing_level);
	nc_attput( filename, nc_global, 'license',[sprintf('These data can be used freely for research purposes provided that the following source is acknowledged: %s. ', 'RIJKSWATERSTAAT')...
                'disclaimer: This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.']);
    nc_attput( filename, nc_global, 'cdm_data_type', 'grid');
    % spatial reference using wkt. approach used by gdal.
    % nc_attput( filename, nc_global, 'spatial_ref', 'COMPD_CS["Amersfoort / RD New + NAP",PROJCS["Amersfoort / RD New",GEOGCS["Amersfoort",DATUM["Amersfoort",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],TOWGS84[565.04,49.91,465.84,-0.40939438743923684,-0.35970519561431136,1.868491000350572,0.8409828680306614],AUTHORITY["EPSG","6289"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4289"]],PROJECTION["Oblique Stereographic",AUTHORITY["EPSG","9809"]],PARAMETER["central_meridian",5.387638888888891],PARAMETER["latitude_of_origin",52.15616055555556],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000.0],PARAMETER["false_northing",463000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","28992"]],VERT_CS["Normaal Amsterdams Peil",VERT_DATUM["Normaal Amsterdams Peil",2005,AUTHORITY["EPSG","5109"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5709"]],AUTHORITY["EPSG","7415"]]');
    
%% Define and create dimensions    
    nc_add_dimension(filename, 'time'       , 0);
    nc_add_dimension(filename, 'bounds2'    , 2);
    nc_add_dimension(filename, 'alongshore' , length(grid.id));
    nc_add_dimension(filename, 'cross_shore', length(grid.crossShoreCoordinate));
    nc_add_dimension(filename, 'stringsize' , STRINGSIZE);

%% Define and create variables
    s.Name      = 'id';
    s.Nctype    = nc_int;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name' ,'comment'},...
                         'Value',{'identifier','sum of area code (*1e6) and alongshore coordinate'});
    nc_addvar(filename, s);
    
    [flag_values,flag_meanings]=jarkus_area_definition;
     flag_meanings = str2line(flag_meanings,'s',' ');
    
    s.Name      = 'areacode';
    s.Nctype    = nc_int;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name','flag_values','flag_meanings','flag_comment'       ,'comment'},...
                         'Value',{'area code', flag_values , flag_meanings ,'points to: areaname','codes for the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    nc_addvar(filename, s);

    s.Name      = 'areaname';
    s.Nctype    = nc_char;
    
    s.Dimension = {'alongshore', 'stringsize'};
    s.Attribute = struct('Name' ,{'long_name','flag_comment'        ,'comment'},...
                         'Value',{'area name','indexed in: areacode','names for the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    nc_addvar(filename, s);

    s.Name      = 'alongshore';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'alongshore coordinate', 'm'     , 'alongshore coordinate within the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    nc_addvar(filename, s);
    
    s.Name      = 'cross_shore';
    s.Nctype    = nc_double;
    s.Dimension = {'cross_shore'};
    s.Attribute = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'cross-shore coordinate', 'm'    , 'cross-shore coordinate relative to the rsp (rijks strand paal)'});
    nc_addvar(filename, s);

    % TODO: change to days since epoch
    s.Name      = 'time';
    s.Nctype    = nc_double;
    s.Dimension = {'time'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'axis' ,'units'                 ,'cell_methods','bounds'     ,'comment'         },...
                         'Value',{'time'                   ,'T'    ,'days since 1970-01-01' ,'mean'        ,'time_bounds','measurement year (date is artificially set to July, 1st); see bathy and time_topo for more detailed measurement dates'});
    nc_addvar(filename, s);

    s.Name      = 'time_bounds';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'bounds2'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'units'                },...
                         'Value',{'time'                   ,'days since 1970-01-01'});
    nc_addvar(filename, s);

    % smaller variables first
    [lon,lat,OPT]=convertCoordinates(0,0,'CS1.code',28992,'CS2.code',4326);
    %[CoordinateSystems, Operations , CoordSysCart ,CoordSysGeo] = GetCoordinateSystems();
    epsg        = 28992;
    s.Name      = 'epsg';
    s.Nctype    = nc_int;
    s.Dimension = {};
    s.Attribute = struct('Name', ...
       {'grid_mapping_name', ...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'latitude_of_projection_origin', ...
        'longitude_of_projection_origin', ...
        'false_easting', ...
        'false_northing', ...
        'scale_factor_at_projection_origin',...
        'comment'}, ...
        'Value', ...
        {OPT.proj_conv1.method.name,    ...
        OPT.CS1.ellips.semi_major_axis, ...
        OPT.CS1.ellips.semi_minor_axis, ...
        OPT.CS1.ellips.inv_flattening,  ...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Latitude of natural origin'    )), ...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Longitude of natural origin'   )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'False easting'                 )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'False northing'                )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Scale factor at natural origin')),...
        'value is equal to EPSG code'});
    nc_addvar(filename, s);
    
    s.Name      = 'x';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore' ,'cross_shore'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'units','axis'},...
                         'Value',{'projection_x_coordinate','m'    ,'X'});
    nc_addvar(filename, s);
    
    s.Name      = 'y';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore' ,'cross_shore'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'units','axis'},...
                         'Value',{'projection_y_coordinate','m'    ,'Y'});
    nc_addvar(filename, s);
    
    s.Name      = 'lat';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore' ,'cross_shore'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'units'       ,'axis'},...
                         'Value',{'latitude'               ,'degree_north','X'});
    nc_addvar(filename, s);
    
    s.Name      = 'lon';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore' ,'cross_shore'};
    s.Attribute = struct('Name' ,{'standard_name','units'      ,'axis'},...
                         'Value',{'longitude'    ,'degree_east','Y'});
    nc_addvar(filename, s);
    

        
    s.Name      = 'angle';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'        , 'units'  , 'comment'},...
                         'Value',{'angle of transect', 'degrees', 'positive clockwise 0 north'});
    nc_addvar(filename, s);
    
    s.Name      = 'mean_high_water';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'      , 'units', 'comment'},...
                         'Value',{'mean high water level', 'm'   , 'mean high water level relative to nap'});
    nc_addvar(filename, s);
    
    s.Name      = 'mean_low_water';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'     , 'units', 'comment'},...
                         'Value',{'mean low water level', 'm'    , 'mean low water level relative to nap'});
    nc_addvar(filename, s);
    
%% Some extra variables for convenience

    s.Name      = 'max_cross_shore_measurement';
    s.Nctype    = nc_int;
    s.Dimension = {'time', 'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'                            , 'comment'                                       , '_FillValue'},...
                         'Value',{'Maximum cross shore measurement index', 'Index of the cross shore measurement (0 based)',        -9999});
    nc_addvar(filename, s);

    s.Name      = 'min_cross_shore_measurement';
    s.Nctype    = nc_int;
    s.Dimension = {'time', 'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'                            , 'comment'                                       , '_FillValue'},...
                         'Value',{'Minimum cross shore measurement index', 'Index of the cross shore measurement (0 based)',        -9999});
    nc_addvar(filename, s);
    
%     s.Name      = 'has_data';
%     s.Nctype    = nc_int;
%     s.Dimension = {'time', 'alongshore'};
%     s.Attribute = struct('Name' ,{'long_name'       , 'comment',                                'flag_values', 'flag_meanings'},...
%                          'Value',{'Has data' ,        'Data availability per year per transect', 0:1,          'false true'});
%     nc_addvar(filename, s);
    
    s.Name      = 'nsources';
    s.Nctype    = nc_int;
    s.Dimension = {'time', 'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'              , 'comment'},...
                         'Value',{'Number of data sources' , 'Transects that are based on more than one source should be interpreted with care'});
    nc_addvar(filename, s);
    
    s.Name      = 'max_altitude_measurement';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'       , 'actual_range', '_FillValue'},...
                         'Value',{'Maximum altitude', [NaN NaN],             -9999});
    nc_addvar(filename, s);

    s.Name      = 'min_altitude_measurement';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'       , 'actual_range', '_FillValue'},...
                         'Value',{'Minimum altitude', [NaN NaN],              -9999});
    nc_addvar(filename, s);

    s.Name      = 'rsp_x';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'              , 'units'            , 'axis', 'comment'},...
                         'Value',{'location for beach pole', 'm'                , 'X'   ,'Location of the beach pole (rijks strand paal)'});
    nc_addvar(filename, s);
    
    s.Name      = 'rsp_y';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'              , 'units'            , 'axis', 'comment'},...
                         'Value',{'location for beach pole', 'm'                , 'Y'   , 'Location of the beach pole (rijks strand paal)'});
    nc_addvar(filename, s);
    
    s.Name      = 'rsp_lat';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'              , 'units'            , 'comment'},...
                         'Value',{'location for beach pole', 'degrees_north'    , 'Location of the beach pole (rijks strand paal)'});
    nc_addvar(filename, s);
    
    s.Name      = 'rsp_lon';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'              , 'units'            , 'comment'},...
                         'Value',{'location for beach pole', 'degrees_east'     , 'Location of the beach pole (rijks strand paal)'});
    nc_addvar(filename, s);

    
%% information about measurements    
    
    
    s.Name      = 'time_topo';
    s.Nctype    = nc_double;
    s.Dimension = {'time','alongshore'};
    s.Attribute = struct('Name' ,{'long_name'                     , 'units'                    , 'comment'},...
                         'Value',{'measurement date of topography', 'days since 1970-01-01'    , 'Measurement date of the topography'});
    nc_addvar(filename, s);
    s.Name      = 'time_bathy';
    s.Nctype    = nc_double;
    s.Dimension = {'time','alongshore'};
    s.Attribute = struct('Name' ,{'long_name'                     , 'units'                    , 'comment'},...
                         'Value',{'measurement date of bathymetry', 'days since 1970-01-01'    , 'Measurement date of the bathymetry'});
    nc_addvar(filename, s);

    s.Name      = 'origin';
%     id=1 non-overlap     beach data
%     id=2     overlap     beach data
%     id=3     interpolation     data (between beach and off shore)
%     id=4     overlap off shore data
%     id=5 non-overlap off shore data
    s.Nctype    = nc_short;
    s.Dimension = {'time', 'alongshore', 'cross_shore'};
%     s.Attribute = struct('Name' ,{'long_name'         , 'comment'},...
%                          'Value',{'measurement method', 'Measurement method 1:TO DO, 3:TO DO, 5:TO DO used short for space considerations'});
    flag_values   = [ 1          2             3             4           5        ]; 
    s.Attribute = struct('Name' ,{'long_name'         , 'flag_values','flag_meanings', 'comment'},...
                         'Value',{'measurement method',  flag_values  ,'beach_only beach_overlap interpolation sea_overlap sea_only', sprintf('The transects in this file are a combination of origins (flags):%s', sprintf(' %i', origins))});
    nc_addvar(filename, s);    
    
%% Store index variables

    nc_varput(filename, 'time'        , grid.time    );
    nc_varput(filename, 'time_bounds' , grid.timelims);

    nc_varput(filename, 'id'          , grid.id);
    nc_varput(filename, 'areacode'    , grid.areaCode);
%    TODO: Hack to store whole array
    areanames = grid.areaName;
    areanames(:, size(areanames,2)+1:STRINGSIZE) = ' ';
    nc_varput(filename, 'areaname', areanames);

    nc_varput(filename, 'alongshore', grid.alongshoreCoordinate);

    nc_varput(filename, 'cross_shore', grid.crossShoreCoordinate);
    nc_varput(filename, 'x'          , grid.X);
    nc_varput(filename, 'y'          , grid.Y);
    
    nc_varput(filename, 'rsp_x'      , grid.x_0);
    nc_varput(filename, 'rsp_y'      , grid.y_0);
    
% add WGS84 [lat,lon]
    
    [lon,lat,OPT]=convertCoordinates(grid.X,grid.Y,'CS1.code',28992,'CS2.code',4326);
    nc_varput(filename, 'lat', lat);
    nc_varput(filename, 'lon', lon);

    [rsplon, rsplat] = convertCoordinates(grid.x_0,grid.y_0, 'CS1.code',28992, 'CS2.code', 4326);
    nc_varput(filename, 'rsp_lat', rsplat)
    nc_varput(filename, 'rsp_lon', rsplon)
    
    
    if isfield(grid,'angle')
%     if strcmp('angle', fieldnames(grid)) % <= OLD CODE will not trigger "if", if angle is not first field!!! RPN 22-11-2012
        nc_varput(filename, 'angle'          , grid.angle);
    end
    if isfield(grid,'meanHighWater')
%     if strcmp('meanHighWater', fieldnames(grid)) % <= OLD CODE will not trigger "if", if meanHighWater is not first field!!! RPN 22-11-2012
        nc_varput(filename, 'mean_high_water', grid.meanHighWater);
    end
    if isfield(grid,'meanLowWater')
%     if strcmp('meanLowWater', fieldnames(grid)) % <= OLD CODE will not trigger "if", if meanLowWater is not first field!!! RPN 22-11-2012
        nc_varput(filename, 'mean_low_water' , grid.meanLowWater);
    end

%% altitude is big therefor done seperately
%     Some timer routines here to test performance. This can become a bit
%     slow. 
    s.Name      = 'altitude';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'alongshore', 'cross_shore'};
    s.Attribute = struct('Name', {'standard_name'   , 'units', 'actual_range', 'comment'                   , 'coordinates', 'grid_mapping', '_FillValue'}, ...
                        'Value', {'surface_altitude', 'm'    , [NaN NaN],      'altitude above geoid (NAP)', 'lat lon'    , 'epsg'        , -9999       });
    nc_addvar(filename, s);

%% Print header    
%     try	
%     disp('Will try to run ncdump, no problem if command is not found')
%     system(['ncdump -vyear,id,cross_shore_distance ' filename]); % system will not be catched by try in this way, RPN 22-11-2012

      nc_dump(filename)

%     catch
%         disp('can not find the ncdump command, not a problem');
%     end

end % function jarkus_grid2netcdf
