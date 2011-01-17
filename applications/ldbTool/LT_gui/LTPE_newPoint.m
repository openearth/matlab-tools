function LTPE_newPoint
%LTPE_NEWPOINT ldbTool GUI function to add a new point to the ldb, starting
%a new segment
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

%% Code
[but,fig]=gcbo;

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

data=LT_getData;
ldb=data(5).ldb;
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;

if ~isnan(ldb(end,1))
ldb = [ldb ; nan nan];
end

ldb = [ldb ; nan nan];

insertPoints=1;
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click location of new points, right click when done');

tempId=length(ldbCell)+1;
while insertPoints==1
    [xClick, yClick,b]=ginput(1);
    if b~=3
        ldb=[ldb(1:end-1,:) ; xClick yClick; nan nan];
        nanId=find(isnan(ldb(:,1)));
        ldbCell{tempId}=ldb(nanId(end-1)+1:nanId(end)-1,:);
        ldbBegin(tempId,:)=ldbCell{tempId}(1,:);
        ldbEnd(tempId,:)=ldbCell{tempId}(end,:);
        LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
    else
        insertPoints=0;
    end
end

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
set(findobj(fig,'tag','LT_saveMenu'),'enable','on');
set(findobj(fig,'tag','LT_save2Menu'),'enable','on');