function savestr(fname,str)
%SAVESTR   save 2D char array to ASCII file
%
%   SAVESTR(filename,string)
%
% saves 2D char or cellstr string to file filename.
% Note: does not prompt if filename already exists.
%
%See also: FOPEN, FPRINTF, FCLOSE, SAVE (*,'-ASCII')

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
%   -------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

if iscellstr(str)
   str = char(str);
end

fid = fopen(fname,'w');

for ii=1:size(str,1)

   fprintf(fid,'%s\n',str(ii,:));
   
end   

fclose(fid);

%% EOF