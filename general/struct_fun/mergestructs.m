function result = mergestructs(varargin)
%MERGESTRUCTS  Merges 2 or more structs into new struct.
%
% mergestructs merges 2 or any more number of structs 
% into a new struct.
%
%    result = mergestructs(a,b,c,..,) 
%
% creates a struct 'result' containing all field names
% and values of structs a, b, and c.
%
% - The sizes of all input struct should be equal. An empty
%   structure (size = 0) is not allowed).
% - By default an error is generated if
%   a field name is present in 2 or more structs. An
%   optional argument can be specified to allow merging
%   of structs with similar fieldnames:
%   result = mergestructs('overwrite',a,b,c,..,) 
%   overwrites fields with the same name with the field
%   value of the struct appearing <last> among the
%   input arguments.
%
%See also: struct, setproperty

%21-8-2006

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
% $Keywords:

%% initialize
OPT.overwrite   = 0;
OPT.firststruct = 1;
if ~isstruct(varargin{1})
    if strcmp(varargin{1},'overwrite')
        OPT.overwrite   = 1;
        OPT.firststruct = 2;
    end
end    


%% Perform check on struct sizes
for i=OPT.firststruct:nargin-1
   if ~isstruct(varargin{i})
      error(['Argument ',num2str(i),' is not a struct.']);
   end
   for j=1:length(size(varargin{i}))
      if ~(size(varargin{i},(j))==size(varargin{i+1},(j)))
         error(['Structures ',num2str(i),' and ',num2str(i+1),' do not have the same size']);
      end
   end
end

%% Get field names
for i=OPT.firststruct:nargin
   FLDNAMES(i) = {fieldnames(varargin{i})};
end

%% Perform check on double fieldnames

% for all input structs
for i=OPT.firststruct:nargin-1
   % for all field names
   for k = 1:length(FLDNAMES{i})
      if strcmp(char(FLDNAMES{i}),char(FLDNAMES{i+1}));
         if ~(OPT.overwrite)
            error(['Same field name is present in structs ',num2str(i),' and ',num2str(i+1)]);
         end
      end
   end
end

%% Merge structs

% for all input structs
for i=OPT.firststruct:nargin

   % for all elements of input structs
   for j=1:prod(size(varargin{i}))

      % for all field names
      for k = 1:length(FLDNAMES{i})
         result(j).(char(FLDNAMES{i}(k))) = varargin{i}(j).(char(FLDNAMES{i}(k)));
      end

   end

end


%% Output

result = reshape(result,size(varargin{OPT.firststruct}));
