function xcen = corner2center1(xcor);
%CORNER2CENTER1  calculates centers in between vector of corner points.
%
%   xcen = corner2center1(xcor) 
%
%   Interpolates a 1D vector linearly to obtain center values
%   from corner values. The cdnter array is one element smaller.
%   Works for non-equidistant grid spacing.
%
%   Do note that only for equidistant grid spacing the following holds:
%   xcor = center2corner1(corner2center1(xcor))
%
%   corner points:   o---o-----o--------o------------o---o-o 
%   center points:     +----+------+----------+--------+--+  
%
%   See also: CORNER2CENTER, CENTER2CORNER, CENTER2CORNER1

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

dimensions_of_xcen = fliplr(sort(size(xcor))); % 1st element is biggest

%% 1D

if dimensions_of_xcen(2)==1
   
   %% Initialize with nan


     %xcen = nan(1:length(xcor)-1);% not in R6
      xcen = nan.*zeros(length(xcor)-1,1);

   %% Give value to those corner points that have 
   %  4 active center points around
   %  and do not change them with 'internal extrapolations

      xcen = (xcor(1:end-1) + xcor(2:end))./2;
     
%% 2D or more

else

   error('only 1D arrays allowed, use center2corner instead') 

end
