function LTSE_assignSamplesOldStyle
%LTSE_ASSIGNSAMPLESOLDSTYLE ldbTool GUI function to assign samples to a ldb
%segment (old style)
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
persistent sampleSpecs

[but,fig]=gcbo;

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

data=LT_getData;
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click near start or end point of segment to show, right click to cancel');


[xClick, yClick,b]=ginput(1);

allhCp=[];
while b==1
    
    disStart=sqrt((xClick(1)-ldbBegin(:,1)).^2+(yClick(1)-ldbBegin(:,2)).^2);
    disEnd=sqrt((xClick(1)-ldbEnd(:,1)).^2+(yClick(1)-ldbEnd(:,2)).^2);
    
    if min(disStart)<min(disEnd);
        [dum, id]=min(disStart);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp=plot(ldbCell{id}(:,1),ldbCell{id}(:,2),'b');
    else
        [dum, id]=min(disEnd);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp=plot(ldbCell{id}(:,1),ldbCell{id}(:,2),'b');
    end
    
    set(hCp,'ZData',repmat(3,size(get(hCp,'XData'))));
    
    if isempty(sampleSpecs)
        sampleSpecs{1}='10';
        sampleSpecs{2}='10';
    end
    
    [sampleSpecs]=inputdlg({'Sample value','Distance between sample points'},'LDBtool',1,sampleSpecs);
    
    %Store all handles
    allhCp=[allhCp hCp];
    %Make red what's done
    set(hCp,'color','r');
    
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
    
    if isempty(sampleSpecs)
        delete(allhCp);
        return
    else
        assignSamples(ldbCell{id}(:,1),ldbCell{id}(:,2),str2num(sampleSpecs{1}),str2num(sampleSpecs{2}),'samplesFromLDBTool.xyz')
    end
    
    [xClick, yClick,b]=ginput(1);
    
end

delete(allhCp);