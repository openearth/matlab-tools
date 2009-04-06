function station_name = KNMI_etmgeg_stations(station_number)
%KNMI_ETMGEG_STATIONS   returns name of WMO KNMI station number
%
%   code long_name           
%   210  Valkenburg          
%   235  De Kooy             
%   240  Schiphol            
%   242  Vlieland            
%   249  Berkhout            
%   251  Hoorn (Terschelling)
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

   if ischar(station_number)
      station_number = num2str(station_number);
   end

   names{210}='Valkenburg';
   names{235}='De Kooy';% Den Helder 
   names{240}='Schiphol';% Groningen
   names{242}='Vlieland';
   names{249}='Berkhout';
   names{251}='Hoorn (Terschelling)';
   names{257}='Wijk aan Zee';
   names{260}='De Bilt';
   names{265}='Soesterberg';
   names{267}='Stavoren';
   names{269}='Lelystad';
   names{270}='Leeuwarden';
   names{273}='Marknesse';
   names{275}='Deelen';
   names{277}='Lauwersoog';
   names{278}='Heino';
   names{279}='Hoogeveen';
   names{280}='Eelde';%Groningen
   names{283}='Hupsel';
   names{286}='Nieuw Beerta';
   names{290}='Twenthe';
   names{310}='Vlissingen';
   names{319}='Westdorpe';
   names{323}='Wilhelminadorp';
   names{330}='Hoek van Holland';
   names{340}='Woensdrecht';
   names{344}='Rotterdam';
   names{348}='Cabauw';
   names{350}='Gilze-Rijen';
   names{356}='Herwijnen';
   names{370}='Eindhoven';
   names{375}='Volkel';
   names{377}='Ell';
   names{380}='Maastricht';% (Beek)
   names{391}='Arcen';

   station_name = names{station_number};

   if isempty(station_name)
     station_name = '?';
   end

%% EOF