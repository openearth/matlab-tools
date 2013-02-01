function mkpath(directory)
%MKPATH   Make new directory (recursively) incl. all subdirs.
%
% Makes an absolute or relative path 
% including all subdirectories.
%
% When the path already exists, nothing is done.
% 
%See also: MKDIR,  EXIST, PATH2OS,    COPYFILE, CD, LAST_SUBDIR,
%          DELETE, DIR,   FILEATTRIB, MOVEFILE, RMDIR.

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
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

directory = path2os([directory,filesep]);

j = strfind(directory,':');
if ~(directory(j+1)==filesep)
   error([': should be followed by ',filesep]);
end

if ~(exist(directory,'dir')==7)

   indices   = strfind(directory,filesep);
   
   % this expception if for network directories starting with '\\'
   if numel(indices)>=2
       if isequal(indices(1:2),[1 2])
           indices = indices(3:end);
       end
   end
   
   if length(indices)==1
   
      %% Make subdirectory lowest in directory tree
      %  in pwd,
      %  end of recursion
      %---------------------------------------
   
      mkdir(directory)
   
   elseif length(indices)==2
   
      %% Make subdirectory lowest in directory tree
      %  in other parent dir,
      %  end of recursion
      %---------------------------------------

      dirleft   = directory(1:indices(1));
      dirright  = directory(  indices(1):end);
      mkdir(dirleft,dirright)
   
   else
   
      %% Recursively create one level deeper
      %  in exiting path
      %---------------------------------------

      for i=2:length(indices)
      
         dirleft   = directory(1:indices(i));
         dirright  = directory(  indices(i):end);
         
         status = exist(dirleft,'dir');
         if ~(status==7)
            dirold = directory(1:indices(i-1));
            dirnew = directory(  indices(i-1)+1:indices(i));
            mkdir (dirold,dirnew);
            mkpath(directory);
            break % recursive
         end
      
      end
   end
   
end   

%% EOF