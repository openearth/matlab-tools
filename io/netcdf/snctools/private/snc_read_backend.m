function [retrieval_method,fmt] = snc_read_backend(ncfile)
% SNC_READ_BACKEND:  figure out which backend to use: mexnc, java or 
% tmw or tmw_hdf4 (native matlab netcdf/hdf4 package)

tmw_gt_r2008a = false;
tmw_gt_r2010a = false;

use_java = getpref('SNCTOOLS','USE_JAVA',false);

% Check for this early.
if isa(ncfile,'ucar.nc2.NetcdfFile') && use_java
    retrieval_method = 'java';
	fmt = 'netcdf-java';
	return
end


fmt = snc_format(ncfile);
mv = version('-release');
switch ( mv )
    case { '11', '12' };
		error('Not supported on releases below R13.');

    case { '13', '14', '2006a', '2006b', '2007a', '2007b', '2008a', '2008b', '2009a', '2009b', '2010a'}
        p = computer;
        if strcmp(p,'PCWIN64')
            if strcmp(fmt,'HDF4')
                retrieval_method = 'tmw_hdf4';
            else
                retrieval_method = 'java';
            end
            return
        end
	try
	nv = mexnc('inq_libvers'); 
	catch
	disp('no valid mexnc, we''ll try java instead:...')
	if use_java
	   retrieval_method = 'java';
	   disp('... and java is enabled: java backend used for reading local netCDF files.')
	   return
	else
	   error('...and no valid java backend found either: please enable java, see README')
	end
	end
        
    case { '2008b', '2009a', '2009b', '2010a' }
        nv = mexnc('inq_libvers');
        tmw_gt_r2008a = true;

    otherwise
		% Assume 10b or beyond.
		nv = netcdf.inqLibVers;
        tmw_gt_r2008a = true;
        tmw_gt_r2010a = true;

end



if tmw_gt_r2008a && strcmp(fmt,'netCDF')
    % Use TMW for all local NC3 files when the version >= R2008b
    retrieval_method = 'tmw';
elseif strcmp(fmt,'netCDF') && ~tmw_gt_r2008a
    % Local NC3 files should rely on mexnc when the version <= R2008a
    retrieval_method = 'mexnc';
elseif strcmp(fmt,'netCDF-4') && tmw_gt_r2010a
    % If netcdf-4 and 10b or higher, use the native package again.
    retrieval_method = 'tmw';
elseif strcmp(fmt,'netCDF-4') && (nv(1) == '4')
    % If mexnc says we are at version 4 of the library, use mexnc
    retrieval_method = 'mexnc';
elseif use_java && strcmp(fmt,'GRIB')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'GRIB2')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'URL')
    retrieval_method = 'java';
elseif use_java && strcmp(fmt,'netCDF-4')
    retrieval_method = 'java';
elseif strcmp(fmt,'URL')
    % a URL when java is not enabled.  Use mexnc
    retrieval_method = 'mexnc';
elseif strcmp(fmt,'netCDF-4') 
    % NC4 file where we have <=2008b and java is not an option.
    % Try to use the community mex-file.
    retrieval_method = 'mexnc';  
elseif strcmp(fmt,'HDF4')
    retrieval_method = 'tmw_hdf4';
elseif use_java
    % Last chance is if it is some format that netcdf-java can handle.
    retrieval_method = 'java';
    fmt = 'netcdf-java';
else
    error('SNCTOOLS:unknownBackendSituation', ...
      'Could not determine which backend to use with %s.', ...
       ncfile );
end

return



