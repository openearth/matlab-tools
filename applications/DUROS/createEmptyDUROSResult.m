function result = createEmptyDUROSResult()
% CREATEEMPTYDUROSRESULT
%
% routine to create an empty structure containing various field which are
% relevant for a DUROS calculation
%
% Syntax:       result = createEmptyDUROSResult
%
% Input:
% result = structure
%
% Output:
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

% $Id: $ 
% $Date: $
% $Author: $
% $Revision: $

%%
result = struct('info', [],...
    'Volumes', [],...
    'xLand', [],...
    'zLand', [],...
    'xActive', [],...
    'zActive', [],...
    'z2Active', [],...
    'xSea', [],...
    'zSea', []);

result.info = struct('time',[],...
    'ID',[],...
    'messages',[],...
    'x0',[],...
    'iter',[],...
    'precision',[],...
    'resultinboundaries',true,...
    'input',[]);

result.Volumes = struct('Volume',[],...
    'volumes',[],...
    'Accretion',[],...
    'Erosion',[]);