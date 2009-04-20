function varsize = nc_varsize(ncfile, varname)
% NC_VARSIZE:  return the size of the requested netncfile variable
%
% VARSIZE = NC_VARSIZE(NCFILE,NCVAR) returns the size of the netCDF variable 
% NCVAR in the netCDF file NCFILE.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id$
% $LastChangedDate$
% $LastChangedRevision$
% $LastChangedBy$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snc_nargchk(2,2,nargin);
snc_nargoutchk(1,1,nargout);

if ~ischar(ncfile)
	snc_error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input filename must be a string.' );
end
if ~ischar(varname)
	snc_error ( 'SNCTOOLS:NC_VARSIZE:badInputType', 'The input variable name must be a string.' );
end


v = nc_getvarinfo ( ncfile, varname );

varsize = v.Size;

return

