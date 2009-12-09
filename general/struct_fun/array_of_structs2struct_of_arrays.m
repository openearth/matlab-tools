function S1 = array_of_structs2struct_of_arrays(S2,varargin)
%ARRAY_OF_STRUCTS2STRUCT_OF_ARRAYS    merge D(:).fields(:) into D.fields(:,:)
%
%      s1 = array_of_structs2struct_of_arrays(s2)
%
% transforms an array of structures into a structure of arrays when
% all fields are character or numeric. The first dimension of s1
% corresponds to the size of s2. You can adjust this with PERMUTE.
%
% All fields with a common name need to be of the same type, and have the
% same size if numeric. cellstrings are turned in chars.
%
% Example: if s2(1:6) is an array of 6 structures, each with fields
%   
%     a: 'lampje'
%     b: [1x3]
%     c: [1x2]
%
% then s1 is a structure
%   
%     a: {1x6 cell}
%     b: [6x1x3]
%     c: [6x1x2]
%   
%See also: STRUCT_OF_ARRAYS2ARRAY_OF_STRUCTS, CELL2STRUCT, STRUCT2CELL, PERMUTE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

fldnames = fieldnames(S2);
n        = length(S2);

C = struct2cell(S2);

for ifld = 1 : length(fldnames)  % loop on fields

   fldname = fldnames{ifld};

   str = ischar(S2(1).(fldname)) | iscellstr(S2(1).(fldname));
   
   if str
      % check for identical type
      for i = 1 : n
         if ~(ischar(S2(i).(fldname)) |iscellstr(S2(i).(fldname)))
         error(['Field ''',fldname,''' in struct(',num2str(i),') is not a char while in struct(1) it is.'])
         end
      end
      % merge data      
      for i = 1 : n
         if ischar(S2(i).(fldname))
         S1.(fldname){i} = S2(i).(fldname);
         else
         S1.(fldname){i} = char(S2(i).(fldname));
         end
      end      
   else
      sz = size(S2(1).(fldname));
      % check for identical type
      for i = 1 : n
         if ~isnumeric(S2(i).(fldname))
         error(['Field ''',fldname,''' in struct(',num2str(i),') is not numeric while in struct(1) it is.'])
         end
      end
      % check for identical size
      for i = 1 : n
         if ~isequal(size(S2(i).(fldname)),sz)
         error(['Size of field ''',fldname,''' in struct(',num2str(i),') doe snot have same size as in struct(1).'])
         end
      end    
      % merge data
      S1.(fldname) = repmat(nan,[n sz(:)']);
      for i = 1 : n
         S1.(fldname)(i,:) = S2(i).(fldname)(:);
      end
   end

end

%% EOF

