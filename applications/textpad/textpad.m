function textpad(mfile,varargin)
%TEXTPAD   launches textpad and opens specified (m)file
%
%   TEXTPAD(mfile,<line>)
%   TEXTPAD(mfile,<line>,<col>)
%
%   puts the cursor in specified line en column number.
%
%See also: EDIT, http://www.textpad.com/

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   OPT.line = 1;
   OPT.col  = 1;
   
   if nargin>1
      OPT.line = varargin{1};
   end
   if nargin>2
      OPT.col  = varargin{2};
   end

   fullmfile = which(mfile);

       if exist('c:\progra~1\textPad\textpad.exe')==2
   eval(['!c:\progra~1\textPad\textpad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
   elseif exist('c:\progra~1\textPad 4\textpad.exe')==2
   eval(['!c:\progra~1\textPa~1\textpad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
   elseif exist('c:\progra~1\textPad 5\textpad.exe')==2
   eval(['!c:\progra~1\textPa~1\textpad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
   end
  %eval(['!c:\Program Files\textPad\textpad.exe ...'); % does not work

%% EOF