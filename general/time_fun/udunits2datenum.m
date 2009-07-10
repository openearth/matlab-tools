function datenumbers = udunits2datenum(varargin)
%UDUNITS2DATENUM   converts date(s) in ISO 8601 units to Matlab datenumber(s)
%
%    datenumbers = udunits2datenum(time,isounits)
%    datenumbers = udunits2datenum(timestring)
%
% Examples (N.B. vectorized):
%
%    datenumbers = udunits2datenum( [602218 648857], 'days since 0000-0-0 00:00:00 +01:00')
%    datenumbers = udunits2datenum( [602218 648857],{'days since 0000-0-0 00:00:00 +01:00',...
%                                                    'days since 0000-0-0 00:00:00 +01:00'})
%    datenumbers = udunits2datenum({'602218           days since 0000-0-0 00:00:00 +01:00',...
%                                   '648857           days since 0000-0-0 00:00:00 +01:00'})
%
%See web: <a href="http://www.unidata.ucar.edu/software/udunits/">http://www.unidata.ucar.edu/software/udunits/</a>
%See also: DATENUM, DATESTR, ISO2DATENUM, TIME2DATENUM, XLSDATE2DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% 2009 jul 09: added option to pass only 1 string argument [GJdB]

%% Handle input
%--------------------

   if     nargin==1
   
      if     iscell(varargin{1})
         celltime = varargin{1};
      elseif ischar(varargin{1})
         celltime = cellstr(varargin{1});
      end
      for irow=1:length(celltime)
     [time{irow},...
      isounits{irow}] = strtok(celltime{irow});
      end
      time = str2num(char(time));
   elseif nargin==2
      time      = varargin{1};
      isounits  = cellstr(varargin{2});
      if length(time) >1 & length(isounits)==1
         isounits = repmat(isounits,size(time));
      end
   end   

   for irow=1:length(time)
   rest = isounits{irow};

  [units,rest] = strtok(rest);
  [dummy,rest] = strtok(rest);

   %% Get reference date
   %--------------------

  [refdatenum,...
   zone] = iso2datenum(rest);

   %% Change units and apply reference date
   %--------------------

   datenumbers(irow) = time(irow).*convert_units(units,'day') + refdatenum;

   end

   
%% EOF   