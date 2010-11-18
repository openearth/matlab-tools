function tf = nc_isunlimitedvar ( ncfile, varname )
%NC_ISUNLIMITEDVAR determine if variable has unlimited dimension.
%
%   TF = NC_ISUNLIMITEDVAR(NCFILE,VARNAME) returns true if the netCDF
%   variable VARNAME in the netCDF file NCFILE has an unlimited dimension,
%   and false otherwise.
%
%   Example (requires 2008b or higher):
%       nc_dump('example.nc');
%       tf = nc_isunlimitedvar('example.nc','time_series')
%
%   See also NC_ISCOORDVAR, NC_DUMP.


v = version('-release');
switch(v)
    case { '14', '2006a', '2006b', '2007a' }
        tf = snc_is_unlimitedvar_lt_2007b(ncfile,varname);
     
    otherwise
        tf = snc_is_unlimitedvar(ncfile,varname);
        
end




%--------------------------------------------------------------------------
function tf = snc_is_unlimitedvar_lt_2007b(ncfile,varname)
try
    DataSet = nc_getvarinfo ( ncfile, varname );
catch %#ok<CTCH>
    e = lasterror; %#ok<LERR>
    switch ( e.identifier )
        case { 'SNCTOOLS:NC_GETVARINFO:badVariableName', ...
                'SNCTOOLS:NC_VARGET:MEXNC:INQ_VARID', ...
                'MATLAB:netcdf:inqVarID:variableNotFound' }
            tf = false;
            return
        otherwise
            error('SNCTOOLS:NC_ISUNLIMITEDVAR:unhandledCondition', e.message );
    end
end

tf = DataSet.Unlimited;