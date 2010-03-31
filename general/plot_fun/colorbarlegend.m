function varargout = colorbarlegend(varargin)
%COLORBARLEGEND   Overlays colorbar in separate axes.
% 
% COLORBARLEGEND plots a colorbar in another axes.
% This axes is (i) either an exisiting axes passed by handle
% or (ii) it is created on top of axising axes in the current figure.
% at the specified position. When the colorbar is drawn 
% at a specified position it does not affect the position of other axes.
% Does not work properly for suplots due to 'OuterPosition' property.
%
% Use:
% COLORBARLEGEND(                 clims,<'option',value>)
% COLORBARLEGEND(     xlims,ylims,clims,<'option',value>)
% COLORBARLEGEND(axes,            clims,<'option',value>)
% COLORBARLEGEND(axes,xlims,ylims,clims,<'option',value>)
%
% axeshandle = COLORBARLEGEND(xlims,ylims,clims)
%
% The positions can be specified in data units, or in
% normalized units. The colorbar is plotted for the range 
% specified in clim:
%
% OPTIONS          VALUES
% ---------------- ---------------------------
% - units          'data'        ,'normalized' <default> passed to axesontop
% - reference      'gcf'         ,'gca'        <default> passed to axesontop
% - ontop           1,           ,0            <default> passed to axesontop
%
% - title           string array
% - titleposition   string array: title, xlabel, ylabel, htext, vtext
% - titlecolor      .
% - orientation    'vertical'    ,'horizontal' <default>
% - ctick           real array
%                   [] for ctick=clim
%                   nan for auto               <default>
%
% As the colorbar is overlaid on other axes it is INVISIBLE 
% by default. Make sure to make it visible by setting it 
% to active the moment you want to see/plot it using axes(A). 
% Or set keyword 'ontop' to 1, to make it directly visible, 
% but then do realize that the next plotting event
% will happen in the very colorbar axes.
%
% Calls AXESONTOP to create axes.
%
% Note: colorbar does not appear correctly on screen, but prints
% correctly to A4 paper when no automatic subplots and colorbars are present.
%
%See also: COLORBAR, AXESONTOP, KML colorbar

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

zposition   = -1e3;         % vertical psoition colorbar patch within axes
xlims       = [];
ylims       = [];

if ishandle(varargin{1})
   AX          = varargin{1};
   if isnumeric(varargin{4})
      xlims    = varargin{2};
      ylims    = varargin{3};
      clims    = varargin{4};
      argstart = 5;
   else
      xlims    = [];
      ylims    = [];
      clims    = varargin{2};
      argstart = 3;
   end
else
   if isnumeric(varargin{3})
      xlims    = varargin{1};
      ylims    = varargin{2};
      clims    = varargin{3};
   else
      xlims    = [];
      ylims    = [];
      clims    = varargin{1};
   end
   argstart = 4;
end

OPT.units          = 'normalized';
OPT.reference      = 'gca';
OPT.ontop          = 0;

OPT.title          = [];
OPT.titleposition  = 'title';
OPT.titlecolor     = 'k';
OPT.orientation    = 'horizontal'; % 'vertical';
OPT.ctick          = nan; % nan = auto, [] = clims, values = values

OPT.axes           = gca;
OPT.figure         = gcf;

OPT.figure0        = gcf;
OPT.axes0          = gca;

OPT = setProperty(OPT,varargin{argstart:end});
   
%% Make colorbar axes active

   if ~isempty(xlims)
   AX        = axesontop(xlims,ylims,'units',OPT.units,...
                                 'reference',OPT.reference,...
                                     'ontop',OPT.ontop);
   end
   
%% Calculate position

   if isempty(xlims)
      xlims   = get(AX  ,'xlim');
   else
      set(AX  ,'xlim',[xlims]);
   end
   if isempty(ylims)
      ylims   = get(AX  ,'ylim');
   else
      set(AX  ,'ylim',[ylims]);
   end

   clrmap  = get(gcf,'colormap');
   
   L       = size(clrmap,1);

   x       = linspace(clims(1),clims(2),L+1);
   x       = [x;x];

   y       = zeros(size(x));
   y(1,:)  = ylims(1);
   y(2,:)  = ylims(2);

   x       = x';
   y       = y';

   c       = [linspace(clims(1),clims(2),L) nan];
   c       = [c;c]';
   z       = zeros(size(c)) + zposition;

%% Old code

   %image([xlims],[ylims],clrmap)
   %clrbar      = colorbar(A);
   %clrbarchild = get(clrbar,'Children');
   %clrbarchild = findobj(clrbarchild,'Tag','TMW_COLORBAR')
   %Xdata       = get(clrbarchild,'Xdata')
   %Ydata       = get(clrbarchild,'Ydata')
   %Xdata(1)    = xlims(1);
   %Xdata(2)    = ylims(2);
   %Ydata(1)    = xlims(1);
   %Ydata(2)    = ylims(2);
   %set(clrbarchild,'Xdata',Xdata);
   %set(clrbarchild,'Ydata',Ydata);

%% Fix color limits

   caxis(clims);
   
%% Draw colorbar patch

   if strcmp(lower(OPT.orientation(1)),'h')

      P  = surf(x,y,z,c);

      xlim(clims);
      ylim([min(y(:)) max(y(:))]);%ylim([0 1]);

         set(gca,'ytick',[])
      if isempty(OPT.ctick)
         set(gca,'xtick',clims)
      elseif isnan(OPT.ctick)
      else
         set(gca,'xtick',OPT.ctick)
      end

      %set(A,'xtick'     ,[1 L+1]);
      %set(A,'xticklabel',{num2str(clims(1)),num2str(clims(2))});
      
   elseif strcmp(lower(OPT.orientation(1)),'v')

      P  = surf(y,x,z,c);
      
      xlim([min(y(:)) max(y(:))]);%xlim([0 1]);
      ylim(clims);

         set(gca,'xtick',[])
      if isempty(OPT.ctick)
         set(gca,'ytick',clims)
      elseif isnan(OPT.ctick)
      else
         set(gca,'ytick',OPT.ctick)
      end

      %set(AX,'xtick'     ,[1 L+1]);
      %set(AX,'xticklabel',{num2str(clims(1)),num2str(clims(2))});
      
   end
   view(0,90)
   set(P,'FaceColor','flat');
   set(P,'EdgeColor','flat');
   grid off
   axis tight
   
%% Add title

   if ~isempty(OPT.title)
      if     strcmpi(OPT.titleposition,'title')
         h.title = title(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'xlabel')
         h.title = xlabel(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'ylabel')
         h.title = ylabel(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'htext')
         h.title = text(.5,.5,OPT.title,'units','normalized','horizontalalignment','center');
      elseif strcmpi(OPT.titleposition,'vtext')
         h.title = text(.5,.5,OPT.title,'units','normalized','horizontalalignment','center','rotation',90);
      end
      set(h.title,'color',OPT.titlecolor)
   end

%% Restore previous figure and axes

   if    OPT.ontop
   axes  (OPT.axes);
   end

if nargout==1
   varargout = {AX};
end

%% EOF
