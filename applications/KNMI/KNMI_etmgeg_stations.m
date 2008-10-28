function station_name = KNMI_etmgeg_stations(station_number)
%KNMI_ETMGEG_STATIONS   returns name of WMO KNMI station number
%
%   Station 235 Den Helder (De Kooy)
%   Station 240 Amsterdam (Schiphol)
%   Station 260 De Bilt
%   Station 270 Leeuwarden
%   Station 280 Groningen (Eelde)
%   Station 290 Twenthe
%   Station 310 Vlissingen
%   Station 344 Rotterdam
%   Station 370 Eindhoven
%   Station 380 Maastricht (Beek)
%
%See also: KNMI_ETMGEG

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
   
   names{235}='Den Helder (De Kooy)';
   names{240}='Amsterdam (Schiphol)';
   names{260}='De Bilt';
   names{270}='Leeuwarden';
   names{280}='Groningen (Eelde)';
   names{290}='Twenthe';
   names{310}='Vlissingen';
   names{344}='Rotterdam';
   names{370}='Eindhoven';
   names{380}='Maastricht (Beek)';
   
   station_name = names{station_number};

%% EOF