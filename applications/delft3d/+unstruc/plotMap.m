function varargout = plotMap(varargin)
%plotMap Plot an unstructured map.
%
%     G  = unstruc.readNet(ncfile) 
%     D  = unstruc.readMap(ncfile,<it>) 
%    <h> = unstruc.plotMap(G,D,<keyword,value>) 
%          % or 
%    <h> = unstruc.plotMap(ncfile,<it>,<keyword,value>);
%
%   plots an unstructured map,
%   optionally the handles h are returned.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for while grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%   Cells with plot() properties, e.g. {'EdgeColor','k'}
%    * patch
%    * parameter: field in D.cen to plot
%   Defaults values can be requested with OPT = unstruc.plotNet().
%
%   Note: every flow cell is plotted individually as a patch: slow.
%
%   See also UNSTRUC

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

%% input

   OPT.axis      = []; % [x0 x1 y0 y1] or polygon OPT.axis.x, OPT.axis.y
   % arguments to plot(x,y,OPT.keyword{:})
   OPT.patch     = {'k-'};
   OPT.parameter = 'zwl';
   OPT.quiver    = 1;

   if nargin==0
      varargout = {OPT};
      return
   else
      if ischar(varargin{1})
      ncfile   = varargin{1};
      G        = unstruc.readNet(ncfile);
      else
      G        = varargin{1};
      end
      
      nextarg = 3;
      if ~odd(nargin)
        if isnumeric(varargin{2}) & ischar(varargin{1}) % only output file, not input file
          it      = varargin{2};
          D       = unstruc.readMap(ncfile,it);
        elseif isstruct(varargin{2})
          D       = varargin{2};
        else
          error('when timestep is supplied the first argument should be ''ncfile''.')
        end
      else
        D       = unstruc.readMap(ncfile); % readMap gets last it
        nextarg = 2;
      end
      
      OPT = setProperty(OPT,varargin{nextarg:end});
      
   end
   
   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end

%% plot centres (= flow cells = circumcenters)

   if isfield(G,'peri')

   if isempty(OPT.axis)
      cen.mask = 1:G.cen.n;
   else
      cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
   end
   
   peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
   peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
   
   if ~iscell(G.peri.x) % can also be done in readNet
     [x,y] = unstruc.peri2cell(G.peri.x(:,peri.mask),G.peri.y(:,peri.mask));
   else
      x = G.peri.x;
      y = G.peri.y;
   end

%% lay out !!!! before plotting patches: much faster !!!

   hold on
   axis equal
   grid on
   title(D.datestr)

%% plot

   h = repmat(0,[1 length(x)]);
   for icen=1:length(x)
      h(icen) = patch(x{icen},y{icen},D.cen.(OPT.parameter)(peri.mask(icen)));
   end

  %shading flat; % not needed an slow
   
   set(h,OPT.patch{:})
   
   end
   
%% return handles

   if nargout==1
      varargout = {h};
   end
