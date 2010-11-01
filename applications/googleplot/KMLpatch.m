function [OPT, Set, Default] = KMLpatch(lat,lon,varargin)
%KMLPATCH Just like patch
%
%    KMLpatch(lat,lon,<keyword,value>)
% 
% only works for a singe patch (filled polygon)
% see the keyword/value pair defaults for additional options. 
% For the <keyword,value> pairs call. Toe orientation of 
% lat,lon doe snot matter.
%
%    OPT = KMLpatch()
%
% See also: googlePlot, patch

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
z = 'clampToGround';

OPT = KMLpatch3;

if nargin==0
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin{:});
    
OPT = KMLpatch3(lat,lon,z,OPT);