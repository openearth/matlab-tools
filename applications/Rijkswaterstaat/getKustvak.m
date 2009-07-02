function varargout = getKustvak(varargin)
%GETKUSTVAK  routine to return area name from code or code from area name
%
%   This routine returns the name of the coastal area 'Kustvak' along the Dutch 
%   coast when an area code is input, and the code of the area if the name is 
%   input. An overview of all areas, including codes, is listed in the
%   command window if no input arguments are given and no output arguments
%   are asked.
%
%   Syntax:
%   varargout = getKustvak(varargin)
%
%   Input:
%   varargin  =
%       AreaCode  = number of area 'Kustvak' along the Dutch coast
%       AreaName  = name of area 'Kustvak' along the Dutch coast
%
%   Output:
%   varargout =
%
%   Example
%   % display list of area codes and area names
%   for AreaCode = 1:17
%       fprintf('%2i %s\n', AreaCode, getKustvak(AreaCode));
%   end
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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

% Created: 07 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
Areas = {
    'Rottumeroog en Rottumerplaat',...  %1
    'Schiermonnikoog',...               %2
    'Ameland',...                       %3
    'Terschelling',...                  %4
    'Vlieland',...                      %5
    'Texel',...                         %6
    'Noord-Holland',...                 %7
    'Rijnland',...                      %8
    'Delfland',...                      %9
    'Maasvlakte / slufter',...          %10
    'Voorne',...                        %11
    'Goeree',...                        %12
    'Schouwen',...                      %13
    'Oosterschelde / Neeltje Jans',...	%14
    'Noord-Beveland',...                %15
    'Walcheren',...                     %16
    'Zeeuws-Vlaanderen' ...             %17
    };

%% show overview of areas including codes
if nargin == 0 && nargout == 0
    fprintf(1, 'code  name\n')
    for i = 1:length(Areas)
        fprintf(1, '%2i    %s\n', i, Areas{i})
    end
end

%%
for i = 1:nargin
    if isnumeric(varargin{i}) % area code
        varargout{i} = Areas{varargin{i}}; % return area name
    elseif ischar(varargin{i}) % area name
        varargout{i} = find(strcmp(Areas, varargin{i})); % return area code
    end
end

if nargin > 1 && nargout < length(varargout)
    varargout = {varargout};
end