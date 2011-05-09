function varargout = readNet2tri(varargin)
%readNet   Reads network data of a D-Flow FM unstructured net as a set of triangles
%
%     G = dflowfm.readNet2tri(ncfile) 
%
%   reads the network network (grid) data from a D-Flow FM NetCDF file
%   and triangulates it by splitting all quadrilatersls and pentagons
%   into triangles. G contains
%
%    cor: node = corner data (incl. connectivity)
%    map: original patch mapping information
%    tri: triangulation mapping information
%      n: numbers of [1 2 3 4 5 6 7]-agons
%
% NOTE: cor and cen from dflowfm.readNet are exactly identical objects 
% but their meaning in the network differs. G.link contains the 
% relation between the cor and cen object.
%
% The triangulation allows much fatser plots than plotting per
% patch as dflowfm.plotMap, but can only handle data at corners 
% currently, not data at centers where dflowfm.plotMap assumed data.
%
% Example:
%
%   ncfile = 'p01w_thd_crs_vak_map.nc';
%   G      = dflowfm.readNet2tri(ncfile)
%   trisurf(G.tri,G.cor.x,G.cor.y,G.cor.z)
%   shading interp
%   view(0,90)
%   tickmap('xy')
%
% See also: dflowfm, delft3d, triquat, delauney

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% input

   OPT.debug = 0;

   if nargin==0
      varargout = {OPT};
      return
   else
      ncfile   = varargin{1};
      OPT = setProperty(OPT,varargin{2:end});
   end

%% read network: corners only: input file

   D.cor.x    = nc_varget(ncfile,'NetNode_x');
   D.cor.y    = nc_varget(ncfile,'NetNode_y');
   D.cor.z    = nc_varget(ncfile,'NetNode_z');
   D.map      = nc_varget(ncfile,'NetElemNode');

%% determine # of triangles

   nface    = sum(D.map > 0,2);

   D.n(3)     = sum(nface==3);
   D.n(4)     = sum(nface==4); % become 2 triangles each
   D.n(5)     = sum(nface==5); % become 3 triangles each
   D.n(6)     = sum(nface==6); % become 4 triangles each
   D.n(7)     = sum(nface==7); % become 5 triangles each
   ntri       = sum(D.n.*[0 0 1 2 3 4 5]);
   D.tri      = repmat(int32(0),[ntri 3]);
   
%% 3: re-use exisitng triangles

   ind = find(nface==3);
   D.tri(1:length(ind),:)     = D.map(ind,1:3);

%% 4: quadrilaterals: 2 triangles each

   if OPT.debug
      ind = find(nface==3);
      tri     = D.map(ind,1:3);
      trisurf(tri,D.cor.x,D.cor.y,D.cor.z)
      view(0,90)
      hold on
   end  

   ind = find(nface==4);
   n   = D.n(3);

   for i=1:length(ind)
   
       quad     = D.map(ind(i),1:4);
       x        = D.cor.x(quad);
       y        = D.cor.y(quad);
       trilocal = delaunay(x,y); % sometimes fails for perfect square, and does not always yield 2 triangles
       
       if size(trilocal,1) > 2
          warning(['quadrilateral is not divided onto 2 triangles but ',num2str(size(trilocal,1)),': triangle(s) ingnored'])
          trilocal = trilocal(1:2,:);
          if OPT.debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       elseif size(trilocal,1) < 2
          warning(['quadrilateral is not divided onto 2 triangles but ',num2str(size(trilocal,1)),': triangle duplicated'])
          trilocal = [trilocal;trilocal];
          if OPT.debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       end
       
       D.tri(n+1:n+2,:) = quad(trilocal);
       n   = n + 2;
   
   end

%% 5: pentagons: 3 triangles each

   ind = find(nface==5);
   if ~(n== sum(D.n.*[0 0 1 2 0 0 0]))
       error('error after tri + quad')
   end
   %n== D.n(3) + D.n(4)*2; % overwrite already existing 3 + 4

   for i=1:length(ind)
   
       pent     = D.map(ind(i),1:5);
       x        = D.cor.x(pent);
       y        = D.cor.y(pent);
       trilocal = delaunay(x,y); % sometimes fails, and does not always yield 3 triangles
       
       if size(trilocal,1) > 3
          warning(['pentagon is not divided onto 3 triangles but ',num2str(size(trilocal,1)),': triangle(s) ingnored'])
          trilocal = trilocal(1:3,:);
          if OPT.debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       elseif size(trilocal,1) < 3
          warning(['pentagon is not divided onto 3 triangles but ',num2str(size(trilocal,1)),': triangle(s) duplicated'])
          if size(trilocal,1) ==1
          trilocal = [trilocal;trilocal;trilocal];
          else
          trilocal = [trilocal;trilocal(1,:)];
          end
          if OPT.debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       end
       
       D.tri(n+1:n+3,:) = pent(trilocal);
       n   = n + 3;
   
   end

%% 6

   ind = find(nface==6);
   if ~(n== sum(D.n.*[0 0 1 2 3 0 0]))
       error('error after tri + quad + pent')
   end

   if ~isempty(ind)
   error('hexagons not implemented yet')
   end

%% 7

   ind = find(nface==7);
   if ~(n== sum(D.n.*[0 0 1 2 3 4 0]))
       error('error after tri + quad + hex')
   end

   if ~isempty(ind)
   error('heptagons not implemented yet')
   end

%% out

   varargout = {D};