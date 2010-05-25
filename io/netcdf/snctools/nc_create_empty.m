function nc_create_empty ( ncfile, mode )
%NC_CREATE_EMPTY  creates an empty netCDF file.
%   NC_CREATE_EMPTY(FILENAME,MODE) creates the empty netCDF file FILENAME
%   with the given MODE.  MODE can be one of the following strings:
%   
%       'clobber'       - deletes existing file, creates netcdf-3 file
%       'noclobber'     - creates netcdf-3 file if it does not already
%                         exist.
%       '64bit_offset'  - creates a netcdf-3 file with 64-bit offset
%       'hdf4'          - creates an HDF4 file
%
%   MODE can also be a numeric value that corresponds either to one of the
%   named netcdf modes or a numeric bitwise-or of them.
%
%   EXAMPLE:  Create an empty classic netCDF file.
%       nc_create('myfile.nc');
%
%   EXAMPLE:  Create an empty netCDF file with the 64-bit offset mode, but
%   do not destroy any existing file with the same name.
%       mode = bitor(nc_noclobber_mode,nc_64bit_offset_mode);
%       nc_create_empty('myfile.nc',mode);
%
%   EXAMPLE:  Create a netCDF-4 file.  This assumes that you have a 
%   netcdf-4 enabled mex-file.
%       mode = nc_netcdf4_classic;
%       nc_create_empty('myfile.nc',mode);  
%
%   SEE ALSO:  nc_noclobber_mode, nc_clobber_mode, nc_64bit_offset_mode, 
%   nc_netcd4_classic.

% Set the default mode if necessary.
if nargin == 1
    mode = nc_clobber_mode;
end

% We cannot rely on snc_write_backend to determine how to proceed in this 
% case because the file has not yet been created!
switch ( version('-release') )
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
        tmw_lt_r2008b = true;
    otherwise
        tmw_lt_r2008b = false;
end

if (isnumeric(mode) && (mode == 4352))  || tmw_lt_r2008b
    % either the matlab version is lower than R2008b, or 
    % the mode involved NC_CLASSIC_MODE, implying netcdf-4
    [ncid, status] = mexnc ( 'CREATE', ncfile, mode );
    if ( status ~= 0 )
        ncerr = mexnc ( 'STRERROR', status );
        error ( 'SNCTOOLS:NC_CREATE_EMPTY:MEXNC:CREATE', ncerr );
    end
    mexnc('close',ncid);
elseif strcmp(mode,'hdf4')
    if exist(ncfile,'file')
        delete(ncfile);
    end
    sd_id = hdfsd('start',ncfile,'create');
	if sd_id == -1
		error('SNCTOOLS:NC_CREATE_EMPTY:hdf4:create', ...
              'Could not create HDF4 file %s.\n', ncfile);
	end
    status = hdfsd('end',sd_id);
	if status == -1
		error('SNCTOOLS:NC_CREATE_EMPTY:hdf4:end', ...
              'Could not close HDF4 file %s.\n', ncfile);
	end
else
    ncid = netcdf.create(ncfile, mode );
    netcdf.close(ncid);
end


