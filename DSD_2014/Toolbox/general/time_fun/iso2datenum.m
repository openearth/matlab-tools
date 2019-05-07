function varargout = iso2datenum(isounits)
%ISO2DATENUM   converts date in ISO 8601 units to datenum and zone (beta)
%
%    [datenumbers,zone] = iso2datenum(time)
%
% Example:
%
%    iso2datenum('1999-1-14 13:12:11 +01:00')
%    iso2datenum('1999-1-14T13:12:11 +01:00')
%    iso2datenum('1999-1-14 13:12:11Z')
%    iso2datenum('1999-1-14T13:12:11Z')
%    iso2datenum('1999-1-14')
%    iso2datenum('1999-1')    % !!! = datenum(1999, 1, 0), and not datenum(1999, 1, 1)
%    iso2datenum('1999')      % !!! = datenum(1999, 0, 0), and not datenum(1999, 1, 1)
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
% $Id: iso2datenum.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/time_fun/iso2datenum.m $
% $Keywords: $

% TO DO: implement week option
% TO DO: implement ordinal date

%% Date + Time

   rest = isounits;

   OPT.yyyy   = 0;
   OPT.mm     = 0;
   OPT.dd     = 0;
   OPT.HH     = 0;
   OPT.MM     = 0;
   OPT.SS     = 0;

                     [OPT.yyyy ,rest] = strtok(rest,'-:T Z');OPT.yyyy   = str2num(OPT.yyyy);
   if ~isempty(rest);[OPT.mm   ,rest] = strtok(rest,'-:T Z');OPT.mm     = str2num(OPT.mm  );end
   if ~isempty(rest);[OPT.dd   ,rest] = strtok(rest,'-:T Z');OPT.dd     = str2num(OPT.dd  );end
   if ~isempty(rest);[OPT.HH   ,rest] = strtok(rest,'-:T Z');OPT.HH     = str2num(OPT.HH  );end
   if ~isempty(rest);[OPT.MM   ,rest] = strtok(rest,'-:T Z');OPT.MM     = str2num(OPT.MM  );end
   if ~isempty(rest);[OPT.SS   ,rest] = strtok(rest,'-:T Z');OPT.SS     = str2num(OPT.SS  );end
   
%% Zone

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
   
   datenumber = datenum(OPT.yyyy,OPT.mm,OPT.dd,OPT.HH,OPT.MM,OPT.SS);
   
%% out

   if     nargout<2
        varargout = {datenumber}; 
   elseif nargout==2
        varargout = {datenumber,zone}; 
   end
   
%% EOF   

% r=textscan('1987-2-3 11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')
% r=textscan('1987-2-3T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')

% r=sscanf('1987-1-2T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d%s')

 