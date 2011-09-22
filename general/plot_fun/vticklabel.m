function vticklabel(varargin)
%VTICKLABEL  Adds vertical tick labels to x-axis
%
%   Adds vertical tick labels to x-axis of current axis
%
%   WARNING: NEEDS TO BECOME MORE GENERIC
%
%   Syntax:
%   vticklabel(varargin)
%
%   Input:
%   varargin  = tick labels
%
%   Output:
%   none
%
%   Example
%   vticklabel('Label 1', 'Label 2', 'Label 3')
%
%   See also set

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% set labels

hx  = get(gca, 'XLabel');

set(hx,'Units','data'); 
pos = get(hx,'Position'); 
y   = pos(2); 

txt = [];
for j = 1:length(varargin)
    txt(j) = text(j,y,varargin{j}); 
end

set(txt,'Rotation',-90,'HorizontalAlignment','left');
