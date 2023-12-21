%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Change reference time of NC file

function NC_change_reference_time(fpath_nc,str_time)

ncid=netcdf.open(fpath_nc,'WRITE');
netcdf.reDef(ncid);
varid=netcdf.inqVarID(ncid,'time');
netcdf.putAtt(ncid,varid,'units',str_time)
netcdf.close(ncid)

end %function
