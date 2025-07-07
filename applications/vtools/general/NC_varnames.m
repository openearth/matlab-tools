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
