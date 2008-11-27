function varargout = xy2mn(x,y,xv,yv)
%XY2MN  get indices of random (x,y) points in curvilinear grid
%
% [m,n] = xy2mn(xy2mn(x,y,xv,yv) returns indices (m,n)
% of the curvilinear (x,y) grid of points closest
% to the random points (xv,yv) where m is the 1st, and 
% n is teh 2nd dimension of x and y.
%
% Alternatives:
%  struct      = xy2mn(...) with fields m, n, mn and eps (match accuracy)
% [m,n,mn]     = xy2mn(...)
% [m,n,mn,eps] = xy2mn(...)
% where mn = the linear index.
%
% See also:
% SUB2IND, IN2SUB, FIND, MIN, MAX

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
%   --------------------------------------------------------------------

mn   = zeros(size(xv));
m    = zeros(size(xv));
n    = zeros(size(xv));
mmax = size(x,1);

%method = 'curvilinear';
%
%switch method
%
%case 'unstructured'
%
%   z    = 1:prod(size(x));
%   z    = reshape(z,size(x));
%
%   %% TOO SLOW !!!!!!!!!
%
%   mask = ~isnan(x)&~isinf(x)&~isnan(y)&~isinf(y);
%   
%   for i=1:length(xv(:))
%      mn(i) = griddata(x(mask),y(mask),z(mask),xv(i),yv(i),'nearest');
%      % NOT zero based
%      m(i)  = mod(mn(i)-1,mmax)+1;
%      n(i)  = div(mn(i)-1,mmax)+1;
%      disp(['Processed ',num2str(i),' of ',num2str(length(xv(:))),...
%      ' mn = ',num2str(mn(i)),...
%      ' m = ' ,num2str(m (i)),...
%      ' n = ' ,num2str(n (i))])
%   end
%
%case 'curvilinear'

   accuracy  = zeros(size(xv)); % distance between matrix node and random point

   for i=1:length(xv(:))

      %% get matrix of distances between random point and all matrix nodes
      %% -----------------------------
      dist = sqrt((x - xv(i)).^2 + ...
                  (y - yv(i)).^2);
                  
                  %pcolor(x,y,dist)
                  %colorbar
                  %pausedisp
                  %hold on
                  
      %% The (m,n) we are looking for is where this distance is minimal 
      %% -----------------------------

      [accuracies,mns] = min(dist(:));
      
      if length(accuracies) >1 
         disp(['Point ',num2str(xv(i)),'',num2str(yv(i)),'has multiple matches in matrix, one is arbitrarily chosen.'])
      end
      
      accuracy(i) = accuracies(1);
      mn(i)       = mns(1);

      %% NOT zero based,
      %% can also use sub2ind here.
      %% -----------------------------
      m(i)        = mod(mn(i)-1,mmax)+1;
      n(i)        = div(mn(i)-1,mmax)+1;
   end

%end

%% Output
%% -----------------------------

if nargout==1
   S.m   = m;
   S.n   = n;
   S.mn  = mn;
   S.eps = accuracy;
   varargout = {S};
elseif nargout==2
   varargout = {m,n};
elseif nargout==3
   varargout = {m,n,mn};
elseif nargout==4
   varargout = {m,n,mn,accuracy};
end


function intdiv = div(x,y)
%   DIV(x,y) floor(x./y) if y < 0.
%            ceil (x./y) if y > 0.
% - Number of times y fits into x.
% - Limits x to largets integer multiple of y 
%
% Note that rem  = mod in fortran
%           mod ~= mod in fortran

%  if x>=0
%   intdiv = floor(x./y);
%  elseif x<0
%   intdiv = ceil(x./y);
%  end

% SAME AS
  intdiv = sign(x).*sign(y).*floor(abs(x./y));