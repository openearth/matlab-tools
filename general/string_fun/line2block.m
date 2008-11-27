function block = line2block(line,blockwidth)
%LINE2BLOCK   reshape 1D character to 2D chaacter with fixed width
%
% textblock = LINE2BLOCK(textline,blockwidth)
% 
% reshapes to a 1D character or numeric array 
% to a block where the second dimension
% is equal to blockwidth. The length of the 
% array does not have to be an integer multiple 
% of blockwidth because the 1D array is padded with
% spaces or zeros to be reshapable.
% The last row or column will thus contains
% zeros or spaces.
%
% See also: LINE2STR, CELLSTR, CHAR

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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

   nlines    = ceil(length(line)/blockwidth);
   
   line      = pad(line,nlines*blockwidth);
   
   block     = reshape(line,blockwidth,nlines)';

%% EOF