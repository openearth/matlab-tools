function rws_waterbase_get_url_loop(varargin)
%RWS_WATERBASE_GET_URL_LOOP   download waterbase: 1 parameter, all stations, selected time period 
%
% See also: <a href="http://live.waterbase.nl">live.waterbase.nl</a>,  rijkswaterstaat

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

   OPT.donar_wnsnum       = []; % 0=all or select number from 'donar_wnsnum' column in rws_waterbase_name2standard_name.xls

%% Initialize

   OPT.directory_raw      = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';
   OPT.directory_raw_old  = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\old\';

   OPT.period             = [datenum(1798, 5,24) floor(now)]; % 24 mei 1798: Oprichting voorloper Rijkswaterstaat in Bataafse Republiek
   OPT.period             = [datenum(1648,10,24) floor(now)]; % 24 okt 1648: Oprichting Staat der Nederlanden, Vrede van Munster
   
   %Note: first water level in waterbase 1737 @ Katwijk
   
   OPT.zip                = 1; % zip txt file and delete it
   OPT.nc                 = 0; % not implemented yet
   OPT.opendap            = 0; % not implemented yet
   OPT.cleanup            = 0;
   
%% Keyword,value

   OPT = setproperty(OPT,varargin{:});
   
%% Parameter choice

   DONAR = xls2struct([fileparts(mfilename('fullpath')) filesep 'rws_waterbase_name2standard_name.xls']);

   if  OPT.donar_wnsnum==0
       OPT.donar_wnsnum = DONAR.donar_wnsnum;
   end

%% Parameter loop

for ivar=[OPT.donar_wnsnum]

index = find(DONAR.donar_wnsnum==ivar);

%-%for ialt=1:length(OPT.codes{index});

   OPT.code           = DONAR.donar_wnsnum(index);
   OPT.standard_name  = DONAR.cf_standard_name{index};
   
%% Make destination (clean)

      if ~exist   ([OPT.directory_raw],'dir')
          disp    (['Created: ',OPT.directory_raw])
          mkpath  ([OPT.directory_raw])
      end

      if OPT.cleanup
         ~exist   ([OPT.directory_raw_old],'dir');
          disp    (['Created: ',OPT.directory_raw_old]);
          mkpath  ([OPT.directory_raw_old]);
          movefile([OPT.directory_raw    filesep '*'],...
                   [OPT.directory_raw_old filesep]);
      end

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
      
      for indLoc=1:length(LOC.ID)
      
         disp(['----------------------------------------'])
         disp(['indLoc   :',num2str(             indLoc ),' of ',num2str(length(LOC.ID))])
         disp(['FullName :',        LOC.FullName{indLoc} ])
         disp(['ID       :',        LOC.ID{indLoc} ])
         
         OPT.filename = ...
         rws_waterbase_get_url(SUB.Code(OPT.indSub),...
                               LOC.ID{indLoc},...
                               OPT.period,...
                              [OPT.directory_raw]);

%% Zip (especially useful for large sea_surface_height series)
   
         if OPT.zip
            zip   (OPT.filename,OPT.filename);
            delete(OPT.filename)
         end
         
      end % for indLoc=1:length(LOC.ID)
      
%-%end % for ialt
end % for ivar=1:length(OPT.codes)

%% EOF
