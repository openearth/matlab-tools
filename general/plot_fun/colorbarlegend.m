function varargout = colorbarlegend(varargin)
%COLORBARLEGEND   Overlays colorbar in separate axes.
% 
% COLORBARLEGEND plots a colorbar in another axes.
% This axes is (i) either an exisioting axes passed by handle
% or (ii) it is created on top of axising axes in the current figure.
% at the specified position. When the colorbar is drawn 
% a a specified position it does not affect the position of other axes.
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
% G.J. de Boer, TU Delft, Environmental FLuid Mechanics, Jan 2005 - 2008.
%
%See also: COLORBAR, AXESONTOP

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
   if isnumeric(varargin{3})
      xlims    = varargin{2};
      ylims    = varargin{3};
      clims    = varargin{4};
   else
      xlims    = [];
      ylims    = [];
      clims    = varargin{2};
   end
   argstart = 2;
else
   if isnumeric(varargin{2})
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
OPT.orientation    = 'horizontal'; % 'vertical';
OPT.ctick          = nan; % nan = auto, [] = clims, values = values

OPT.curaxes        = gca;
OPT.curfigure      = gcf;

OPT.curfigure0     = gcf;
OPT.curaxes0       = gca;

%% Keywords
%% --------------------------------
i=argstart;
while i<=nargin
  if ischar(varargin{i}),
    switch lower(varargin{i})
    case 'units';         i=i+1;OPT.units          = varargin{i};
    case 'reference'     ;i=i+1;OPT.reference = varargin{i};
    case 'ontop';         i=i+1;OPT.ontop          = varargin{i};
    
    case 'title';         i=i+1;OPT.title          = varargin{i};
    case 'titleposition'; i=i+1;OPT.titleposition  = varargin{i};
    case 'axes';          i=i+1;OPT.curaxes        = varargin{i};
    case 'figure';        i=i+1;OPT.curfigure      = varargin{i};
    case 'orientation';   i=i+1;OPT.orientation    = varargin{i};
    case 'ctick';         i=i+1;OPT.ctick          = varargin{i};
    otherwise
      i=i+1;
      % error(sprintf('Invalid string argument: %s.',varargin{i}));
      % IGNORE KEYWORDS WHICH ARE NOT RECOGNIZED
    end
  end;
  i=i+1;
end;
   
   %% Make colorbar axes active
   %% --------------------------------

   if ~isempty(xlims)
   AX        = axesontop(xlims,ylims,'units',OPT.units,...
                                 'reference',OPT.reference,...
                                     'ontop',OPT.ontop);
   end
   axes(AX);
   
   %% Calculate position
   %% --------------------------------
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
   %% --------------------------------
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
   %% --------------------------------
   caxis(clims);
   
   %% Draw colorbar patch
   %% --------------------------------
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
   %% --------------------------------
   if ~isempty(OPT.title)
      if     strcmpi(OPT.titleposition,'title')
         title(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'xlabel')
         xlabel(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'ylabel')
         ylabel(OPT.title,'VerticalAlignment','bottom','HorizontalAlignment','center');
      elseif strcmpi(OPT.titleposition,'htext')
         text(.5,.5,OPT.title,'units','normalized','horizontalalignment','center');
      elseif strcmpi(OPT.titleposition,'vtext')
         text(.5,.5,OPT.title,'units','normalized','horizontalalignment','center','rotation',90);
      end
   end

   %% Restore previous figure and axes
   %% --------------------------------
   figure(OPT.curfigure0);
   if    ~OPT.ontop
   axes  (OPT.curaxes0);
   end

if nargout==1
   varargout = {AX};
end

%% EOF
