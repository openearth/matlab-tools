function [x2,y2,OPT]=convertCoordinates(x1,y1,varargin)
%CONVERTCOORDINATES transformation between coordinate systems
%
% [x2,y2,<OPT>] = convertCoordinatesNew(x1,y1,'keyword','value')
%
% Note 1: Beware of the Lon-Lat order of in- and output arguments!
% Note 2: (x1,y1) can be vectors or matrices (vectorized).
% Note 3: Does not work for MatLab 7.0 and older (gives invalid MEX file
%         warnings)
% Note 4: Rijksdriehoek(RD) to WGS 84 conversions are NOT exact. Accuracy 
%         is better than 0.5m, but multiple conversions can mess things up.
%         For accurate conversions, see  <a href="http://www.rdnap.nl/">www.rdnap.nl/</a>
%
% x1,y1 : values of the coordinates to be transformed   , either X-Y or Lon-Lat.
% x2,y2 : values of the coordinates after transformation, either X-Y or Lon-Lat.
% OPT   : contains all conversion parameters that were used.
%         To check this output, use 'var2evalstr(OPT)'.
% 
% Optionally the data structure with EPSG codes van be pre-loaded, this 
% greatly speeds up the routine if many calls are made. The call is either 
%
%    EPSG        = load('EPSG');
%    [x2,y2,OPT] = convertCoordinates(x1,y1,EPSG,'keyword','value')
%                  
%    or:
%
%    [x2,y2,OPT] = convertCoordinates(x1,y1,     'keyword','value')
%
% The most important keyword value pairs are the identifiers for the
% coordinate systems:
%    (from) 'Coordinate System 1' (CS1)
%    (to)   'Coordinate System 2' (CS2).
%
% Any combination of name, type and code that indetifies a unique
% coordinate system will do, e.g.:
%
%    CS1.name = coordinate system name
%    CS1.code = coordinate system reference code 
%    CS1.type = projection type
%
% When insufficient combinations are specified, remaining choices are suggested.
% 
% Projection types supported     : projected and geographic 2D
% Projection not (yet) supported : engineering, geographic 3D, vertical, geocentric,  compound
% 
% Allowed synonyms for 'projected'    : 'xy','proj','cartesian','cart'
% Allowed synonyms for 'geographic 2D': 'geo','latlon','lat lon','geographic','geographic2d'
%
% Example 1: 4 different notations of 1 single transformation case:
%
%    [x,y,OPT]=convertCoordinates(5,52,'CS1.name','WGS 84','CS1.type','geo','CS2.name','WGS 84 / UTM zone 31N','CS2.type','xy')
%    [x,y,OPT]=convertCoordinates(5,52,'CS1.code',4326                     ,'CS2.name','WGS 84 / UTM zone 31N')
%
%    ESPG = load('EPSG')
%
%    [x,y,OPT]=convertCoordinates(52,5,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',32631)
%    [x,y,OPT]=convertCoordinates(52,5,EPSG,'CS1.code',4326                     ,'CS2.code',32631)
%
% Example 2: Rijksdriehoek to WGS 84:
%
%   [lon,lat,OPT]=convertCoordinates(xRD,yRD,'CS1.code',28992,'CS2.code',4326)
%
% Example 3: decimal degree to sexagesimal DMS conversion:
%
%   [lon,lat,OPT]=convertCoordinates(52,5.5,'CS1.code',4326,'CS2.code',4326,'CS2.UoM.name','sexagesimal DMS')
%
% To find specifications of coordinate systems (name <=> code):
% <a href="http://www.epsg-registry.org">www.epsg-registry.org</a>.
%
% See also: SuperTrans, EPSG.mat

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%   Based on SuperTrans by Maarten van Ormondt (Maarten.vanOrmondt@deltares.nl). 
%   Rewritten by
%
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
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

%% version check
if datenum(version('-date'))<datenum(2007,1,1)
    warning('the matlab version your using might be to old for this function'); %#ok<WNTAG>
end

%% check if EPSG codes are given

if odd(length(varargin))
    STD = varargin{1};
    varargin(1)=[];
else
    STD = load('EPSG');
end

%% get and set keyword value parameters
OPT=[];
OPT=FindCSOptions(OPT,STD,varargin);

%% Transform input coordinates to geographic 2D radians
switch OPT.CS1.type
    case 'projected' % convert projection to geographic radians
%         x1 = convertUnits(x1,OPT.CS1.UoM.name,'metre',STD);
%         y1 = convertUnits(y1,OPT.CS1.UoM.name,'metre',STD);
        [lat1,lon1] = ConvertCoordinatesProjectionConvert(x1,y1,OPT.CS1,OPT.proj_conv1,'xy2geo',STD);
    case 'geographic 2D' % do nothing, except for a unit conversion
        lon1 = convertUnits(x1,OPT.CS1.UoM.name,'radian',STD);
        lat1 = convertUnits(y1,OPT.CS1.UoM.name,'radian',STD);
end

%% find datum transformation options
% check if geogcrs_code1 and geogcrs_code2 are different
%
% check if there is a direct transormation between geogcrs_code1 and
% geogcrs_code2; 
% 
% * if multiple options found, use the newest unless user has defined something else
% * if no direct transformation exists, convert via WGS 84
OPT = ConvertCoordinatesFindDatumTransOpt(OPT,STD);

%% do datum transformation

if ischar(OPT.datum_trans)
    if strcmpi(OPT.datum_trans,'no transformation available')
        error('No transformation methods available ...');
    end
end

if ischar(OPT.datum_trans)
    % no transformation required
    lat2 = lat1;
    lon2 = lon1;
else
    if ~isfield(OPT,'datum_trans_from_WGS84') %only exists when tranforming via WGS 84
        [lat2,lon2] = ConvertCoordinatesDatumTransform(lat1,lon1,OPT,'datum_trans');
    else
        [lat2,lon2] = ConvertCoordinatesDatumTransform(lat1,lon1,OPT,'datum_trans_to_WGS84');
        [lat2,lon2] = ConvertCoordinatesDatumTransform(lat2,lon2,OPT,'datum_trans_from_WGS84');
    end
end

%% Transform geographic 2D radians to output coordinates 
switch OPT.CS2.type
    case 'projected' % convert projection to geographic radians
        [y2,x2] = ConvertCoordinatesProjectionConvert(lon2,lat2,OPT.CS2,OPT.proj_conv2,'geo2xy',STD);
        x2 = convertUnits(x2,OPT.CS2.UoM.name,'metre',STD);
        y2 = convertUnits(y2,OPT.CS2.UoM.name,'metre',STD);
    case 'geographic 2D' 
        x2 = convertUnits(lon2,'radian',OPT.CS2.UoM.name,STD);
        y2 = convertUnits(lat2,'radian',OPT.CS2.UoM.name,STD);
end
%% EOF
end