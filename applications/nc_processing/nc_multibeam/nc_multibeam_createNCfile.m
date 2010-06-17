function nc_multibeam_createNCfile(OPT,ncfile,X,Y,EPSG)
%% *** create empty outputfile
% OPT.WBmsg{2}  = 'Creating NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
% indicate NetCDF outputfile name and create empty structure
if ~exist(OPT.netcdf_path,'dir')
    mkdir(OPT.netcdf_path)
end
NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');
dimSizeX = (OPT.mapsizex/OPT.gridsize)+1;
dimSizeY = (OPT.mapsizey/OPT.gridsize)+1;


%% add attributes global to the dataset
% OPT.WBmsg{2}  = 'Adding attributes to NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

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
% OPT.WBmsg{2}  = 'Adding variables to NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
% add variable: coordinate system reference (this variable contains all projection information, e.g. for use in ArcGIS)
crsVariable = struct(...
    'Name', 'crs', ...
    'Nctype', 'int', ...
    'Dimension', {{}}, ...
    'Attribute', struct( ...
    'Name', ...
    {'spatial_ref'}, ...
    'Value', ...
    {nc_getEPSGdescription(OPT.EPSGcode)} ...
    ) ...
    );
netcdf_addvar(NCid, crsVariable);

nc_oe_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'time'}, 'oe_standard_name', {'time'},                    'dimension', {'time'},      'timezone', '+01:00');
% nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lon'},  'cf_standard_name', {'longitude'},               'dimension', {'x','y'});
% nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'lat'},  'cf_standard_name', {'latitude'},                'dimension', {'x','y'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'x'},    'cf_standard_name', {'projection_x_coordinate'}, 'dimension', {'x'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'y'},    'cf_standard_name', {'projection_y_coordinate'}, 'dimension', {'y'});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'z'},    'cf_standard_name', {'altitude'},                'dimension', {'x','y','time'});

%% Expand NC file
% OPT.WBmsg{2}  = 'Expanding NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

netcdf.endDef(NCid)

%% add data
% OPT.WBmsg{2}  = 'Adding data to NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

varid = netcdf.inqVarID(NCid,'y');
netcdf.putVar(NCid,varid,Y(:,1));
varid = netcdf.inqVarID(NCid,'x');
netcdf.putVar(NCid,varid,X(1,:));

% [lon,lat] = convertCoordinates(X,Y,EPSG,'CS1.code',OPT.EPSGcode,'CS2.code',4326);
% varid = netcdf.inqVarID(NCid,'lat');
% netcdf.putVar(NCid,varid,lat);
% varid = netcdf.inqVarID(NCid,'lon');
% netcdf.putVar(NCid,varid,lon);

%% close NC file
% OPT.WBmsg{2}  = 'Closing NC File';
% waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

netcdf.close(NCid)
end