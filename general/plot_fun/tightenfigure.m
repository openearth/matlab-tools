function tightenfigure(fhandle)
% TIGHTENFIGURE routine to maximise a figure within its window
%
% Routine to maximise a figure by reducing the margins to a minimum
%
% Syntax: 
% tightenfigure(fhandle)
%
% Input:
% fhandle = figure handle
%
% Output:
%
% See also:

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

% $Id$ 
% $Date$
% $Author$
% $Revision$

%% get defaults
getdefaults('fhandle', gcf, 0)

%% find axes handles and save current state
Axeshandles = findobj(fhandle,...
    'Type', 'axes',...
    '-and','-not',...
    'Tag', 'legend');

if isempty(Axeshandles)
    return
end

% keep current warning state and turn of all warnings
state.warning = warning;
warning off %#ok<WNOFF>

% obtain current property settings
state.Axes = get(Axeshandles);

% reset original warning state
warning(state.warning);

if length(Axeshandles)>1 && ...
        ~all(all(diff(cell2mat(get(Axeshandles, 'Position')))==0))
    % multiple panels in one figure
%     set(Axeshandles,...
%         'Units', 'normalized');
%     OuterPosition = cell2mat(get(Axeshandles, 'OuterPosition'));
%     Subplotsize = max(round(1./OuterPosition(:,3:4)));
    % currently, tightenfigure is not suitable for figures with multiple
    % panels
    return
end


%% reset outerposition and set units to centimeters
set(Axeshandles,...
    'Units', 'normalized',...       % first normalize
    'OuterPosition', [0 0 1 1],...  % then reset
    'Units', 'centimeters')         % then units in centimeters

%% get tightinset and outerposition
TightInset = get(Axeshandles, 'TightInset');
OuterPosition = get(Axeshandles, 'OuterPosition');

if iscell(TightInset)
    % is cell in case of multiple axes
    TightInset = cell2mat(TightInset);
    OuterPosition = cell2mat(OuterPosition);
end

id_notvisible = strcmp(get(Axeshandles, 'Visible'), 'off');
if any(id_notvisible)
    % set tightinset of non-visible axes to zero
    TightInset(id_notvisible, :) = zeros(1,4);
end
% preserve maximum tightinset for each margin
TightInset = max(TightInset,[],1);
% preserve minimum outerposition (they should be equal)
OuterPosition = min(OuterPosition,[],1);

%% derive new width and height
Width = OuterPosition(3) - sum(TightInset([1 3]));
Height = OuterPosition(4) - sum(TightInset([2 4]));

%% fit figure tight in window
set(Axeshandles, 'Position', [TightInset(1:2) Width Height]);

%% reset units to original state
for id = 1:length(Axeshandles)
    set(Axeshandles(id), 'Units', state.Axes(id).Units)
end