function monitormatlab(action)
%MONITORMATLAB Displays runtime diagnostic information
% This task manager like tool displays real time memory
% state of MATLAB, HG, and Java using time based strip charts. 
%
% The following information is displayed:
% * Memory allocated by MATLAB
% * Memory allocated by Java
% * Memory allocted by the O/S
% * Number of HG objects in memory
% * Number of MFiles in MATLAB memory
% * Size of m-file parsing stack
%
% To see real time MATLAB memory allocation, start MATLAB with
% the O/S environment flag "MATLAB_MEM_MGR" set to a "debug" 
% as in: set MATLAB_MEM_MGR = debug.
% 
% Example:
%
% monitormatlab
% bench

if str2num(version('-release'))<14
    error('MATLAB version 14sp2 or later required')
end

if nargin==0
    action = 'start';
end

if strcmp(action,'start')
    info = localStart; 
elseif strcmp(action,'stop')
    localStop;
else
    error('Invalid input')
end

%----------------------------------------------------------%
function [info] = localStart

drawnow;
[info] = localShowUI;
drawnow;
localSetInfo(info);

localStartPause;
[info] = localStartTimer(info);
localSetInfo(info);

drawnow;
localStopPause;

%----------------------------------------------------------%
function [info] = localShowUI
% Singleton: Only create new UI if current one is stale or empty

info = localGetInfo;
if isempty(info.figure) || ~ishandle(info.figure);
   [info] = localRegisterPanels(info);
   [info] = localCreateUI(info);
end

%----------------------------------------------------------%
function localOpenRecording(obj,evd)

localStartPause;
info = localGetInfo;
doload = true;
doreset = false;
[filename, pathname] = uigetfile('monitor.mat', 'Open mat file');
if filename ~= 0

    s = load(fullfile(pathname,filename),'-mat');

    % Loop through and set view
    for n = 1:length(info.panel)
        % Update each panel
        hfunc = info.panel(n).update;
        info.panel(n) = feval(hfunc,info.panel(n),s.info.panel(n),doload,doreset);
    end
else
    localStopPause;
end
localSetInfo(info);

%----------------------------------------------------------%
function localStartPause

h = findall(0,'type','uicontrol','Tag','Pause');
set(h,'Value',1);

%----------------------------------------------------------%
function localStopPause

h = findall(0,'type','uicontrol','Tag','Pause');
set(h,'Value',0);

%----------------------------------------------------------%
function localSaveRecording(obj,evd)

localStartPause
[filename, pathname] = uiputfile('monitor.mat', 'Open mat file');
if filename ~= 0
    info = localGetInfo;
    info.dorecord = true;
    localSetInfo(info);
    localUpdateRecording(fullfile(pathname,filename));
end
info = localGetInfo;
info.dorecord = false;
localSetInfo(info);
localStopPause;

%----------------------------------------------------------%
function localRecord(obj,evd)

info = localGetInfo;

p = get(obj,'parent');
ubegin = findall(p,'tag','BeginRecording');
ustop = findall(p,'tag','StopRecording');

if isequal(obj,ustop)
    info.dorecord = false;
    set(ubegin,'Enable','on');
    set(ustop,'Enable','off');
elseif isequal(obj,ubegin)
    info.dorecord = true;
    set(ubegin,'Enable','off');
    set(ustop,'Enable','on');
end

localSetInfo(info);

%----------------------------------------------------------%
function [info] = localCreateUI(info)

fig = figure('resize','off','handlevis','off','toolbar','none',...
    'name','MATLAB Monitoring Tool','NumberTitle','off','units','pixels',...
    'pos',[100 100 500 340],'DeleteFcn',@localShutDown);
info.figure = fig;

% Create figure menus
delete(findall(fig,'type','uimenu'));

% File Menu
u = uimenu('Parent',fig,'Label','File');
uimenu('Parent',u,'Tag','Load','Label','Open...',...
    'Callback',@localOpenRecording);
uimenu('Parent',u,'Tag','Load','Label','Save',...
    'Callback',@localSaveRecording);

% Tools menu
u = uimenu('Parent',fig,'Label','Tools');
uimenu('Parent',u,'Tag','BeginRecording',...
       'Callback',@localRecord,...
       'Label','Begin Recording to ''monitor.mat'' File');
