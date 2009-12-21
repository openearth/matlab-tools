function varargout = KNMI_etmgeg_stations(station)
%KNMI_ETMGEG_STATIONS   returns meta-info of WMO KNMI station number
%
%    S = KNMI_etmgeg_stations(<station>) % returns data struct for all or one station
%    [code,long_name,lon,lat] = KNMI_etmgeg_stations(station) 
%
% where station can be code or long_name:
%
%   code long_name           
%   210  Valkenburg          
%   225  IJmuiden
%   235  De Kooy             
%   240  Schiphol            
%   242  Vlieland            
%   249  Berkhout            
%   251  Hoorn Terschelling
%   257  Wijk aan Zee        
%   260  De Bilt             
%   265  Soesterberg         
%   267  Stavoren            
%   269  Lelystad            
%   270  Leeuwarden          
%   273  Marknesse           
%   275  Deelen              
%   277  Lauwersoog          
%   278  Heino               
%   279  Hoogeveen           
%   280  Eelde               
%   283  Hupsel              
%   286  Nieuw Beerta        
%   290  Twenthe             
%   310  Vlissingen          
%   319  Westdorpe           
%   323  Wilhelminadorp      
%   330  Hoek van Holland    
%   340  Woensdrecht         
%   344  Rotterdam           
%   348  Cabauw              
%   350  Gilze-Rijen         
%   356  Herwijnen           
%   370  Eindhoven           
%   375  Volkel              
%   377  Ell                 
%   380  Maastricht          
%   391  Arcen               
%
% Example:
%
%                         S = KNMI_etmgeg_stations('schiphol')
%                         S = KNMI_etmgeg_stations('amsterdam')
%  [code,long_name,lon,lat] = KNMI_etmgeg_stations(240)
%                         S = KNMI_etmgeg_stations
%
%See web:<a href="http://www.knmi.nl/klimatologie/metadata/stationslijst.html">http://www.knmi.nl/klimatologie/metadata/stationslijst.html</a>
%        <a href="http://www.knmi.nl/klimatologie/metadata/index.html">http://www.knmi.nl/klimatologie/metadata/index.html</a>
%        <a href="http://www.ncdc.noaa.gov/oa/climate/rcsg/cdrom/ismcs/alphanum.html">http://www.ncdc.noaa.gov/oa/climate/rcsg/cdrom/ismcs/alphanum.htm</a>
%        <a href="http://weather.gladstonefamily.net/site">http://weather.gladstonefamily.net/site</a>

%See also: KNMI_ETMGEG

% TO DO: add coordinates

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   USA or
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%% Load data file
%------------------

   OPT.xlsfile = [filepathstr(mfilename('fullpath')),filesep,'KNMI_etmgeg_stations.csv'];

   D           = xls2struct(OPT.xlsfile);
   
%% Calculate decimal coordinates
%------------------
  
   for ival=1:length(D.code)
   icirc       = strfind(D.position{ival},'�'); % in xls file
   if isempty(icirc)
   icirc       = strfind(D.position{ival},'�'); % in csv file
   end
   iprime      = strfind(D.position{ival},'''');
   
   D.londeg(ival)= str2num(D.position{ival}(icirc(1)-2:icirc (1)-1));
   D.lonmin(ival)= str2num(D.position{ival}(icirc(1)+1:iprime(1)-1));
   D.latdeg(ival)= str2num(D.position{ival}(icirc(2)-2:icirc (2)-1));
   D.latmin(ival)= str2num(D.position{ival}(icirc(2)+1:iprime(2)-1));
   
   end
   
   D.lat   = D.londeg + D.lonmin./60;  
   D.lon   = D.latdeg + D.latmin./60;

%% Select station
%------------------

   if nargin==1
   if ischar(station)
   i   = find(strcmpi(D.long_name,station));
      if isempty(i)
      i   = find(strcmpi(D.long_name_alt,station));
      end
      if isempty(i)
         disp('no station found')
         varargout = {[],[],[],[]};
         return
      end
   else
   i   = find(D.code==station);
   end
   S.code      = D.code(i);
   S.long_name = D.long_name{i};
   S.lon       = D.lon(i);
   S.lat       = D.lat(i);
   end
   
%% Return
%------------------

   if nargin==0
      varargout = {D};
   elseif nargin==1
   if     nargout==1
      varargout = {S};
   elseif nargout==4
      varargout = {S.code,S.long_name,S.lon,S.lat};
   end
   end

%% EOF