%GETWATERBASEDATALOOP   script to download waterbase data for one parameter for all stations for a selected time period 
%
% See also: GETWATERBASEDATA, DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>,  
%           GETWATERBASEDATA_SUBSTANCES, GETWATERBASEDATA_LOCATIONS, GETWATERBASE2NC_TIME_DIRECT
%           DONARNAME2STANDARD_NAME

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% TO DO: convert to SI units here
%% TO DO: add option to loop entire donar_substances.csv

%% Choose parameter and provide CF standard_names and units.
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
%  See also: donarname2standard_name

   OPT.codes          = 1;
   OPT.standard_names = {'sea_surface_height'};

   OPT.codes          = 54;
   OPT.standard_names = {'sea_surface_height'};

   OPT.codes          = 410;
   OPT.standard_names = {'concentration_of_suspended_matter_in_sea_water'};

   OPT.codes          = 22 
   OPT.standard_names = {'sea_surface_wave_significant_height'};

   OPT.codes          = 23 
   OPT.standard_names = {'sea_surface_wave_from_direction'}; % alias: sea_surface_wave_to_direction

   OPT.codes          = 24];
   OPT.standard_names = {'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};

   OPT.codes          = 559 
   OPT.standard_names = {'sea_surface_salinity'}; % alias: sea_water_salinity

   OPT.codes          = 44 
   OPT.standard_names = {'sea_surface_temperature'}; % alias: sea_water_temperature

   OPT.codes          = 282;
   OPT.standard_names = {'concentration_of_chlorophyll_in_sea_water'}; % alias: chlorophyll_concentration_in_sea_water
                         
%% Initialize

   OPT.directory.raw = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';

   OPT.period        = datenum([1961 2008],1,1);
   OPT.zip           = 1; % zip txt file and delete it
   OPT.nc            = 0; % not implemented yet
   OPT.opendap       = 0; % not implemented yet
   
%% Parameter loop

for ivar=1:length(OPT.codes)

   OPT.code           = OPT.codes(ivar);
   OPT.standard_name  = OPT.standard_names{ivar};

%% Match and check Substance
   
      SUB        = getWaterbaseData_substances;
      OPT.indSub = find(SUB.Code==OPT.code);
   
      disp(['--------------------------------------------'])
      disp(['indSub   :',num2str(             OPT.indSub )])
      disp(['CodeName :',        SUB.CodeName{OPT.indSub} ])
      disp(['FullName :',        SUB.FullName{OPT.indSub} ])
      disp(['Code     :',num2str(SUB.Code    (OPT.indSub))])
   
%% get and check Locations
   
      LOC = getWaterbaseData_locations(SUB.Code(OPT.indSub));
      
      if ~exist([OPT.directory.raw,filesep,OPT.standard_name])
         mkdir([OPT.directory.raw,filesep,OPT.standard_name])
      end
   
      for indLoc=1:length(LOC.ID)
      
         disp(['----------------------------------------'])
         disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
         disp(['FullName :',        LOC.FullName{indLoc} ])
         disp(['ID       :',        LOC.ID{indLoc} ])
         
         OPT.filename = ...
         getWaterbaseData(SUB.Code(OPT.indSub),LOC.ID{indLoc},...
                          OPT.period,...
                         [OPT.directory.raw,filesep,OPT.standard_name]);

%% Zip (especially useful for large sea_surface_height series)
   
         if OPT.zip
            zip   (OPT.filename,OPT.filename);
            delete(OPT.filename)
         end
         
      end % for indLoc=1:length(LOC.ID)
      
%% Transform to *.nc files (future)
   
      if OPT.nc
      for indLoc=1:length(LOC.ID)
        %getWaterbase2nc_time_direct(OPT.standard_name,directory.raw,directory.nc)
      end
      end
      
%% Copy to OPeNDAP server (future)
   
      if OPT.opendap
      for indLoc=1:length(LOC.ID)
        %filecopy(...)
      end
      end

end % for ivar=1:length(OPT.codes)

%% EOF