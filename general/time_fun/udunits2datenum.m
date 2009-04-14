function datenumbers = udunits2datenum(time,isounits)
%UDUNITS2DATENUM   converts date in ISO 8601 units to datenum
%
%    datenumbers = udunits2datenum(time,isounits)
%
% Example:
%
%    datenumbers = udunits2datenum(733880,'days since 0000-0-0 00:00:00 +01:00')
%
%See also: DATENUM, DATESTR, ISO2DATENUM

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
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

%% Get reference date
%--------------------

    rest = isounits;
   [OPT.units,rest] = strtok(rest);
   [    dummy,rest] = strtok(rest);
   [OPT.refdatenum,...
    OPT.zone] = iso2datenum(rest)

   datenumbers = (time + OPT.refdatenum).*convert_units(OPT.units,'day');
   
%% EOF   