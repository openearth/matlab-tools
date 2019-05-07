function inputSize  = getInputSize(variables)
%GETINPUTSIZE   routine to derive the size of input variables
%
%   Routine determines the size of variables of the 'caller' function
%
%   syntax:
%   inputSize  = getInputSize(variables)
%
%   input:
%       variables       = cell array containing input arguments of the 
%                           'caller' function
%
%   example:
%
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
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

% $Id: getInputSize.m 4147 2014-10-31 10:12:42Z bieman $ 
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $

%%
n = min([evalin('caller','nargin') length(variables)]); % get number of input arguments of the caller function
inputSize = zeros(length(variables),2); % preallocate inputSize with zeros
for a = 1 : n
    inputSize(a,:) = evalin('caller',['size(' variables{a} ')']);
end

if n<length(variables) % in case of not assigned variables in the caller function
    for a = n+1:length(variables) % not assigned variables
        evalin('caller',[variables{a} '=[];']); % make an empty array
    end
end