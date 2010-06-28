function odvplot_cast(D,varargin)
%ODVPLOT_CAST   plot profile view (parameter,z) of ODV file read by ODVREAD (still test project)
%
%   D = odvread(fname)
%
%   odvplot_cast(D,<keyword,value>)
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

   OPT.variable  = '';%'P011::PSALPR02'; % char or numeric: nerc vocab string (P011::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.index.var = 0;
   OPT.index.z   = 0;
   OPT.lon       = [];
   OPT.lat       = [];
   OPT.clim      = [];
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
   for i=1:length(D.sdn_standard_name)
      if any(strfind(D.sdn_standard_name{i},OPT.variable))
         OPT.index.var = i;
         break
      end
   end
   
   for i=1:length(D.sdn_standard_name)
      if any(strfind(D.sdn_standard_name{i},'PRESPS01'))
         OPT.index.z = i;
         break
      end
   end
   
   if OPT.index.var==0
     error([OPT.variable,' not found.'])
     return
   end

   nvar = 1;
   AX = subplot_meshgrid(nvar+1,1,[.04],[.1]);
   
   if D.cast==1
   
   for ivar=1:nvar
    axes(AX(ivar)); cla %subplot(1,4,1)
       var.x = str2num(char(D.rawdata{OPT.index.var,:}));
       var.y = str2num(char(D.rawdata{OPT.index.z  ,:}))
       if ~isempty(var.x)
       plot  (var.x,var.y,'.-')
       set   (gca,'ydir','reverse')
       xlabel([D.local_name{OPT.index.var},' [',D.local_units{OPT.index.var},']'])
       ylabel([D.local_name{OPT.index.z  },' [',D.local_units{OPT.index.z  },']'])
       grid on
       hold on
       plot(xlim,[D.data.bot_depth D.data.bot_depth],'r')
       hold off
       else
       cla
       noaxis(AX(2))
       end
   
   end

end       
       
    axes(AX(nvar+1)); cla %subplot(1,4,4)
    
       plot(D.data.longitude,D.data.latitude,'ro')
       hold on
       plot(D.data.longitude,D.data.latitude,'r.')
       axis      tight
       
       plot(OPT.lon,OPT.lat,'k')
       axislat   (52)
       grid       on
       tickmap   ('ll','texttype','text')
       box        on
       hold       off
       
    AX(nvar+2) = axes('position',get(AX(1),'position'));

    axes(AX(nvar+2)); cla %subplot(1,4,4)
    noaxis(AX(nvar+2))
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
