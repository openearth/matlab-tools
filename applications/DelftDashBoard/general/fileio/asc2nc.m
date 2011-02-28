function asc2nc(ascfile,ncfile,OPT)

fid=fopen(ascfile,'r');

str=fgets(fid);
ncols=str2double(str(6:end));
str=fgets(fid);
nrows=str2double(str(6:end));
str=fgets(fid);
xll=str2double(str(10:end));
str=fgets(fid);
yll=str2double(str(10:end));
str=fgets(fid);
cellsz=str2double(str(9:end));
str=fgets(fid);
noval=str2double(str(13:end));

x=xll:cellsz:xll+(ncols-1)*cellsz;
y=yll:cellsz:yll+(nrows-1)*cellsz;

%% *** create empty outputfile
% indicate NetCDF outputfile name and create empty structure

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

dimSizeX = length(x);
dimSizeY = length(y);
switch lower(OPT.EPSGtype)
    case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
        xstr = 'lon';
        ystr = 'lat';
        standardxstr = 'longitude';
        standardystr = 'latitude';
    case{'xy','proj','projected','projection','cart','cartesian'}
        xstr = 'x';
        ystr = 'y';
        standardxstr = 'projection_x_coordinate';
        standardystr = 'projection_y_coordinate';
end
varstr = 'depth';

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
netcdf.defDim(NCid,          xstr,           dimSizeX);
netcdf.defDim(NCid,          ystr,           dimSizeY);
netcdf.defDim(NCid,          'info',         1);

nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {xstr},  'cf_standard_name', {standardxstr},'dimension', {xstr});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {ystr},  'cf_standard_name', {standardystr}, 'dimension', {ystr});
nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {varstr},  'cf_standard_name', {'depth'},    'dimension', {xstr,ystr},'tp',OPT.tp);

%% Expand NC file
netcdf.endDef(NCid)


varid = netcdf.inqVarID(NCid,xstr);
netcdf.putVar(NCid,varid,x');
varid = netcdf.inqVarID(NCid,ystr);
netcdf.putVar(NCid,varid,y');

varid = netcdf.inqVarID(NCid,'depth');
nn=1000;

for i=1:nrows/nn
    
%    disp([num2str(i) ' of ' num2str(nrows/nn)]);
    
%    tic
    z = textscan(fid,'%f',ncols*nn);
    z = cell2mat(z);
    try
    z=reshape(z,[ncols nn]);
    catch
        kut=1;
    end
    z=z';
    z=flipud(z);
    z(z==noval)=-9999;
    z=int16(z);
%    toc

%    tic    
    netcdf.putVar(NCid,varid,[nrows-nn*i 0],[nn ncols],z);
%    toc
       
end

fclose(fid);

%% close NC file

netcdf.close(NCid)


