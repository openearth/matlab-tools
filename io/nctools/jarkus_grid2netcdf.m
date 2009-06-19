function jarkus_grid2netcdf(filename, grid)
%JARKUS_GRID2NETCDF  converts Jarkus grid struct to netCDF-CF file
%
%    jarkus_grid2netcdf(filename, grid)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

STRINGSIZE = 100;
%% Create file    
%     make sure there's enough space for headers. This will speed up
%     putting attributes

    nc_create_empty(filename)
    nc_padheader ( filename, 200000 );   
    
%% Put global attributes    
    nc_attput( filename, nc_global, 'title'      , 'Jarkus Data');
    nc_attput( filename, nc_global, 'institution', 'Rijkswaterstaat');
    nc_attput( filename, nc_global, 'source'     , 'on shore and off shore measurements');
    nc_attput( filename, nc_global, 'history'    , ['Data received from Rijkswaterstaat, converted to netCDF on ' date]);    
    nc_attput( filename, nc_global, 'references' , ['Original source: http://www.watermarkt.nl/kustenzeebodem/' ...
                                                    'Deltares storage: https://repos.deltares.nl/repos/mcdata/trunk/jarkus/' ...
                                                    'Converted with script with $Id$']);
    nc_attput( filename, nc_global, 'Conventions', 'CF-1.4');    
    % spatial reference using wkt. approach used by gdal.
    nc_attput( filename, nc_global, 'spatial_ref', 'COMPD_CS["Amersfoort / RD New + NAP",PROJCS["Amersfoort / RD New",GEOGCS["Amersfoort",DATUM["Amersfoort",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],TOWGS84[565.04,49.91,465.84,-0.40939438743923684,-0.35970519561431136,1.868491000350572,0.8409828680306614],AUTHORITY["EPSG","6289"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4289"]],PROJECTION["Oblique Stereographic",AUTHORITY["EPSG","9809"]],PARAMETER["central_meridian",5.387638888888891],PARAMETER["latitude_of_origin",52.15616055555556],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000.0],PARAMETER["false_northing",463000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","28992"]],VERT_CS["Normaal Amsterdams Peil",VERT_DATUM["Normaal Amsterdams Peil",2005,AUTHORITY["EPSG","5109"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5709"]],AUTHORITY["EPSG","7415"]]');
    
%% Define and create dimensions    
    nc_add_dimension(filename, 'time'       , 0);
    nc_add_dimension(filename, 'alongshore' , length(grid.id));
    nc_add_dimension(filename, 'cross_shore', length(grid.crossShoreCoordinate));
    nc_add_dimension(filename, 'stringsize' , STRINGSIZE);

