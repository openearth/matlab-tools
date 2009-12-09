function varargout = gradient2(varargin)
%GRADIENT2   first order spatial gradient in global co-ordinates in curvi-linear grid
%
%      gradient2(x,y,z) 
%
%   calculates gradient dz/dx and dz/dy (in global co-ordinates)
%   for data on curvilinear grid (x,y) (unlike GRADIENT, wich only
%   calculates gradients in matrix-space).
%
%    out    = GRADIENT2(...) returns a struct with fields fx and fy
%   [fx,fy] = GRADIENT2(...) returns 2 matrices fx and fy
%
%   Note that by default fx and fy are given at the centers of the grid (x,y)
%   The size of fx and fy is therefore 1 element smaller in both
%   matrix directions. With the default GRADIENT2 there are no border
%   effects: the total area covered with data is reduced with 
%   0.5 grid cell at every boundary (also internal holes where you have NaN's).
%   Optionally a central scheme can be chosen as used in GRADIENT. 
%   In this case the gradients are defined at the data points, with the
%   border containing gradients filled in with NaN (no confusing lower 
%   order approximations at all). 
%
%   out    = GRADIENT2(x,y,z,<'keyword',value>) where the following options 
%   are implemented:
%
%  * 'average': GRADIENT2(x,y,z,'average',value) with value 'min', 'max' or 'mean.
%
%      The input grid is triangulated. For each triangle the 
%      gradient is determined by fitting a plane through the 3 corner
%      points, by solving the exact equations of a plane. Thus, every quadrangle
%      contains 2 triangles. By default the gradient values in these 2 triangles
%      are averaged to get the gradient of the quadrangles. An extra (optional) 
%      argument can be provided to choose between 'min', 'max, and 'mean'. This 
%      can be used for example to check the accuracy for example. Note that the 
%      direction of the gradient might be a bit off when triangulation is 
%      performed oddly. Example:
%
%  * 'discretisation': GRADIENT2(x,y,z,'discretisation',value) with value 'upwind', or 'central'.
%
%      By default an upwind gradient method is used, where the results is 
%      staggered with respect to the input co-ordinates (x,y).
%      An alternative central differentiation method is also available.
%      In this method the gradients are defined at the same location as 
%      the input co-ordinates (x,y). The 'upwind' method is vectorized, 
%      the 'central' method not yet. For the borders no lower order discretisation
%      is used, but simply NaN are returned.
%                                                                            
%      |       |       |       |           |       |       |       |         
%      +   x   +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%      o---+---o---+---o---+---o---+-      o---+--2o3--+---o---+---o---+-    
%      |       |       |       |           |       |       |       |         
%      +   x   +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%     1o2--+--2o2--+---o---+---o---+-     1o2--+--2o2--+--3o2--+---o---+-    
%      |       |       |       |           |       |       |       |         
%      +  axa  +   x   +   x   +   x       +   x   +   x   +   x   +   x     
%      |       |       |       |           |       |       |       |         
%     1o1--+--2o1--+---o---+---o---+-      o---+--2o1--+---o---+---o---+-    
%                                                                            
%      discretisation: 'upwind'            discretisation: 'central'         
%                                                                            
%      the corner values at                the corner values at
%      (1,1), (1,2), (2,1), (2,2)          (2,1), (1,2), (2,3), (3,2)
%      are used to get a gradient at       are used to get a gradient at
%      CERNTER points (a,a)                CORNER points (2,2), corner points
%                                          at the boundary like (1,1), (2,1),(1,2)
% o: input corner data point               will get no gradient data but NaN.
% x: center point
%
%   See also: GRADIENT, QUAT, TRIQUAT, TRI2QUAT, TRI_GRAD, PCOLORCORCEN

% GRADIENT2 calls:
% - triquat
% - tri_grad
% - samesize

%%
%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
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


%% In
% ------------------------------

   x   = squeeze(varargin{1});
   y   = squeeze(varargin{2});
   z   = squeeze(varargin{3});
   
   sx = size(x);
   sy = size(y);
   sz = size(z);
   
   if ~ all(size(sx)==size(sy))
      error('x and y do not have same size')
   end
   
   if ~ all(size(sx)==size(sx))
      error('x and z do not have same size')
   end
   
   szcor  = size(x);
   
   sz1cor = size(x,1);
   sz2cor = size(x,2);
   
   sz1cen = sz1cor - 1;
   sz2cen = sz2cor - 1;
   
%% Keywords
% ------------------------------

   OPT.discretisation = 'upwind';
   OPT.average        = 'mean';

   %% Cycle keywords in input argument list
   %  to overwrite default values.
   %  Align code lines as much as possible
   %  to allow for block editing in textpad.
   % ------------------------
   
   if nargin>3
   iargin = 4;
   while iargin<=nargin,
     if ischar(varargin{iargin}),
       switch lower(varargin{iargin})
       case 'discretisation';iargin=iargin+1;OPT.discretisation  = varargin{iargin};
       case 'average'       ;iargin=iargin+1;OPT.average         = varargin{iargin};
       otherwise
          error(['Invalid string argument: %s.',varargin{iargin}]);
       end
     end;
     iargin=iargin+1;
   end; 
   end; 
   
   if strcmp(OPT.discretisation,'upwind')

      %% Triangulate curvi-linear grid
      %  and calculate gradients in all separate triangles.
      % -------------------------------------
      
         map     = triquat(x,y);
         
         %% replaces below 3 calls becuase it's faster, 
         %% becuase we know the structure of the data,
         %% while delaunay considers the co-ordinates 
         %% randomly distributed.
         
         % map.quat = quat(x,y);
         % tri      = delaunay(x,y);
         % map      = tri2quat(tri,quat);
      
      %% Calculate gradient per triangle
      % -------------------------------------

         [tri.fx,tri.fy] = tri_grad(x,y,z,map.tri);
         
         fx =  zeros([sz1cen,sz2cen]);
         fy =  zeros([sz1cen,sz2cen]);
         
      %% Map value at centres of trangles to centers
      %  of quadrangles using mapper provided by triquat.
      % -------------------------------------
      
      % 1ST traingle per quadrangle : tri_per_quat(:,1)
      % 2ND traingle per quadrangle : tri_per_quat(:,2)
      
             if strcmp(OPT.average,'min')
            fx(:) = min( tri.fx(map.tri_per_quat(:,1)),...
                         tri.fx(map.tri_per_quat(:,2)));
            fy(:) = min( tri.fy(map.tri_per_quat(:,1)),...
                         tri.fy(map.tri_per_quat(:,2)));
         elseif strcmp(OPT.average,'mean')
            fx(:) =     (tri.fx(map.tri_per_quat(:,1))+...
                         tri.fx(map.tri_per_quat(:,2)))./2;
            fy(:) =     (tri.fy(map.tri_per_quat(:,1))+...
                         tri.fy(map.tri_per_quat(:,2)))./2;
         elseif strcmp(OPT.average,'max')
            fx(:) = max( tri.fx(map.tri_per_quat(:,1)),...
                         tri.fx(map.tri_per_quat(:,2)));
            fy(:) = max( tri.fy(map.tri_per_quat(:,1)),...
                         tri.fy(map.tri_per_quat(:,2)));
         else
            error(['gradient2: averaging method unknown: either ''min'', ''max'' or ''mean'', not: ''',OPT.average,''''])
         end
   
   elseif strcmp(OPT.discretisation,'central')
   
         fx  =  nan.*zeros(szcor);
         fy  =  nan.*zeros(szcor);   
         fxA =  nan.*zeros(szcor);
         fyA =  nan.*zeros(szcor);   
         fxB =  nan.*zeros(szcor);
         fyB =  nan.*zeros(szcor);   
         
   %% Calculations
   % --------------------

%     |       |       |       |         
%     +   x   +   x   +   x   +   x     
%     |      B|3      |       |         
%     o---+---o---+---o---+---o---+-    
%     |     /:|:\     |       |         
%     +   /:::+:::\   +   x   +   x     
%     | /:::B:|:B:::\ |       |         
% AB1 o---+---o---+---oAB2+---o---+-    
%     | \%%%A%|%A%%%/ |       |         
%     +   \%%%+%%%/   +   x   +   x     
%     |     \%|%/     |       |         
%     o---+---o---+---o---+---o---+-    
%            A3

  %% Looped approach
  % ------------------

   n_triangles = 1; % one triangle per time in a looped manner
   
   %% tri indices into corner (x,y) matrices
   triA     = zeros(n_triangles,3);
   triB     = zeros(n_triangles,3);
  
   for ind1=2:szcor(1)-1
   for ind2=2:szcor(2)-1

      triA(:,1) = sub2ind(szcor,ind1-1,ind2  ); % 1st corner point AB1
      triA(:,2) = sub2ind(szcor,ind1+1,ind2  ); % 2nd corner point AB2
      triA(:,3) = sub2ind(szcor,ind1  ,ind2-1); % 3rd corner point A 3
      
      triB(:,1) = sub2ind(szcor,ind1-1,ind2  ); % 1st corner point AB1
      triB(:,2) = sub2ind(szcor,ind1+1,ind2  ); % 2nd corner point AB2
      triB(:,3) = sub2ind(szcor,ind1  ,ind2+1); % 3rd corner point  B3
      
      [fxA(ind1,ind2),...
       fyA(ind1,ind2)] = tri_grad(x,y,z,triA);
      
      [fxB(ind1,ind2),...
       fyB(ind1,ind2)] = tri_grad(x,y,z,triB);
   
   end
   end
   
  %% Vectorized attempt
  % ------------------
  
  %   %% all inpout excpet outer rows and columns
  %   n_triangles = (szcor(1)-2)*(szcor(2)-2)
  %   
  %   %% tri indices into corner (x,y) matrices
  %   triA     = zeros(n_triangles,3)
  %   triB     = zeros(n_triangles,3)
  %   
  %   [sub1,sub2]=meshgrid(1:szcor(1)-2,2:szcor(2)-1);
  %   [sub1,sub2]=meshgrid(3:szcor(1)  ,2:szcor(2)-1);
  %   [sub1,sub2]=meshgrid(2:szcor(1)-1,1:szcor(2)-2);
  %   
  %   triA(:,1) = sub2ind(szcor,1:szcor(1)-2,2:szcor(2)-1); % 1st corner point AB1
  %   triA(:,2) = sub2ind(szcor,3:szcor(1)  ,2:szcor(2)-1); % 2nd corner point AB2
  %   triA(:,3) = sub2ind(szcor,2:szcor(1)-1,1:szcor(2)-2); % 3rd corner point A 3
  %   
  %   triB(:,1) = sub2ind(szcor,1:szcor(1)-2,2:szcor(2)-1); % 1st corner point AB1
  %   triB(:,2) = sub2ind(szcor,3:szcor(1)  ,2:szcor(2)-1); % 2nd corner point AB2
  %   triB(:,3) = sub2ind(szcor,2:szcor(1)-1,3:szcor(2)  ); % 3rd corner point  B3
  %   
  %   [fxA(2:end-1,2:end-1),...
  %    fyA(2:end-1,2:end-1)] = tri_grad(x,y,z,triA);
  %    
  %   [fxB(2:end-1,2:end-1),...
  %    fyB(2:end-1,2:end-1)] = tri_grad(x,y,z,triB);
  %                    

  %% Average
  % ------------------

      if     strcmp(OPT.average,'min')
         fx  = min(fxA, fxB);  
         fy  = min(fyA, fyB);  
      elseif strcmp(OPT.average,'mean')
         fx  = (fxA + fxB)./2;  
         fy  = (fyA + fyB)./2;  
      elseif strcmp(OPT.average,'max')
         fx  = max(fxA, fxB);  
         fy  = max(fyA, fyB);  
      else
         error(['gradient2: averaging method unknown: either ''min'', ''max'' or ''mean'', not: ''',OPT.average,''''])
      end
   
   else
   
      error(['gradient2: discretisation method unknown: either ''upwind'' or ''central'', not: ''',OPT.discretisation,''''])

   end


%% Out
% ------------------------------

if nargout<2
   out.fx    = fx;
   out.fy    = fy;
   varargout = {out};
elseif nargout==2
   varargout = {fx,fy};
end

%% EOF