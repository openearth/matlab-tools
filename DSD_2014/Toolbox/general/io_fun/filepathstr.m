function PATHSTR = filepathstr(fullfilename,varargin)
%FILEPATHSTR   Returns PATHSTR from    [PATHSTR,NAME,EXT] = FILEPARTS(FILE).
% 
% By default PATHSTR does NOT end with a filesep.
% PATHSTR(fullfilename,1) adds a filesep.
%
% Note that FILEPATHSTR is vectorized, whereas FILEPARTS is not.
%
% See also:
% FILEPARTS, FILENAME, FILEEXT, FILENAMEEXT, FULLFILE, FILEPATHSTRNAME

% $Id: filepathstr.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/io_fun/filepathstr.m $
% $Keywords$

if iscellstr(fullfilename)
    fullfilename = char(fullfilename);
end

for iname=1:size(fullfilename,1)

   [PATHSTR{iname},NAME{iname},EXT{iname}] = fileparts(fullfilename(iname,:));

end 

PATHSTR = char(PATHSTR);

if nargin==2
   if varrgin{1}
   PATHSTR = [PATHSTR,filesep];
   end
end

% Feb 2008, vectorized.
   
%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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

%% EOF