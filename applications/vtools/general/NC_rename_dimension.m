%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19243 $
%$Date: 2023-11-20 11:49:45 +0100 (Mon, 20 Nov 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken.m 19243 2023-11-20 10:49:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/branch_rijntakken.m $
%
%Renames a dimension in a netCDF file. My objective is to 
%remove it, but I did not find a d wa

function NC_rename_dimension(fpath_nc,dimname_in,dimname_out)

nci=netcdf.open(fpath_nc,'NC_WRITE');
netcdf.reDef(nci)
dimid=netcdf.inqDimID(nci,dimname_in);
netcdf.renameDim(nci,dimid,dimname_out)
netcdf.close(nci);

end %function