function TH = grid_angle(varargin)
%GRID_ANGLE  get angle orientation at centers of grid
%
%    TH = grid_angle(x,y,<keyword,value>) 
%
% gives the grid cell orientation TH defined as the 
% angle in radians between the m axis (1st dimension, say x-ish) 
% and the n-axis (2nd dimension, say y-ish) of the center points. 
%
% The following <keyword,value> pairs have been implemented.
% * dim       which dimension to use as (1st dimension, say x-ish)
%             default 1. Setting dim=2 does: x=x', y'y'.
%
% Works well for grids created with NDGRID, not with MESH_GRID.
%
% See also: GRID_FUN, NDGRID

% TO DO
% * location 'cen<ter>' (default) or 'cor<ner>' determines
%             whether TH is defines at teh cell centers (one 
%             smaller in both dimension) or at the coners (same
%             size as x and y)

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
% Created: 14 Jul 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Input

   cor.x = varargin{1};
   cor.y = varargin{2};
   
   OPT.location  = 'cen';
   OPT.dim       = 1;
   OPT.debug     = 0;
   
   OPT = setProperty(OPT,varargin{3:end});

%% Swap

   if OPT.dim==2
     cor.x = cor.x';
     cor.y = cor.y';
   end

%% Calculate

   if strcmpi(OPT.location(1:3),'cen')
   
      %cen.dxdksi                  = (+ cor.x(2:end  ,2:end  ) - cor.x(1:end-1,2:end  ) ...
      %                               + cor.x(2:end  ,1:end-1) - cor.x(1:end-1,1:end-1))./2;
      %
      %cen.dydksi                  = (+ cor.y(2:end  ,2:end  ) - cor.y(1:end-1,2:end  ) ...
      %                               + cor.y(2:end  ,1:end-1) - cor.y(1:end-1,1:end-1))./2;
      %          
      %TH = atan2(cen.dydksi, cen.dxdksi);
      
      TH = repmat(nan,[size(cor.x,1)-1,size(cor.x,2)-1,4]);
      
      cen.dxdksi                  =  + cor.x(2:end  ,1:end-1) - cor.x(1:end-1,1:end-1);
      cen.dydksi                  =  + cor.y(2:end  ,1:end-1) - cor.y(1:end-1,1:end-1);
      TH(:,:,1) = atan2(cen.dydksi, cen.dxdksi);
      
      cen.dxdksi                  =  + cor.y(2:end  ,2:end  ) - cor.y(2:end  ,1:end-1);
      cen.dydksi                  =  + cor.x(2:end  ,2:end  ) - cor.x(2:end  ,1:end-1);
      TH(:,:,2) = -atan2(cen.dydksi, cen.dxdksi);
      
      cen.dxdksi                  =  + cor.x(2:end  ,2:end  ) - cor.x(1:end-1,2:end  );
      cen.dydksi                  =  + cor.y(2:end  ,2:end  ) - cor.y(1:end-1,2:end  );
      TH(:,:,3) = atan2(cen.dydksi, cen.dxdksi);
      
      cen.dxdksi                  =  + cor.y(1:end-1,2:end  ) - cor.y(1:end-1,1:end-1);
      cen.dydksi                  =  + cor.x(1:end-1,2:end  ) - cor.x(1:end-1,1:end-1);
      TH(:,:,4) = -atan2(cen.dydksi, cen.dxdksi);
      
      if OPT.debug
      rad2deg(TH(:))
      end
      
      TH = mean(TH,3);

   elseif strcmpi(OPT.location(1:3),'cor')
   
   error('GRID_ANGLE not tested yet for corner')
      
      cor.dxdksi = repmat(nan,size(cor.x));
      cor.dydksi = repmat(nan,size(cor.x));
      
      cor.dxdksi(2:end-1,2:end-1) = (+ cor.x(3:end  ,2:end-1) - cor.x(1:end-2,2:end-1));
      cor.dydksi(2:end-1,2:end-1) = (+ cor.y(3:end  ,2:end-1) - cor.y(1:end-2,2:end-1));
      
      cor.dxdksi(2:end-1,2:end-1) = (+ cor.x(3:end  ,2:end-1) - cor.x(1:end-2,2:end-1));
      cor.dydksi(2:end-1,2:end-1) = (+ cor.y(3:end  ,2:end-1) - cor.y(1:end-2,2:end-1));

      TH   = atan2(cor.dydksi, cor.dxdksi);
   
   end

%% EOF