uimenu('Callback',@localRecord,...
       'Parent',u,'Tag','StopRecording',...
       'Label','Stop Recording','Enable','off');

info.frame_center = uipanel('title','','titleposition','centertop',...
    'parent',fig,'units','norm','pos',[0 0 1 1 ]);

info.frame_left = uibuttongroup('parent',info.frame_center,...
                                'units','norm',...
                                'pos',[0 0 .3 1 ],...
                                'BackgroundColor',[.4 .4 .4],...
                                'SelectionChangeFcn',@localButtonCallback);

uicontrol('style','togglebutton','Parent',info.frame_center,...
    'units','norm','pos',[.03 .02 .2 .07],'string','Pause',...
    'Tag','Pause');

uicontrol('style','pushbutton','Parent',info.frame_center,...
    'units','norm','pos',[.03 .12 .2 .07],'string','Reset',...
    'Tag','Reset','Callback',@localReset);

% Toggle button properties
props.style = 'togglebutton';
props.parent = info.frame_left;
props.units = 'norm';
props.position = [.1 1 .66 .07];

% Create each panel and button
for n = 1:length(info.panel)
    panel_name = info.panel(n).name;
    
    % Create panel
    h = uipanel('parent',info.frame_center,...
                'units','norm','pos',[.25 0 1 1],'Visible','off');
    if (n==1)
        set(h,'Visible','on');
    end
    
    info.panel(n).panel = h;
        
    % Add a button for each panel
    props.string = panel_name;
    props.position(2) = props.position(2) - .1;
    u(n) = uicontrol(props);
    
    % Add panel contents
   hfunc = info.panel(n).create;
   info.panel(n).data = feval(hfunc,info.panel(n));
end

% Set first button to on by default
if length(u)>0
    set(u(1),'Value',1);
end

%----------------------------------------------------------%
function [info] = localRegisterPanels(info)

ind = 0;

ind = ind + 1;
info.panel(ind).name = 'General';
info.panel(ind).update = @localUpdatePanelGeneral;
info.panel(ind).create = @localCreatePanelGeneral;
info.panel(ind).data = [];
info.panel(ind).panel = [];

ind = ind + 1;
info.panel(ind).name = 'MATLAB Memory';
info.panel(ind).update = @localUpdatePanelMalloc;
info.panel(ind).create = @localCreatePanelMalloc;
info.panel(ind).data = [];
info.panel(ind).panel = [];

% Don't show this panel on unix
if ispc
    try
        evalc('feature memstats');
        doshow = true;
    catch
        doshow = false;
    end
    if(doshow)
        ind = ind + 1;
        info.panel(ind).name = 'O/S Memory';
        info.panel(ind).update = @localUpdatePanelMemory;
        info.panel(ind).create = @localCreatePanelMemory;
        info.panel(ind).data = [];
        info.panel(ind).panel = [];
    end  
end

ind = ind + 1;
info.panel(ind).name = 'Handle Graphics';
info.panel(ind).update = @localUpdatePanelHG;
info.panel(ind).create = @localCreatePanelHG;
info.panel(ind).data = [];
info.panel(ind).panel = [];

ind = ind + 1;
info.panel(ind).name = 'Java Memory';
info.panel(ind).update = @localUpdatePanelJava;
info.panel(ind).create = @localCreatePanelJava;
info.panel(ind).data = [];
info.panel(ind).panel = [];


%----------------------------------------------------------%
function localButtonCallback(obj,evd)

obj = evd.NewValue;
str = get(obj,'String');
localSetCurrentPanel(str);

%----------------------------------------------------------%
function localSetCurrentPanel(str)

info = localGetInfo;
% Only make the selected panel visible
for n = 1:length(info.panel)
    panel_name = info.panel(n).name;
    if strcmp(panel_name,str)
        set(info.panel(n).panel,'Visible','on');
    else
        set(info.panel(n).panel,'Visible','off');
    end
end

%----------------------------------------------------------%
function [info] = localStartTimer(info)

