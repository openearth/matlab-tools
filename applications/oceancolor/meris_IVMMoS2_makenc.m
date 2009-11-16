%MERIS_IVMMoS2_makenc  rewrite processed MERIS file as defined by IVMMoS2 into NetCDF files
%
%
%See also: MERIS_MASK, MERIS_FLAGS, MERIS_NAME2META,MERIS_IVMMoS2_LOAD

% TO DO: check units, 
% TO DO: check definition of standard error
% TO DO:check display of originator info & use rights (cf Creative Commons & GNU licensing)
% TO DO add flags description next to names
% TO DO arrays as attributes
% TO DO check CF feature type
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 August IVM-VU
%       N.O.de Reus
%
%       nils.de.reus@ivm.vu.nl	
%
%       Institute for Environmental Studies
%       De Boelelaan 1085/1087
%       1081 HV Amsterdam
%       The Netherlands
%
%   This work is derived from meris_WaterInsight2nc V0.3.
%   All conditions apply as detailed in the original copyright below:
%
%   Copyright (C) 2009 July Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Initialize

   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   OPT.dump           = 0;
   OPT.pause          = 0;
   OPT.debug          = 0;
   OPT.zip            = 0; % this remains unused?
   
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention

%% File loop

%
%   Hardcoding paths is absolutely hideous, but since everyone was using their own path aliases and shortcuts to
%   the data, there was just no guarantee that the correct path could be constructed from the input argument.
%
    OPT.directory.raw  = [pwd,filesep,'mat'];
%   OPT.directory.raw  = 'E:\Remote Sensing\PROJECTS\Active\MoS2\Oplevering\codeandresults\intermediate';
    OPT.directory.nc   = [pwd,filesep,'nc'];
%   OPT.directory.nc   = 'E:\Remote Sensing\PROJECTS\Active\MoS2\Oplevering\RepoMoS2\trunk\meris';
   
   mkpath(OPT.directory.nc)

   OPT.files          = dir([OPT.directory.raw filesep 'MER*.mat']);
   
   [IMAGE_names,extensions] = meris_directory(OPT.directory.raw);

   for ifile=1:length(IMAGE_names)  
   
      OPT.filename = ([OPT.directory.raw, filesep, IMAGE_names{ifile}]); % MER_RR__2CNACR20090502_102643_000022462078_00366_37494_0000*.mat
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(IMAGE_names)),': ',filename(OPT.filename)])

%% 0 Read raw data

      D = meris_IVMMoS2_load(OPT.filename);
      D.version = 'V0.3-2 DeReus-Blaas';
      
      if OPT.debug
      pcolorcorcen(D.lon,D.lat,D.l2_flags)
      end

%% 1a Create file
   
      OPT.ext = '';

      outputfile    = [OPT.directory.nc,filesep,D.basename,OPT.ext,'.nc']; % 30 (ISO 8601) 'yyyymmddTHHMMSS' name
   
      nc_create_empty (outputfile)
   
