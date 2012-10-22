function varargout = plotMap(varargin)
%plotMap Plot a D-Flow FM unstructured map.
%
%   NB For faster scalar map plots, please use dflowfm.readFlowGeom2tri.
%
%     G  = dflowfm.readNet(ncfile) 
%     D  = dflowfm.readMap(ncfile,<it>) 
%    <h> = dflowfm.plotMap(G,D,<keyword,value>) 
%    <h> = dflowfm.plotMap(G,center_matrix,<keyword,value>) 
%          % or 
%    <h> = dflowfm.plotMap(ncfile,<it>,<keyword,value>);
%
%   plots a D-Flow FM unstructured map, optionally the handles h are returned.
%   For plotting multiple timesteps it is most efficient
%   to read the unstructured grid G once, and update D and plotMap.
%   Note that you need to read the grid G from the map file (*_map.nc),
%   not from the grid input file (*_net.nc) beause that lacks the
%   node connectivity information.
%
%   The following optional <keyword,value> pairs have been implemented:
%    * axis: only grid inside axis is plotted, use [] for while grid.
%            for axis to be be a polygon, supply a struct axis.x, axis.y.
%    * parameter: field in D.cen to plot (default 1st field 'zwl')
%   For user-defined paramter: simply add them to D before calling plotMapkml.
%   Cells with plot() properties, e.g. {'EdgeColor','k'}
%    * patch
%   Defaults values can be requested with OPT = dflowfm.plotNet().
%
%   Note: every flow cell is plotted individually as a patch: slow.
%
%   Apply any plot lay-out before plotMap: much fatser.
%
%   Example: plot maximum velocity
%
%     ncfile    = 'p01k3_map.nc';
%     G         = dflowfm.readNet(ncfile);
%     T.datenum = nc_cf_time(ncfile);
%
%     %% statistics
%     umax = zeros(size(G.cen.x));
%     for it=1:length(T.datenum)
%        ucx = ncread(ncfile,'ucx',[1 it],[Inf 1])';%ucx = nc_varget(ncfile,'ucx',[(it-1) 0],[1 Inf])';
%        ucy = ncread(ncfile,'ucy',[1 it],[Inf 1])';%ucy = nc_varget(ncfile,'ucy',[(it-1) 0],[1 Inf])';
%       [uth,ur] = cart2pol(ucx,ucy);
%        umax = max(umax, ur);
%     end   
%     delft3d_io_xyz('write', [filename(ncfile),'_umax.xyz'],G.cen.x,G.cen.y,umax);
%      
%     %% lay-out
%     clim([0 2])
%     colorbarwithvtext('max(u) [m/s]')
%     dflowfm.plotMap(G,umax)
%     axis equal
%     axis([100 220 540 620].*1e3)
%     tickmap('xy')
%     grid on
%     title(['Maximum velocity for in period ',datestr(T.datenum(1)),' - ',datestr(T.datenum(end))])
%
%   See also dflowfm, delft3d, readFlowGeom2tri

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
   OPT.patch     = {'EdgeColor','none','LineStyle','-'};
   OPT.parameter = [];
   OPT.quiver    = 1;
   OPT.layout    = 0;

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
      
      nextarg = 3;
      if ~odd(nargin)
        if isnumeric(varargin{2}) & isscalar(varargin{2}) & ischar(varargin{1}) % only output file, not input file
          it      = varargin{2};
          D       = dflowfm.readMap(ncfile,it);
        elseif isnumeric(varargin{2}) & isscalar(varargin{2}) & ~ischar(varargin{1})
          error('when timestep/data is supplied the first argument should be ''ncfile''.')
        elseif isnumeric(varargin{2}) & ~isscalar(varargin{2})
          it      = varargin{2};
          OPT.parameter     = 'auto';
          D.cen.(OPT.parameter) = varargin{2};
        elseif isstruct(varargin{2})
          D       = varargin{2};
        else
          error('??')
        end
      else
        D       = dflowfm.readMap(ncfile); % readMap gets last it
        nextarg = 2;
      end
      
      OPT = setproperty(OPT,varargin{nextarg:end});
      
   end
   
   if isempty(OPT.parameter)
      flds = fieldnames(D.cen);
      if length(flds)==0
         error('D.cen has no fields')
      else
        OPT.parameter = flds{1};
      end
   end
   
   if isnumeric(OPT.axis) & ~isempty(OPT.axis) % axis vector 2 polygon
   tmp        = OPT.axis;
   OPT.axis.x = tmp([1 2 2 1]);
   OPT.axis.y = tmp([3 3 4 4]);clear tmp
   end

%% plot centres (= flow cells = circumcenters)

if ~(isfield(G,'peri') & isfield(G,'cen'))

   error('unable to plot map: read BOTH the grid and map from *_map.nc (*_net.nc does not contain node connectivity!)')

else

   if isempty(OPT.axis)
      cen.mask = 1:G.cen.n; % TO DO: check whether all surrounding corners are outside, instead of centers
   else
      cen.mask = inpolygon(G.cen.x,G.cen.y,OPT.axis.x,OPT.axis.y);
   end
   
   peri.mask1 = find(cen.mask(G.cen.LinkType(cen.mask)==1));
   peri.mask  = find(cen.mask(G.cen.LinkType(cen.mask)~=1)); % i.e. 0=closed or 2=between 2D elements
   
   if ~iscell(G.peri.x) % can also be done in readNet
     [x,y] = dflowfm.peri2cell(G.peri.x(:,peri.mask),G.peri.y(:,peri.mask));
   else
      x = G.peri.x;
      y = G.peri.y;
   end

%% lay out !!!! before plotting patches: much faster !!!

   if OPT.layout
      hold on
      axis equal
      grid on
      title(D.datestr)
   end

%% plot

   h = repmat(0,[1 length(x)]);
   for icen=1:length(x)
      h(icen) = patch(x{icen},y{icen},D.cen.(OPT.parameter)(peri.mask(icen)));
   end

  %shading flat; % not needed an slow
  
   set(h,OPT.patch{:});
   
end
   
%% return handles

if nargout==1
   varargout = {h};
end
