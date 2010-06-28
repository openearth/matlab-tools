function odvplot_overview(D,varargin)
%ODVPLOT_OVERVIEW   plot map view (lon,lat) of ODV file read by ODVREAD (still test project)
%
%   D = odvread(fname)
%
%   odvplot_overview(D,<keyword,value>)
%
% Show overview of ODV locations, works when D.cast=0.
%
% Works only for trajectory data, i.e. when D.cast = 0;
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

   OPT.variable = ''; %'P011::PSSTTS01'; % char or numeric: nerc vocab string (P011::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.index    = 0;
   OPT.lon      = [];
   OPT.lat      = [];
   OPT.clim     = [];
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
   for i=1:length(D.sdn_standard_name)
      if any(strfind(D.sdn_standard_name{i},OPT.variable))
         OPT.index = i;
         break
      end
   end
   
   AX = subplot_meshgrid(1,1,[.04],[.1]);
   
    axes(AX(1)); cla %subplot(1,4,4)
    
       if OPT.index==0
          plot (D.data.longitude,D.data.latitude,'ro')
          hold on
          plot (D.data.longitude,D.data.latitude,'r.')
       else
          if ~isempty(OPT.clim)
          clim(OPT.clim)
          end
          plotc(D.data.longitude,D.data.latitude,str2num(char(D.rawdata{OPT.index,:})))
          hold on
          colorbarwithtitle('')
       end
       
       axis      tight
       
       plot(OPT.lon,OPT.lat,'k')
       axislat   (52)
       grid       on
       tickmap   ('ll','texttype','text')
       box        on
       hold       off

       txt = ['Cruise: ',D.data.cruise{1},...
               '   -   ',datestr(min(D.data.datenum),31),...
               '   -   ',datestr(max(D.data.datenum),31)];

       title     (txt)

       
%% EOF       
