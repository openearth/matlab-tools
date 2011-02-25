function [handle,tabhandles]=tabpanel(fcn,varargin)

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
    handle=findobj(fig,'Tag',lower(tag),'Type','uipanel');
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
        iac=strmatch(tabname,tabnames,'exact');
        select(handle,iac,callbackopt);
    case{'delete'}
        deleteTabPanel(handle);
    case{'resize'}
        resizeTabPanel(handle,pos);
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
% set(tabs(ntabs+1:20),'Visible','off');
% set(tabText(ntabs+1:20),'Visible','off');
% set(blankText(ntabs+1:20),'Visible','off');

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
drawnow;

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
el.activeTabNr=iac;
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

if strcmpi(opt,'withcallback') && ~isempty(panel.callbacks{iac})
    % Execute callback
    if isempty(panel.inputArguments{iac})
        feval(panel.callbacks{iac});
    else
        feval(panel.callbacks{iac},panel.inputArguments{iac});
    end
end

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
