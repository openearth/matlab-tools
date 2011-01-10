function [retrieval_method,fmt] = snc_read_backend(ncfile)
% which backend do we employ?  Many, many possibilities to consider here.

retrieval_method = '';

use_java = getpref('SNCTOOLS','USE_JAVA',false);
use_mexnc = getpref('SNCTOOLS','USE_MEXNC',false);

% Check for this early.
if isa(ncfile,'ucar.nc2.NetcdfFile') && use_java
    retrieval_method = 'java';
	fmt = 'netcdf-java';
	return
end


fmt = snc_format(ncfile);

% These cases have no alternatives.
if strcmp(fmt,'HDF4') 
    % always use MATLAB's HDF interface for HDF-4 files.
    retrieval_method = 'tmw_hdf4';
	return
elseif use_java && (strcmp(fmt,'GRIB') || strcmp(fmt,'GRIB2') || strcmp(fmt,'URL'))
    % Always use netcdf-java for grib files or URLs (when java is enabled).
    retrieval_method = 'java';
	return
elseif strcmp(fmt,'URL')
    % If java is not available, we have to assume that mexnc was compiled with
	% opendap support.
    retrieval_method = 'mexnc';
	return
end

mv = version('-release');
switch ( mv )
    case { '11', '12', '13' };
		error('Not supported on releases below R14.');

    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
		% No native matlab support here.  We will favor java over
		% mexnc for now.
        if use_java && (strcmp(fmt,'NetCDF') || strcmp(fmt,'NetCDF-4'))
			% We will favor java over mexnc.
            retrieval_method = 'java';
        elseif use_mexnc && strcmp(fmt,'NetCDF') 
            retrieval_method = 'mexnc';
        elseif use_mexnc && strcmp(fmt,'NetCDF-4') && use_mexnc
			% Assume the user knows what they are doing here.
        elseif use_java
            % Last chance is if it is some format that netcdf-java can handle.
            retrieval_method = 'java';
            fmt = 'netcdf-java';
        end
        
    case { '2008b', '2009a', '2009b', '2010a' }
        % 2008b introduced native netcdf-3 support.
		% netcdf-4 still requires either mexnc or java, and we will favor
		% java again.
        if strcmp(fmt,'NetCDF') && use_mexnc
            % Use mexnc only if the user is dead serious about it.
            retrieval_method = 'mexnc';
        elseif strcmp(fmt,'NetCDF')
            % otherwise use TMW for all local NC3 files 
            retrieval_method = 'tmw';
        elseif strcmp(fmt,'NetCDF-4') && use_java
            % Use TMW for all local NC3 files 
            retrieval_method = 'java';
        elseif strcmp(fmt,'NetCDF-4') 
            % Assume the user knows what they are doing.
            retrieval_method = 'mexnc';
        elseif use_java
            % Last chance is if it is some format that netcdf-java can handle.
            retrieval_method = 'java';
            fmt = 'netcdf-java';
        end

    otherwise
        % R2010b:  introduced netcdf-4 support.
        if strcmp(fmt,'NetCDF') || strcmp(fmt,'NetCDF-4')
            retrieval_method = 'tmw';
        elseif use_java
            % Last chance is if it is some format that netcdf-java can handle.
            retrieval_method = 'java';
            fmt = 'netcdf-java';
        end

end

if isempty(retrieval_method)
    error('SNCTOOLS:unknownBackendSituation', ...
      'Could not determine which backend to use with %s.', ...
       ncfile );
end
return