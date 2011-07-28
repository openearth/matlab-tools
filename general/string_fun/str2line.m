function line1D = str2line(str2D,varargin)
%STR2LINE reshape 2D char or cell array to newline-delimited 1D string
%
%   line1D = str2line(str2D)
%   line1D = str2line(str2D,OS,<symbols>) 
%   where OS determines whether 
%   * for 'w' or 'd' (windows/dos) CR,LF               is used 
%   * for 'l' or 'u' (unix/linuz)  LF                  is used 
%   * for 'm'        (macintosh)   CR                  is used 
%   * for 's'        (symbol)	   optional <symbols> are used 
%   as the end of line markation, where
%   LF = char(10) and CR = char(13)
%
%   NOTE that also when a just 1D array is passed, a newline is added!
%   NOTE that trailing blanks are preserved.
%   NOTE that you can pass symbol end-of-line as in SPRINTF by 
%        using STR2LINE(..,'s','\n')
%   NOTE that you can remove trailing blanks of a 2D char
%        using STR2LINE(CELLSTR(..),'s','')
%
%   Example;
%
%   >> l=str2line({'aap','noot','mies'},'s',char(10))
%   
%   l =
%   
%   aapnootmies
%   
%   
%   >> l=str2line({'aap','noot','mies'},'s','_')
%   
%   l =
%   
%   aap_noot_mies_
%
%See also: LINE2STR, SPRINTF, STRCAT, STRVCAT, CELLSTR

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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% TO DO add regular expression or c-format specifiers: \n \n\r
% TO DO do irregular line wrap to cell in future
% TO DO implement apple

%OS = 'windows';
 OS = 'unix';

if nargin>1
   OS = varargin{1};
end

%% Define EOL
LF = char(10); % LF line feed, new line (0A in hexadecimal)
CR = char(13); % carriage return        (0D in hexadecimal) (windows oLFy)
% char(48)=0
% char(65)=A

%% character array, all at once
if ischar(str2D)
   if strcmpi(lower(OS(1)),'w') | ...
      strcmpi(lower(OS(1)),'d')
      %% add a CR (first) and a LF (second)
      str2D = pad(str2D,LF,size(str2D,2)+2);
      str2D(:,end-1) = CR; % first 0D (carriage return), then 0A (line feed)
   elseif strcmpi(lower(OS(1)),'m')
      %% add a CR (only)
      str2D = pad(str2D,CR,size(str2D,2)+1);
   elseif strcmpi(lower(OS(1)),'u') | ...
          strcmpi(lower(OS(1)),'l')
      %% add a LF (only)
      str2D = pad(str2D,LF,size(str2D,2)+1);
   elseif strcmpi(lower(OS(1)),'s')
         %% add symbol
      str2D = addrowcol(str2D,0,1,varargin{2});
   end
   line1D = reshape(str2D',[1 prod(size(str2D))]);
else

%% cell array, line by line
   cell2D  = str2D;
   line1D  = '';
   
   for ii=1:length(cell2D)
      if strcmpi(lower(OS(1)),'w') | ...
         strcmpi(lower(OS(1)),'d')
         
         line1D = [line1D(:)',char(cell2D{ii}),CR,LF]; % add a CR (first) and a LF (second), note later versions strcat remove all LF and CR
         
      elseif strcmpi(lower(OS(1)),'m')
         
         line1D = [line1D(:)',char(cell2D{ii}),CR   ]; % add a CR (only)
         
      elseif strcmpi(lower(OS(1)),'u') | ...
             strcmpi(lower(OS(1)),'l')
         
         line1D = [line1D(:)',char(cell2D{ii}),LF   ]; % add a LF (only)
         
      elseif strcmpi(lower(OS(1)),'s')
         try % in order not to crash on NaNs
            line1D  = [strcat(line1D,char(cell2D{ii}),{varargin{2}})]; % %% add symbol, but keep also trailing spaces as symbol
         catch
            line1D = '';
         end
         
      end
   end

      if strcmpi(lower(OS(1)),'s')
         
         line1D  = char(line1D);
         
      end
end

%% EOF