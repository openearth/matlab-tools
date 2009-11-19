function degN = xy2degN(x0, y0, x1, y1)
%XY2DEGN  find angle in degrees, positive clockwise and 0 north
%
%   More detailed description goes here.
%
%   Syntax:
%   degN = xy2degN(x0, y0, x1, y1)
%
%   Input:
%   x0   = x-coordinate of starting point of vector(s)
%   y0   = y-coordinate of starting point of vector(s)
%   x1   = x-coordinate of end point of vector(s)
%   y1   = y-coordinate of end point of vector(s)
%
%   Output:
%   degN = angle in degrees, positive clockwise and 0 north
%
%   Example
%   xy2degN
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
dx = x1 - x0; % derive horizontal distance
dy = y1 - y0; % derive vertical distance

quadr2or3 = dy < 0; % second and third quadrant
quadr4 = dx < 0 & dy >= 0; % fourth quadrant

degN = atand(dx ./ dy); % derive angle
degN(quadr2or3) = degN(quadr2or3) + 180; % modify second and third quadrant
degN(quadr4) = degN(quadr4) + 360; % modify fourth quadrant
