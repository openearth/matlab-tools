%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20065 $
%$Date: 2025-02-21 08:59:22 +0100 (Fri, 21 Feb 2025) $
%$Author: chavarri $
%$Id: D3D_simpath.m 20065 2025-02-21 07:59:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath.m $
%
%Get dimensions from a NetCDF file.
%
%The standard is:
%```
% nci=ncinfo(fpath_map);
% {nci.Dimensions.Name};
%```
%This function is faster. 

function [dimname, dimlen]=NC_dimensions(fpath_map)

ncid = netcdf.open(fpath_map, 'NOWRITE');

[ndims, ~, ~, ~] = netcdf.inq(ncid);

dimname=cell(1,ndims);
dimlen=NaN(1,ndims);
for ki=1:ndims
    [dimname{ki}, dimlen(ki)] = netcdf.inqDim(ncid,ki-1);
end

netcdf.close(ncid);

end %function