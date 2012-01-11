function [OPT, Set, Default] = KMLtricontour3(tri,lat,lon,z,varargin)
% KMLTRICONTOUR3   Just like contour3
%
% see the keyword/vaule pair defaults for additional options
%
% See also: googlePlot, contour3

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

%% process varargin

OPT               = KMLtricontour();
OPT.is3D          = true;
OPT.zScaleFun     = @(z) (z+20)*10;

if nargin==0
  return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

KMLtricontour(tri,lat,lon,z,OPT);