t = timer('TimerFcn',@localTimerCallback, 'Period', .5);
set(t,'ExecutionMode','fixedRate');
start(t);
info.timer = t;

localSetHGCreateFcn(@localHGCreateCallback);

%----------------------------------------------------------%
function localTimerCallback(obj,evd)

localUpdateRecording('monitor.mat');

%----------------------------------------------------------%
function localUpdateRecording(filename)

info = localGetInfo;
doload = false;
doreset = info.doreset;

h = findall(0,'type','uicontrol','Tag','Pause');
if get(h,'Value')==0
    for n = 1:length(info.panel)
        % Update each panel
        hfunc = info.panel(n).update;
        info.panel(n) = feval(hfunc,info.panel(n),[],doload,doreset);
    end

    % Save state to file
    if info.dorecord
        fname = filename;
        save(fname,'info','-mat');
    end
end

info = localGetInfo;
info.doreset = false;
localSetInfo(info);

%----------------------------------------------------------%
function [retval] = localCreatePanelMalloc(panel_info)

ax = localMakeStripChart(panel_info.panel,'top');
pos = get(ax,'Position');
set(ax,'Position',[pos(1),.2,pos(3),.5]);
retval.ax_malloc = ax;

uicontrol('parent',panel_info.panel,...
    'style','pushbutton',...
    'string','''clear all''',...
    'fontsize',13,...
    'units','norm',...
    'position',[.23 .05 .3 .09],...
    'callback','clear all');
           
retval.line_malloc = localMakeLine(retval.ax_malloc);

if ~system_dependent('CheckMalloc')
    ax = retval.ax_malloc;
    axis(ax,'off');
    text('Parent',ax,...
        'String',...
        {'To see MATLAB memory allocation information',...
         'Create an O/S environment variable using ''set''',...
         'set MATLAB_MEM_MGR = debug',...
         'then restart MATLAB.',...
         'Remove this O/S variable to restore original settings.'},...
        'Units','Norm',...
        'Interpreter','None',...
        'Position',[.5 .5],...
        'HorizontalAlignment','Center',...
        'Color','k',...
        'FontWeight','Bold');
end

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelMalloc(panel_info, serialize_info, doload, doreset)

if system_dependent('CheckMalloc')
    MB = 1048576; % megabyte
    hLine = panel_info.data.line_malloc;
    hAxes = panel_info.data.ax_malloc;
    if doload
        ydata = serialize_info.data.data_malloc;
        xdata = 1:length(ydata);
        set(hLine,'xdata',xdata,'ydata',ydata);
    else
        dispval = system_dependent('CheckMallocMemoryUsage');
        dispval = dispval/MB;
        system_dependent('CheckMallocClear');
        localUpdateLineData(hLine,dispval,doreset);
        panel_info.data.data_malloc = get(hLine,'ydata');
        str = ['Memory Allocated: ',num2str(dispval,4), ' (MB)'];
        title(hAxes,str);
    end
end
%----------------------------------------------------------%
function [retval] = localCreatePanelMemory(panel_info)

% Swap Space
str = 'Swap Space Consumed (red = available)';
retval.ax_swap_memory = localMakeStripChart(panel_info.panel,'top',str,'MB');
retval.line_swap_memory = localMakeLine(retval.ax_swap_memory);
retval.line_max_swap_memory = localMakeLine(retval.ax_swap_memory,'r');

% Physical Memory
str = 'Physical Memory Consumed (red = available)';
retval.ax_physical_memory = localMakeStripChart(panel_info.panel,'middle',str,'MB');
retval.line_physical_memory = localMakeLine(retval.ax_physical_memory);
retval.line_max_physical_memory = localMakeLine(retval.ax_physical_memory,'r');

% Block memory
str = 'Largest Contiguous Memory Block';
retval.ax_block_memory = localMakeStripChart(panel_info.panel,'bottom',str,'MB');
retval.line_block_memory = localMakeLine(retval.ax_block_memory);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelMemory(panel_info,serialize_info,doload,doreset)

mem_info = localGetMemoryInfo;

% Swap space
hLine = panel_info.data.line_swap_memory;
if doload
    ydata = serialize_info.data.data_swap_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = mem_info.PageFile.InUse;
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_swap_memory = get(hLine,'ydata');
end

