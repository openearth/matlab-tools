function odvplot(D)
%ODVPLOT   plot file in ODV format read by ODVREAD (still test project)
%
%   D = odvread(fname)
%       odvread(D)
%
% Example plotm function that shows vertical profiles of temperature, salinity, fluorescence.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: ODVREAD, ODVDISP

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

    subplot(1,3,1)
       index.x = 12;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       ylabel(D.variables{index.y})
       grid on
       title (['Cruise: ',D.data.cruise{1}])
    
    subplot(1,3,2)
       index.x = 14;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       set   (gca,'yticklabel',{})
       grid on
       title (['Station: ',mktex(D.data.station{1}),' (',num2str(D.data.lat(1)),'\circE, ',num2str(D.data.lon(1)),'\circN)'])
       
    subplot(1,3,3)
       index.x = 16;
       index.y = 10;
       plot  (str2num(char(D.rawdata{index.x,:})),...
              str2num(char(D.rawdata{index.y,:})))
       set   (gca,'ydir','reverse')
       xlabel(D.variables{index.x})
       set   (gca,'yticklabel',{})
       grid on
       title ([datestr(D.data.datenum(1),31)])  
       
%% EOF       
