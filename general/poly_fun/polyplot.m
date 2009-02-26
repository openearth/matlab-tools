function varargout = polyplot(X,Y,varargin)
%POLYPLOT   Plots NaN-separated polygon segments one by one.
%
% polyplot(X,Y,<names>)
% polyplot(X,Y,<names>,<'keyword',value>) 
% where implemented <'keyword',value> pairs are:
%
%    names = polyplot(X,Y,'getnames',1) SOMEHOW MAKES MATLAB 2006 crash.
%            polyplot(X,Y,'color'   ,'r') color of active segment
%
% Plots all segmenmts in gray, and then plots the segments one by one,
% one at a time on top of the all gray segments. Handy when naming them.
%
% See also: CONTOURC, POLYSPLIT, POLYJOIN, POLYSELECT, POLYFINDNAME

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

%% Kewords
%-----------------------

   OPT.color    = 'r';
   OPT.getnames = 0;

   if odd(nargin)
      iargin = 2;
      if iscell(varargin{1})
         D.namecells = varargin{1};
      elseif ischar(varargin{1})
         D.namecells = cellstr(varargin{1});
      end
   else
      iargin = 1;
   end
   
   OPT = SetProperty(OPT,varargin{:})
   
%% Split
%-----------------------

   [D.loncells,D.latcells]=polysplit(X,Y);
   
%% Plot
%-----------------------

   plot(X,Y,'color',[.5 .5 .5]);hold on
   
   nline = length(D.latcells);
   
   first = 1;
   for iline = 1:nline
   
      P1 = plot(D.loncells {iline},...
                D.latcells {iline},'color',OPT.color);
      hold on
      axis equal
      if ~isempty(D.loncells {iline})
      P2 = plot(D.loncells {iline}([1 end]),...
                D.latcells {iline}([1 end]),'.','color',OPT.color);
      end
      try;delete(t);end
      if ~(OPT.getnames)
         if isfield(D,'namecells')
         if ~(first)
            delete(T1)
         end
          T1 = text(D.loncells {iline}(1),...
                   D.latcells {iline}(1),...
                   D.namecells{iline},'color','r');
         end
      end
      if OPT.getnames
         title(['Showing polygon segment No..',num2str(iline)])
         D.namecells{iline} = input('Give segmnent name: ','s');
      else
         if isfield(D,'namecells')
         title({['Showing polygon segment No..',num2str(iline),':'],...
                 D.namecells{iline}})
         else
         title(['Showing polygon segment No..',num2str(iline)])
         end
      end

      disp(['Plotted ',num2str(iline),' of ',num2str(nline),', ress key to continue'])
      pause
   
      set(P1,'color','k');
      set(P2,'color','k');
   
      first = 0;

   end
   
%% Out
%-----------------------

   if nargout==1
      varargout = {char(D.namecells)};
   end
   
%% EOF   