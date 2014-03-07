function varargout = contour2poly(c,varargin)
%CONTOUR2POLY transforms contour array to NaN-delimited polygon vector
%
% [x,y] = CONTOUR2POLY(c) converts a contourc c vector like this
%
%  c = [level1 x1 x2 x3 level2 x4 x5 x6 x7 ...;
%       n1     y1 y2 y3 n2     y4 y5 y6 x7 ...]
%
% to a NaN-delimited polygon vectors like this:
%
%  x = [       x1 x2 x3 nan    x4 x5 x6 x7 ...]
%  y = [       x1 x2 x3 nan    x4 x5 x6 x7 ...]
%
% [x,y]        = CONTOUR2POLY(c) Note that level information 
%                is lost so this option is useful only for 
%                contours with only 1 level (e.g. coastline).
%
% [x,y,levels,n] = CONTOUR2POLY(c)
%
% where levels contains the c value assiocated with each
% polygonsegment, and n the number of points per segment.
%
% struc        = CONTOUR2POLY(c) Returns struct with fields 
%                'x','y','levels' and 'n'.
%
% Note that although c=contourc also returns the contour x,y data 
% without plotting, it does not work for curvi-linear grids, so 
% there we have to use [c,h]=contour(...); delete(h).
%
% Eaxmple:
% 
%    z=peaks;
%    [c,h]=contour(z,[-3 3])
%    hold on
%    L = contour2poly(c);
%    plot(L.x,L.y,'o')
%
% See also: CONTOURC, POLY_SPLIT, POLY_JOIN, POLY2CONTOUR

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

%   Quick and ulgy fix for "When contourc creates the contour matrix, it replaces the x,y 
%   coordinates containing the low z-values with NaNs to prevent contour lines that pass 
%   along matrix edges from being displayed. This is why contour matrices returned by 
%   contourf sometimes contain NaN values."
%   http://www.mathworks.nl/help/matlab/creating_plots/the-contouring-algorithm.html
%   We fill with last previous non-nan value (loopwise, not vectorized in
%   case of subsequent NaNs!)

OPT.fillnan = 0;

OPT = setproperty(OPT,varargin);

if OPT.fillnan

    mask = find(isnan(c(1,:)) | isnan(c(2,:)));
    disp(['filled ',num2str(length(mask)),' nans'])
    if any(mask)
        for ind = mask
        c(1,ind) = c(1,ind - 1);
        c(2,ind) = c(2,ind - 1);
        end
    end
    
end

   if ~isempty(c)
      
      %% pre-allocate for efficient memory (speed)
      %  every [level1 pairs1] becomes a nan
      %  except the first one
      %  -----------------------------------------
      
      %  C = [level1 x1 x2 x3 ... level2 x2 x2 x3 ...;
      %       pairs1 y1 y2 y3 ... pairs2 y2 y2 y3 ...]
                
      length_c               = size(c,2);
      
      %% copy array and set delimiters to NaN when all positions are known.
      %  -----------------------------------------
      S.x = c(1,2:end);
      S.y = c(2,2:end);
      
      %% Initialize
      %  -----------------------------------------
      
      ncontours     = 1;
      S.levels  (1) = c(1,1); % levels_per_contour
      S.n       (1) = c(2,1); % linepieces_per_contour
      delimiters(1) = S.n+1;
      
      %% Scroll through array (perhaps better to pre allocate)?
      %  S.levels = levels_per_contour
      %  S.n      = linepieces_per_contour

      %%  delimiters
      %  -----------------------------------------
      
      while delimiters(end) < length_c
      
         ncontours             = ncontours + 1;
         S.levels  (ncontours) = c(1,delimiters(end)+1);
         S.n       (ncontours) = c(2,delimiters(end)+1);
         delimiters(ncontours) = sum(S.n) + ncontours;
      
      end
      
      %  Overwrite all delimiter positions with NaNs
      %  But remember, not the first one that we skip in the nan-separated array
      %  and not the last one, that is not even present in the c vector
      %  -----------------------------------------
      
      delimiters      = delimiters(1:end-1);
      S.x(delimiters) = nan;
      S.y(delimiters) = nan;
   
   
      %% Output
      %  -----------------------------------------

      if nargout==1
      
         varargout = {S};
         
      elseif nargout==2
      
         varargout = {S.x,S.y};
         
      elseif nargout==3
      
         varargout = {S.x,S.y,S.levels};

      elseif nargout==4
      
         varargout = {S.x,S.y,S.levels,S.n};

      end
   
   else %  if ~isempty(c)
   
      %% Output
      %  -----------------------------------------

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

      elseif nargout==4
      
         varargout = {[],[],[],[]};
         
      end   
   
   end %  if ~isempty(c)
   
%% EOF