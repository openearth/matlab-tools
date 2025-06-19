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
%Get variable names from a NetCDF file.
%
%The standard is:
%```
% nci=ncinfo(fpath_map);
% varnames={nci.Variables.Name};
%```
%This function is faster. 

function [varnames,dimids]=NC_varnames(fpath_map)

ncid = netcdf.open(fpath_map,'NOWRITE');
[~, nvars, ~, ~] = netcdf.inq(ncid);

varnames=cell(1,nvars);
dimids=cell(1,nvars);
for ki=1:nvars
    [varnames{ki},~, dimids{ki},~]=netcdf.inqVar(ncid,ki-1);
end

netcdf.close(ncid);

end %function
