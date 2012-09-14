function C = strtokens2cell(STR,DELIM)
%STRTOKENS2CELL   rewrites space delimitered keyword list to cell array
%
% C = strtokens2cell(STR) rewrites space delimitered keyword 
% list into cell array
%
% C = strtokens2cell(STR,DELIM) rewrites space delimitered keyword 
% list into cell array using first token in DELIM as delimiter
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
% See also: STRTOK, STR2LINE

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

rest_of_STR = STR;
no_of_tok   = 0;
if nargin==1
    DELIM = ' ';
end

while ~(length(deblank(rest_of_STR))==0)
   [tok, rest_of_STR]  = strtok(rest_of_STR,DELIM);
   no_of_tok           = no_of_tok + 1;
   C{no_of_tok}        = tok;
end   

%% EOF