%% CF attributes

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
      nc_attput(outputfile, nc_global, 'title'           , 'MERIS Reduced Resolution data');
      nc_attput(outputfile, nc_global, 'institution'     , 'IVM');
      nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
      nc_attput(outputfile, nc_global, 'history'         ,['Original filename: ',filename(OPT.filename),...
                                                           ', version:' ,D.version,... 
                                                           ', tranformation to NetCDF: $HeadURL: $']);
      nc_attput(outputfile, nc_global, 'references'      , 'http://www.vu.nl/ivm');
      nc_attput(outputfile, nc_global, 'email'           , 'marieke.eleveld@ivm.vu.nl');
   
      nc_attput(outputfile, nc_global, 'comment'         , '');
      nc_attput(outputfile, nc_global, 'version'         , D.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType'  , ''); % grid
   
      nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: WaterInsight.');
      nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
      
%% MERIS specific attributes
      
      nc_attput(outputfile, nc_global, 'sensor'               ,D.sensor); % 'Meris'
      nc_attput(outputfile, nc_global, 'product'              ,D.product);
      nc_attput(outputfile, nc_global, 'product_level'        ,D.product_level); % 'L2'
      nc_attput(outputfile, nc_global, 'parent_child'         ,D.parent_child);
      nc_attput(outputfile, nc_global, 'processing_stage_flag',D.processing_stage_flag);
      nc_attput(outputfile, nc_global, 'center'               ,D.center);
      nc_attput(outputfile, nc_global, 'timezone'             ,D.timezone);
      nc_attput(outputfile, nc_global, 'start_day'            ,D.start_day);
      nc_attput(outputfile, nc_global, 'start_time'           ,D.start_time);
      nc_attput(outputfile, nc_global, 'duration_in_seconds'  ,D.duration_in_seconds);
      nc_attput(outputfile, nc_global, 'datenum'              ,D.datenum); % array !
      nc_attput(outputfile, nc_global, 'mission_phase'        ,D.mission_phase);
      nc_attput(outputfile, nc_global, 'cycle_number'         ,D.cycle_number);
      nc_attput(outputfile, nc_global, 'relative_orbit_number',D.relative_orbit_number);
      nc_attput(outputfile, nc_global, 'absolute_orbit_number',D.absolute_orbit_number);
      nc_attput(outputfile, nc_global, 'counter'              ,D.counter);
      nc_attput(outputfile, nc_global, 'coordinate_system'    ,D.coordinate_system);
      nc_attput(outputfile, nc_global, 'coordinate_units'     ,D.coordinate_units);
      nc_attput(outputfile, nc_global, 'geoid'                ,D.geoid);
   
%% 2 Create dimensions
   
      nc_add_dimension(outputfile, 'dim1'         , size(D.l2_flags,1)); 
      nc_add_dimension(outputfile, 'dim2'         , size(D.l2_flags,2)); 
      nc_add_dimension(outputfile, 'time'         , 1);  
      nc_add_dimension(outputfile, 'band'         , size(D.Kd,3));  
      nc_add_dimension(outputfile, 'L2_flags_bits', length(D.flags.bit));
      nc_add_dimension(outputfile, 'strlen1'      , size(char(D.flags.name),2));

%% 3 Create variables
   
      clear nc
      ifld = 0;
      
      %% Meta data
      %------------------
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'meta';
      nc(ifld).Nctype       = 'char';
     %nc(ifld).Dimension    = {''}; % no dimension, dummy variable
      nc(ifld).Attribute(1) = struct('Name', 'T'          ,'Value', num2str([0 1 1 1]));  % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(2) = struct('Name', 'Ci'         ,'Value', num2str([1 5 5 0.3000])); % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(3) = struct('Name', 'b'          ,'Value', num2str([1 2 3 4 5 6 7 9]));  % HMM, ATRRIBUTES CANNOT BE ARRAYS
      nc(ifld).Attribute(4) = struct('Name', 'Fdiff'      ,'Value', 0.4000);
      nc(ifld).Attribute(5) = struct('Name', 'method'     ,'Value', 1);
      nc(ifld).Attribute(6) = struct('Name', 'errormodel' ,'Value', 0);
      nc(ifld).Attribute(7) = struct('Name', 'maxIter'    ,'Value', 100);
      nc(ifld).Attribute(8) = struct('Name', 'SIOP'       ,'Value', 'NEWSIOP2006_5_ASnHGnPCD113yBIy'); % ME NEWSIOP2006_5_ASnHGnPCD113yBIy
      nc(ifld).Attribute(9) = struct('Name', 'fname'      ,'Value', 'C:\Bio-Opti\AAN\LUT16.dat');

      %% Coordinate system
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
      %------------------
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'crs';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {}; % no dimension, dummy variable
      nc(ifld).Attribute(1) = struct('Name', 'grid_mapping_name'          ,'Value', 'latitude_longitude');
      nc(ifld).Attribute(2) = struct('Name', 'longitude_of_prime_meridian','Value', D.longitude_of_prime_meridian);
      nc(ifld).Attribute(3) = struct('Name', 'semi_major_axis'            ,'Value', D.semi_major_axis            );
      nc(ifld).Attribute(4) = struct('Name', 'inverse_flattening'         ,'Value', D.inverse_flattening         );
     %nc(ifld).Attribute(5) = struct('Name', 'comment'                    ,'Value', 'Value is EPSG code');

      %% Longitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      %------------------
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'longitude';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'           ,'Value', 'longitude');

      %% Latitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      %------------------
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'latitude';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'          ,'Value', 'latitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'              ,'Value', 'degrees_north');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'      ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'axis'               ,'Value', 'latitude');

      %% Time
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
      % time is a dimension, so there are two options:
      % * the variable name needs the same as the dimension
      %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
      % * there needs to be an indirect mapping through the coordinates attribute
      %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
      %------------------
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'time';
      nc(ifld).Nctype       = 'double';                        % !!!! % float not sufficient as datenums are big: double
      nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
      nc(ifld).Attribute(1) = struct('Name', 'long_name'          ,'Value', 'time');
      nc(ifld).Attribute(2) = struct('Name', 'units'              ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',D.timezone]);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'      ,'Value', 'time');
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'         ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'axis'               ,'Value', 'time');

      %% Parameters with standard names
      % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
      %------------------
   
      %% Define dimensions in this order:
      %  time,z,y,x

        ifld = ifld + 1;
      nc(ifld).Name         = 'spectral_bands'; 
      nc(ifld).Nctype       = 'double';
      nc(ifld).Dimension    = {'band'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wavelength');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'nm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'radiation_wavelength'); % standard name
      
%        ifld = ifld + 1;
%      nc(ifld).Name         = 'Chla';
%      nc(ifld).Nctype       = 'float';
%      nc(ifld).Dimension    = {'dim1','dim2'};
%      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'chlorophyll-a');
%      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'mg m-3'); % ASSUMED, NOT IN MAT FILES
%      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'concentration_of_chlorophyll_in_sea_water'); % standard name
%      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
%      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
%      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units undocumented, asssumed');
  
