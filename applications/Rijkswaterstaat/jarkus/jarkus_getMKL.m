function [xMKL] = jarkus_getMKL(x,z,UpperBoundary,LowerBoundary,varargin)
%JARKUS_GETMKL returns the cross shore coordinate of the volume based coastal indicator MKL 
%
%   input:
%       x                   = column array with x points (increasing index and positive x in seaward direction)
%       z                   = column array with z points
%       UpperBoundary       = upper horizontal plane of MKL area 
%       LowerBoundary       = lower horizontal plane of MKL area 
%       varargin            = optional: 'plot' (generates a plot)
%
%  output: 
%    xMKL                   = cross shore coordinate of MKL
%
% See also: jarkus_getVolume, jarkus_getVolumeFast

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

LandwardBoundary = max(jarkus_findCrossings(x,z,[x(1) x(end)],[UpperBoundary UpperBoundary])); %most seaward crossing
SeawardBoundary  = max(jarkus_findCrossings(x,z,[x(1) x(end)],[LowerBoundary LowerBoundary])); %most seaward crossing

if isempty(LandwardBoundary)
    warning('transect does not cross UpperBoundary')
    xMKL = NaN;
    return
end

if isempty(SeawardBoundary)
    warning('transect does not cross LowerBoundary')
    xMKL = NaN;
    return
end

if LandwardBoundary >= SeawardBoundary
    warning('can''t calculate MKL position: LandwardBoundary >= SeawardBoundary')
    xMKL = NaN;
    return
end

% jarkus_getVolume is really slow, use jarkus_getVolumeFast instead
% volume           = jarkus_getVolume(x,z,UpperBoundary,LowerBoundary,LandwardBoundary,SeawardBoundary);

volume           = jarkus_getVolumeFast(x,z,UpperBoundary,LowerBoundary,LandwardBoundary,SeawardBoundary,varargin);
xMKL             = LandwardBoundary+volume/(UpperBoundary - LowerBoundary);

%% plot (visualize proces)
if length(varargin)>0
    if strcmpi(varargin{1},'plot')
       vline(xMKL,'r-')
       title(sprintf('The MKL position is %.1fm',xMKL))
    end
end
