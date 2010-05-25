function bool = nc_isunlimitedvar ( ncfile, varname )
% NC_ISUNLIMITEDVAR:  determines if a variable has an unlimited dimension
%
% BOOL = NC_ISUNLIMITEDVAR ( NCFILE, VARNAME ) returns TRUE if the netCDF
% variable VARNAME in the netCDF file NCFILE has an unlimited dimension, 
% and FALSE otherwise.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% $Id$
% $LastChangedDate$
% $LastChangedRevision$
% $LastChangedBy$
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
    DataSet = nc_getvarinfo ( ncfile, varname );
catch %#ok<CTCH>
    e = lasterror; %#ok<LERR>
    switch ( e.identifier )
        case { 'SNCTOOLS:NC_GETVARINFO:badVariableName', ...
               'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ...
	       'MATLAB:netcdf:inqVarID:variableNotFound' }
            bool = false;
            return
        otherwise
            error('SNCTOOLS:NC_ISUNLIMITEDVAR:unhandledCondition', e.message );
    end
end

bool = DataSet.Unlimited;

return;