%        ifld = ifld + 1;
%      nc(ifld).Name         = 'Chla_std_err';
%      nc(ifld).Nctype       = 'float';
%      nc(ifld).Dimension    = {'dim1','dim2'};
%      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'chlorophyll-a standard error');
%      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'mg m-3'); % ASSUMED, NOT IN MAT FILES
%      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_concentration_of_chlorophyll_in_sea_water'); % quasi standard name
%      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
%      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
%      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units undocumented, asssumed');
%       nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'TSM';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'suspended particulate matter');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); 
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'concentration_of_suspended_matter_in_sea_water'); % standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units empirically confirmed');

        ifld = ifld + 1;
      nc(ifld).Name         = 'TSM_std_err';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'suspended particulate matter standard error');% check: ASSUMED, NOT IN MAT FILES: standard error? 
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); 
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_concentration_of_suspended_matter_in_sea_water'); % quasi standard name
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units empirically confirmed');
%       nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
 
%              ifld = ifld + 1;
%      nc(ifld).Name         = 'CDOM';
%      nc(ifld).Nctype       = 'float';
%      nc(ifld).Dimension    = {'dim1','dim2'};
%      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'colored dissolved organic matter');
%      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); % ASSUMED, NOT IN MAT FILES
%      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'concentration_of_dissolved_organic_matter_in_sea_water'); % quasi standard name
%      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
%      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
%      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units undocumented, asssumed');

%        ifld = ifld + 1;
%      nc(ifld).Name         = 'CDOM_std_err';
%      nc(ifld).Nctype       = 'float';
%      nc(ifld).Dimension    = {'dim1','dim2'};
%      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'colored dissolved organic matter standard error');% check: ASSUMED, NOT IN MAT FILES: standard error? 
%      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'g m-3'); % ASSUMED, NOT IN MAT FILES
%      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'standard_error_of_concentration_of_suspended_matter_in_sea_water'); % quasi standard name
%      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
%      nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
%      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'units undocumented, asssumed');
%      nc(ifld).Attribute(7) = struct('Name', 'cell_methods'   ,'Value', 'area: standard_deviation'); % STD in space, time, or none? NOT IN MAT FILES
  
        ifld = ifld + 1;
      nc(ifld).Name         = 'Kd';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'dim1','dim2','band'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'spectral extinction coefficient');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm-1'); % units empirically confirmed
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'volume_attenuation_coefficient_of_downwelling_radiative_flux_in_sea_water_per_radiation_wavelength'); % standard name
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags';
      nc(ifld).Nctype       = 'double';                       % !!!!
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '24 bit bytestring'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', 'Refer to ESA flag codings'); 
      nc(ifld).Attribute(5) = struct('Name', 'comment'        ,'Value', 'example bit numbers (=string index-1)'); 
      nc(ifld).Attribute(6) = struct('Name', 'comment'        ,'Value', 'refer to: '); 
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags_name';
      nc(ifld).Nctype       = 'char';                       % !!!!
      nc(ifld).Dimension    = {'L2_flags_bits','strlen1'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags names');
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'L2_flags_bits';
      nc(ifld).Nctype       = 'int';                       % !!!!
      nc(ifld).Dimension    = {'L2_flags_bits'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'MERIS Level 2 flags bits');      
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'chisq';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Chi^2');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'none'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'P';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'dim1','dim2'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'cumulative probability of Chi^2');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'none'); 
      nc(ifld).Attribute(3) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude time');
      


%% 4 Create variables with attributes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info. So there is no 
% need to use NC_PADHEADER.
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill variables
   
      nc_varput(outputfile, 'crs'          , D.epsg);

      % double
      nc_varput(outputfile, 'longitude'    , double(D.lon));
      nc_varput(outputfile, 'latitude'     , double(D.lat));
      nc_varput(outputfile, 'L2_flags'     , (D.l2_flags));
      nc_varput(outputfile, 'L2_flags_name', char(D.flags.name));
      nc_varput(outputfile, 'L2_flags_bits', D.flags.bit);

      % single
      nc_varput(outputfile, 'spectral_bands'        ,  D.bands.wavelength);
      nc_varput(outputfile, 'time'         ,  D.datenum(1) - OPT.refdatenum);
%     nc_varput(outputfile, 'Chla'         , (D.c (:,:,2)));
%     nc_varput(outputfile, 'Chla_std_err' , (D.dc(:,:,2)));
      nc_varput(outputfile, 'TSM'          ,  D.cTSM);
      nc_varput(outputfile, 'TSM_std_err'  ,  D.dcTSM);
%     nc_varput(outputfile, 'CDOM'         , (D.c (:,:,4)));
%     nc_varput(outputfile, 'CDOM_std_err' , (D.dc(:,:,4)));
      nc_varput(outputfile, 'Kd'           , (D.Kd));
      nc_varput(outputfile, 'chisq'        , (D.chisq));
      nc_varput(outputfile, 'P'            , (D.P));
      
%% 6 Check
   
      if OPT.dump
      nc_dump(outputfile);
      end
      
%% Pause
   
      if OPT.pause
         pausedisp
      end
      
   end %for ifile=1:length(IMAGE_names)  

%% EOF
