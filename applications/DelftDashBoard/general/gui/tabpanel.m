function tabpanel(fig,panel,fcn,varargin)

clr=get(fig,'Color');

tabnames=[];
inputarguments=[];
strings=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
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
%             case{'color'}
%                 color=varargin{i+1};
        end
    end
end

if isempty(tabnames) && ~isempty(strings)
    tabnames=strings;
end

switch lower(fcn)
    case{'create'}
        createTabPanel(fig,panel,clr,pos);
        changeTabPanel(fig,panel,strings,callbacks,inputarguments,tabnames);
    case{'change'}
        changeTabPanel(fig,panel,strings,callbacks,inputarguments,tabnames);
    case{'select'}
        select(fig,panel,tabname);
    case{'delete'}
        deleteTabPanel(fig,panel);
    case{'resize'}
        resizeTabPanel(fig,panel,pos);
end

%%
function createTabPanel(fig,panelname,clr,panelPosition)

foregroundColor=clr;
backgroundColor=clr*0.9;

leftpos=panelPosition(1)+3;
vertpos=panelPosition(2)+panelPosition(4)-1;
tabHeight=20;

ntabs=20;
tabs=zeros(ntabs,1);
tabText=tabs;
blankText=tabs;

for i=1:ntabs
    
    position=[leftpos vertpos 30 tabHeight];
    
    % Add tab
    tabs(i) = uipanel('Parent',fig,'Units','pixels','Position',position,'Tag','dummy','BorderType','beveledout','BackgroundColor',backgroundColor,'Visible','off');
    
    % Add text, first use bold
    tabText(i) = uicontrol(fig,'Style','text','String','dummy','Position',position,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor',backgroundColor,'Visible','off');   
    set(tabText(i),'Enable','inactive');

    % Set user data
    usd.nr=i;
    usd.panel=panelname;
    usd.figureHandle=fig;
    usd.textHandle=tabText(i);

    set(tabText(i),'UserData',usd);
    set(tabs(i),'UserData',usd);
    set(tabText(i),'UserData',usd);

    % Left position for next tab
    leftpos=leftpos+30;

end

% Create new main panel
panelHandle = uipanel('Parent',fig,'Units','pixels','Position',panelPosition,'BorderType','beveledout','BackgroundColor',foregroundColor,'Tag',panelname);

% Add blank texts
leftpos=panelPosition(1)+4;
vertpos=panelPosition(2)+panelPosition(4)-1;
for i=1:ntabs
    position=[leftpos vertpos 30 tabHeight];
    blankText(i) = uicontrol(fig,'Style','text','String','','Position',position,'Visible','off');
    leftpos=leftpos+30;
end

set(blankText,'BackgroundColor',foregroundColor);
set(blankText,'HandleVisibility','off','HitTest','off');

% Add user data to panel
panel.nrTabs=ntabs;
panel.tabHandles=tabs;
panel.tabTextHandles=tabText;
panel.blankTextHandles=blankText;
panel.handle=panelHandle;
panel.position=panelPosition;
panel.foregroundColor=foregroundColor;
panel.backgroundColor=backgroundColor;

set(panelHandle,'UserData',panel);


%%
function changeTabPanel(fig,panelname,strings,callbacks,inputarguments,tabnames)

ntabs=length(strings);

if isempty(inputarguments)
    for i=1:length(strings)
        inputarguments{i}=[];
    end
end

panelHandle=findobj(fig,'Tag',panelname,'Type','uipanel');
% Set panel tabs invisible
panel=get(panelHandle,'UserData');
tabs=panel.tabHandles;
tabText=panel.tabTextHandles;
blankText=panel.blankTextHandles;

set(tabs(1:ntabs),'Visible','on');
set(tabText(1:ntabs),'Visible','on');
set(blankText(1:ntabs),'Visible','on');
set(tabs(ntabs+1:20),'Visible','off');
set(tabText(ntabs+1:20),'Visible','off');
set(blankText(ntabs+1:20),'Visible','off');

foregroundColor=panel.foregroundColor;
backgroundColor=panel.backgroundColor;

panelPosition=panel.position;

leftpos(1)=panelPosition(1)+3;
vertpos=panelPosition(2)+panelPosition(4)-1;
leftTextMargin=3;
bottomTextMargin=2;
tabHeight=20;
textHeight=15;

for i=1:ntabs
    
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
    
    % Add callback   
    set(tabs(i),'ButtonDownFcn',{@clickTab});
    set(tabText(i),'ButtonDownFcn',{@clickTab});
    
    % Set user data
    usd=get(tabs(i),'UserData');
    usd.callback=callbacks{i};
    usd.inputArguments=inputarguments{i};
    usd.textHandle=tabText(i);

    set(tabs(i),'Tag',tabnames{i});
    set(tabs(i),'UserData',usd);
    set(tabText(i),'Tag',tabnames{i});
    set(tabText(i),'UserData',usd);

    % Left position for next tab
    leftpos(i+1)=leftpos(i)+wdt(i)+1;

end

% % Set text positions
% for i=1:length(strings)
%     set(tabText(i),'Parent',panelHandle);
%     newPosition=get(tabText(i),'Position');
%     newPosition(1)=newPosition(1)-panelPosition(1);
%     newPosition(2)=newPosition(2)-panelPosition(2);
%     set(tabText(i),'Position',newPosition);
% end

% Set blank text positions
leftpos(1)=panelPosition(1)+4;
vertpos=panelPosition(2)+panelPosition(4)-1;
for i=1:length(strings)
    position=[leftpos(i)+1 vertpos wdt(i)-3 3];
    set(blankText(i),'Position',position);
end

% Set values for all tabs
set(tabs,'BackgroundColor',backgroundColor);
set(tabText,'BackgroundColor',backgroundColor,'FontWeight','normal');
% set(tabText,'BackgroundColor',[1 0 0]);
set(blankText,'Visible','off');

% Give first tab background color and make blank text visible
set(tabs(1),'BackgroundColor',foregroundColor);
set(tabText(1),'BackgroundColor',foregroundColor,'FontWeight','bold');
set(blankText(1),'Visible','on');

% Add user data to panel
panel.nrTabs=ntabs;
panel.strings=strings;

set(panelHandle,'UserData',panel);

%%
function clickTab(hObject,eventdata)

usd=get(hObject,'UserData');
panel=usd.panel;
tabname=get(hObject,'Tag');

%profile on
select(gcf,panel,tabname);
% profile off
% profile viewer

%%
function select(fig,panelname,tabname)

h=findobj(fig,'Type','uipanel','Tag',panelname);
tabh=findobj(fig,'Type','uipanel','Tag',tabname);
tab=get(tabh,'UserData');
iac=tab.nr;
panel=get(h,'UserData');

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

if isempty(tab.inputArguments)
    feval(tab.callback);
else
    feval(tab.callback,tab.inputArguments);
end

%%
function deleteTabPanel(fig,panel)

h=findobj(fig,'Tag',panel);
if ~isempty(h)
    panel=get(h,'UserData');
    delete(panel.tabHandles);
    delete(panel.tabTextHandles);
    delete(panel.blankTextHandles);
    delete(panel.handle);
end

%%
function resizeTabPanel(fig,panelname,panelPosition)

h=findobj(fig,'Type','uipanel','Tag',panelname);
panel=get(h,'UserData');
set(h,'Position',panelPosition);

vertpos=panelPosition(2)+panelPosition(4)-1;
bottomTextMargin=2;

for i=1:panel.nrTabs

    pos=get(panel.tabHandles(i),'Position');
    pos(2)=vertpos;
    set(panel.tabHandles(i),'Position',pos);
    
    pos=get(panel.blankTextHandles(i),'Position');
    pos(2)=vertpos;
    set(panel.blankTextHandles(i),'Position',pos);
    
    pos=get(panel.tabTextHandles(i),'Position');
    pos(2)=vertpos+bottomTextMargin;
%    pos(2)=vertpos;
    set(panel.tabTextHandles(i),'Position',pos);
    
end

panel.position=panelPosition;
set(h,'UserData',panel);
