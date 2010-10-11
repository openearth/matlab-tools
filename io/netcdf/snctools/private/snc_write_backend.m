function backend = snc_write_backend(ncfile)
% SNC_WRITE_BACKEND:  figure out which backend to use, either mexnc or the
% native matlab netcdf/hdf4 package

switch ( version('-release') )
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a' }
        tmw_lt_r2008b = true;
        tmw_lt_r2010b = true;

    case { '2008b', '2009a', '2009b', '2010a' }
        tmw_lt_r2008b = false;
        tmw_lt_r2010b = true;

    otherwise
        tmw_lt_r2008b = false;
        tmw_lt_r2010b = false;
end

fmt = snc_format(ncfile);
nl = mexnc('inq_libvers');
if strcmp(fmt,'HDF4')
    backend = 'tmw_hdf4';
elseif (nl(1) == '4') && tmw_lt_r2010b
    % netcdf-4 enabled mex-file
    backend = 'mexnc';
elseif strcmp(fmt,'netCDF-4') && tmw_lt_r2010b
	% TMW can't write to netcdf-4 files at this point.
	% Have to hope that mexnc can do it.
	backend = 'mexnc';
elseif tmw_lt_r2008b
	% If the version of matlab is less than r2008b, we have n choice but to 
    % use mexnc
	backend = 'mexnc';
else
	backend = 'tmw';
end

return




