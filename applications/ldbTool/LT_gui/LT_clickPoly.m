function LT_clickPoly
%LT_CLICKPOLY ldbTool GUI function to click a polygon
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Code
[but,fig]=gcbo;

% pick some boundaries
uo = []; vo = []; button = [];

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: use left mouse button to add points, right click when done');
set(findobj(gcf,'tag','LT_showPolygonBox'),'value',1);

[uo,vo,lfrt] = ginput(1);
button = lfrt;
hold on;
data=get(fig,'userdata');
data(1,5).ldb=[uo vo];
set(fig,'userdata',data);
LT_plotLdb;

while lfrt == 1
    [u,v,lfrt] = ginput(1);
    if lfrt==1;
        uo=[uo;u]; vo=[vo;v]; button=[button;lfrt];
    end
    data=get(fig,'userdata');
    data(1,5).ldb=[uo vo];
    set(fig,'userdata',data);
    LT_plotLdb;
end

% Bail out at ESCAPE = ascii character 27
if lfrt == 27
    return
end

% set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: ');

LTSE_selectSegmentsInPoly;
