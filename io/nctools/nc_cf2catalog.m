%function ATT = struct2catalog(varargin)
%STRUCT2CATALOG   test for creating catalogs of set of directories (BETA)
%
% Extracts  (i) netCDF CF meta-data keywords 
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
%
%          (ii) THREDDS meta-data keywords 
%              'urlPath'
%              'standard_names'
%              'timecoverage_start'
%              'timecoverage_end'
%              'timecoverage_duration'
%              'geospatialCoverage_northsouth'
%              'geospatialCoverage_eastwest'
%              'dataTypes'
%
% from all specified netCDF files and stores them into a 
% struct for storage in netCDF file (now still mat file)
%
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#geospatialCoverageType
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#timeCoverageType
%  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html#dataType
% (http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html)
%
%See also: STRUCT2NC, NC2STRUCT

% TO DO: gather all catalogs from subdirectories into overlying levels

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

%% which directories to scan

   OPT.base           = 'P:\mcdata\opendap\';
   
   OPT.directories    = {'rijkswaterstaat\waterbase\concentration_of_chlorophyll_in_sea_water',...
                         'rijkswaterstaat\waterbase\concentration_of_suspended_matter_in_sea_water',...
                         'rijkswaterstaat\waterbase\sea_surface_height',...
                         'rijkswaterstaat\waterbase\sea_surface_salinity',...
                         'rijkswaterstaat\waterbase\sea_surface_temperature',...
                         'rijkswaterstaat\waterbase\sea_surface_wave_from_direction',...
                         'rijkswaterstaat\waterbase\sea_surface_wave_significant_height',...
                         'rijkswaterstaat\waterbase\sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
                         'knmi\etmgeg',...
                         'knmi\potwind',...
                         'knmi\NOAA\mom\1990_mom\5\'};
   
   OPT.pause          = 0;

%% Directory loop

for idir = 3 % 1:length(OPT.directories)

   OPT.directory = [OPT.directories{idir}];

   disp(['Processing   ',num2str(idir,'%0.4d'),'/',num2str(length(OPT.directories),'%0.4d'),': ',OPT.directory,filesep]);
   
   nc_cf_directory2catalog([OPT.base,filesep,OPT.directory])
   
   if OPT.pause
      pausedisp
   end
   
end   


%% EOF
