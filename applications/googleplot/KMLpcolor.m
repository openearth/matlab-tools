function varargout = KMLpcolor(lat,lon,c,varargin)
% KMLPCOLOR Just like pcolor
%
%    KMLpcolor(lat,lon,c,<keyword,value>)
% 
% If c and lat/lon have the same dimensions, c is interpolated to be 
% the mean value of the surrounding gridpoints with corner2center().Therefore
% the resulting kml file always has 'shading flat' look since Google Earth
% does not support 'shading interp' look. KMLpcolor is a wrapper for KMLsurf.
% Note: lat, and lon can be either vectors or full curvi-linear matrices.
%
% Note: for large grids, KMLpcolor objects migth be slow in Google 
% Earth, use KMLfig2pngNew instead, that use the native Google Earth
% technology to speed up visualisation of enormous grids.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLpcolor()
%
% See also: googlePlot, KMLfig2pngNew, KMlsurf, pcolor, pcolorcorcen

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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

% TO DO: patches without outlines, outline as separate polygons, to prevent course resolution lines at low angles
% KMLline(lat,lon)
% KMLline(lat',lon')

   OPT            = KMLsurf();
   OPT.zScaleFun  = @(z) 'clampToGround';
   
   if nargin==0
     varargout = {OPT};
     return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
   KMLsurf(lat,lon,[],c,OPT); % do not pass c as z, because c can be at centers, while z needs to be at corners (always). KMLsurf handles empty z.

%% EOF