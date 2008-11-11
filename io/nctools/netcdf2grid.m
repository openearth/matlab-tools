function grid = netcdf2grid(filename)
%NETCDF2GRID
%
% grid = netcdf2grid(filename)
%
%See also: GRID2NETCDF

    grid.year            = nc_varget(filename, 'year');
    grid.id              = nc_varget(filename, 'id');
    grid.seawardDistance = nc_varget(filename, 'seaward_distance');
    
end % function netcdf2grid