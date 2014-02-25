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
% - By default an error is generated if a field name is present 
%   in 2 or more structs. An optional argument can be specified 
%   to allow merging of structs with identical fieldnames:
%   R = mergestructs('overwrite',a,b,c,..,) 
%   will overwrite fields with the same name with the field
%   value of the struct appearing <last> among the input arguments.
% - For fields that are also structs, the keyword 'recursive' can be
%   supplied to delegete overwriting of it to a nested call of
%   mergestructs, where overwriting of subfields is handled. The 
%   recursive flag means that substructs will never be kept/overwritten
%   entirely, but only its respective subfields, e.g.:
%   R = mergestructs('overwrite','recursive',a,b,c,..,) 
%
%See also: struct, setproperty

%21-8-2006

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section / Faculty of Civil Engineering and Geosciences
%       PO Box 5048 / 2600 GA Delft / The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   -------------------------------------------------------------------- 

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% initialize

OPT.overwrite   = 0; % 0 stops, 1 overwrites
OPT.recursive   = 0; % calls mergestructs recursively on substructs

firststruct = 1;
while 1
  if isstruct(varargin{firststruct})
      break
  else
    if     strcmp(varargin{firststruct},'overwrite');OPT.overwrite = 1;
    elseif strcmp(varargin{firststruct},'recursive');OPT.recursive = 1;
    end
    firststruct = firststruct + 1;
  end
end

%% Perform check on struct sizes

for i=firststruct:nargin-1
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

for i=firststruct:nargin
   FLDNAMES(i) = {fieldnames(varargin{i})};
   ISSTRUCT{i} = structfun(@(x) isstruct(x),varargin{i});
end

%% Perform check on double fieldnames

% for all input structs
for i=firststruct:nargin-1
   % for all field names
   for k = 1:length(FLDNAMES{i})
      if any(strcmp(FLDNAMES{i}{k},FLDNAMES{i+1}))
          
          FLD1 = varargin{1}.(FLDNAMES{i}{k});
          FLD2 = varargin{2}.(FLDNAMES{i+1}{find(strcmp(FLDNAMES{i}{k},FLDNAMES{i+1}))});
          notequalvalues  =1;
          % do not stop if : (1) fields have similar content OR (2) fields are empty
          if ischar(FLD1) && ischar(FLD2)
              notequalvalues = 1-strcmpi(FLD1,FLD2);
          elseif isnumeric(FLD1) && isnumeric(FLD2)
              notequalvalues = 1-(FLD1==FLD2);
          elseif isempty(FLD1)
              %varargin{1}= rmfield(varargin{1},(FLDNAMES{i}{k}));
              notequalvalues = 0;
          elseif isempty(FLD2)
              %varargin{2}= rmfield(varargin{2},(FLDNAMES{i+1}{find(strcmp(FLDNAMES{i}{k},FLDNAMES{i+1}))}));
              notequalvalues = 0;
          end
         % identical 1 1 1 1 1 1 1 1
         % overwrite 0 0 0 0 1 1 1 1
         % struct    0 0 1 1 0 0 1 1
         % recursive 0 1 0 1 0 1 0 1
         % error     1 1 1 0 0 0 0 0
          
         if notequalvalues
             if (OPT.overwrite) | (OPT.recursive & ISSTRUCT{i}(k))
                % delegate substructs to deeper call of mergestructs.
             else
                error(['Same field name is present in structs ',num2str(i),' and ',num2str(i+1)]);
             end
         end
      end
   end
end

%% Merge structs
% for all input structs
for i=firststruct:nargin
  % for all elements of input structs
  for j=1:prod(size(varargin{i}))
    % for all field names
    for k = 1:length(FLDNAMES{i})
      if i > firststruct && (OPT.recursive & ISSTRUCT{i}(k))
        if isfield(result(j),char(FLDNAMES{i}(k)))
          result(j).(char(FLDNAMES{i}(k))) = mergestructs('overwrite','recursive',result(j).(char(FLDNAMES{i}(k))),varargin{i}(j).(char(FLDNAMES{i}(k))));
        else
          result(j).(char(FLDNAMES{i}(k))) = varargin{i}(j).(char(FLDNAMES{i}(k)));
       end
      else
        result(j).(char(FLDNAMES{i}(k))) = varargin{i}(j).(char(FLDNAMES{i}(k)));
      end
    end % k
  end % j
end % i


%% Output

result = reshape(result,size(varargin{firststruct}));
