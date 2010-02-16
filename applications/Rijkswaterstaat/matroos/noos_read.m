function [t, values ,header] = noos_read(allLines)
%NOOS_READ   read NOOS timeseries ASCII format
%
%See also: MATROOS_NOOS_HEADER2META

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Rijkswaterstaat
%       Martin Verlaan
%
%       Martin.Verlaan@deltares.nl
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

%% skip and store header
   
   i=0;done=0;
   while((done==0)&(i<length(allLines))),
       i         = i+1;
       header{i} = allLines{i};
       done      = (length(findstr(allLines{i},'#'))==0);
   end;
   
   n    = length(allLines) - length(header);
   
%% read data lines, pre-allocate for speed
   
   done       = 0;
   pointIndex = 1;
   t          = repmat(nan,[1 n]);
   values     = repmat(nan,[1 n]);
   
   while(i<length(allLines)),
       line = allLines{i};
       data = sscanf(line,'%f %f');
       values(pointIndex) = data(end);
       year = sscanf(line( 1: 4),'%d');
       month= sscanf(line( 5: 6),'%d');
       day  = sscanf(line( 7: 8),'%d');
       hour = sscanf(line( 9:10),'%d');
       min  = sscanf(line(11:12),'%d');
       sec  = 0;
       t(pointIndex) = datenum(year,month,day,hour,min,sec);
       i          = i+1;
       pointIndex = pointIndex+1;
   end;

%% EOF   
   