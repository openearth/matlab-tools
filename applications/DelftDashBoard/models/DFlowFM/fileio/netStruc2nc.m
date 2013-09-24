function netStruc2nc(ncfile,netStruc)

nnodes=length(netStruc.nodeX);
nlinks=length(netStruc.linkType);
nelems=size(netStruc.elemNodes,1);
nbndlinks=length(netStruc.bndLink);

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

grdmapping='wgs84';

% Dimensions
nNetNodeDimId        = netcdf.defDim(NCid,          'nNetNode',           nnodes);
nNetLinkDimId        = netcdf.defDim(NCid,          'nNetLink',           nlinks);
nNetLinkPtsDimId     = netcdf.defDim(NCid,          'nNetLinkPts',        2);
nBndLinkDimId        = netcdf.defDim(NCid,          'nBndLink',           nbndlinks);
nNetElemDimId        = netcdf.defDim(NCid,          'nNetElem',           nelems);
nNetElemMaxNodeDimId = netcdf.defDim(NCid,          'nNetElemMaxNode',    size(netStruc.elemNodes,2));

% Variables
varid = netcdf.defVar(NCid,'wgs84','int',[]);
netcdf.putAtt(NCid,varid,'name','WGS84'); 
netcdf.putAtt(NCid,varid,'epsg',4326); 
netcdf.putAtt(NCid,varid,'grid_mapping_name','latitude_longitude'); 
netcdf.putAtt(NCid,varid,'longitude_of_prime_meridian',0); 
netcdf.putAtt(NCid,varid,'semi_major_axis',6.37814e+006); 
netcdf.putAtt(NCid,varid,'semi_minor_axis',6.35675e+006); 
netcdf.putAtt(NCid,varid,'inverse_flattening',298.257); 
netcdf.putAtt(NCid,varid,'proj4_params',' '); 
netcdf.putAtt(NCid,varid,'EPSG_code','EPGS:4326'); 
netcdf.putAtt(NCid,varid,'projection_name',' '); 
netcdf.putAtt(NCid,varid,'wkt',' '); 
netcdf.putAtt(NCid,varid,'comment',' '); 
netcdf.putAtt(NCid,varid,'value','value is equal to EPSG code'); 
netcdf.endDef(NCid);

% Node x
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_x','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','degrees_east');
netcdf.putAtt(NCid,varid,'standard_name','longitude');
netcdf.putAtt(NCid,varid,'long_name','longitude');
netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
% netcdf.putAtt(NCid,varid,'units','m');
% netcdf.putAtt(NCid,varid,'standard_name','projection_x_coordinate');
% netcdf.putAtt(NCid,varid,'long_name','x-coordinate of net nodes');
% netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.nodeX);

% Node y
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_y','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','degrees_north');
netcdf.putAtt(NCid,varid,'standard_name','latitude');
netcdf.putAtt(NCid,varid,'long_name','latitude');
netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
% netcdf.putAtt(NCid,varid,'units','m');
% netcdf.putAtt(NCid,varid,'standard_name','projection_y_coordinate');
% netcdf.putAtt(NCid,varid,'long_name','y-coordinate of net nodes');
% netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.nodeY);

netStruc.nodeLon=netStruc.nodeX;
netStruc.nodeLat=netStruc.nodeY;

% Node lon
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_lon','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','degrees_east');
netcdf.putAtt(NCid,varid,'standard_name','longitude');
netcdf.putAtt(NCid,varid,'long_name','longitude');
netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.nodeLon);

% Node lat
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_lat','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','degrees_north');
netcdf.putAtt(NCid,varid,'standard_name','latitude');
netcdf.putAtt(NCid,varid,'long_name','latitude');
netcdf.putAtt(NCid,varid,'grid_mapping','wgs84');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.nodeLat);

% Node depth
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetNode_z','double',nNetNodeDimId);
netcdf.putAtt(NCid,varid,'units','m');
netcdf.putAtt(NCid,varid,'positive','up');
netcdf.putAtt(NCid,varid,'standard_name','sea_floor_depth');
netcdf.putAtt(NCid,varid,'long_name','Bottom level at net nodes (flow element''s corners)');
netcdf.putAtt(NCid,varid,'coordinates','NetNode_x NetNode_y');
netcdf.putAtt(NCid,varid,'grid_mapping',grdmapping);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.nodeZ);

% Net link
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetLink','int',[nNetLinkPtsDimId nNetLinkDimId]);
netcdf.putAtt(NCid,varid,'standard_name','netlink');
netcdf.putAtt(NCid,varid,'long_name','link between two netnodes');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.linkNodes');

% Net link type
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetLinkType','int',nNetLinkDimId);
netcdf.putAtt(NCid,varid,'long_name','type of netlink');
netcdf.putAtt(NCid,varid,'valid_range',[0 2]);
netcdf.putAtt(NCid,varid,'flag_values',[0 1 2]);
netcdf.putAtt(NCid,varid,'flag_meanings','closed_link_between_2D_nodes link_between_1D_nodes link_between_2D_nodes');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.linkType);

% Net elem node
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'NetElemNode','int',[nNetElemMaxNodeDimId nNetElemDimId]);
netcdf.putAtt(NCid,varid,'long_name','Mapping from net cell to net nodes.');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.elemNodes');

% Bnd Link
netcdf.reDef(NCid);
varid = netcdf.defVar(NCid,'BndLink','int',nBndLinkDimId);
netcdf.putAtt(NCid,varid,'long_name','Netlinks that compose the net boundary.');
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,netStruc.bndLink);

% Close file
netcdf.close(NCid)
