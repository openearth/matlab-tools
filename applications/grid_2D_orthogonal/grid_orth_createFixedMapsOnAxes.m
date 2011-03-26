function ah = grid_orth_createFixedMapsOnAxes(ah, OPT, varargin)
%GRID_ORTH_CREATEFIXEDMAPSONAXES   Plots geographical extents of ncfiles on axes.
%
% See also: grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
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

%% make the axes to use the current one

if size(OPT.x_ranges,1) == 2 && OPT.x_ranges(1,1)<OPT.x_ranges(2,1)
    OPT.x_ranges = OPT.x_ranges';
    OPT.y_ranges = OPT.y_ranges';
end

for ii = 1:length(OPT.urls)
    patch(...
        'xdata',[OPT.x_ranges(ii,1) OPT.x_ranges(ii,2) OPT.x_ranges(ii,2) OPT.x_ranges(ii,1) OPT.x_ranges(ii,1)], ...
        'ydata',[OPT.y_ranges(ii,1) OPT.y_ranges(ii,1) OPT.y_ranges(ii,2) OPT.y_ranges(ii,2) OPT.y_ranges(ii,1)], ...
        'EdgeColor','r','tag',OPT.urls{ii},'FaceColor','none','parent',ah);
end

