function num = timezone_code2iso(code)
%TIMEZONE_CODE2ISO   convert between civilian timezone code (e.g. GMT) to ISO +HH:MM notation
%
%   num = timezone_code2iso(code)
%
% returns +HH:MM character, returns '' for unknown code.
%
% TIMEZONE_CODE2ISO uses the data in 'timezone.xls', that are based on:
% <a href="http://wwp.greenwichmeantime.com/info/timezone.htm">http://wwp.greenwichmeantime.com/info/timezone.htm</a>
% <a href="http://en.wikipedia.org/wiki/ISO_8601"       >http://en.wikipedia.org/wiki/ISO_8601</a>
% <a href="http://www.cl.cam.ac.uk/~mgk25/iso-time.html">http://www.cl.cam.ac.uk/~mgk25/iso-time.htm</a>
%
% Examples:
%
%   num = timezone_code2iso('GMT') % gives +00:00 % (Geeenwich Mean Time)
%   num = timezone_code2iso('CET') % gives +01:00 % (U.S./Canadian Eastern Standard Time)
%   num = timezone_code2iso('EST') % gives +01:00 % (Central European Time (CET))
%
%See also: datenum

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

   OPT.xlsfile = [filepathstr(mfilename('fullpath')),filesep,'timezone.xls'];
   
   DAT = xls2struct(OPT.xlsfile);
   i   = strmatch(upper(code),upper(DAT.civilian_code));
   num = num2str(DAT.offset(i),'%+0.2d:00');
   
%% EOF   