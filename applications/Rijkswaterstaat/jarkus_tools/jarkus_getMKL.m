function [xMKL] = jarkus_getMKL(x,z,UpperBoundary,LowerBoundary)
% GETMKL returns the cross shore coordinate of the volume based coastal indicator MKL 
%
%   input:
%       x                   = column array with x points (increasing index and positive x in seaward direction)
%       z                   = column array with z points
%       UpperBoundary       = upper horizontal plane of MKL area 
%       LowerBoundary       = lower horizontal plane of MKL area 
%
%  output: 
%    xMKL                   = cross shore coordinate of MKL

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

LandwardBoundary = max(findCrossings(x,z,[x(1) x(end)],[UpperBoundary UpperBoundary])); %most seaward crossing
SeawardBoundary  = max(findCrossings(x,z,[x(1) x(end)],[LowerBoundary LowerBoundary])); %most seaward crossing

if isempty(LandwardBoundary)
    warning('transect does not cross UpperBoundary')
    xMKL = NaN;
    return
end

if isempty(LandwardBoundary)
    warning('transect does not cross LowerBoundary')
    xMKL = NaN;
    return
end

volume           = getVolume(x,z,UpperBoundary,LowerBoundary,LandwardBoundary,SeawardBoundary);

xMKL             = LandwardBoundary+volume/(UpperBoundary - LowerBoundary);