function [OPT, Set, Default] = KMLpcolor(lat,lon,c,varargin)
% KMLPCOLOR Just like pcolor
%
%    [<OPT, Set, Default>] = KMLpcolor(lat,lon,c,<keyword,value>)
% 
% If c and lat have the same dimensions, c is calculated as the mean value 
% of the surrounding gridpoints. 
%
% For the additional <keyword,value> pairs call
%
%    OPT = KMLpcolor()
%
% see the keyword/vaule pair defaults for additional options
%
% See also: googlePlot

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
  return
end

[OPT, Set, Default] = setProperty(OPT, varargin);

KMLsurf(lat,lon,c,c,OPT);