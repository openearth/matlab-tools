function nc_multibeam_createNCfile(OPT,EPSG,ncfile,X,Y)
%nc_multibeam_createNCfile
%
%See also: nc_multibeam, snctools

%% *** create empty outputfile
% indicate NetCDF outputfile name and create empty structure
if ~exist(OPT.netcdf_path,'dir')
    mkdir(OPT.netcdf_path)
end

mode     = netcdf.getConstant('NETCDF4');
mode     = bitor(mode,netcdf.getConstant('NOCLOBBER'));
NCid     = netcdf.create(ncfile,mode);
globalID = netcdf.getConstant('NC_GLOBAL');
dimSizeX = (OPT.mapsizex/OPT.gridsizex);
dimSizeY = (OPT.mapsizey/OPT.gridsizey);


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

% specify dimensions (time dimension is set to unlimited)
netcdf.defDim(NCid,          'time',        netcdf.getConstant('NC_UNLIMITED'));
netcdf.defDim(NCid,          'y',           dimSizeY);
netcdf.defDim(NCid,          'x',           dimSizeX);

%% *** add variables ***
try
    epsg_wkt_str = epsg_wkt(OPT.EPSGcode);
catch
    epsg_wkt_str = 'epsg_wkt could not be retreived';
end
x  = unique(X);
dx = abs(unique(diff(x)));
if length(dx) == 1
    actual_range_x = {'actual_range';[min(x)-.5*dx max(x)+.5*dx]};
else
    actual_range_x = {[]};
end

y  = unique(Y);
dy = abs(unique(diff(y)));
if length(dy) == 1
    actual_range_y = {'actual_range';[min(y)-.5*dy max(y)+.5*dy]};
else
    actual_range_y = {[]};
end




% add variable: coordinate system reference (this variable contains all projection information, e.g. for use in ArcGIS)
crsVariable = struct(...
    'Name', 'crs', ...
    'Nctype', 'int', ...
    'Dimension', {{}}, ...
    'Attribute', struct( ...
    'Name', ...
    {'spatial_ref'}, ...
    'Value', ...
    {epsg_wkt_str} ...
    ) ...
    );
netcdf_addvar(NCid, crsVariable);

nc_oe_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'time'}, 'oe_standard_name', {'time'},                    'dimension', {'time'},      'timezone', '+01:00');
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lon'},  'cf_standard_name', {'longitude'},               'dimension', {'x','y'}, 'deflate',1);
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lat'},  'cf_standard_name', {'latitude'},                'dimension', {'x','y'}, 'deflate',1);
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'x'},    'cf_standard_name', {'projection_x_coordinate'}, 'dimension', {'x'},'additionalAtts',actual_range_x);
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'y'},    'cf_standard_name', {'projection_y_coordinate'}, 'dimension', {'y'},'additionalAtts',actual_range_y);
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'z'},    'cf_standard_name', {'altitude'},                'dimension', {'x','y','time'}, 'deflate',1);%



%% Expand NC file

netcdf.endDef(NCid)

%% add data

[lon,lat] = convertCoordinates(X,Y,EPSG,'CS1.code',OPT.EPSGcode,'CS2.code',4326);

varid = netcdf.inqVarID(NCid,'y'  );netcdf.putVar(NCid,varid,Y(:,1));
varid = netcdf.inqVarID(NCid,'x'  );netcdf.putVar(NCid,varid,X(1,:));
varid = netcdf.inqVarID(NCid,'lat');netcdf.putVar(NCid,varid,lat');
varid = netcdf.inqVarID(NCid,'lon');netcdf.putVar(NCid,varid,lon');

%% close NC file

netcdf.close(NCid)
end