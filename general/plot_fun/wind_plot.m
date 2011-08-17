function varargout = wind_plot(t,D,F,varargin)
%WIND_PLOT   Wind rose of direction and intensity
% 
%   Syntax:
%      [HANDLES,DATA] = WIND_PLOT(t,D,I,<keyword,value>)
%
%   plots speed and direction in one axes, with directions
%   overlaid on, and scaled to velocity range.
%
%   Inputs:
%      D   Directions
%      I   Intensities
%
%   Optional keywords:
%       - dtype     type of input directions D, standard or meteo, affects:
%                   (i) 0-convention and (ii) visual interpetation (to/from)
%                   if meteo,     0=from North, 90=from East , etc
%                   if not meteo, 0=to   East , 90=to   North, etc (default)
%       - Ulim      velocity range, used scale directions to axis
%
%   For all keywords, call wind_plot()
%
% See also: wind_rose, degN2degunitcircle, degunitcircle2degN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       gerben.deboer@Deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% varargin options:
   OPT.Ulim    = [0 10];
   OPT.dtype   = 'meteo';

   OPT.thleg   = '\theta [\circ]';
   OPT.thlabel = 'wind from direction [\circ]';
   OPT.thcolor = 'r';

   OPT.Uleg    = '|U| [m/s]';
   OPT.Ulabel  = 'wind speed [m/s]';
   OPT.Ucolor  = 'b';
   
   OPT = setproperty(OPT, varargin{:});
   
   if nargin==0
      varargout = {OPT};
      close % jet launches figure, grr
      return
   end

%% directions conversion:
   if ~isequal(OPT.dtype,'meteo')
     D=deguc2degN(D);
   end

%% plot U
   plot    (t,F ,'color',OPT.Ucolor,'DisplayName',OPT.Uleg);
   hold     on
   ylim    (OPT.Ulim)
   set(gca,'ytick',OPT.Ulim(2).*[0:.25:1]);
   tt = cellstr(get(gca,'yticklabel'));
   tt = cellfun(@(x) [x ' '],tt,'UniformOutput',0);
   set(gca,'yticklabel',{});
   text    ([0 0 0 0 0],[0:.25:1],tt,...
                                          'units','normalized',...
                            'horizontalalignment','right',...
                                          'color',OPT.Ucolor);
   text    (0,.5,{OPT.Ulabel,'',''}      ,'units','normalized',...
                                       'rotation',90,...
                              'verticalalignment','bottom',...
                            'horizontalalignment','center',...
                                          'color',OPT.Ucolor)
   ylim    (OPT.Ulim)

%% plot th
   plot    (t,D./360.*OPT.Ulim(2),        'color',OPT.thcolor,...
                                    'DisplayName',OPT.thleg,...
                                          'color',OPT.thcolor);
   text    ([1 1 1 1 1],[0:.25:1],{' N\downarrow',' E\leftarrow',' S\uparrow',' W\rightarrow',' N\downarrow'},...
                                          'units','normalized',...
                            'horizontalalignment','left',...
                                          'color',OPT.thcolor);
   text    (1,.5,{' ',' ',OPT.thlabel},'units','normalized',...
                                       'rotation',90,...
                              'verticalalignment','top',...
                            'horizontalalignment','center',...
                                          'color',OPT.thcolor)

