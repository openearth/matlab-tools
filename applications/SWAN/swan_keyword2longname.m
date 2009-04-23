function OUT = swan_keyword2longname(IN)
%SWAN_KEYWORD2LONGNAME    get SWAN long  name (OVLNAM) from associated SWAN code (OVKEYW)
%
% long_name = swan_keyword2longname(code) finds long name equivalents of SWAN 
%
% Example: to get 'Significant wave height'
%
%   swan_keyword2longname('HS')
%
%See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, 
%          SWAN_QUANTITY, SWAN_DEFAULTS,
%          SWAN_KEYWORD2SHORTNAME, SWAN_KEYWORD2TEXNAME, SWAN_SHORTNAME2KEYWORD

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

%% input
%------------------------

   OPT.char_out = 0;
   if ischar(IN)
   IN = cellstr(IN);
   OPT.char_out = 1;
   end
   
%% get database
%------------------------

   D = swan_quantity;
   
%% apply database
%------------------------

   for iname = 1:length(IN)
   
      OUT{iname} = D.(IN{iname}).OVLNAM;
   
   end
   
   if OPT.char_out
      OUT = char(OUT);
   end

%% EOF