function varargout = plotNet(varargin)
%plotNet  Plot a D-Flow FM unstructured grid.
%
%     G  = dflowfm.readNet(ncfile) 
%    <h> = dflowfm.plotNet(G     ,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotNet(ncfile,<keyword,value>) 
%
%   plots a D-Flow FM unstructured net (centers, corners, contours),
%   optionally the handles h are returned.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for while grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%   Cells with plot() properties, e.g. {'r*'}, if [] corners are not plotted.
%    * cor
%    * cen
%    * peri
%   Defaults values can be requested with OPT = dflowfm.plotNet().
%
%   Note: all flow cells are plotted as one NaN-separated line: fast.
%
%   See also dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
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

% TO DO: to do: plot center connectors (NetElemNode)
% TO DO: to do: plot 1D cells too

%% input

   OPT.axis = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.cen  = {'b.'};
   OPT.cor  = {'y.','markersize',20};
   OPT.peri = {'k-'};
   
   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
      ncfile   = varargin{1};
      G        = dflowfm.readNet(ncfile);
      else
      G        = varargin{1};
      end
      OPT = setproperty(OPT,varargin{2:end});
   end
   
   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end

%% plot corners ([= nodes)

   if isfield(G,'cor') & ~isempty(OPT.cor)
   
     if isempty(OPT.axis)
        cor.mask = 1:G.cor.n;
     else
        cor.mask = inpolygon(G.cor.x,G.cor.y,OPT.axis.x,OPT.axis.y);
     end
     
     h.cor  = plot(G.cor.x(cor.mask),G.cor.y(cor.mask),OPT.cor{:});
     hold on

   end

%% plot centres (= flow cells = circumcenters)

   if isfield(G,'cen') & ~isempty(OPT.cen)
   
     if isempty(OPT.axis)
        cen.mask = 1:G.cen.n;
     else
        cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
     end
     
     h.cen = plot(G.cen.x(cen.mask),G.cen.y(cen.mask),OPT.cen{:});
     hold on
   
   end

%% plot perimeters (= contours = flow cell faces)
%  plot contour of all circumcenters inside axis 
%  Always plot entire perimeter, so perimeter is partly 
%  outside axis for boundary flow cells. 
%  We turn all contours into a nan-separated polygon. 
%  After plotting this is faster than patches (only one figure child handle).

   if isfield(G,'peri') & ~isempty(OPT.peri)

     peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
     peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
     
     if ~iscell(G.peri.x) % can also be done in readNet
       [x,y] = dflowfm.peri2cell(G.peri.x(:,peri.mask),G.peri.y(:,peri.mask));
        x    = poly_join(x);
        y    = poly_join(y);
     else
        x    = poly_join({G.peri.x{peri.mask}});
        y    = poly_join({G.peri.y{peri.mask}});
     end
     
     h.per = plot(x,y,OPT.peri{:});   
     hold on
   
   end
   
%% lay out

   hold on
   axis equal
   grid on
   
%% return handles

   if nargout==1
      varargout = {h};
   end
