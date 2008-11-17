function start_of_PATHSTR = first_subdir(fullfilename,varargin)
%FIRST_SUBDIR   Returns first subdirectory names from filename
%
% returns first subdirectory names from filename
%
% subdir = first_subdir(file) 
% subdir = first_subdir(file,n) returns first n subdirectories
%
% See also: FILEPARTS, filepathstr, filename, filenameext, last_subdir

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

[PATHSTR,NAME,EXT,VERSN] = fileparts(fullfilename);

PATHSTR                  = path2os(PATHSTR);

slash_positions          = findstr(PATHSTR,filesep);
slash_positions          = [slash_positions length(fullfilename)-1];

if nargin==2
   nsubdir = varargin{1};
else
   nsubdir = 1;
end

if nsubdir > (length(slash_positions));
   nsubdir = length(slash_positions);
   disp(['Warning: n truncated to : ',num2str(nsubdir)])
end

start_of_PATHSTR  = PATHSTR(1:1+slash_positions(nsubdir)-1);