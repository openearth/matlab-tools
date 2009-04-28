function C = strtokens2cell(STR)
%STRTOKENS2CELL           rewrites space delimitered keyword list to cell array
%
%   C = strtokens2cell(STR)
%
% rewrites space delimitered keyword list into cell array
%
% example:
%
%    C = strtokens2cell('a b')
%
% gives C{1}='a';C{2}='b'
%
%   C = 
%  
%      'a'    'b'
%
% See also: STRTOK, EXPRESSIONSFROMSTRING

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

rest_of_STR = STR;
no_of_tok   = 0;

while ~(length(deblank(rest_of_STR))==0)
   [tok, rest_of_STR]  = strtok(rest_of_STR);
   no_of_tok           = no_of_tok + 1;
   C{no_of_tok}        = tok;
end   

%% EOF