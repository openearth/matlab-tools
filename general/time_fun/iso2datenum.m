function varargout = iso2datenum(isounits)
%ISO2DATENUM   converts date in ISO 8601 units to datenum and zone (beta)
%
%    [datenumbers,zone] = iso2datenum(time,isounits)
%
% Example:
%
%    iso2datenum('1999-1-14 13:12:11 +01:00')
%    iso2datenum('1999-1-14T13:12:11 +01:00')
%    iso2datenum('1999-1-14 13:12:11Z')
%    iso2datenum('1999-1-14T13:12:11Z')
%    iso2datenum('1999-1-14')
%
%See also: DATENUM, DATESTR, TIMEZONE_CODE2ISO, UDUNITS2DATENUM

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

% TO DO: implement week option
% TO DO: implement ordinal date

%% Date
%--------------------

   rest = isounits;
   [OPT.yyyy ,rest] = strtok(rest,'-:T ');
   [OPT.mm   ,rest] = strtok(rest,'-:T ');
   [OPT.dd   ,rest] = strtok(rest,'-:T ');

%% Time
%--------------------

   [OPT.HH   ,rest] = strtok(rest,'-:T ');
   [OPT.MM   ,rest] = strtok(rest,'-:T ');
   [OPT.SS   ,rest] = strtok(rest,'-:T ');
   
%% Zone
%--------------------

   if isempty(OPT.SS)
         zone          = '00:00';
   else
      if strcmpi(OPT.SS(end),'z')
         zone          = '00:00';
         OPT.SS        = OPT.SS(1:end-1);
      else
         zone          = rest;
      end
   end

%% Datenum
%--------------------

   OPT.yyyy   = str2num(OPT.yyyy);
   OPT.mm     = str2num(OPT.mm  );
   OPT.dd     = str2num(OPT.dd  );
   if ~isempty(OPT.HH)
   OPT.HH     = str2num(OPT.HH  );
   OPT.MM     = str2num(OPT.MM  );
   OPT.SS     = str2num(OPT.SS  );
   else
   OPT.HH     = 0;
   OPT.MM     = 0;
   OPT.SS     = 0;
   end
   
   datenumber = datenum(OPT.yyyy,OPT.mm,OPT.dd,OPT.HH,OPT.MM,OPT.SS);
   
   if     nargout<2
        varargout = {datenumber}; 
   elseif nargout==2
        varargout = {datenumber,zone}; 
   end
   
%% EOF   

% r=textscan('1987-2-3 11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')
% r=textscan('1987-2-3T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')

% r=sscanf('1987-1-2T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d%s')

 