%% Define and create variables
    s.Name      = 'id';
    s.Nctype    = nc_int;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name' ,'comment'},...
                         'Value',{'identifier','sum of area code (x1000000) and alongshore coordinate'});
    nc_addvar(filename, s);
    
    s.Name      = 'areacode';
    s.Nctype    = nc_int;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name','comment'},...
                         'Value',{'area code','codes for the 15 coastal areas as defined by rijkswaterstaat'});
    nc_addvar(filename, s);

    s.Name      = 'areaname';
    s.Nctype    = nc_char;
    s.Dimension = {'alongshore', 'stringsize'};
    s.Attribute = struct('Name' ,{'long_name','comment'},...
                         'Value',{'area name','names for the 15 coastal areas as defined by rijkswaterstaat'});
    nc_addvar(filename, s);

    s.Name      = 'alongshore';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'alongshore coordinate', 'm'     , 'alongshore coordinate within the 15 coastal areas as defined by rijkswaterstaat'});
    nc_addvar(filename, s);
    
    s.Name      = 'cross_shore';
    s.Nctype    = nc_double;
    s.Dimension = {'cross_shore'};
    s.Attribute = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'cross-shore coordinate', 'm'    , 'cross-shore coordinate relative to the rsp (rijks strand paal)'});
    nc_addvar(filename, s);

    % TODO: change to days since epoch
    s.Name      = 'time';
    s.Nctype    = nc_int;
    s.Dimension = {'time'};
    s.Attribute = struct('Name' ,{'standard_name'          ,'units','comment'         ,'axis'},...
                         'Value',{'time'                   ,'year' ,'measurement year','T'});
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
    
    [CoordinateSystems, Operations , CoordSysCart ,CoordSysGeo] = GetCoordinateSystems();
    epsg        = 28992;
    crs         = CoordinateSystems([CoordinateSystems.coord_ref_sys_code] == epsg);
    transform   = Operations([Operations.coord_op_code ] == crs.projection_conv_code);
    s.Name      = 'crs';
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
        'scale_factor_at_projection_origin'}, ...
        'Value', ...
        {transform.coordinate_operation_method,...
        crs.ellipsoid.semi_major_axis, ...
        crs.ellipsoid.semi_minor_axis, ...
        crs.ellipsoid.inv_flattening, ...
        transform.parameters(strcmp({transform.parameters.name},'Latitude_of_natural_origin'    )).value, ...
        transform.parameters(strcmp({transform.parameters.name},'Longitude_of_natural_origin'   )).value, ...
        transform.parameters(strcmp({transform.parameters.name},'False_easting'                 )).value, ...
        transform.parameters(strcmp({transform.parameters.name},'False_northing'                )).value, ...
        transform.parameters(strcmp({transform.parameters.name},'Scale_factor_at_natural_origin')).value});
    nc_addvar(filename, s);
        
    s.Name      = 'angle';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'        , 'units'  , 'comment'},...
                         'Value',{'angle of transect', 'mradian', 'positive counter clockwise 0 east'});
    nc_addvar(filename, s);
    
    s.Name      = 'mean_high_water';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'      , 'units', 'comment'},...
                         'Value',{'mean high water', 'm'   , 'mean high water relative to nap'});
    nc_addvar(filename, s);
    
    s.Name      = 'mean_low_water';
    s.Nctype    = nc_double;
    s.Dimension = {'alongshore'};
    s.Attribute = struct('Name' ,{'long_name'     , 'units', 'comment'},...
                         'Value',{'mean low water', 'm'    , 'mean low water relative to nap'});
    nc_addvar(filename, s);
    
%% Store index variables
    nc_varput(filename, 'time'    , grid.year, [0], [length(grid.year)]);
    nc_varput(filename, 'id'      , grid.id);
    nc_varput(filename, 'areacode', grid.areaCode);
%    TODO: Hack to store whole array
    areanames = grid.areaName;
    areanames(:, size(areanames,2)+1:STRINGSIZE) = ' ';
    nc_varput(filename, 'areaname', areanames);

    nc_varput(filename, 'alongshore', grid.alongshoreCoordinate);

    nc_varput(filename, 'cross_shore', grid.crossShoreCoordinate);
    nc_varput(filename, 'x'          , grid.X);
    nc_varput(filename, 'y'          , grid.Y);
    
    % converte coordinates
    [CoordinateSystems, Operations] = GetCoordinateSystems();
    [lon, lat] = ConvertCoordinates(grid.X,grid.Y, 28992, 'xy', 4326, 'geo', CoordinateSystems, Operations);
    nc_varput(filename, 'lat', lat);
    nc_varput(filename, 'lon', lon);
    nc_varput(filename, 'crs', 28992)
    
    if strmatch('angle', fieldnames(grid))
        nc_varput(filename, 'angle'          , grid.angle);
    end
    if strmatch('meanHighWater', fieldnames(grid))
        nc_varput(filename, 'mean_high_water', grid.meanHighWater);
    end
    if strmatch('meanLowWater', fieldnames(grid))
        nc_varput(filename, 'mean_low_water' , grid.meanLowWater);
    end

%% altitude is big therefor done seperately
%     Some timer routines here to test performance. This can become a bit
%     slow. 
    s.Name      = 'altitude';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'alongshore', 'cross_shore'};
    s.Attribute = struct('Name', {'standard_name'   , 'units', 'comment'                   , 'coordinates', 'grid_mapping', '_FillValue'}, ...
                        'Value', {'surface_altitude', 'm'    , 'altitude above geoid (NAP)', 'lat lon'    , 'crs'         , -9999       });
    nc_addvar(filename, s);

%% Print header    
    try	
    	system(['ncdump -vyear,id,cross_shore_distance ' filename]);
    catch
        disp('can not find the ncdump command, not a problem');
    end

end % function jarkus_grid2netcdf
