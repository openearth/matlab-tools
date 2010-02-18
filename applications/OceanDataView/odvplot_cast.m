function odvplot_cast(D,varargin)
%ODVPLOT_CAST   plot profile view (parameter,z) of ODV file read by ODVREAD (still test project)
%
%   D = odvread(fname)
%   odvplot_cast(D,<coastline.lon,coastline.lat>)
%
% Example plot function that shows vertical profiles of temperature, salinity, fluorescence.
%
% Works only for profile data, i.e. when D.cast = 1;
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL
% $Keywords:

   AX = subplot_meshgrid(4,1,[.04],[.1]);
   
   if D.cast==1

    axes(AX(1)); cla %subplot(1,4,1)
       var.x = 'sea_water_temperature';
       var.y = 'sea_water_pressure';
       if ~isempty(D.data.(var.x))
       plot  (D.data.(var.x),D.data.(var.y),'.-')
       set   (gca,'ydir','reverse')
       xlabel([D.variables{D.index.(var.x)},' [',D.units{D.index.(var.x)},']'])
       ylabel([D.variables{D.index.(var.y)},' [',D.units{D.index.(var.y)},']'])
       grid on
       hold on
       plot(xlim,[D.bot_depth D.bot_depth],'r')
       hold off
       else
       cla
       noaxis(AX(2))
       end
    
    axes(AX(2)); cla %subplot(1,4,2)
       var.x = 'sea_water_salinity';
       var.y = 'sea_water_pressure';
       if ~isempty(D.data.(var.x))
       plot  (D.data.(var.x),D.data.(var.y),'.-')
       xlabel([D.variables{D.index.(var.x)},' [',D.units{D.index.(var.x)},']'])
       xlim ([30.5 35.5])
       set   (gca,'ydir','reverse')
       set   (gca,'yticklabel',{})
       grid on
       hold on
       plot(xlim,[D.bot_depth D.bot_depth],'r')
       hold off
       else
       cla
       noaxis(AX(2))
       end
       
    axes(AX(3)); cla %subplot(1,4,3)
       var.x = 'sea_water_fluorescence';
       var.y = 'sea_water_pressure';
       if ~isempty(D.data.(var.x))
       plot  (D.data.(var.x),D.data.(var.y),'.-')
       set   (gca,'ydir','reverse')
       xlabel([D.variables{D.index.(var.x)},' [',D.units{D.index.(var.x)},']'])
       set   (gca,'yticklabel',{})
       grid on
       hold on
       plot(xlim,[D.bot_depth D.bot_depth],'r')
       hold off
       else
       cla
       noaxis(AX(3))
       end
       
end       
       
    axes(AX(4)); cla %subplot(1,4,4)
    
       plot(D.data.longitude,D.data.latitude,'ro')
       hold on
       plot(D.data.longitude,D.data.latitude,'r.')
       axis      tight
       
       if nargin>1
       lon = varargin{1};
       lat = varargin{2};
       plot(lon,lat,'k')
       end
       axislat   (52)
       grid       on
       tickmap   ('ll','texttype','text')
       box        on
       hold       off
       
    AX(5) = axes('position',get(AX(1),'position'));

    axes(AX(5)); cla %subplot(1,4,4)
    noaxis(AX(5))
       % text rather than titles per subplot, because subplots can be empty
       if D.cast
          txt = ['Cruise: ',D.data.cruise{1},...
                  '   -   Station: ',mktex(D.data.station{1}),' (',num2str(D.data.latitude(1)),'\circE, ',num2str(D.data.longitude(1)),'\circN)',...
                  '   -   ',datestr(D.data.datenum(1),31)];
       else
          txt = ['Cruise: ',D.data.cruise{1}];
       end
       text (0,1,txt,...
                  'units','normalized',...
                  'horizontalalignment','left',...
                  'verticalalignment','bottom')
    axes(AX(1));
       
%% EOF       
