function varargout = KMLtricontourf(tri,lat,lon,z,varargin)
% KMLTRICONTOURF   Just like tricontourc
%
%   KMLtricontourf(tri,lat,lon,z,<keyword,value>)
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLtricontourf()
%
% See also: googlePlot, tricontourc

% TODO:
% * Also include *all* edge vertices in contours - wip
% * Multiple contour crossings on one boundary gives a problem - fixed
% * Improve edge find algortihm (and turn it into seperate function) - done
% * Major code cleaning - wip
% * Better identification of local lowest ring.
% * Optimization of slow routines (think it can be made faster) - no
%   priority
% * make rest OPT arguments consistent with other KML functions

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs@Damsma.net
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


OPT               = KMLcontourf();
if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

KMLcontourf(lat,lon,z,tri,OPT);