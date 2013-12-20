function simona_getdata_netcdf2CF(ncfile0)
%simona_getdata_netcdf2CF  make netCDF file from SIMONA getdata.exe CF compliant
%
%  simona_getdata_netcdf2CF(ncfile) modified ncfile produces by getdata.exe
%
% This extra functionality is being implemented in getdata, this matlab fucntion
% is used to explore what exactly to implement (ensure complaince with THREDDS and ADAGUC)
% and for future fixes of netCDF files from previous (and current) getdata releases.
%
%See also: netcdf, vs_trim2nc, waqua, 
%  http://www.helpdeskwater.nl/onderwerpen/applicaties-modellen/water_en_ruimte/simona/simona/simona-stekkers/
%  http://apps.helpdeskwater.nl/downloads/extra/simona/release/doc/usedoc/getdata/getdata.pdf

% TODO
% http://wiki.esipfed.org/index.php/Attribute_Convention_for_Data_Discovery_%28ACDD%29

OPT.xy     = 1; % 0 removed coord attribute but does not remove XZETA/YZETA arrays itself
OPT.xybnds = 0; % ADAGUC can work with [x,y] coordinates only by mapping on-the-fly, THREDDS cannot map on-the-fly

OPT.ll     = 1; % required by THREDDS and Panoply
OPT.llbnds = 0; % THREDDS need [lat,lon] matrices to be included


if OPT.xy & OPT.ll
   warning('Panoply cannot handle coords = "lon lat XZETA YZETA"')
end

ncfile  = [filepathstrname(ncfile0),'_xy_',num2str(OPT.xy),num2str(OPT.xybnds),'_ll_',num2str(OPT.ll),num2str(OPT.llbnds),'.nc'];

coords = '';
if OPT.ll
   coords  = [coords ' lon lat'];
end
if OPT.xy
   coords  = [coords ' XZETA YZETA'];
end

copyfile(ncfile0,ncfile);

nc_dump(ncfile);

 nc_attput(ncfile,nc_global,'Conventions','CF-1.6');
 nc_attput(ncfile,nc_global,'coordinate_system','THIS ATTRIBUTE SHOULD BE REPLACED BY NEW VARIABLE "CRS"');
 nc_attput(ncfile,nc_global,'cdm_data_type','Grid');

% make time small caps
 nc_attput(ncfile,'TIME'  ,'standard_name','time');
