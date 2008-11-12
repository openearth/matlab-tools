function [x, z, Xdir, z0, Shift] = checkCrossShoreProfile(x, z, varargin)
% CHECKCROSSSHOREPROFILE routine to derive and/or change x-direction and/or 
% x-origin of a cross-shore profile
%
% Routine detects whether the profile specified by x and z is positive seaward 
% or positive landward, and derives the z-value at x=0. If specified, the 
% positive x-direction can be changed. Furthermore can be chosen either to 
% make the x-origin at the landward or at the seaward side.
%
% Syntax:
% [x, z, Xdir, z0, Shift] = checkCrossShoreProfile (x, z, varargin)
%
% Input:
% x        = column array with x-coordinates
% z        = column array with z-coordinates
% varargin = property value pairs
%               'x_direction' - 1 for positive landward
%                               -1 for positive seaward
%               'x_origin'    - either 'landside' or 'seaside'
%
% Output:
% x        = column array with x-coordinates
% z        = column array with z-coordinates
% Xdir     = x-direction: 1 for positive landward and -1 for positive seaward
% z0       = z-value at x=0
% Shift    = horizontal distance over which the profile has been shifted
%
% See also: 
 
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% sort x ascending and derive current positive x-direction
[x IX] = sort(x); % sort x ascending, get permutation vector
z = z(IX); % rearrange z based on permutation vector
[UpperBoundary LowerBoundary] = deal([]);
LandwardBoundary1 = min(x);
SeawardBoundary2 = max(x);
[SeawardBoundary1, LandwardBoundary2] = deal(mean([LandwardBoundary1 SeawardBoundary2]));
Volume1 = getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary1, SeawardBoundary1);
Volume2 = getVolume(x, z, UpperBoundary, LowerBoundary, LandwardBoundary2, SeawardBoundary2);

if Volume1 > Volume2 %i.e. x-direction positive seaward
    current_Xdir = -1; % positive seaward
else
    current_Xdir = 1; % positive landward
end

%% check whether x-direction has been specified, otherwise take current
if any(strcmpi(varargin, 'x_direction'))
    x_directionid = find(strcmpi(varargin, 'x_direction'));
    Xdir = varargin{x_directionid+1};
else
    Xdir = current_Xdir;
end

%% flip x and z if required
if Xdir ~= current_Xdir
    x = flipud(-x); % change x-direction into positive landward, flipud to keep the x-order ascending
    z = flipud(z);
end

%% check whether x_origin has been specified
if any(strcmpi(varargin, 'x_origin'))
    x_originid = find(strcmpi(varargin, 'x_origin'));
    x_origin = varargin{x_originid+1};
else
    x_origin = [];
end

if ~isempty(x_origin)
    if strcmpi(x_origin, 'landside') && Xdir == 1 ||...
            strcmpi(x_origin, 'seaside') && Xdir == -1
        refX = max(x);
    else
        refX = min(x);
    end
    if refX ~= 0
        Shift = -refX; % cross-shore distance to shift the profile
        x = x + Shift; % change the x-values
    else
        Shift = 0;
    end
else
    Shift = 0;
end

z0 = interp1(x, z, 0);