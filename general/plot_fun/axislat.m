function axislat(varargin)
%AXISLAT   Sets (lon,lat) dataaspectratio for speficic latitude to have equal (dx,dy).
%
%    axislat
%    axislat(latitude)      % passing the speficic latitude
%    axislat(ha)            % passing the axes handle
%    axislat(ha, latitude)  % passing the axes handle and speficic latitude
%
% sets the x and y dataaspectratio so that
% WHEN PLOTTING IN DEGREES LAT AND LON, the vertical 
% scale in km is roughly the same as the horizontal one.
% By default mean(ylim).
%
% See also: daspect, num2strll

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

lat = mean(ylim); %52.5;
ha  = gca;
if nargin==1 
   if ishandle(varargin{1})
       ha = varargin{1};
   else
       lat = abs(varargin{1});
       ha  = gca;
   end
elseif nargin == 2;
    ha  = varargin{1};
    lat = abs(varargin{2});
end

% d = get(gca,'dataaspectratio');
d = get(ha,'dataaspectratio');

d(2) = d(1).*cosd(lat);

daspect(d);

%% EOF