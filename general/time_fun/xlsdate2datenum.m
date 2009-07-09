function matlabDates = xlsdate2datenum(excelDates)
%XLSDATE2DATENUM   calculate matlab datenumber from xls code
%
% matlabDates = xlsdate2datenum(excelDates)
%
% method for real input:
%    matlabDates = datenum('30-Dec-1899') + excelDates;
%
% method for string input:
%
%    datenum(excelDates,'dd-mm-yyyy HH:MM:SS')
%    datenum(excelDates,'dd-mm-yyyy         ') % for midnights 00:00
%
% See also: DATENUM, DATESTR, ISO2DATENUM, TIME2DATENUM, UDUNITS2DATENUM, XLSREAD

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
% Created: 07 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.debug = 0;

if iscell(excelDates)
   excelDates = char(excelDates);
end

   if isnumeric(excelDates)
   
      matlabDates = datenum('30-Dec-1899') + excelDates;
   
   elseif ischar(excelDates)
   
      %% 'dd-mm-yyyy         '
      %%  or 
      %% 'dd-mm-yyyy HH:MM:SS'
      %% first we fill spaces with 00:00:00
      %% then we apply datenum to all rows
      %% ---------------------------------
      
      if size(excelDates,2)==19
         mask                   = strmatch(' ',excelDates(:,19));
         excelDates(mask,12:19) = repmat('00:00:00',[length(mask) 1]);
         if OPT.debug
            for j=1:size(excelDates,1)
            disp(num2str(j))
            matlabDates(j)         = datenum(excelDates(j,:),'dd-mm-yyyy HH:MM:SS');
            end
         else
            matlabDates            = datenum(excelDates(:,:),'dd-mm-yyyy HH:MM:SS');
         end
      elseif size(excelDates,2)==10
         matlabDates            = datenum(excelDates,'dd-mm-yyyy');
      end
      
   end

%% EOF
