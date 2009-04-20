%KNMI_NOAAPC2NC  rewrite binary KNMI NOAA POES SST data files (NOAAPC format) into NetCDF files
%
%  Grid data definition, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
%
%  The KNMI set contains data from the POES satellites 10 to 18: 
%  <a href="www.knmi.nl">www.knmi.nl</a>
%  <a href="http://www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html">www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html</a>
%
%See also: KNMI_NOAAPC_READ

% TO DO: find out polar_stereographic parameters to EPSG
% TO DO: save data with scale_factor and add_offset to UINT8 to sace space
% TO DO: add composite info (to cell_methods)

% function knmi_noaapc2nc(...)

%% Initialize
%------------------

   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   OPT.dump           = 0;
   OPT.pause          = 0;
   OPT.debug          = 0;
   OPT.pack           = 1;
   OPT.ll             = 0;
   
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention

%% File loop
%------------------

   OPT.directory.raw  = ['D:\_GERBEN\KNMI\1990_mom\5\'];
   OPT.directory.raw  = ['E:\KNMI\mom\1990_mom\5\'];
   OPT.directory.nc   = [pwd];
   
   mkpath(OPT.directory.nc)

   OPT.files          = dir([OPT.directory.raw filesep 'K030590M.SST']);

   for ifile=1:length(OPT.files)  
   
      OPT.filename = ([OPT.directory.raw, filesep, OPT.files(ifile).name]); % id1-AMRGBVN-196101010000-200801010000.txt
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

   %% 0 Read raw data
   %------------------

      D = KNMI_noaapc_read(OPT.filename,'center',1,'landmask',nan,'cloudmask',-Inf,'count',OPT.pack); % make sure to set valid_min to prevent -Inf from corrupting color scale in ncBrowse.
      D.version = '';

      if OPT.debug
      pcolorcorcen(D.loncor,D.latcor,D.data)
      end

   %% 1a Create file
   %------------------
   
      outputfile    = [OPT.directory.nc filesep  filename(OPT.filename),'_sst_pack',num2str(OPT.pack),'.nc'];
   
      nc_create_empty (outputfile)
   
      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
      nc_attput(outputfile, nc_global, 'title'           , '');
      nc_attput(outputfile, nc_global, 'institution'     , 'KNMI');
      nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
      nc_attput(outputfile, nc_global, 'history'         ,['Original filename: ',filename(OPT.filename),...
                                                           ', version:' ,D.version,...
                                                           ', filedate:',OPT.files(ifile).date,...
                                                           ', tranformation to NetCDF: $HeadURL$ $Date$ $Author$']);
      nc_attput(outputfile, nc_global, 'references'      , '<www.knmi.nl>,<www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html>,<http://dx.doi.org/10.1016/j.csr.2007.06.011>,<http://openearth.deltares.nl>');
      nc_attput(outputfile, nc_global, 'email'           , '<Hans.Roozekrans@knmi.nl>');
   
      nc_attput(outputfile, nc_global, 'comment'         , '');
      nc_attput(outputfile, nc_global, 'version'         , D.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType'  , '');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
      nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
      
      nc_attput(outputfile, nc_global, 'satnum'          , D.satnum);
      nc_attput(outputfile, nc_global, 'orbnum'          , D.orbnum);
      nc_attput(outputfile, nc_global, 'type'            , D.type);
      nc_attput(outputfile, nc_global, 'yearday'         , D.yearday);
   
   %% 2 Create dimensions
   %------------------
   
      nc_add_dimension(outputfile, 'time' , 1)
      nc_add_dimension(outputfile, 'x_cen', D.nx)
      nc_add_dimension(outputfile, 'y_cen', D.ny)

   %% 3 Create variables
   %------------------
   
      clear nc
      ifld = 0;
   
      %% Coordinate system
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
      %------------------
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'polar_stereographic';
      nc(ifld).Nctype       = 'char';
     %nc(ifld).Dimension    = {'x_cen'}; % no dumension, dummy variable
      nc(ifld).Attribute(1) = struct('Name', 'grid_mapping_name','Value', 'polar_stereographic');

      nc(ifld).Attribute(2) = struct('Name', 'straight_vertical_longitude_from_pole','Value', 0);
      nc(ifld).Attribute(3) = struct('Name', 'latitude_of_projection_origin'        ,'Value', '+90'); % Either +90. or -90.
      nc(ifld).Attribute(4) = struct('Name', 'scale_factor_at_projection_origin'    ,'Value', D.scale_in_m);
    %%nc(ifld).Attribute(4) = struct('Name', 'standard_parallel'                    ,'Value', '');
     %nc(ifld).Attribute(5) = struct('Name', 'false_easting'                        ,'Value', '');
     %nc(ifld).Attribute(6) = struct('Name', 'false_northing'                       ,'Value', '');
      
     %D.lon0
     %D.lat0
     %D.resolution_km_p_pix

      %% Local Cartesian coordinates
      %------------------

        ifld = ifld + 1;
      nc(ifld).Name         = 'x_cen';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'x_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel centers');
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'y_cen';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'y_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel centers');
   
      if OPT.ll
      %% Longitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      %------------------
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'longitude_cen';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'y_cen','x_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
   
      %% Latitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      %------------------
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'latitude_cen';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'y_cen','x_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      end % if OPT.ll

      %% Time
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
      % time is a dimension, so there are two options:
      % * the variable name needs the same as the dimension
      %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
      % * there needs to be an indirect mapping through the coordinates attribute
      %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
      %------------------
      
      OPT.timezone = timezone_code2iso('GMT');
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'time';
      nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
      nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

      %% Parameters with standard names
      % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
      %------------------
   
      %% Define dimensions in this order:
      %  time,z,y,x

        ifld = ifld + 1;
      nc(ifld).Name         = 'SST';
      nc(ifld).Nctype       = 'double';
      nc(ifld).Dimension    = {'x_cen','y_cen','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea surface temperature');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_Celcius');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_surface_skin_temperature'); % standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
      nc(ifld).Attribute(6) = struct('Name', 'grid_mapping'   ,'Value', 'polar_stereographic');

      nc(ifld).Attribute(5) = struct('Name', 'valid_min'      ,'Value', D.data_min_value);
      nc(ifld).Attribute(6) = struct('Name', 'valid_max'      ,'Value', D.data_max_value);
      
      if OPT.pack
      nc(ifld).Nctype       = 'int'; %'byte'; %short
      nc(ifld).Attribute(5) = struct('Name', 'valid_min'      ,'Value', D.count_min_value);
      nc(ifld).Attribute(6) = struct('Name', 'valid_max'      ,'Value', D.count_max_value);
      nc(ifld).Attribute(7) = struct('Name', 'scale_factor'   ,'Value', D.gain);
      nc(ifld).Attribute(8) = struct('Name', 'add_offset'     ,'Value', D.offset);
      end

     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');x
     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');y
     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');time

   %% 4 Create variables with attibutes
   %------------------
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
   %% 5 Fill variables
   %------------------
   
      nc_varput(outputfile, 'x_cen'        , [1:D.nx]);
      nc_varput(outputfile, 'y_cen'        , [1:D.ny]);
      if OPT.ll
      nc_varput(outputfile, 'longitude_cen', D.loncen);
      nc_varput(outputfile, 'latitude_cen' , D.latcen);
      end % if OPT.ll
      nc_varput(outputfile, 'time'         , D.datenum' - OPT.refdatenum);
      if OPT.pack
      nc_datput(outputfile, 'SST'          , int16(flipud(D.count)')); % do not use nc_varput with scale_factor and add_offset
      % uint8 and int8 both becomes nc_byte, 
      % * upper D.count levels ( > 512) are outside n_byte range
      % * unit 8 is read as int8, so [-512 512] instad of [0 1024]
      % * altarnative int16 contains too much space (twice).
      else
      nc_varput(outputfile, 'SST'          , D.data');
      end
      
   %% 6 Check
   %------------------
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
   %% Pause
   %------------------
   
      if OPT.pause
         pausedisp
      end
      
   end %for ifile=1:length(OPT.files)   



