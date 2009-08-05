function [z ErosionVolume result] = x2z(x, varnames, Resistance, varargin)
%X2Z  Limit state function
%
%   More detailed description goes here.
%
%   Syntax:
%   [z ErosionVolume] = x2z(x, varnames, Resistance, varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   x2z
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% cross-shore profile
if ~isempty(varargin)
    xInitial = varargin{1};
    zInitial = varargin{2};
    xInitial = xInitial(~isnan(zInitial));
    zInitial = zInitial(~isnan(zInitial));
else
    xInitial = [-250; -24.375; 5.625; 55.725; 230.625; 1950];
    zInitial = [15; 15; 3; 0; -3; -14.4625];
end

% reference for retreat distance
if length(varargin) > 2
    zRef = varargin{3};
else
    zRef = 5;
end
xRef = max(findCrossings(xInitial, zInitial, [min(xInitial) max(xInitial)]', ones(2,1)*zRef));

%% retrieve calculation values
for i = 1:size(x,2)
    eval([varnames{i} ' = [' num2str(x(:,i)') ']'';'])
end

for i = 1:size(x,1)
    try
        %% set calculation values for additional volume
        DuneErosionSettings('set',...
            'AdditionalVolume', [num2str(Duration(i)) '*Volume + ' num2str(Accuracy(i)) '*Volume'],... string voor het bepalen van het toeslagvolume gedurende de berekening (afslagvolume is negatief)
            'BoundaryProfile', false,...       % Grensprofiel berekenen is niet nodig, gebruiken we niet
            'FallVelocity', {@getFallVelocity 'a' 0.476 'b' 2.18 'c' 3.226 'D50'});
        
        % set coastal curvature, if provided
        if ~isempty(R(i))
            DuneErosionSettings('set', 'Bend', 180 / (pi * R(i)) * 1000);
        else
            DuneErosionSettings('set', 'Bend', 0);
        end
        
        %% carry out DUROS+ computation
        result = getDuneErosion(xInitial, zInitial, D50(i), WL_t(i), Hsig_t(i), Tp_t(i));
        Tp_t(i) = result(1).info.input.Tp_t;

        %% Derive z-value
        [x2 z2 result2] = getFinalProfile(result);
        ErosionVolume(i) = result2.Volumes.Erosion;
        RD(i) = xRef - result(end).VTVinfo.Xr;

        %%
        if length(result) > 1
            Duration(i) = -result(2).Volumes.Volume*Duration(i);
            Accuracy(i) = -result(2).Volumes.Volume*Accuracy(i);
        end
%         for var = {'D50' 'WL_t' 'Hsig_t' 'Tp_t' 'Duration' 'Accuracy' 'RD'}
%             fprintf('%10e ', eval([var{1} '(' num2str(i) ')']))
%         end
%         fprintf('\n');
    catch me
        me
        ErosionVolume(i) = NaN;
        RD(i) = NaN;
        fname = tempname
        save(fname, 'D50', 'WL_t', 'Hsig_t', 'Tp_t', 'Duration', 'Accuracy', 'i')
    end

    z(i,:) = Resistance - RD(i);
end