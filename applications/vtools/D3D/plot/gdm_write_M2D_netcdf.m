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
%

function gdm_write_M2D_netcdf(fpath_netcdf,data)

ncid=netcdf.create(fpath_netcdf,'NETCDF4');
try
    dim_data=netcdf.defDim(ncid,'n',numel(data));
    var_data=netcdf.defVar(ncid,'data','NC_DOUBLE',dim_data);
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'description', ...
        'gdm_write_M2D_netcdf; v1.0');

    netcdf.endDef(ncid);
    netcdf.putVar(ncid,var_data,data(:));
    netcdf.close(ncid);
catch error
    netcdf.close(ncid);
    rethrow(error)
end

messageOut(NaN,sprintf('Finished writing netcdf: %s',fpath_netcdf));
end %function