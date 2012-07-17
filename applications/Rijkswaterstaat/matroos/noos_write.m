function noos = noos_read(time, values,varargin)
%NOOS_WRITE   write NOOS timeseries ASCII format
%
%   cellstr = noos_write(time, values)
%
% To save to file use SAVESTR:
%
%   savestr('matroos_opendap_maps2series2.tim',noos_write(time, values))
%
%See also: NOOS_READ, MATROOS_NOOS_HEADER2META

% TO DO headerlines

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% #------------------------------------------------------
% # Timeseries retrieved from the MATROOS maps1d database
% # Created at Tue Oct 28 20:33:51 CET 2008
% #------------------------------------------------------
% # Location    : MAMO001_0
% # Position    : (64040,444970)
% # Source      : sobek_hmr
% # Unit        : waterlevel
% # Analyse time: 200709020100
% # Timezone    : MET
% #------------------------------------------------------
% 200709010000   -0.387653201818466
% 200709010010   -0.395031750202179
% 200709010020   -0.407451331615448
% 200709010030   -0.414252400398254

OPT.fmt         = '%-0.5f';
OPT.filename    = [];
OPT.headerlines = [];

OPT = setproperty(OPT,varargin);

n = length(values(:));

if isempty(OPT.filename)
   space = repmat(' ',[n 1]);
   noos  = [datestr(time(:),'yyyymmddHHMM') space num2str(values(:),OPT.fmt)];
else

   fid = fopen(OPT.filename,'w');
   for i=1:length(OPT.headerlines)
      fprintf(fid,['%s\n'],OPT.headerlines{i});
   end   
   for i=1:n
      fprintf(fid,['%s ',OPT.fmt,'\n'],datestr(time(i),'yyyymmddHHMM'),values(i));
   end   
   fclose(fid);

end
   
   
   