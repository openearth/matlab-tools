function ATT = struct2catalog(varargin)
%STRUCT2CATALOG   test for creating catalog.nc of CF complaint netCDF files (BETA)
%
% Extracts  (i) THREDDS meta-data keywords 
%               'title'
%               'institution'
%               'source'
%               'history'
%               'references'
%               'email'
%               'comment'
%               'version'
%               'Conventions'
%               'CF:featureType'
%               'terms_for_use'
%               'disclaimer'
%               'geospatial_lat_min'
%               'geospatial_lat_max'
%               'geospatial_lon_min'
%               'geospatial_lon_max'
%               'geospatial_lat_units'
%               'geospatial_lon_units'
%               'time_coverage_start'
%               'time_coverage_end'
%          (ii) filenames ans all availbale standard_names
%              'filename'
%              'standard_names'
% from all specified netCDF files and stores them into a 
% struct for storage in netCDF file (now still mat file)
%
% currently nc_cf2catalog adhares to:
%
% http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html
%
% but should probably switch to the multui-level keywords which are useful for xml
% but less useful for catalog.nc
%
% http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
%
%See also: STRUCT2NC, NC2STRUCT

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

disp('WARNING: BETA FUNCTION')

%% Java issue
% Note: generates error after about 450 files:
%     java.lang.OutOfMemoryError: Java heap space
%
% Note that that opendap acces does not work then (landboundary)

OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');
setpref ('SNCTOOLS', 'USE_JAVA', 0)

%% which directories to scan

OPT.base           = 'P:\mcdata\opendap\';
OPT.catalog_length = 1750 + 205; % rijkswaterstaat + KNMI
OPT.char_length    = 1;

OPT.directories    = {'rijkswaterstaat\waterbase\concentration_of_chlorophyll_in_sea_water',...
                      'rijkswaterstaat\waterbase\concentration_of_suspended_matter_in_sea_water',...
                      'rijkswaterstaat\waterbase\sea_surface_salinity',...
                      'rijkswaterstaat\waterbase\sea_surface_temperature',...
                      'rijkswaterstaat\waterbase\sea_surface_wave_from_direction',...
                      'rijkswaterstaat\waterbase\sea_surface_wave_significant_height',...
                      'rijkswaterstaat\waterbase\sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
                      'knmi\etmgeg',...
                      'knmi\potwind',...
                      'knmi\NOAA\mom\1990_mom\5\'};

OPT.mask           = '*.nc';      
OPT.pause          = 0;

%% what information (global attributes) to extract

OPT.attname        = {'title',...
                      'institution',...
                      'source',...
                      'history',...
                      'references',...
                      'email',...
                      'comment',...
                      'version',...
                      'Conventions',...
                      'CF:featureType',...
                      'terms_for_use',...
                      'disclaimer',...
                      'geospatial_lat_min',...
                      'geospatial_lat_max',...
                      'geospatial_lon_min',...
                      'geospatial_lon_max',...
                      'geospatial_lat_units',...
                      'geospatial_lon_units',...
                      'time_coverage_start',...
                      'time_coverage_end',...
                      'filename',...     % separate
                      'standard_names'};  % separate

OPT.atttype        = [ 0   % 'title',...
                       0   % 'institution',...
                       0   % 'source',...
                       0   % 'history',...
                       0   % 'references',...
                       0   % 'email',...
                       0   % 'comment',...
                       0   % 'version',...
                       0   % 'Conventions',...
                       0   % 'CF:featureType',...
                       0   % 'terms_for_use',...
                       0   % 'disclaimer',...
                       1   % 'geospatial_lat_min',...
                       1   % 'geospatial_lat_max',...
                       1   % 'geospatial_lon_min',...
                       1   % 'geospatial_lon_max',...
                       1   % 'geospatial_lat_units',...
                       1   % 'geospatial_lon_units',...
                       0   % 'time_coverage_start',...
                       0   % 'time_coverage_end',...
                       0   % 'filename',...      % separate
                       0 ];% 'standard_names'};  % separate
                      
