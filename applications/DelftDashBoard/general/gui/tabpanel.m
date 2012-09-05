function [handle tabhandles] = tabpanel(fcn, varargin)
%TABPANEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [handle tabhandles] = tabpanel(fcn, varargin)
%
%   Input:
%   fcn        =
%   varargin   =
%
%   Output:
%   handle     =
%   tabhandles =
%
%   Example
%   tabpanel
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

tabnames=[];
inputarguments=[];
strings=[];
tabname=[];
parent=[];
tag=[];
handle=[];
fig=gcf;
clr=[];
activetabnr=1;
callbackopt='withcallback';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'figure'}
                fig=varargin{i+1};
            case{'tag','name'}
                tag=varargin{i+1};
            case{'handle'}
                handle=varargin{i+1};
            case{'position'}
                pos=varargin{i+1};
            case{'strings'}
                strings=varargin{i+1};
            case{'tabname'}
                tabname=varargin{i+1};
            case{'callbacks'}
                callbacks=varargin{i+1};
            case{'inputarguments'}
                inputarguments=varargin{i+1};
            case{'tabnames'}
                tabnames=varargin{i+1};
            case{'parent'}
                parent=varargin{i+1};
            case{'color'}
                color=varargin{i+1};
            case{'activetabnr'}
                activetabnr=varargin{i+1};
            case{'runcallback'}
                if ~varargin{i+1}
                    callbackopt='nocallback';
                end
        end
    end
end

if isempty(clr)
    clr=get(fig,'Color');
end

if isempty(tabnames) && ~isempty(strings)
    tabnames=strings;
end

if isempty(handle)
    handle=findobj(fig,'Tag',tag,'Type','uipanel');
end

switch lower(fcn)
    case{'create'}
        ntabs=length(tabnames);
        [handle,tabhandles]=createTabPanel(fig,tag,clr,pos,parent,ntabs);
        changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
        select(handle,activetabnr,'nocallback');
    case{'change'}
        changeTabPanel(handle,strings,callbacks,inputarguments,tabnames);
        select(handle,activetabnr,'nocallback');
    case{'select'}
        panel=get(handle,'UserData');
        tabnames=panel.tabNames;
        iac=strmatch(lower(tabname),lower(tabnames),'exact');
        select(handle,iac,callbackopt);
    case{'disabletab'}
        panel=get(handle,'UserData');
        tabnames=panel.tabNames;
        iac=strmatch(lower(tabname),lower(tabnames),'exact');
        set(panel.tabTextHandles(iac),'Enable','off');
    case{'enabletab'}
        panel=get(handle,'UserData');
        tabnames=panel.tabNames;
        iac=strmatch(lower(tabname),lower(tabnames),'exact');
        set(panel.tabTextHandles(iac),'Enable','inactive');
    case{'delete'}
        deleteTabPanel(handle);
    case{'resize'}
        resizeTabPanel(handle,pos);
    case{'update'}
        updateTabElements(handle);
end

%%
function [panelHandle,largeTabs]=createTabPanel(fig,panelname,clr,panelPosition,parent,ntabs)

foregroundColor=clr;
backgroundColor=clr*0.9;

leftpos(1)=3;
vertpos=panelPosition(4)-1;

tabHeight=20;

%ntabs=20;
tabs=zeros(ntabs,1);
tabText=tabs;
blankText=tabs;

pos=[panelPosition(1)-1 panelPosition(2)-1 panelPosition(3)+2 panelPosition(4)+20];

panelHandle = uipanel(fig,'Parent',parent,'Units','pixels','Position',pos,'BorderType','none','BackgroundColor','none','Tag',panelname);

