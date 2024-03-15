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
%Copies a netCDF file and changes the dimension. 
%
%E.G.:
%
% fpath_i='c:\Users\chavarri\Downloads\RIJN_0002_20000101_000000_rst.nc';
% fpath_o='c:\Users\chavarri\Downloads\RIJN_0002_20000101_000000_mod_rst.nc';
% dim_name_mod='nSedTot';
% dim_val_mod=42;

function NC_dimension_change(fpath_i,fpath_o,dim_name_mod,dim_val_mod)

ncid_i=netcdf.open(fpath_i,'NOWRITE');
ncid_o=netcdf.create(fpath_o,'CLOBBER');

% [dimname,dimlen]=netcdf.inqDim(ncid_i,0); % Get dimension name and length
[numdims,numvars,numatts,unlimdimid]=netcdf.inq(ncid_i);

% Copy dimensions (except the one to modify)
for dimid = 0:numdims-1
    [dimname,dimlen]=netcdf.inqDim(ncid_i, dimid);
    if ~strcmp(dimname,dim_name_mod)
        netcdf.defDim(ncid_o,dimname,dimlen);
    else
        netcdf.defDim(ncid_o,dimname,dim_val_mod); % Modify the dimension
    end
end

% Copy variables and attributes
for varid = 0:numvars-1
    [varname, xtype, varDimIDs, numatts] = netcdf.inqVar(ncid_i, varid);
    new_varid = netcdf.defVar(ncid_o, varname, xtype, varDimIDs);
    for attnum = 0:numatts-1
        attname = netcdf.inqAttName(ncid_i, varid, attnum);
        attval = netcdf.getAtt(ncid_i, varid, attname);
        netcdf.putAtt(ncid_o, new_varid, attname, attval);
    end
end

% End definitions
netcdf.endDef(ncid_o);

% Copy variable data
for varid = 0:numvars-1
    data=netcdf.getVar(ncid_i,varid);
    netcdf.putVar(ncid_o,varid,data);
end

% Close both files
netcdf.close(ncid_i);
netcdf.close(ncid_o);

end %function