hLine = panel_info.data.line_max_swap_memory;
hAxes = panel_info.data.ax_swap_memory;
if doload
    ydata = serialize_info.data.data_max_swap_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val2 = mem_info.PageFile.Total;
    localUpdateLineData(hLine,val2,doreset);
    panel_info.data.data_max_swap_memory = get(hLine,'ydata');
    title(hAxes,{'Page File',['Consumed: ', num2str(val),'(MB) Available: ',num2str(val2),'(MB)']});
end

% Physical Memory
hLine = panel_info.data.line_physical_memory;
if doload
    ydata = serialize_info.data.data_physical_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = mem_info.PhysicalMemory.InUse;
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_physical_memory = get(hLine,'ydata');
end

hLine = panel_info.data.line_max_physical_memory;
hAxes = panel_info.data.ax_physical_memory;
if doload
    ydata = serialize_info.data.data_max_physical_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val2 = mem_info.PhysicalMemory.Total;
    localUpdateLineData(hLine,val2,doreset);
    panel_info.data.data_max_physical_memory = get(hLine,'ydata');
    title(hAxes,{'Physical Memory',['Consumed: ', num2str(val),' (MB) Available: ',num2str(val2),' (MB)']});
end

% Memory Block
hLine = panel_info.data.line_block_memory;
hAxes = panel_info.data.ax_block_memory;
if doload
    ydata = serialize_info.data.data_block_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = mem_info.LargestFreeBlock;
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_block_memory = get(hLine,'ydata');
    title(hAxes,['Largest Contiguous Memory Block: ',num2str(val),' (MB)']);
end

%----------------------------------------------------------%
function [retval] = localCreatePanelJava(panel_info)

ax = localMakeStripChart(panel_info.panel,...
                      'top','Java Memory Consumed (red = available)','MB');
pos = get(ax,'Position');
set(ax,'Position',[pos(1),.2,pos(3),.5]);
                  
uicontrol('parent',panel_info.panel,...
    'style','pushbutton',...
    'string','Garbage Collect',...
    'fontsize',13,...
    'units','norm',...
    'position',[.23 .05 .3 .09],...
    'callback','java.lang.System.gc');

retval.ax_java_memory = ax;
% Create lines
retval.line_java_max_memory = localMakeLine(retval.ax_java_memory,'r');
set(retval.line_java_max_memory,'LineStyle',':');
retval.line_java_total_memory = localMakeLine(retval.ax_java_memory,'r');
retval.line_java_used_memory = localMakeLine(retval.ax_java_memory);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelJava(panel_info, serialize_info, doload, doreset)

[free_mem,total_mem,max_mem] = localGetJavaMemory;
consumed = total_mem-free_mem;

% used memory
hLine = panel_info.data.line_java_used_memory;
if doload
    ydata = serialize_info.data.data_java_used_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    localUpdateLineData(hLine,consumed,doreset);
    panel_info.data.data_java_used_memory = get(hLine,'ydata');
end

% total memory
hLine = panel_info.data.line_java_total_memory;
hAxes = panel_info.data.ax_java_memory;
if doload
    ydata = serialize_info.data.data_java_total_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    localUpdateLineData(hLine,total_mem,doreset);
    panel_info.data.data_java_total_memory = get(hLine,'ydata');  
    title(hAxes,{'Java Memory, Garbage collection will fluctuate',...
          ['Total: ',num2str(total_mem,3),' (MB), Maximum: ',num2str(max_mem,3),' (MB)'],...
          ['Consumed: ',num2str(consumed,3),' (MB) ']});
end

% max memory
hLine = panel_info.data.line_java_max_memory;
if doload
    ydata = serialize_info.data.data_java_max_memory;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    localUpdateLineData(hLine,max_mem,doreset);
    panel_info.data.data_java_max_memory = get(hLine,'ydata');  
end

%----------------------------------------------------------%
function [retval] = localCreatePanelHG(panel_info)

retval.ax_hg_objects = localMakeStripChart(panel_info.panel,'top','Number of HG Objects in Memory');
retval.line_hg_objects = localMakeLine(retval.ax_hg_objects);

