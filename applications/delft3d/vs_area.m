function varargout = vs_mask(varargin);
%VS_AREA   reads INCORRECT cell areas from com-file.
%
%   area = vs_area(comfile);
%
% See also: VS_USE, VS_GET, VS_LET, GETAREACURVILINEARGRID

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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

% C is the NFS struct handle as returned by C = vs_use(...)

   %% Input
   %% --------------------

   if ~odd(nargin)
     NFStruct=vs_use('lastread');
   else
     if isstruct(varargin{1})
        NFStruct = varargin{1};
     else % filename
        NFStruct = vs_use(varargin{1});
     end
   end
   
   %% Test
   %% --------------------

   switch vs_type(NFStruct),
      case 'Delft3D-com',
      otherwise
      error('Areas only in comfile.')
   end;
   iargin = 1; % argument counter
   
   %  %% Input
   %  %% --------------------
   %  value = 'real';
   %  while iargin<=nargin-2,
   %    if ischar(varargin{iargin}),
   %      switch lower(varargin{iargin})
   %      case 'keyword'   ;iargin=iargin+1;value    = varargin{i};
   %      otherwise
   %         error(sprintf('Invalid string argument: %s.',varargin{i}));
   %      end
   %    end;
   %    iargin=iargin+1;
   %  end;   

   area_wrong = squeeze(vs_let(NFStruct,'GRID','GSQS'));

if nargout==1
   varargout = {area_wrong};
%elseif narout==2
%   area_correct = getareacurvilineargrid()
%   varargout = {area_wrong,area_correct};
end
   