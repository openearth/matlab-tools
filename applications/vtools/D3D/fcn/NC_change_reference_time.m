%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19314 $
%$Date: 2023-12-15 15:00:55 +0100 (Fri, 15 Dec 2023) $
%$Author: chavarri $
%$Id: D3D_map_max_min.m 19314 2023-12-15 14:00:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_map_max_min.m $
%
%Change reference time of NC file

function NC_change_reference_time(fpath_nc,str_time)

ncid=netcdf.open(fpath_nc,'WRITE');
netcdf.reDef(ncid);
varid=netcdf.inqVarID(ncid,'time');
netcdf.putAtt(ncid,varid,'units',str_time)
netcdf.close(ncid)

end %function
