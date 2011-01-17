function LTPE_cutPoint(fig)
%LTPE_CUTPOINT ldbTool GUI function to cut a ldb at the specified point,
%splitting the segment into two segments
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
set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

data=LT_getData;
ldb=data(5).ldb;
nanId=find(isnan(ldb(:,1)));
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: left click existing ldb-point to make cut, right click to cancel');

[xClick, yClick, b]=ginput(1);
if b==3
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
    return
end
dist=sqrt((ldb(:,1)-xClick).^2+(ldb(:,2)-yClick).^2);
[sortDist, sortId]=sort(dist);
whileLoop=0;
iid=1;

while whileLoop==0
    id=sortId(iid);
    tempId=find(nanId>id);
    tempId=tempId(1);
    if isempty(find(abs(nanId-id)==1)) %check of het geen eind of begin punten van segmenten zijn
        ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:id,1:2);
        ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
        ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);
        ldbCell{end+1}=ldb(id+1:nanId(tempId)-1,:);
        ldbBegin(end+1,:)=ldbCell{end}(1,:);
        ldbEnd(end+1,:)=ldbCell{end}(end,:);
        ldb=[ldb(1:id,1:2) ; ldb(nanId(tempId):end,1:2); ldb(id+1:nanId(tempId)-1,1:2) ; nan nan];    
        whileLoop=1;
    elseif sortDist(1)==sortDist(2); %anders kijken of er een identiek punt onder ligt en het daarmee proberen
        iid=iid+1;
    else
        whileLoop=1;
        warndlg('You cannot cut a start or end point of a segment','ldbTool');
        return
    end
end

LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');