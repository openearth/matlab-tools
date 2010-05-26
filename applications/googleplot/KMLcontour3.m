function [OPT, Set, Default] = KMLcontour3(lat,lon,z,varargin)
% KMLCONTOUR3   Just like contour3
%
%    KMLcontour3(lat,lon,z,<keyword,value>)
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontour3()
%
% The most important keywords are 'fileName' and 'levels';
%
%    OPT = KMLcontour3(lat,lon,z,'fileName','mycontour3.kml','levels',20)
%
% The kml code hat is written to fle 'fileName' can optionally be returned.
%
%    kmlcode = KMLcontour3(lat,lon,<keyword,value>)
%
% See also: googlePlot, contour, contour3

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

OPT               = KMLcontour();
OPT.is3D          = true;
OPT.zScaleFun     = @(z) (z+20)*10;

if nargin==0
  return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

kmlcode = KMLcontour(lat,lon,z,OPT);

if nargout ==1
   OPT = {kmlcode};
end

%% EOF