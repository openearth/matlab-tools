function nc_padheader ( ncfile, num_bytes )
%NC_PADHEADER  pad header of netCDF-3 file.
%   nc_padheader(NCFILE,NUM_BYTES) pads the header of a netCDF-3 file
%   NCFILE with NUM_BYTES bytes.
% 
%   When a netCDF file gets very large, adding new attributes can become
%   a time-consuming process.  This can be mitigated by padding the 
%   netCDF header with additional bytes.  Subsequent new attributes will
%   not result in long time delays unless the length of the new 
%   attribute exceeds that of the header.
%
%   This routine should not be used with a netCDF-4 file.
%
%   See also:  nc_create_empty.


error(nargchk(2,2,nargin,'struct'));

[ncid,status] = mexnc ( 'open', ncfile, nc_write_mode );
if ( status ~= 0 )
	ncerr = mexnc ( 'strerror', status );
	error ( 'SNCTOOLS:NC_PADHEADER:MEXNC:OPEN', ncerr );
end

status = mexnc ( 'redef', ncid );
if ( status ~= 0 )
	mexnc ( 'close', ncid );
	ncerr = mexnc ( 'strerror', status );
	error ( 'SNCTOOLS:NC_PADHEADER:MEXNC:REDEF', ncerr );
end

%
% Sets the padding to be "num_bytes" at the end of the header section.  
% The other values are default values used by "ENDDEF".
status = mexnc ( '_enddef', ncid, num_bytes, 4, 0, 4 );
if ( status ~= 0 )
	mexnc ( 'close', ncid );
	ncerr = mexnc ( 'strerror', status );
	error ( 'SNCTOOLS:NC_PADHEADER:MEXNC:_ENDDEF', ncerr );
end

status = mexnc ( 'close', ncid );
if ( status ~= 0 )
	mexnc ( 'close', ncid );
	ncerr = mexnc ( 'strerror', status );
	error ( 'SNCTOOLS:NC_PADHEADER:MEXNC:CLOSE', ncerr );
end
