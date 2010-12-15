function stringout = mkvar(stringin,varargin);
%MKVAR   Make char string into valid variable name.
%
% stringout = mkvar(stringin)
% Replaces everything in s1 that's not a letter or digit with '_'
% so s2 can be used as variable name or as fieldname in a struct.
%
% If necesarry the first position is filled with 'x' rather than '_'.
% stringout = mkvar(stringin,letter) replaces the first position with the 
% user specified letter.
%
% stringout = mkvar(stringin,letter,'add'/'replace') replaces / adds first
% character, default 'add'.
%
% GENVARNAME does the same but insert nasty hex codes, whereas MKVAR inserts a '_'.
%
% See also: ISLETTER, MKTEX, MKHTML, GENVARNAME

%   --------------------------------------------------------------------
%   Idea: Howard E. Motteler form http://www.csee.umbc.edu/%7Emotteler/index.html
%   --------------------------------------------------------------------
%   Copyright (C) 2004-2006 Delft University of Technology
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

   OPT.whattodo1st = 'add';
   OPT.excludes    = char([181 223 228]); % [µ ß ä], special problemetic chars that are a true letter nevertheless
   OPT.firstletter = 'x';
   
   if nargin==2
      OPT.firstletter = varargin{1}';
   end
   
   keep             = (isletter(stringin) | ('0' <= stringin & stringin <= '9')) & ~ismember(stringin,OPT.excludes);
   stringout        = stringin;
   stringout(~keep) = '_';
   
   if stringout(1)  == '_'
      stringout(1)  = OPT.firstletter;
   end

%% First character can not be a number
%  either replace or pad.

   keep1  = isletter(stringin(1));
   if ~keep1
   if nargin==3
       OPT.whattodo1st = varargin{2};
   end    
       
   if strcmpi(OPT.whattodo1st(1),'a');
      stringout    = [OPT.firstletter,stringout];
   elseif strcmpi(OPT.whattodo1st(1),'r');
      stringout(1) = OPT.firstletter;
   end
   end

