function ITHK_KMLicons(x,y,class,icons,offset,sens)
% ITHK_KMLicons(x,y,class,icons,offset,sens)
%
% creates kml-txt for a pop-up at the specified x,y location.
% 
% coordinates (lat,lon) are in decimal degrees. 
%   LON is converted to a value in the range -180..180)
%   LAT must be in the range -90..90
%
% be aware that GE draws the shortest possible connection between two 
% points, when crossing the null meridian.
%
% The kml code (without header/footer) is written to the S structure 

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Bas Huisman
%
%       Bas.Huisman@deltares.nl	
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

global S

if nargin<6
sens=1;
end

for kk=1:length(icons)
    iconclass(kk) = str2double(icons(kk).class);
end

for jj = 1:length(S.PP(sens).settings.tvec)
    time    = datenum((S.PP(sens).settings.tvec(jj)+S.PP(sens).settings.t0),1,1);
    for ii=2:length(x)-1
        % dunes to KML  
        [lon,lat] = convertCoordinates(x(ii)+offset,y(ii),S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        id = find(iconclass==class(ii,jj));
        OPT.icon = icons(id).url;
        S.PP(sens).output.kml = [S.PP(sens).output.kml ITHK_KMLtextballoon(lon,lat,'icon',OPT.icon,'timeIn',time,'timeOut',time+364)];
    end
end