function odvplot_overview_kml(D,varargin)
%ODVPLOT_OVERVIEW_KML   plots map view (lon,lat) of ODV file read by ODVREAD (still test project)
%
%   D = odvplot_overview_kml(fname)
%       odvplot_overview_kml(D)
%
% Show overview of ODV locations, ue when D.cast=0.
%
% Works when D.cast = 0;
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

   OPT.variable      = 'P011::PSSTTS01'; % char or numeric: nerc vocab string (P011::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   OPT.colorbar      = 1;
   OPT.colormap      = @(m) jet(m);
   OPT.fileName      = '';
   OPT.clim          = [];
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
   for i=1:length(D.sdn_standard_name)
      if any(strfind(D.sdn_standard_name{i},OPT.variable))
         OPT.variable = i;
         break
      end
   end
   
   KMLanimatedIcon(D.data.latitude,D.data.longitude,str2num(char(D.rawdata{OPT.variable,:})),...
        'fileName',OPT.fileName,...
          'timeIn',D.data.datenum-1,...
         'timeOut',D.data.datenum+1,...
         'kmlName',[D.LOCAL_CDI_ID],...
     'description',['cruise: ',D.cruise,', EDMO_code:',num2str(D.EDMO_code)],...
        'colorbar',OPT.colorbar,...
            'cLim',[5 25],...
   'colorbartitle',[D.local_name{OPT.variable},' (',D.local_units{OPT.variable},')'])

%% EOF