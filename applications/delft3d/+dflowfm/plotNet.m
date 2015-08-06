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
%    * idmn: plot grid with the specified domain number only (if available)
%   Cells with plot() properties, e.g. {'r*'}, if [] corners are not plotted.
%    * node
%    * edge
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
   OPT.face  = {'b.'};
   OPT.node  = {'r.','markersize',10};
   OPT.edge  = {'k-'};
   OPT.idmn  = -1;   % domain to plot
   
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
   
   if isnumeric(OPT.axis) && ~isempty(OPT.axis) % axis vector 2 polygon
       tmp        = OPT.axis;
       OPT.axis.x = tmp([1 2 2 1]);
       OPT.axis.y = tmp([3 3 4 4]);
       clear tmp
   end

%% plot nodes ([= corners)

   if isfield(G,'node') && ~isempty(OPT.node)
   
     if isempty(OPT.axis)
        node.mask = true(1,G.node.n);
     else
        node.mask = inpolygon(G.node.x,G.node.y,OPT.axis.x,OPT.axis.y);
     end
     

     if ( isfield(G.face, 'FlowElemCont_x') && isfield(G.face, 'FlowElemCont_y') )
%        plot nodes with cell mask later (to be preferred, as we don't have node domain numbers)
     else
%        plot nodes with node mask         
         h.node  = plot(G.node.x(node.mask),G.node.y(node.mask),OPT.node{:});
         hold on
         disp('here')
     end

   end
   
%% plot centres (= flow cells = circumcenters)

%    if isfield(G,'face')
%      if isempty(OPT.axis)
%         face.mask = true(1,G.face.FlowElemSize);
%      else
%         face.mask = inpolygon(G.face.FlowElemCont_x,G.face.FlowElemCont_y,OPT.axis.x,OPT.axis.y);
%      end
%      
%      if ( OPT.idmn>-1 && isfield(G.face,'FlowElemDomain') )
%          if ( length(G.face.FlowElemDomain)==G.face.FlowElemSize )
%             face.mask = (face.mask & G.face.FlowElemDomain==OPT.idmn);
%          end
%      end
%    end
% 
%    if isfield(G,'face') && ~isempty(OPT.face)
%    
%        h.node = plot(reshape(G.face.FlowElemCont_x(:,face.mask),1,[]), reshape(G.face.FlowElemCont_y(:,face.mask),1,[]), OPT.node{:});
%        hold on
%        h.face = plot(G.face.FlowElemCont_x(:,face.mask),G.face.FlowElemCont_y(:,face.mask),OPT.face{:});
%        hold on
%    
%    end

%% plot connections (network edges)
%  plot contour of all circumcenters inside axis  
%  Always plot entire perimeter, so perimeter is partly 
%  outside axis for boundary flow cells. 
%  We turn all contours into a nan-separated polygon. 
%  After plotting this is faster than patches (only one figure child handle).

   if isfield(G,'edge') && ~isempty(OPT.edge)
    
    x = G.node.x(G.edge.NetLink);
    y = G.node.y(G.edge.NetLink);    
    
    x(3,:)=NaN;
    y(3,:)=NaN;
       
    if isempty(OPT.axis)
        h.edge = plot(x(:),y(:),OPT.edge{:});  
    else
        %REQUIRES FURTHER LOOKING
        edge.mask = inpolygon(x,y,OPT.axis.x,OPT.axis.y);
        h.edge = plot(x(edge.mask),y(edge.mask),OPT.edge{:});
    end        
    hold on   
   end
   
%% lay out

%    hold on
%    axis equal
%    grid on
   
%% return handles

   if nargout==1
      varargout = {h};
   end
