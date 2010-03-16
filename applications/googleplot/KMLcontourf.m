function varargin = KMLcontourf(lat,lon,z,varargin)
% KMLCONTOURF Just like contourf (BETA!!!, still sawtooh edges )
%
%    KMLcontourf(lat,lon,z,<keyword,value>)
% 
% KMLcontourf triangulates a curvi-linear grid (mesh) and then
% calls KMLtricontourf on all active cells.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLcontourf()
%
% See also: googlePlot, KMLtricontourf, contourf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% process <keyword,value>

   OPT            = KMLtricontourf();

   if nargin==0
      varargout = {OPT};
      return
   end

   [OPT, Set, Default] = setProperty(OPT, varargin);

%% contourf

   [tri,quat] = triquat(lon,lat,'active',1); % active removes inactive quadrangles
   KMLtricontourf(tri,lat,lon,z,OPT);
   
%% EOF