retval.ax_hg_created_objects = localMakeStripChart(panel_info.panel,'middle');
retval.line_hg_created_objects = localMakeLine(retval.ax_hg_created_objects);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelHG(panel_info, serialize_info, doload,doreset)

info = localGetInfo;
hgmem = info.HGObjectInMemory;
ind = find(ishandle(hgmem)~=true);
hgmem(ind) = [];
info.HGObjectInMemory = hgmem;

hLine = panel_info.data.line_hg_objects;
hAxes = panel_info.data.ax_hg_objects;
if doload
    ydata = serialize_info.data.data_hg_objects;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = length(findall(0));
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_hg_objects = get(hLine,'YData');
    title(hAxes,['Number of HG Objects in Memory: ',num2str(val)]);
end

hLine = panel_info.data.line_hg_created_objects;
hAxes = panel_info.data.ax_hg_created_objects;
if doload
    ydata = serialize_info.data.data_hg_created_objects;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = info.HGObjectCreatedCount;
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_hg_created_objects = get(hLine,'YData');
    title(hAxes,...
        { ['HG Objects Created per Unit Time: ', num2str(val)],...
          'Performance sensitive plotting code should',...
          'resuse and not create objects during animations.'});
end
info.HGObjectCreatedCount = 0;
localSetInfo(info);

%----------------------------------------------------------%
function [retval] = localCreatePanelGeneral(panel_info)

retval.ax_mfiles = localMakeStripChart(panel_info.panel,'top');
retval.line_mfiles = localMakeLine(retval.ax_mfiles);

retval.ax_dbstack = localMakeStripChart(panel_info.panel,'middle');
retval.line_dbstack = localMakeLine(retval.ax_dbstack);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelGeneral(panel_info, serialize_info, doload, doreset)

hLine = panel_info.data.line_mfiles;
hAxes = panel_info.data.ax_mfiles;
if doload
    ydata = serialize_info.data.data_mfiles;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    [val] = inmem;
    val = length(val);
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_mfiles = get(hLine,'ydata');
    title(hAxes,['Number of M-Files in Memory (''inmem''): ',num2str(val)]);   
end

hLine = panel_info.data.line_dbstack;
hAxes = panel_info.data.ax_dbstack;
if doload
    ydata = serialize_info.data.data_dbstack;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    val = length(dbstack);
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_dbstack = get(hLine,'ydata');
    title(hAxes,['M-File Call-Stack Size (''dbstack''): ',num2str(val),' ']); 
end

%----------------------------------------------------------%
function [retval] = localCreatePanelObjects(panel_info)

retval.ax_objects = localMakeStripChart(panel_info.panel,'top','Number of Oops Objects in Memory');
retval.line_objects = localMakeLine(retval.ax_objects);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelObjects(panel_info, serialize_info, doload,doreset)

hLine = panel_info.data.line_objects;
hAxes = panel_info.data.ax_objects;
if doload
    ydata = serialize_info.data.data_objects;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    [val] = localGetOopsCount;
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data_objects = get(hLine,'ydata');
    title(hAxes,['Number of Oops Objects in Memory: ',num2str(val)]);
end

%----------------------------------------------------------%
function [retval] = localCreatePanelAWT(panel_info)

retval.ax_java_awt = localMakeStripChart(panel_info.panel,'top','Number of Events in the AWT Queue');
retval.line_java_awt_events = localMakeLine(retval.ax_java_awt);

retval.ax_java_paint = localMakeStripChart(panel_info.panel,'middle','Number of Paint Events in the AWT Queue');
retval.line_java_paint_events = localMakeLine(retval.ax_java_paint);

%----------------------------------------------------------%
function [panel_info] = localUpdatePanelAWT(panel_info, serialize_info, doload, doreset)

h = MonitorEventQueue.getInstance;
val = h.getTotalEventCount;
hLine = panel_info.data.line_java_awt_events;
if doload
    ydata = serialize_info.data.data_java_awt_events;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data.data_java_awt_events = get(hLine,'ydata');
end

val = h.getPaintEventCount;
hLine = panel_info.data.line_java_paint_events;
if doload
    ydata = serialize_info.data.data_java_paint_events;
    xdata = 1:length(ydata);
    set(hLine,'xdata',xdata,'ydata',ydata);
