function varargout = readNet2tri(varargin)
%readNet   Reads network data of a D-Flow FM unstructured net as a set of triangles
%
%     G          = dflowfm.readNet2tri(ncfile) 
%    [tri,x,y]   = dflowfm.readNet2tri(ncfile) 
%    [tri,x,y,z] = dflowfm.readNet2tri(ncfile) 
%
%   reads the network network (grid) data from a D-Flow FM netCDF file
%   and triangulates it by splitting all quadrilatersls and pentagons
%   into triangles. G contains
%
%        cor: node = corner data (x,y,z)
%        map: original patch mapping information
%        tri: triangulation mapping information
%          n: numbers of [1 2 3 4 5 6]-agons
%  patch2tri: permutation index to replicate patch center
%             data (triangles, quadrilaterals, pentagons, 
%             hexagons) to triangle face data
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
%    ncfile    = '*_map.nc'
%    G         = dflowfm.readNet2tri(ncfile);
%    G.datenum = nc_cf_time(ncfile);
%
%    % plot corner data: shading interp look
%    
%    trisurf(G.tri,G.cor.x,G.cor.y,G.cor.z);
%    shading interp
%    colorbarwithvtext('depth [m]')
%    view   (0,90)
%    axis    equal
%    tickmap('xy')
%    grid    on
%     
%    % plot center data: shading flat look
%    
%    figure
%    % tricontour(G.tri,G.cor.x,G.cor.y,G.cor.z,[-2 -2],'k'); % not always works
%    hold on
%    for it=1:length(G.datenum)
%      D      = dflowfm.readMap(ncfile,it);
%      h = trisurf(G.tri,G.cor.x,G.cor.y,G.cor.y.*-1e3,... % set z below tricontour()
%                  'FaceColor','flat',...
%                      'cdata',D.cen.zwl(G.patch2tri),...
%                  'EdgeColor','none');
%      title(datestr(D.datenum))
%      clim([-1 1]);
%      colorbarwithvtext('\eta [m]')
%      view   (0,90)
%      axis    equal
%      tickmap('xy')
%      grid    on
%      pausedisp
%      delete(h)
%     end    
%
% See also: DFLOWFM, DELFT3D, TRIQUAT, DELAUNEY, TRISURF, TRICONTOUR

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

   nface       = sum(D.map > 0,2);

   D.n(3)      = sum(nface==3);
   D.n(4)      = sum(nface==4); % become 2 triangles each
   D.n(5)      = sum(nface==5); % become 3 triangles each
   D.n(6)      = sum(nface==6); % become 4 triangles each
   ntri        = sum(D.n.*[0 0 1 2 3 4]);
   D.tri       = repmat(int32(0),[ntri 3]);
   
%% 3: re-use exisitng triangles

   ind = find(nface==3);
   D.tri      (1:length(ind),:) = D.map(ind,1:3);
   D.patch2tri(1:length(ind))   = ind;

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
   length(ind)
   rep = make1d(repmat(ind,[1 2])')';
   D.patch2tri  = [D.patch2tri, rep];

   n            = D.n(3);
  [D.tri,n]     = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,4,n,ind,OPT.debug,'quadrilateral');

%% 5: pentagons: 3 triangles each

   ind = find(nface==5)
   rep = make1d(repmat(ind,[1 3])')';
   
   if ~(n== sum(D.n.*[0 0 1 2 0 0]));error('error after tri + quad');end
  [D.tri,n]     = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,5,n,ind,OPT.debug,'pentagon');
   D.patch2tri  = [D.patch2tri, rep];

%% 6: hexagons: 4 triangles each

   ind = find(nface==6);
   rep = make1d(repmat(ind,[1 4])')';
   if ~(n== sum(D.n.*[0 0 1 2 3 0]));error('error after tri + quad + pent');end
  [D.tri,n]     = nface2tri(D.map,D.cor.x,D.cor.y,D.tri,6,n,ind,OPT.debug,'hexagon');
   D.patch2tri  = [D.patch2tri, rep];

%% out

   if nargout==1
     varargout = {D};
   elseif nargout==3
     varargout = {D.tri,D.cor.x,D.cor.y};
   elseif nargout==4
     varargout = {D.tri,D.cor.x,D.cor.y,D.cor.z};
   end
   
%% genericish subsidiary for quad-, pent- and hexagons

function [tri,n] = nface2tri(Map,X,Y,tri,type,n,ind,debug,txt)

   order = type-2;

   for i=1:length(ind)
   
       pointers = Map(ind(i),1:type);
       x        = X(pointers);
       y        = Y(pointers);
       trilocal = delaunay(x,y); % sometimes fails, and does not always yield correct # of triangles
       
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
   