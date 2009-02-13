function grid2netcdf(filename, grid)
%GRID2NETCDF
%
% grid2netcdf(filename, grid)
%
%See also: NETCDF2GRID

STRINGSIZE = 100;
%% Create file    
    nc_create_empty(filename)

%     make sure there's enough space for headers. This will speed up
%     putting attributes
    nc_padheader ( filename, 200000 );   
%% Put global attributes    
    nc_attput( filename, nc_global, 'title', 'Jarkus Data');
    nc_attput( filename, nc_global, 'institution', 'Rijkswaterstaat');
    nc_attput( filename, nc_global, 'source', 'on shore and off shore measurements');
    nc_attput( filename, nc_global, 'source', 'on shore and off shore measurements');
    nc_attput( filename, nc_global, 'history', ['data received from Rijkswaterstaat, converted to netcdf on ' date]);    
    nc_attput( filename, nc_global, 'references', ['Original source: http://www.watermarkt.nl/kustenzeebodem/ ' ...
        'Deltares storage: https://repos.deltares.nl/repos/mcdata/trunk/jarkus/' ...
        'Converted with script with $Id$' ]);
    nc_attput( filename, nc_global, 'Conventions', 'CF-1.3');    
    
%% Define dimensions    
    nc_add_dimension(filename, 'time', length(grid.year));
    nc_add_dimension(filename, 'transect', length(grid.id));
    nc_add_dimension(filename, 'seaward', length(grid.seawardDistance));
    nc_add_dimension(filename, 'stringsize', STRINGSIZE);

%% Define variables
    s.Name      = 'id';
    s.Nctype    = nc_int;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);
    
    s.Name      = 'areacode';
    s.Nctype    = nc_int;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);

    s.Name      = 'areaname';
    s.Nctype    = nc_char;
    s.Dimension = {'transect', 'stringsize'};
    nc_addvar(filename, s);

    s.Name      = 'coastward_distance';
    s.Nctype    = nc_double;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);
    
    s.Name      = 'seaward_distance';
    s.Nctype    = nc_double;
    s.Dimension = {'seaward'};
    nc_addvar(filename, s);

    s.Name      = 'year';
    s.Nctype    = nc_int;
    s.Dimension = {'time'};
    nc_addvar(filename, s);

    s.Name      = 'x';
    s.Nctype    = nc_double;
    s.Dimension = {'transect', 'seaward'};
    nc_addvar(filename, s);
    
    s.Name      = 'y';
    s.Nctype    = nc_double;
    s.Dimension = {'transect', 'seaward'};
    nc_addvar(filename, s);
    
    s.Name      = 'angle';
    s.Nctype    = nc_double;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);
    
    s.Name      = 'MHW';
    s.Nctype    = nc_double;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);
    
    s.Name      = 'MLW';
    s.Nctype    = nc_double;
    s.Dimension = {'transect'};
    nc_addvar(filename, s);
    
%% Define attributes
    nc_attput( filename, 'id', 'comment', 'sum of areacode (x1000000) and coastward_distance');    
    nc_attput( filename, 'id', 'long_name', 'unique identifier for transect');    
    
    nc_attput( filename, 'areacode', 'long_name', 'unique identifier for area');        
    nc_attput( filename, 'areaname', 'long_name', 'name for area');        
    
    nc_attput( filename, 'coastward_distance', 'long_name', 'distance along the coast within the area (metrering)');        
    nc_attput( filename, 'coastward_distance', 'unit', 'meter');        
    
    nc_attput( filename, 'seaward_distance', 'long_name', 'seaward distance');        
    nc_attput( filename, 'seaward_distance', 'unit', 'meter');        

%% Store index variables
    nc_varput(filename, 'year', grid.year);
    nc_varput(filename, 'id', grid.id);
    nc_varput(filename, 'areacode', grid.areacode);
%    TODO: Hack to store whole array
    areanames = grid.areaname;
    areanames(:, size(areanames,2)+1:STRINGSIZE) = ' ';
    nc_varput(filename, 'areaname', areanames);

    nc_varput(filename, 'coastward_distance', grid.coastwardDistance);

    nc_varput(filename, 'seaward_distance', grid.seawardDistance);
    nc_varput(filename, 'x', grid.X);
    nc_varput(filename, 'y', grid.Y);
    nc_varput(filename, 'angle', grid.angle);
    nc_varput(filename, 'MHW', grid.MHW);
    nc_varput(filename, 'MLW', grid.MLW);


%% Height is big therefor done seperate
%     Some timer routines here to test performance. This can become a bit
%     slow. 
    s.Name      = 'height';
    s.Nctype    = nc_double;
    s.Dimension = {'time', 'transect', 'seaward'};
    nc_addvar(filename, s);

    nc_attput( filename, 'height', 'standard_name', 'sea_surface_height_above_sea_level');
    nc_attput( filename, 'height', 'positive', 'up');
    nc_attput( filename, 'height', 'unit', 'meter'); 
    nc_attput( filename, 'height', '_FillValue', -99999);

%% Print header    
%     try	
%     	system(['ncdump -vyear,id,seaward_distance ' filename]);
%     catch
%     end

end % function grid2netcdf

