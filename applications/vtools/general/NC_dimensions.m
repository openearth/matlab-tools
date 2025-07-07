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