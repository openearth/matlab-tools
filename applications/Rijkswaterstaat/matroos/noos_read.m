function varargout = noos_read(varargin)
%NOOS_READ   read NOOS timeseries ASCII format
%
%   [time, values, headerlines] = noos_read(cellstr)
%
% where the headerlines can be interpreted with 
% MATROOS_NOOS_HEADER2META is the NOOS file file originates
% from matroos. when the file contains multpel data blocks,
% [time, values, headerlines], are cells. Alternative output:
%
%   D = noos_read(cellstr)
%
% where D has fields  datenum, value and headers.
%
%See also: MATROOS_NOOS_HEADER2META

%% TO DO: parse a file with only concatenated comment blocks (in cas eof no data)

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

   OPT.varname = 'value';
   
   OPT = setproperty(OPT,varargin{2:end});

%% load file, if necesarry

   if ischar(varargin{1})
      fname    = varargin{1}; 
      fid      = fopen(fname,'r');
      allLines = textscan(fid,'%s','Delimiter','');
      allLines = allLines{1}';
      fclose(fid);
   else
      allLines = varargin{1};
   end

%% detect blocks and headers
%  Mind that data sections can be missing altogether!: so header blocks are concatenated

   ind   = strmatch('# Timeseries retrieved from the MATROOS series database',allLines);
   nloc  = length(ind);
   
   hind0 = ind-1;
   hind1 = ind+9;
   ind0  = ind+10;
   ind1  = [(ind(2:end)-2)' length(allLines)];
   
%% parse data

   for iloc=1:nloc
   
      %% read data lines, with pre-allocated vectors for speed
      
      done                 = 0;
      pointIndex           = 1;
      nt                   = ind1(iloc) - ind0(iloc) + 1;
      D(iloc).header       = allLines(hind0(iloc):hind1(iloc));
      D(iloc).datenum      = repmat(nan,[1 nt]);
      D(iloc).(OPT.varname) = repmat(nan,[1 nt]);
      
      for i = ind0(iloc):ind1(iloc)
          line                              = allLines{i};
          data                              = sscanf(line,'%f %f');
          D(iloc).(OPT.varname)(pointIndex) = data(end);
          year                              = sscanf(line( 1: 4),'%d');
          month                             = sscanf(line( 5: 6),'%d');
          day                               = sscanf(line( 7: 8),'%d');
          hour                              = sscanf(line( 9:10),'%d');
          min                               = sscanf(line(11:12),'%d');
          sec                               = 0;
          D(iloc).datenum(pointIndex)       = datenum(year,month,day,hour,min,sec);
          i                                 = i+1;
          pointIndex                        = pointIndex+1;
      end;
      
   end
   
%% output

   if nargout==1
      varargout = {D};
   elseif nargout==2
      if nloc==1
         varargout = { D.datenum , D.(OPT.varname) };
      else
         varargout = {{D.datenum},{D.(OPT.varname)}};
      end
   elseif nargout==3
      if nloc==1
         varargout = { D.datenum , D.(OPT.varname) , D.header };
      else
         varargout = {{D.datenum},{D.(OPT.varname)},{D.header}};
      end
   end

%% EOF   
   