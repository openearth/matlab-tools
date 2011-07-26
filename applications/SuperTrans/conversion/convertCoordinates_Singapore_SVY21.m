function [lon2,lat2]=convertCoordinates_Singapore_SVY21(X,Y)
%convertCoordinates_Singapore_SVY21   custom coordinate projection for Singapore (epsg:3414)
%
%  [lon,lat]=convertCoordinates_Singapore_SVY21(X,Y)
%
% conversion of Singapore xy projected grid (SVY21) to lat lon coordinate WGS84
%
%See also: convertCoordinates, 
% http://spatialreference.org/ref/epsg/3414/,
% http://www.sla.gov.sg/htm/ser/ser0402.htm

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
%       Maarten van Ormondt, Ann Sisomphon, Gerben de Boer
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% use radian
A=  1.366666666    .*pi./180;
B=103.8333333333333.*pi./180;

[lon,lat]= TransverseMercator(X,Y,6378137,298.257223563,1,28001.642,38744.572,A,B,2);

%% convert back to deg
lon2=lon.*180./pi;
lat2=lat.*180./pi;

% TO DO: implement in convertCoordinates
% use map code (3414=SVY21/TM projected, 4757=Singapore Geographic2D => transfer to the same globe reference)
% [lon,lat,log]=convertCoordinates(grid.X,grid.Y,'CS1.code',3414,'CS2.code',4757)