for i=1:ntabs
    
    position=[leftpos vertpos 30 tabHeight];
    
    % Add tab
    tabs(i) = uipanel(fig,'Parent',panelHandle,'Units','pixels','Position',position,'Tag','dummy','BorderType','beveledout','BackgroundColor',backgroundColor,'Visible','on');
    
    % Add text, first use bold
    tabText(i) = uicontrol(fig,'Units','pixels','Parent',panelHandle,'Style','text','String','dummy','Position',position,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor',backgroundColor,'Visible','off');
    set(tabText(i),'Enable','inactive');
    
    % Set user data
    usd.nr=i;
    usd.panelHandle=panelHandle;
    set(tabs(i),'UserData',usd);
    set(tabText(i),'UserData',usd);
    
    % Left position for next tab
    leftpos=leftpos+30;
    
end

% Create new main panel
visph = uipanel(fig,'Units','pixels','Parent',panelHandle,'Position',[1 1 panelPosition(3) panelPosition(4)],'BorderType','beveledout','BackgroundColor',foregroundColor);

pos=[1 1 panelPosition(3) panelPosition(4)+20];
for i=1:ntabs
    largeTabs(i) = uipanel(fig,'Parent',panelHandle,'Units','pixels','Position',pos,'Tag','largeTab','BorderType','none','BackgroundColor','none','Visible','on','HitTest','off');
end

% Add blank texts
leftpos=3;
vertpos=panelPosition(4)-1;
for i=1:ntabs
    position=[leftpos vertpos 30 tabHeight];
    blankText(i) = uicontrol(fig,'Style','text','String','','Position',position,'Visible','off','Parent',panelHandle);
    leftpos=leftpos+30;
end

set(blankText,'BackgroundColor',foregroundColor);
set(blankText,'HandleVisibility','off','HitTest','off');

% Add user data to panel
panel.nrTabs=ntabs;
panel.visiblePanel=visph;
panel.tabHandles=tabs;
panel.largeTabHandles=largeTabs;
panel.tabTextHandles=tabText;
panel.blankTextHandles=blankText;
panel.handle=panelHandle;
panel.position=panelPosition;
panel.foregroundColor=foregroundColor;
panel.backgroundColor=backgroundColor;
panel.activeTab=1;

set(panelHandle,'UserData',panel);


%%
function changeTabPanel(panelHandle,strings,callbacks,inputarguments,tabnames)

ntabs=length(strings);

if isempty(inputarguments)
    for i=1:length(strings)
        inputarguments{i}=[];
    end
end

% Set panel tabs invisible
panel=get(panelHandle,'UserData');
tabs=panel.tabHandles;
tabText=panel.tabTextHandles;
blankText=panel.blankTextHandles;
largeTabs=panel.largeTabHandles;

set(tabs(1:ntabs),'Visible','on');
set(tabText(1:ntabs),'Visible','on');
set(blankText(1:ntabs),'Visible','on');

foregroundColor=panel.foregroundColor;
backgroundColor=panel.backgroundColor;

panelPosition=panel.position;

leftpos=3;
vertpos=panelPosition(4)-1;
leftTextMargin=3;
bottomTextMargin=2;
tabHeight=20;
textHeight=15;

for i=1:ntabs
    
    set(largeTabs(i),'Tag',tabnames{i});
    
    tmppos=get(tabText(i),'Position');
    tmppos(3)=150;
    set(tabText(i),'Position',tmppos);
    set(tabText(i),'String',strings{i},'FontWeight','bold');
    
    % Compute new position
    ext=get(tabText(i),'Extent');
    wdt(i)=ext(3)+2*leftTextMargin;
    position=[leftpos(i) vertpos ext(3)+2*leftTextMargin tabHeight];
    set(tabs(i),'Position',position);
    textPosition=[position(1)+leftTextMargin position(2)+bottomTextMargin ext(3) textHeight];
    set(tabText(i),'Position',textPosition);
    
    position=[leftpos(i)+1 vertpos wdt(i)-3 3];
    set(blankText(i),'Position',position);
    
    % Add callback
    set(tabs(i),'ButtonDownFcn',{@clickTab});
    set(tabText(i),'ButtonDownFcn',{@clickTab});
    
    % Set user data
    usd=get(tabs(i),'UserData');
    set(tabs(i),'UserData',usd);
    set(tabText(i),'UserData',usd);
    
    % Left position for next tab
    leftpos(i+1)=leftpos(i)+wdt(i)+1;
    
end

% Set values for all tabs
set(tabs,'BackgroundColor',backgroundColor);
set(tabText,'BackgroundColor',backgroundColor,'FontWeight','normal');
set(blankText,'Visible','off');

% Give first tab background color and make blank text visible
set(tabs(1),'BackgroundColor',foregroundColor);
set(tabText(1),'BackgroundColor',foregroundColor,'FontWeight','bold');
set(blankText(1),'Visible','on');

% Add user data to panel
panel.nrTabs=ntabs;
panel.strings=strings;
panel.tabNames=tabnames;
panel.callbacks=callbacks;
panel.inputArguments=inputarguments;

set(panelHandle,'UserData',panel);

for i=1:length(panel.largeTabHandles)
    set(panel.largeTabHandles(i),'Visible','off');
end
%drawnow;

%%
function clickTab(hObject,eventdata)

usd=get(hObject,'UserData');
h=usd.panelHandle;
nr=usd.nr;
enable=get(hObject,'Enable');
%profile on
switch lower(enable)
    case{'off'}
    otherwise
        select(h,nr,'withcallback');
end
% profile off
% profile viewer

%%
function select(h,iac,opt)

panel=get(h,'UserData');

%drawnow
% for i=1:length(panel.largeTabHandles)
%     if i~=iac
%         set(panel.largeTabHandles(i),'Visible','off');
%         drawnow;
%     end
% end
%drawnow;

set(panel.largeTabHandles(panel.activeTab),'Visible','off');
%drawnow('expose');

% Set new tab visible
set(panel.largeTabHandles(iac),'Visible','on');
%drawnow('expose');

panel.activeTab=iac;
set(h,'UserData',panel);

% Set active tab number in appdata
try
    el=getappdata(h,'element');
end
el.activetabnr=iac;
setappdata(h,'element',el);

% All tabs
set(panel.tabHandles,'BackgroundColor',panel.backgroundColor);
set(panel.tabTextHandles,'FontWeight','normal');
set(panel.tabTextHandles,'BackgroundColor',panel.backgroundColor);
set(panel.blankTextHandles,'Visible','off');

% Active tab
set(panel.tabHandles(iac),'BackgroundColor',panel.foregroundColor);
set(panel.tabTextHandles(iac),'BackgroundColor',panel.foregroundColor);
set(panel.tabTextHandles(iac),'FontWeight','bold');
set(panel.blankTextHandles(iac),'Visible','on');



% % Callback
% if strcmpi(opt,'withcallback') && ~isempty(panel.callbacks{iac})
%     % Execute callback
%     if isempty(panel.inputArguments{iac})
%         feval(panel.callbacks{iac});
%     else
%         feval(panel.callbacks{iac},panel.inputArguments{iac});
%     end
% end



% Find handle of tab panel and get tab info
% h=findobj(gcf,'Tag',tag,'Type','uipanel');
% el=getappdata(h,'element');
% tab=el.tabs(tabnr).tab;

activetabhandle=panel.largeTabHandles(iac);
setappdata(gcf,'activetabhandle',activetabhandle);

if strcmpi(opt,'withcallback')
    
    % Elements is structure of elements inside selected tab
    element=el.tab(iac).tab.element;
    
    callback=el.tab(iac).tab.callback;
    elementstoupdate=element;
    % Now look for tab panels within this tab, and execute callback associated
    % with active tabs
    for k=1:length(element)
        if strcmpi(element(k).element.style,'tabpanel')
%             % Update tabs (some may have to be disabled or enabled)
            for itab=1:length(element(k).element.tab)
                htab=element(k).element.tab(itab).tab.handle;
                gui_updateDependency(htab);
            end
            % Find active tab
            hh=element(k).element.handle;
            el=getappdata(hh,'element');
            iac=el.activetabnr;
            callback=el.tab(iac).tab.callback;
            elementstoupdate=el.tab(iac).tab.element;
            activetabhandle=el.tab(iac).tab.handle;
            break
        end
    end
    
    if ~isempty(elementstoupdate)
        gui_setElements(elementstoupdate);
    end
    
    setappdata(gcf,'activetabhandle',activetabhandle);
    
    if ~isempty(callback)
        feval(callback);
    end
    
end


% Check if there are any tab panels inside this tab


%%
function deleteTabPanel(h)

delete(h);

%%
function resizeTabPanel(h,panelPosition)

panel=get(h,'UserData');

posInvisibleTab=[panelPosition(1)-1 panelPosition(2)-1 panelPosition(3)+2 panelPosition(4)+20];

% Outer (invisible) panel
set(h,'Position',posInvisibleTab);

pvis=panel.visiblePanel;

posVisibleTab=[1 1 panelPosition(3) panelPosition(4)];
% Outer (invisible) panel
set(pvis,'Position',posVisibleTab);

bottomTextMargin=3;
vertPosTabs=panelPosition(4)-1;
vertPosText=vertPosTabs+bottomTextMargin;

posLargeTabs=[1 1 panelPosition(3) panelPosition(4)+20];

for i=1:panel.nrTabs
    
    set(panel.largeTabHandles(i),'Position',posLargeTabs);
    
    pos=get(panel.tabHandles(i),'Position');
    pos(2)=vertPosTabs;
    set(panel.tabHandles(i),'Position',pos);
    
    pos=get(panel.blankTextHandles(i),'Position');
    pos(2)=vertPosTabs;
    set(panel.blankTextHandles(i),'Position',pos);
    
    pos=get(panel.tabTextHandles(i),'Position');
    pos(2)=vertPosText;
    set(panel.tabTextHandles(i),'Position',pos);
    
end

panel.position=panelPosition;
set(h,'UserData',panel);