else
    localUpdateLineData(hLine,val,doreset);
    panel_info.data.data.data_java_paint_events = get(hLine,'ydata');
end

%----------------------------------------------------------%
function [val] = localGetCustom
% val: numeric scalar

% Change this to output scalar value of interest
val = rand(1,1);

%----------------------------------------------------------%
function localHGCreateCallback(obj,evd)
% Callback fires when HG object is created

info = localGetInfo;
count = info.HGObjectCreatedCount;
info.HGObjectCreatedCount = count + 1;

list = info.HGObjectInMemory;
info.HGObjectInMemory = [list,obj];
localSetInfo(info);

%-----------------------------------------------------
function [ax] = localMakeStripChart(frame,loc,titl,ylab)

pos = [.14 .3 .5 .15];
gray = [.4 .4 .4];
switch(loc)
    case 'bottom'
        pos(2) = .09;
    case 'middle'
        pos(2) = .35;
    case 'top'
        pos(2) = .66;
end

ax = axes('Parent',frame,'units','norm',...
    'position',pos,'XLim',[1 200],...
    'YScale','linear','XTickLabel','','XMinorGrid','off','XGrid','on',...
    'Color','w','XColor',[.4 .4 .4],'YColor',[.4 .4 .4],'box','on');
if nargin>2
    title(ax,titl,'FontSize',8);
end
set(ax,'fontsize',8);
if nargin>3
    ylabel(ax,ylab);
end

%----------------------------------------------------------%
function [hLine] = localMakeLine(ax,color)
if nargin==1
    color= 'b';
end
hLine = line('xdata',nan,'ydata',nan,'Parent',ax,'Color',color,'LineWidth',1.5);

%----------------------------------------------------------%
function localReset(obj,evd)

% reset line data
info = localGetInfo;
info.doreset = true;
localSetInfo(info);

%----------------------------------------------------------%
function localUpdateLineData(hLine,newval,doreset)

if ~ishandle(hLine)
    return;
end

if doreset
    set(hLine,'xdata',nan,'ydata',nan);
    return;
end

MAX = 200;
ydata = get(hLine,'ydata');

% Remove startup noise
if length(ydata)<2
    newval = nan;
end

ydata = [ydata,newval];

% Clip out front of data
len = length(ydata);
if len>MAX
    ydata = ydata((len-MAX+1):MAX+1);
end

xdata = (MAX-length(ydata)+1):1:MAX;
set(hLine,'xdata',xdata,'ydata',ydata,'Visible','on');

%----------------------------------------------------------%
function localShutDown(obj,evd)

info = localGetInfo;
try, 
    localStop(info);
end
localSetInfo([]);

%----------------------------------------------------------%
function localStop(info);

try,
    t = info.timer;
    stop(t);
    delete(t);
end

%----------------------------------------------------------%
function val = localGetOopsCount
% Get number of oops objects in memory

val = 0; 
s = objectdirectory;
if ~isempty(s)
    c = struct2cell(s);
    count = 0;
    for n = 1:length(c)
        count = c{n} + count;
    end
    val = count;
end

%----------------------------------------------------------%
function val = localGetBaseWorkspaceSize

val = 0;
ret = evalin('base','whos');
for n = 1:length(ret)
   val = ret(n).bytes + val;
end
val = val/1e6;

%----------------------------------------------------------%
function localSetHGCreateFcn(val)

set(0,'DefaultFigureCreateFcn', val);
set(0,'DefaultAxesCreateFcn', val);
set(0,'DefaultUIPanelCreateFcn', val);
set(0,'DefaultPatchCreateFcn', val);
set(0,'DefaultRectangleCreateFcn', val);
set(0,'DefaultSurfaceCreateFcn', val);
set(0,'DefaultImageCreateFcn', val);
set(0,'DefaultTextCreateFcn', val);
set(0,'DefaultLineCreateFcn', val);
set(0,'DefaultUIControlCreateFcn', val);
set(0,'DefaultUIMenuCreateFcn', val);

%----------------------------------------------------------%
function localUpdateAxesLimits(hAxes,hLine)

