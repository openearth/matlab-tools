function M = matroos_noos_header2meta(header)
%MATROOS_NOOS_HEADER2META   parse NOOS time series header enriched by MATROOS
%
%See also: MATROOS_GET_SERIES, NOOS_READ

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
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

M = [];

for i=1:length(header)

   if any(strfind(header{i},'Location'    )); 
   index              = strfind(header{i},':');
   M.loc              =        (header{i}(index+1:end));
   end

   if any(strfind(header{i},'Position'    )); 
   index1             = strfind(header{i},'(');
   index2             = strfind(header{i},',');
   index3             = strfind(header{i},')');
   M.latlonstr        =    ['(',header{i}(index1+1:index2-1),'°E,',...
                                header{i}(index2+1:index3-1),'°N)'];
   M.lon              = str2num(header{i}(index1+1:index2-1));
   M.lat              = str2num(header{i}(index2+1:index3-1));
   end

   if any(strfind(header{i},'Source'      )); 
   index              = strfind(header{i},':');
   M.source           = strtok(header{i}(index+1:end));
   end

   if any(strfind(header{i},'Unit'        )); 
   index              = strfind(header{i},':');
   M.unit             = strtok(header{i}(index+1:end));
   end

   if any(strfind(header{i},'Analyse time'));
   if any(strfind(header{i},'*** no data found ***'))
   M.tanalysis        = [];
   M.datenumanalysis  = [];
   else
   index              = strfind(header{i},':');
   M.tanalysis        = strtok(header{i}(index+1:end));
   M.datenumanalysis  = datenum(M.tanalysis,'yyyymmddHHMM');
   end
   end

   if any(strfind(header{i},'Timezone'    )); 
   index              = strfind(header{i},':');
   M.timezone         = strtok(header{i}(index+1:end));
   end

   if any(strfind(header{i},' Created at'    )); 
   index              = strfind(header{i},'Created at');
   M.tretrieved       = header{i}(index+11:end);
  %M.datenumretrieved = 
   end
   
end