%% pre-allocate

   for ifld=1:length(OPT.attname)
   
     fldname = mkvar(OPT.attname{ifld});
   
     if OPT.atttype(ifld)==1
     ATT.(fldname) = nan(OPT.catalog_length,1);
     else
     ATT.(fldname) = repmat(' ',[OPT.catalog_length,OPT.char_length]);
     end
   
   end

%TO DO standard_name_vocabulary
%TO DO cdm_data_type Attribute "Grid", "Image", "Station", "Trajectory", "Radial". Its use is recommended.       

%% Directory loop

entry = 0;

% PRE ALLOCATE

for idir=1:length(OPT.directories)

   OPT.directory = [OPT.base,filesep,OPT.directories{idir}];

   disp(['Processing   ',num2str(idir,'%0.4d'),'/',num2str(length(OPT.directories),'%0.4d'),': ',OPT.directory,filesep]);

%% File loop to get meta-data

   OPT.files        = dir([OPT.directory,filesep,OPT.mask]);

   for ifile=1:length(OPT.files)
   
   entry = entry + 1;
   
      OPT.filename = [OPT.directory, filesep, OPT.files(ifile).name];
   
      disp(['  Processing ',num2str(ifile,'%0.4d'),'/',num2str(length(OPT.files),'%0.4d'),': ',filename(OPT.filename)]);

%% Get global attributes (PRE-ALLOCATE)

      ATT.filename(entry,1:length(OPT.filename)) = OPT.filename;

   %% get relevant attributes

      for iatt = 1:length(OPT.attname)
      
         attname = OPT.attname{iatt};
         fldname = mkvar(attname);
         try
         att = nc_attget(OPT.filename, nc_global,attname);
         if isnumeric(att)
         ATT.(fldname)(entry)               = att;
         else
         ATT.(fldname)(entry,1:length(att)) = att;
         end
         end
         
      end
      
   %% get all standard_names (and prevent doubles)
   
         fileinfo       = nc_info(OPT.filename);
         standard_names = [];
         
         % cycle all datasets
         ndat = length(fileinfo.Dataset);
	 for idat=1:ndat

         % cycle all attributes
         natt = length(fileinfo.Dataset(idat).Attribute);
	 for iatt=1:natt
	    Name = fileinfo.Dataset(idat).Attribute(iatt).Name;

            % get standard_names only ...
	    if strcmpi('standard_name',Name)
	    Value = fileinfo.Dataset(idat).Attribute(iatt).Value;

            % ... once
	    if ~any(strfind(standard_names,[' ',Value]))  % remove redudant standard_names (can occur with statistics)
	    standard_names = [standard_names ' ' Value];  % needs to be char
	    end
	    end
	 end
	 end
	 
	 ATT.standard_names(entry,1:length(standard_names)) = standard_names;
   
      if OPT.pause
         pausedisp
      end
   
   end % ifile
end % directory

%% remove amount to much pre-allocated

   for ifld=1:length(OPT.attname)
   
     fldname = mkvar(OPT.attname{ifld});
   
     ATT.(fldname) = ATT.(fldname)(1:entry,:);
   
   end
   
%% store database (mat file, netCDF file, xls file, ..... and perhaps some day as xml file)

%% struct2nc character does not completely write because any space is considered as end-of-line
   struct2nc ([                 'catalog.nc' ],ATT);
   save      (                  'catalog.mat' ,'-struct','ATT');
   struct2xls(                  'catalog.xls' ,ATT);
 
% load database as check

   ATT1 = nc2struct ([          'catalog.nc' ]); % WRONG, beucase nc chars in nc are wrong.
   ATT2 = load      ([          'catalog.mat']);
   ATT3 = xls2struct(           'catalog.xls' );

%% Java issue
               
   setpref ('SNCTOOLS', 'USE_JAVA', OPT.USE_JAVA)

%% EOF