min_data = min(get(hLine,'ydata'));
max_data = max(get(hLine,'ydata'));
if max_data<10
    newlim = [min_data 10];
else
   delta = abs(max_data);
   newlim = [min_data - .1*delta, max_data + .1*delta];
end

set(hAxes,'YLim',newlim);

%----------------------------------------------------------%
function [names] = localGetClassLoadingNames

names = [];
try
    h = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    cloader = h.getCustomClassLoader;
    if ~isempty(cloader)
       names = char(cloader.debugGetClassNames);
    end
end

%----------------------------------------------------------%
function [val] = localGetClassLoadingSize

val = 0;
try
    h = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    cloader = h.getCustomClassLoader;
    if ~isempty(cloader)
       val = cloader.debugGetCacheSize;
    end
end

% hack to keep line visible on log plot
if (val<1)
    val = 1;
end

%----------------------------------------------------------%
function [free_memory,total_memory, max_memory] = localGetJavaMemory

MB = 1048576; % megabyte
free_memory = java.lang.Runtime.getRuntime.freeMemory/MB;
total_memory = java.lang.Runtime.getRuntime.totalMemory/MB;
max_memory = java.lang.Runtime.getRuntime.maxMemory/MB;

%-----------------------------------------------------
function retval = localGetIconPath

retval = [];
persistent iconpath;
if isempty(iconpath)
    [iconpath,filename,ext] = fileparts(which(mfilename));
    iconpath = fullfile(iconpath,'private');
end
retval = iconpath;

%-----------------------------------------------------
function info = localGetMemoryInfo

% Big hack here, parse output of memstats since there
% are no output variables. 

str = evalc('feature memstats');
ind = findstr(str,'MB');
LEN = 20;

% Parse output

%   Physical Memory (RAM):
%         In Use:                              483 MB (1e305000)
%         Free:                                539 MB (21ba3000)
%         Total:                              1022 MB (3fea8000)

retval = str((ind(1)-2):-1:ind(1)-LEN);
info.PhysicalMemory.InUse = str2num(fliplr(retval));
%retval = str((ind(2)-2):-1:ind(2)-LEN);
%info.PhysicalMemory.Free = str2num(fliplr(retval));
retval = str((ind(3)-2):-1:ind(3)-LEN);
info.PhysicalMemory.Total = str2num(fliplr(retval));

%     Page File (Swap space):
%         In Use:                              571 MB (23b57000)
%         Free:                               1890 MB (76220000)
%         Total:                              2461 MB (99d77000)

retval = str((ind(4)-2):-1:ind(4)-LEN);
info.PageFile.InUse = str2num(fliplr(retval));
retval = str((ind(5)-2):-1:ind(5)-LEN);
info.PageFile.Free = str2num(fliplr(retval));
retval = str((ind(6)-2):-1:ind(6)-LEN);
info.PageFile.Total = str2num(fliplr(retval));        

%     Virtual Memory (Address Space):
%         In Use:                              536 MB (21851000)
%         Free:                               1511 MB (5e78f000)
%         Total:                              2047 MB (7ffe0000)
%retval = str((ind(7)-2):-1:ind(7)-LEN);
%info.VirtualMemory.InUse = str2num(fliplr(retval));
%retval = str((ind(8)-2):-1:ind(8)-LEN);
%info.VirtualMemory.Free = str2num(fliplr(retval));
%retval = str((ind(9)-2):-1:ind(9)-LEN);
%info.VirtualMemory.Total = str2num(fliplr(retval));          

%     Largest Contiguous Free Blocks:
%          1. [at 25d20000]                    859 MB (35b40000)
retval = str((ind(10)-2):-1:ind(10)-LEN);
info.LargestFreeBlock = str2num(fliplr(retval));

%----------------------------------------------------------%
function info = localGetInfo
info = getappdata(0,'MonitorMATLAB');

if isempty(info)
    info = struct;
    info.figure = [];
    info.HGObjectCreatedCount = [];
    info.HGObjectInMemory = [];
    info.dorecord = false;
    info.doreset = false;
end

%----------------------------------------------------------%
function localSetInfo(info)
setappdata(0,'MonitorMATLAB',info);
