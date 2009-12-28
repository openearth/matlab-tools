function D = rws_waterbase_get_substances(varargin)
%RWS_WATERBASE_GET_SUBSTANCES   list of waterbase substances from www.waterbase.nl
%
%    Substance = rws_waterbase_get_substances()
%
% gets list of all SUBSTANCES available for queries at <a href="http://www.waterbase.nl">www.waterbase.nl</a>.
%
% Substance struct has fields:
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. 22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% See also: DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>, GETWATERBASEDATA, RWS_WATERBASE_GET_LOCATIONS

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.debug   = 0;

   %% Special HTML symbols to be encodied as hex value with ISO 8859-1 Latin alphabet No. 1
   % http://www.ascii.cl/htmlcodes.htm:ISO 8859-1 Latin alphabet No. 1
   % ' '    20 space
   % |      7C
   % /      2F
   % <      3C
   % ,      2C
   % (      28
   % )      29
   % '      27
   OPT.symbols = {' ','|','/','<',',','(',')',''''}; 
   
   %% Get page
   [s status]    = urlread('http://www.waterbase.nl/index.cfm?page=start');
   if (status == 0)
      warndlg('www.waterbase.nl may be offline or you are not connected to the internet','Online source not available');
      close(h);
      OutputName = [];
      return;
   end

   %% Get substances from page
   ind0 = strfind(s,'<option value="');
   ind1 = strfind(s,'</option>');
   for ii=1:length(ind1)
      if OPT.debug
      disp([num2str(ii,'%0.3d'),'  ',s(ind0(ii)+15:ind1(ii)-1)])
      end
      
      str  = s(ind0(ii)+15:ind1(ii)-1);
      sep0 = strfind(str,'|');
      sep1 = strfind(str,'">');
      
      D.Code(ii)     = str2num(str(     1:sep0-1));
      D.FullName{ii} =         str(sep0+1:sep1-1);
      D.CodeName{ii} =         str(     1:sep1-1);
      D.CodeName{ii} = strrep(D.CodeName{ii},' ','+');

      for isymbol=1:length(OPT.symbols)
      symbol = OPT.symbols{isymbol};
      D.CodeName{ii} = strrep(D.CodeName{ii},symbol,['%',dec2hex(unicode2native(symbol, 'ISO-8859-1'))]);
      end
      
   end   
   
   %% check substances from website by comparing with csv file.
   if OPT.debug
      E = rws_waterbase_get_substances_csv;
      for ii=1:length(D.Code)
         if ~strcmpi(D.CodeName{ii},E.CodeName{ii})
            disp(num2str(ii))
            disp(['>',D.CodeName{ii},'<'])
            disp(['>',E.CodeName{ii},'<'])
            disp('------------------------')
            % 284
            % >713%7CExtinctiecoefficient+in+%2Fm+in+oppervlaktewater<
            % >713%7CExtinctie+in+%2Fm+in+oppervlaktewater<
         end
      end
   end

%% EOF