function [k] = findstr2afterstr1(str, str1, str2)
% FINDSTR2AFTERSTR1 searches occurences of str2 after str1 within str
%
% searches within string 'str' for any occurrences of 'str2' after the first 
% occurence of 'str1', returning the starting index of each such occurrence 
% in the double array k.
%
% Syntax:
% [k] = findstr2afterstr1(str, str1, str2)
%
% Input:
% str  = string to search in
% str1 = string after which will be searched
% str2 = string to search for
%
% Output:
% k    = starting index of occurrences
%
% See also: findstr
 
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
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

% $Id: findstr2afterstr1.m 43 2008-11-13 14:03:15Z heijer $ 
% $Date: 2008-11-13 15:03:15 +0100 (do, 13 nov 2008) $
% $Author: heijer $
% $Revision: 43 $

%% 
str1loc = min(findstr(str, str1));
if isempty(str1loc)
    k = [];
else
    str2loc = findstr(str, str2);

    k = str2loc(str2loc>str1loc);
end