%nc_attput(ncfile,'TIME'  ,'comment'      ,'make variable name lower case');
 
 nc_attput(ncfile,'SEP'   ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'SEP'   ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix

%nc_attput(ncfile,'UP'    ,'standard_name','eastward_sea_water_velocity');
 nc_attput(ncfile,'UP'    ,'standard_name','sea_water_x_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'UP'    ,'long_name'    ,'velocity, x-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'UP'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'UP'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute

%nc_attput(ncfile,'VP'    ,'standard_name','northward_sea_water_velocity');
 nc_attput(ncfile,'VP'    ,'standard_name','sea_water_y_velocity'); % change: legal standard_name, different when grid is in spherical coordinates
 nc_attput(ncfile,'VP'    ,'long_name'    ,'velocity, y-component'); % change: QuickPlot requires this in order to show vectors
 nc_attput(ncfile,'VP'    ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'VP'    ,'grid_mapping' ,'CRS'); % add grid_mapping attribute

 nc_attput(ncfile,'H'     ,'standard_name','sea_floor_depth_below_sea_level'); % change
 nc_attput(ncfile,'H'     ,'coordinates'  ,'XDEP YDEP'); % connect CORNER (x,y) to CORNER matrix (is H at corners???)
 nc_attput(ncfile,'H'     ,'grid_mapping' ,'CRS'); % add grid_mapping attribute

 nc_attput(ncfile,'XZETA' ,'long_name'    ,'x coordinate Arakawa-C centers'); % change: make different than XDEP
 nc_attput(ncfile,'XZETA' ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'XZETA' ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 if OPT.xybnds
 nc_attput(ncfile,'XZETA' ,'bounds'       ,'XZETA_bnds'); % bounds:XDEP add bounds attribute once XDEP is 3D [4 x n x m]'); % add bounds attribute once XDEP is 3D [4 x n x m]
 end

 nc_attput(ncfile,'YZETA' ,'long_name'    ,'y coordinate Arakawa-C centers'); % change: make different than YDEP
 nc_attput(ncfile,'YZETA' ,'coordinates'  ,coords); % connect CENTER (x,y) to CENTER matrix
 nc_attput(ncfile,'YZETA' ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 if OPT.xybnds
 nc_attput(ncfile,'YZETA' ,'bounds'       ,'YZETA_bnds'); % bounds:YDEP add bounds attribute once YDEP is 3D [4 x n x m]'); % add bounds attribute once YDEP is 3D [4 x n x m]
 end
 
 nc_attput(ncfile,'XDEP'  ,'long_name'    ,'x coordinate Arakawa-C corners'); % change: make different than XZETA
 nc_attput(ncfile,'XDEP'  ,'standard_name','projection_x_coordinate');        % change: make identical as XZETA
 nc_attput(ncfile,'XDEP'  ,'coordinates'  ,'YDEP XDEP'); % connect CORNER (x,y) to CORNER matrix
 nc_attput(ncfile,'XDEP'  ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'XDEP'  ,'comment'      ,'XDEP and XZETA can''t be same size: document or remove dummy rows/columns');

 nc_attput(ncfile,'YDEP'  ,'long_name'    ,'y coordinate Arakawa-C corners'); % change: make different than YZETA
 nc_attput(ncfile,'YDEP'  ,'standard_name','projection_y_coordinate');        % change: make identical as XZETA
 nc_attput(ncfile,'YDEP'  ,'coordinates'  ,'YDEP XDEP'); % connect CORNER (x,y) to CORNER matrix
 nc_attput(ncfile,'YDEP'  ,'grid_mapping' ,'CRS'); % add grid_mapping attribute
 nc_attput(ncfile,'YDEP'  ,'comment'      ,'XDEP and XZETA can''t be same size: document or remove dummy rows/columns');
 
 attr = nc_cf_grid_mapping(28992);
 attr(end).Value = 'these values differ per coordinate system, for SIMONA this is mostly one of 3 flavours: Amersfoort/RD or UTM31/ED50 or LATLON/WGS84/ETRS89';
 nc  = struct('Name','CRS', ...
                     'Datatype'   , 'int32', ...
                     'Dimension' , [], ...
                     'Attribute' , attr,...
                     'FillValue'  , []); % this doesn't do anything
 nc_addvar(ncfile,nc); clear attr;% ADD
 
 G.XZETA = nc_varget(ncfile,'XZETA');
 G.YZETA = nc_varget(ncfile,'YZETA');
 [G.lon,G.lat] = convertCoordinates(G.XZETA,G.YZETA,'CS1.code',28992,'CS2.code',4326);
 
 %% lat, lon
 if OPT.ll
     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','latitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_north');
     attr(5) = struct('Name','long_name'    ,'Value','latitude');
     attr(6) = struct('Name','coordinates'  ,'Value',coords); % connect CENTER (x,y) to CENTER matrix
     if (OPT.ll & OPT.llbnds)
     attr(7) = struct('Name','bounds'       ,'Value','lat_bnds');
     end
     nc  = struct('Name','lat', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lat',G.lat); % ADD 

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','longitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_east');
     attr(5) = struct('Name','long_name'    ,'Value','longitude');
     attr(6) = struct('Name','coordinates'  ,'Value',coords); % connect CENTER (x,y) to CENTER matrix     
     if (OPT.ll & OPT.llbnds)
     attr(7) = struct('Name','bounds'       ,'Value','lon_bnds');
     end
     nc  = struct('Name','lon', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lon',G.lon); % ADD 
 end
 %%
 if (OPT.xy & OPT.xybnds) | (OPT.ll & OPT.llbnds)
    nc_adddim(ncfile,'bounds',4)
 end

 %% (lat,lon) bounds
 if (OPT.ll & OPT.llbnds)
     G.lon_bnds = nc_cf_cor2bounds(G.lon);
     G.lat_bnds = nc_cf_cor2bounds(G.lat);

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','latitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_north');
     attr(5) = struct('Name','long_name'    ,'Value','latitude corners');
     nc  = struct('Name','lon_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lon_bnds',G.lon_bnds); % ADD 

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','longitude');
     attr(4) = struct('Name','units'        ,'Value','degrees_east');
     attr(5) = struct('Name','long_name'    ,'Value','longitude corners');
     nc  = struct('Name','lat_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'lat_bnds',G.lat_bnds); % ADD 
 end
 %% (x,y) bounds
 if (OPT.xy & OPT.xybnds)
     G.XZETA_bnds = nc_cf_cor2bounds(G.XZETA);
     G.YZETA_bnds = nc_cf_cor2bounds(G.YZETA);

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','projection_x_coordinate');
     attr(4) = struct('Name','units'        ,'Value','m');
     attr(5) = struct('Name','long_name'    ,'Value','x corners');     
     nc  = struct('Name','XZETA_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'XZETA_bnds',G.XZETA_bnds); % ADD 

     attr(1) = struct('Name','_FillValue'   ,'Value',9.969209968386869e+36);
     attr(2) = struct('Name','missing_value','Value',9.969209968386869e+36);
     attr(3) = struct('Name','standard_name','Value','projection_y_coordinate');
     attr(4) = struct('Name','units'        ,'Value','m');
     attr(5) = struct('Name','long_name'    ,'Value','y corners'); 
     nc  = struct('Name','YZETA_bnds', ...
                         'Datatype'   , 'float', ...
                         'Dimension' , {{'N','M','bounds'}}, ...
                         'Attribute' , attr,...
                         'FillValue'  , []); % this doesn't do anything
     nc_addvar(ncfile,nc); clear attr;% ADD 
     nc_varput(ncfile,'YZETA_bnds',G.YZETA_bnds); % ADD 
 end
 %%
 nc_dump(ncfile0,[],[filename(ncfile0),'.cdl'])
 nc_dump(ncfile ,[],[filename(ncfile) ,'.cdl'])
 
 fclose all