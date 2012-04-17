function bool = nc_isdim_tmw(ncfile,dimname)
% TMW backend for NC_ISDIM.

ncid = netcdf.open(ncfile,'NOWRITE');
try
	netcdf.inqDimID(ncid,dimname);
	bool = true;
catch myException %#ok<NASGU>
	bool = false;
end

netcdf.close(ncid);
return
