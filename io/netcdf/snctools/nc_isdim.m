function tf = nc_isdim(ncfile,dimname)
%NC_ISDIM  Determine if variable is present in file.
%
%   BOOL = NC_ISDIM(NCFILE,DIMNAME) returns true if the dimension DIMNAME is 
%   present in the file NCFILE and false if it is not.
%
%   Example (requires R2008b):
%       bool = nc_isdim('example.nc','temperature')
%       
%   See also nc_isatt, nc_isvar

% Both inputs must be character
if nargin ~= 2
	error ( 'snctools:isdim:badInput', 'must have two inputs' );
end
if ~ ( ischar(ncfile) || isa(ncfile,'ucar.nc2.NetcdfFile') || isa(ncfile,'ucar.nc2.dods.DODSNetcdfFile') )
	error ( 'snctools:isdim:badInput', 'first argument must be character or a JAVA netCDF file object.' );
end
if ~ischar(dimname)
	error ( 'snctools:isdim:badInput', 'second argument must be character.' );
end


retrieval_method = snc_read_backend(ncfile);

switch(retrieval_method)
	case 'tmw'
		tf = nc_isdim_tmw(ncfile,dimname);
	case 'java'
		tf = nc_isdim_java(ncfile,dimname);
	case 'mexnc'
		tf = nc_isdim_mexnc(ncfile,dimname);
	case 'tmw_hdf4'
		tf = nc_isdim_hdf4(ncfile,dimname);
	otherwise
		error ( 'snctools:isdim:unrecognizedCase', ...
		        '%s is not recognized method for NC_ISDIM.', retrieval_method );
end
 

%--------------------------------------------------------------------------
function bool = nc_isdim_hdf4(hfile,dimname)

error('not implemented yet for HDF4')

%-----------------------------------------------------------------------
function bool = nc_isdim_mexnc ( ncfile, dimname )

[ncid,status] = mexnc('open',ncfile, nc_nowrite_mode );
if status ~= 0
	ncerr = mexnc ( 'STRERROR', status );
	error('snctools:isdim:mexnc:open', ncerr );
end


[varid,status] = mexnc('INQ_DIMID',ncid,dimname);
if ( status ~= 0 )
	bool = false;
else 
	bool = true;
end

mexnc('close',ncid);
return

%--------------------------------------------------------------------------
function bool = nc_isdim_java ( ncfile, dimname )
% assume false until we know otherwise
bool = false;

import ucar.nc2.dods.*
import ucar.nc2.*

close_it = true;


% Try it as a local file.  If not a local file, try as
% via HTTP, then as dods
if isa(ncfile,'ucar.nc2.NetcdfFile')
	jncid = ncfile;
	close_it = false;
elseif isa(ncfile,'ucar.nc2.dods.DODSNetcdfFile')
	jncid = ncfile;
	close_it = false;
elseif exist(ncfile,'file')
	jncid = NetcdfFile.open(ncfile);
else
	try 
		jncid = NetcdfFile.open ( ncfile );
	catch %#ok<CTCH>
		try
			jncid = DODSNetcdfFile(ncfile);
		catch %#ok<CTCH>
			error ( 'snctools:isdim:fileOpenFailure', ...
			'Could not open ''%s'' as either a local file, a regular URL, or as a DODS URL.', ...
			ncfile);
		end
	end
end

jvarid = jncid.findDimension(dimname);

%
% Did we find anything?
if ~isempty(jvarid)
	bool = true;
end

if close_it
	close(jncid);
end

return

