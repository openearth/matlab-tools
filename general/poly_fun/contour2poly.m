function varargout = contour2poly(c)
%CONTOUR2POLY transforms contour array to NaN-delimited polygon vector
%
% [x,y] = CONTOUR2POLY(c) converts a contourc c vector like this
%
%  c = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
%       pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
%
% to a NaN-delimited polygon vectors like this:
%
%  x = [       x1 x2 x3 ... nan    x2 x2 x3 ...]
%  y = [       x1 x2 x3 ... nan    x2 x2 x3 ...]
%
% [x,y]        = CONTOUR2POLY(c) Note that level information 
%                is lost so this option is useful only for 
%                contours with only 1 level.
%
% [x,y,levels] = CONTOUR2POLY(c)
%
% struc        = CONTOUR2POLY(c) Returns struct with fields 
%                'x','y','n' and 'levels'.
%
% Note that although c=contourc also returns the contour x,y data 
% without plotting, it does not work for curvi-linear grids, so 
% we have to use [c,h]=contour(...); delete(h).
%
% Eaxmple:
% 
%    z=peaks;
%    [c,h]=contour(z,[-3 3])
%    hold on
%    L = contour2poly(c);
%    plot(L.x,L.y,'o')
%
% See also: CONTOURC, POLYSPLIT, POLYJOIN, POLY2CONTOUR

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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   if ~isempty(c)
      
      %% pre-allocate for efficient memory (speed)
      %% every [level1 pairs1] becomes a nan
      %% except the first one
      %% -----------------------------------------
      
      %% C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
      %%      pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
                
      length_c               = size(c,2);
      
      %% copy array and set delimiets to nan when all positions are known.
      %% -----------------------------------------
      S.x = c(1,2:end);
      S.y = c(2,2:end);
      
      %% Initialize
      %% -----------------------------------------
      
      ncontours     = 1;
      S.levels  (1) = c(1,1);%levels_per_contour
      S.n       (1) = c(2,1);% linepieces_per_contour
      delimiters(1) = S.n+1;
      
      %% Scroll through array (perhaps better to pre allocate:?
      %% S.levels = levels_per_contour
      %% S.n      = linepieces_per_contour
      %% delimiters
      %% -----------------------------------------
      
      while delimiters(end) < length_c
      
         ncontours             = ncontours + 1;
         S.levels  (ncontours) = c(1,delimiters(end)+1);
         S.n       (ncontours) = c(2,delimiters(end)+1);
         delimiters(ncontours) = sum(S.n) + ncontours;
      
      end
      
      %% Overwrite all delimiter positions with NaNs
      %% But remember, not the first one that we skip in the nan-separated array
      %% and not the last one, that is not even present in the c vector
      %% -----------------------------------------
      
      delimiters      = delimiters(1:end-1);
      S.x(delimiters) = nan;
      S.y(delimiters) = nan;
   
   
      %% Output
      %% -----------------------------------------

      if nargout==1
      
         varargout = {S};
         
      elseif nargout==2
      
         varargout = {S.x,S.y};
         
      elseif nargout==3
      
         varargout = {S.x,S.y,S.levels};

      end
   
   else %  if ~isempty(c)
   
      %% Output
      %% -----------------------------------------

      if nargout==1
      
         S.x       = [];
         S.y       = [];
         S.levels  = [];
         S.n       = [];
         varargout = {S};
         
      elseif nargout==2
      
         varargout = {[],[]};

      elseif nargout==3
      
         varargout = {[],[],[]};
         
      end   
   
   end %  if ~isempty(c)
   
%% EOF