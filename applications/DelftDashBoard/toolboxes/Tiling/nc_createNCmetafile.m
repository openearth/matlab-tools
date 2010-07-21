function nc_createNCmetafile(ncfile,x0,y0,dxk,dyk,nnxk,nnyk,nx,ny,iavailable,javailable,OPT)
%% *** create empty outputfile
% indicate NetCDF outputfile name and create empty structure

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

%% add attributes global to the dataset

netcdf.putAtt(NCid,globalID, 'Conventions',     OPT.Conventions);
netcdf.putAtt(NCid,globalID, 'CF:featureType',  OPT.CF_featureType); % http://www.unidata.ucar.edu/software/netcdf-java/v4.1/javadoc/ucar/nc2/constants/CF.FeatureType.html
netcdf.putAtt(NCid,globalID, 'title',           OPT.title);
netcdf.putAtt(NCid,globalID, 'institution',     OPT.institution);
netcdf.putAtt(NCid,globalID, 'source',          OPT.source);
netcdf.putAtt(NCid,globalID, 'history',         OPT.history);
netcdf.putAtt(NCid,globalID, 'references',      OPT.references);
netcdf.putAtt(NCid,globalID, 'comment',         OPT.comment);
netcdf.putAtt(NCid,globalID, 'email',           OPT.email);
netcdf.putAtt(NCid,globalID, 'version',         OPT.version);
netcdf.putAtt(NCid,globalID, 'terms_for_use',   OPT.terms_for_use);
netcdf.putAtt(NCid,globalID, 'disclaimer',      OPT.disclaimer);

varid = netcdf.defVar(NCid,'crs','int',[]);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,OPT.EPSGcode);
netcdf.reDef(NCid);
netcdf.putAtt(NCid,varid,'coord_ref_sys_name',OPT.EPSGname);
netcdf.putAtt(NCid,varid,'coord_ref_sys_kind',OPT.EPSGtype);
netcdf.putAtt(NCid,varid,'vertical_reference_level',OPT.VertCoordName);
netcdf.putAtt(NCid,varid,'difference_with_msl',OPT.VertCoordLevel);

% specify dimensions (time dimension is set to unlimited)
netcdf.defDim(NCid,          'zoomlevels',   length(dxk));

for k=1:length(dxk)
    netcdf.defDim(NCid,      ['nravailable' num2str(k)],   length(iavailable{k}));
end

%% *** add variables ***
% add variable: coordinate system reference (this variable contains all projection information, e.g. for use in ArcGIS)
% crsVariable = struct(...
%     'Name', 'crs', ...
%     'Nctype', 'int', ...
%     'Dimension', {{}}, ...
%     'Attribute', struct( ...
%     'Name', ...
%     {'spatial_ref'}, ...
%     'Value', ...
%     '' ...
% %     ) ...
% %     );
% crsVariable=' '
% netcdf_addvar(NCid, crsVariable);

nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'grid_size_x'},  'cf_standard_name', {'grid_size_x'},'dimension',{'zoomlevels'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'grid_size_y'},  'cf_standard_name', {'grid_size_y'},'dimension',{'zoomlevels'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'x0'},  'cf_standard_name', {'x0'},'dimension',{'zoomlevels'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'y0'},  'cf_standard_name', {'y0'},'dimension',{'zoomlevels'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'nx'},  'cf_standard_name', {'nx'},'dimension',{'zoomlevels'},'tp','int');
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ny'},  'cf_standard_name', {'ny'},'dimension',{'zoomlevels'},'tp','int');
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ntilesx'},  'cf_standard_name', {'ntilesx'},'dimension',{'zoomlevels'},'tp','int');
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ntilesy'},  'cf_standard_name', {'ntilesy'},'dimension',{'zoomlevels'},'tp','int');

for k=1:length(dxk)
    nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {['iavailable' num2str(k)]},  'cf_standard_name', {['iavailable' num2str(k)]},'dimension',{['nravailable' num2str(k)]},'tp','int');
    nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {['javailable' num2str(k)]},  'cf_standard_name', {['javailable' num2str(k)]},'dimension',{['nravailable' num2str(k)]},'tp','int');
end

%% Expand NC file

netcdf.endDef(NCid)

%% add data

varid = netcdf.inqVarID(NCid,'grid_size_x');
netcdf.putVar(NCid,varid,dxk);
varid = netcdf.inqVarID(NCid,'grid_size_y');
netcdf.putVar(NCid,varid,dyk);
varid = netcdf.inqVarID(NCid,'x0');
netcdf.putVar(NCid,varid,x0);
varid = netcdf.inqVarID(NCid,'y0');
netcdf.putVar(NCid,varid,y0);
varid = netcdf.inqVarID(NCid,'nx');
netcdf.putVar(NCid,varid,nx);
varid = netcdf.inqVarID(NCid,'ny');
netcdf.putVar(NCid,varid,ny);
varid = netcdf.inqVarID(NCid,'ntilesx');
netcdf.putVar(NCid,varid,nnxk);
varid = netcdf.inqVarID(NCid,'ntilesy');
netcdf.putVar(NCid,varid,nnyk);
for k=1:length(dxk)
    varid = netcdf.inqVarID(NCid,['iavailable' num2str(k)]);
    netcdf.putVar(NCid,varid,iavailable{k});
    varid = netcdf.inqVarID(NCid,['javailable' num2str(k)]);
    netcdf.putVar(NCid,varid,javailable{k});
end

%% close NC file

netcdf.close(NCid)
