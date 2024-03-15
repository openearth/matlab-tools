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
%Renames a dimension in a netCDF file. My objective is to 
%remove it, but I did not find a d wa

function NC_rename_dimension(fpath_nc,dimname_in,dimname_out)

nci=netcdf.open(fpath_nc,'NC_WRITE');
netcdf.reDef(nci)
dimid=netcdf.inqDimID(nci,dimname_in);
netcdf.renameDim(nci,dimid,dimname_out)
netcdf.close(nci);

end %function