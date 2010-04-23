function ZI = griddata_nearest(X,Y,Z,XI,YI,varargin)
%GRIDDATA_NEAREST Data gridding and surface fitting.
%
%     ZI = griddata_nearest(X,Y,Z,XI,YI) 
%
%   GRIDDATA_NEAREST fits a surface of the form Z = F(X,Y) to the
%   data in the (usually) nonuniformly-spaced vectors (X,Y,Z). GRIDDATA_NEAREST
%   interpolates this surface at the points specified by (XI,YI) to produce
%   ZI.  The surface always goes through the data points. XI and YI are
%   usually a uniform grid (as produced by MESHGRID) and is where GRIDDATA_NEAREST
%   gets its name.
%
%   Unlike GRIDDATA, GRIDDATA_NEAREST does not connect 
%   all points [X,Y] in a mesh (delaunay triangulation)  
%   before interpolation. Instead GRIDDATA_NEAREST 
%   finds the closest point in the random set of points 
%   [X,Y] for all points [XI,YI]  one-at-a-time and 
%   copies the associated value.
%
%   Note: GRIDDATA_NEAREST is much slower than GRIDDATA, but
%   owes it existence to those cases where 
%    i) GRIDDATA leads to gives DELAUNAY triangulation errors.
%   ii) laaarge X and Y matrixes lead to MEMORY issues in GRIDDATA
%
%   See also: GRIDDATA, GRIDDATA_NEAREST, GRIDDATA_AVERAGE, GRIDDATE_REMAP,
%   INTERP2, BIN2 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% TO DO: find closest of 3 points and interpolate value using
%        analytical fit of linear surface (if inside the triangle), 
%        or use inverse distance
% TO DO: throw away any points outside (note: they can be nearest !!)
% TO DO: make space varying Rmax official ? 
   OPT.ndisp = 100;
   OPT.Rmax  = Inf; % make this optionally same size as X and Y.
 % Rmax      = [];
 % 
 % if ~odd(nargin)
 %    Rmax     = varargin{1};
 %    nextarg  = 2;
 % else
      nextarg  = 1;
 % end
   
   OPT  = setProperty(OPT,varargin{nextarg:end})

   ZI   = repmat(NaN,(size(XI)));
   R    = repmat(NaN,(size(X )));
   npix = length(XI(:));

   for ipix = 1:npix % index in new (orthogonal) grid
   
      R = sqrt((XI(ipix) - X).^2 + ...
               (YI(ipix) - Y).^2);
               
      % Wondering whether would it be faster to 
      % * update R with the distance between  XI(ipix) and XI(ipix+1), or is min() the slowest process?
      % * do not use pixel by pixel but use larger chunks
      
      [pix.distance,pix.index] = min(R(:)); % index in old (random point) grid
      
    % if ~isempty(Rmax);
    %    OPT.Rmax = Rmax(pix.index); % locally varying max distance
    % end
      
      if (pix.distance < OPT.Rmax)
      ZI(ipix)                 = Z(pix.index);
     %else
     %NaN
      end
      
      if mod(ipix-1,floor(npix/OPT.ndisp))==0 
      disp(['processed ',num2str(100.*ipix./npix,'%0.2f'),' % in ',num2str(toc,'%0.2f'),' s'])
      end

   end

%% EOF