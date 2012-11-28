function varargout = readFlowGeom2tri(varargin)
%readNet   Reads network as triangles only for speed-up with TRISURF
%
%     G = dflowfm.readFlowGeom2tri(ncfile) 
%
%   reads the network (flow geometry) data from a D-Flow FM NetCDF file
%   and triangulates it by splitting all polygonal cells into triangles.
%   G contains
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
% The triangulation allows much faster plots than plotting per
% patch as dflowfm.plotMap, but can only handle data at corners 
% currently, not data at centers where dflowfm.plotMap assumes scalars.
%
% Example:
%
%   ncfile = 'p01w_thd_crs_vak_map.nc';
%   G      = dflowfm.readFlowGeom2tri(ncfile)
%   trisurf(G.tri,G.cor.x,G.cor.y,G.cor.z)
%   shading interp
%   view(0,90)
%   tickmap('xy')
%
% See also: dflowfm, delft3d, triquat, delaunay

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
      OPT = setproperty(OPT,varargin{2:end});
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
   ntri       = sum(D.n.*[0 0 1 2 3 4]);
   D.tri      = repmat(int32(0),[ntri 3]); % pre-allocate for speed
   
%% 3: re-use existing triangles

   ind = find(nface==3);
   D.tri(1:length(ind),:)     = D.map(ind,1:3);

%% plot existing triangles

   if OPT.debug
      ind = find(nface==3);
      tri     = D.map(ind,1:3);
      trisurf(tri,D.cor.x,D.cor.y,D.cor.z)
      view(0,90)
      hold on
   end
   
%% 4: quadrilaterals: 2 triangles each

   ind = find(nface==4);
   n   = D.n(3);
   % Split quad into two triangles directly: cut 'along' shortest diagonal.
   ismaindiag = (   (D.cor.x(D.map(ind,1)) - D.cor.x(D.map(ind,3))).^2 ...
                  + (D.cor.y(D.map(ind,1)) - D.cor.y(D.map(ind,3))).^2 ...
                ) > (D.cor.x(D.map(ind,2)) - D.cor.x(D.map(ind,4))).^2 ...
                  + (D.cor.y(D.map(ind,2)) - D.cor.y(D.map(ind,4))).^2;
   ntri1 = sum(ismaindiag);
   ntri2 = sum(~ismaindiag);
   i1 = ind(ismaindiag);
   i2 = ind(~ismaindiag);

   % Quads where 2--4 is shortest diagonal: tris are 1-2-4 and 2-3-4
   D.tri(n+1:n+ntri1,            1:3) = D.map(i1,[1 2 4]);
   D.tri(n+ntri1+1:n+2*ntri1,    1:3) = D.map(i1,[2 3 4]);
   n = n+2*ntri1;

   % Quads where 1--3 is shortest diagonal: tris are 1-2-3 and 1-3-4
   D.tri(n+1:n+ntri2,            1:3) = D.map(i2,[1 2 3]);
   D.tri(n+ntri2+1:n+2*ntri2,    1:3) = D.map(i2,[1 3 4]);
   n = n+2*ntri2;

   %[D.tri,n] = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,4,n,ind,OPT.debug,'quadrilateral');
   
%% 5: pentagons: 3 triangles each

   ind = find(nface==5);
   if ~(n== sum(D.n.*[0 0 1 2 0 0]));error('error after tri + quad');end
   [D.tri,n] = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,5,n,ind,OPT.debug,'pentagon');

%% 6

   ind = find(nface==6);
   if ~(n== sum(D.n.*[0 0 1 2 3 0]));error('error after tri + quad + pent');end
   [D.tri,n] = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,6,n,ind,OPT.debug,'hexagon');

%% out

   varargout = {D};
   
%% genericish subsidiary for quad-, pent- and hexagons

function [tri,n] = nface2tri(Map,X,Y,tri,type,n,ind,debug,txt)

   order = type-2;

   for i=1:length(ind)
   
       pointers = Map(ind(i),1:type);
       x        = X(pointers);
       y        = Y(pointers);
       trilocal = delaunay(x,y); % sometimes fails, and does not always yield 3 triangles
       
       if size(trilocal,1) > order
          warning([txt,' is not divided onto ',num2str(order),' triangles but ',num2str(size(trilocal,1)),': triangle(s) ingnored'])
          trilocal = trilocal(1:order,:);
          if debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       elseif size(trilocal,1) < order
          warning([txt,' is not divided onto ',num2str(order),' triangles but ',num2str(size(trilocal,1)),': triangle(s) duplicated'])
          
          trilocal = repmat(trilocal,[order 1])
          
          if debug
             plot(x,y,'c-o','linewidt',10)
             pausedisp
          end
       end
       
       tri(n+1:n+order,:) = pointers(trilocal);
       n                  = n + order;
       
   end       
   