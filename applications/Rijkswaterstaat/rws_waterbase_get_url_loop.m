function rws_waterbase_get_url_loop(varargin)
%RWS_WATERBASE_GET_URL_LOOP   download waterbase: 1 parameter, all stations, selected time period 
%
% See also: RWS_WATERBASE_GET_URL, DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>,  
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

   OPT.codes{01}          = [1 2];
   OPT.standard_names{01} = 'sea_surface_height'; % takes 24 hours
   
   OPT.codes{02}          = 410;
   OPT.standard_names{02} = 'concentration_of_suspended_matter_in_sea_water';
   
   OPT.codes{03}          = 22;
   OPT.standard_names{03} = 'sea_surface_wave_significant_height';
   
   OPT.codes{04}          = 23;
   OPT.standard_names{04} = 'sea_surface_wave_from_direction'; % alias: sea_surface_wave_to_direction
   
   OPT.codes{05}          = 24;
   OPT.standard_names{05} = 'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment';
   
   OPT.codes{06}          = 559;
   OPT.standard_names{06} = 'sea_surface_salinity'; % alias: sea_water_salinity
   
   OPT.codes{07}          = 44;
   OPT.standard_names{07} = 'sea_surface_temperature'; % alias: sea_water_temperature
   
   OPT.codes{08}          = 282;
   OPT.standard_names{08} = 'concentration_of_chlorophyll_in_sea_water'; % alias: chlorophyll_concentration_in_sea_water
   
   OPT.codes{09}          = 29;
   OPT.standard_names{09} = 'water_volume_transport_into_sea_water_from_rivers'; % alias: water_volume_transport_into_ocean_from_rivers
                         
   OPT.parameter          = 0; %[9]; % 0=all or select index from OPT.names above

%% Initialize

   OPT.directory_raw      = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';

   OPT.period             = [datenum(1798, 5,24) floor(now)]; % 24 mei 1798: Oprichting voorloper Rijkswaterstaat in Bataafse Republiek
   OPT.period             = [datenum(1648,10,24) floor(now)]; % 24 okt 1648: Oprichting Staat der Nederlanden, Vrede van Munster
   
   %Note: first water level in waterbase 1737 @ Katwijk
   
   OPT.zip                = 1; % zip txt file and delete it
   OPT.nc                 = 0; % not implemented yet
   OPT.opendap            = 0; % not implemented yet
   
%% Keyword,value

   OPT = setProperty(OPT,varargin{:});
   
%% Parameter choice

   if ischar(OPT.parameter)
      OPT.parameter = strmatch(OPT.parameter,OPT.standard_names)
   else   
      if  OPT.parameter==0
          OPT.parameter = 1:length(OPT.codes);
      end
   end   

%% Parameter loop

for ivar=[OPT.parameter]
for ialt=1:length(OPT.codes{ivar});

   OPT.code           = OPT.codes{ivar}(ialt);
   OPT.standard_name  = OPT.standard_names{ivar};

%% Match and check Substance
   
      SUB        = rws_waterbase_get_substances;
      OPT.indSub = find(SUB.Code==OPT.code);
   
      disp(['--------------------------------------------'])
      disp(['indSub   :',num2str(             OPT.indSub )])
      disp(['CodeName :',        SUB.CodeName{OPT.indSub} ])
      disp(['FullName :',        SUB.FullName{OPT.indSub} ])
      disp(['Code     :',num2str(SUB.Code    (OPT.indSub))])
   
%% get and check Locations
   
      LOC = rws_waterbase_get_locations(SUB.Code(OPT.indSub),SUB.CodeName{OPT.indSub});
      
      if ~exist([OPT.directory_raw])
          mkdir([OPT.directory_raw])
      end
   
      for indLoc=1:length(LOC.ID)
      
         disp(['----------------------------------------'])
         disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
         disp(['FullName :',        LOC.FullName{indLoc} ])
         disp(['ID       :',        LOC.ID{indLoc} ])
         
         OPT.filename = ...
         rws_waterbase_get_url(SUB.Code(OPT.indSub),LOC.ID{indLoc},...
                               OPT.period,...
                              [OPT.directory_raw]);

%% Zip (especially useful for large sea_surface_height series)
   
         if OPT.zip
            zip   (OPT.filename,OPT.filename);
            delete(OPT.filename)
         end
         
      end % for indLoc=1:length(LOC.ID)
      
end % for ialt
end % for ivar=1:length(OPT.codes)

%% EOF