function axislat(varargin)
%AXISLAT   Sets (lon,lat) dataaspectratio for speficic latitude to have equal (dx,dy).
%
%    axislat
%    axislat(latitude)
%
% sets the x and y dataaspectratio so that
% WHEN PLOTTING IN DEGREES LAT AND LON, the vertical 
% scale in km is roughly the same as the horizontal one.
% By default mean(ylim).
%
% See also: daspect

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% changed G.J. de Boer(g.j.deboer@tudelft.nl) 11th March 2006

% $Id: axislat.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/plot_fun/axislat.m $
% $Keywords: $

lat = mean(ylim); %52.5;

if nargin==1
   lat = abs(varargin{1});
end

d = get(gca,'dataaspectratio');

d(2) = d(1).*cosd(lat);

daspect(d);

%% EOF