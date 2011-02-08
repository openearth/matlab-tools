function varargout=table(varargin)

position=[0 0];
nrrows=0;
columntypes='';
width=[];
data=[];
enab=[];
popuptext='';
pushtext='';
callbacks=[];
fmt=[];
includebuttons=0;
includenumbers=0;
parent=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i})),
            case{'position'}
                position=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
            case{'nrrows'}
                nrrows=varargin{i+1};
            case{'columntypes'}
                columntypes=varargin{i+1};
            case{'width'}
                width=varargin{i+1};
            case{'data'}
                data=varargin{i+1};
            case{'popuptext'}
                popuptext=varargin{i+1};
            case{'pushtext'}
                pushtext=varargin{i+1};
            case{'enable'}
                enab=varargin{i+1};
            case{'format'}
                fmt=varargin{i+1};
            case{'callbacks'}
                callbacks=varargin{i+1};
            case{'includebuttons'}
                includebuttons=varargin{i+1};
            case{'includenumbers'}
                includenumbers=varargin{i+1};
            case{'parent'}
                parent=varargin{i+1};
        end
    end
end            

nrcolumns=length(columntypes);

if isempty(enab)
    enab=zeros(nrrows,nrcolumns)+1;
end
if isempty(callbacks)
    for i=1:nrcolumns;
        callbacks{i}=[];
    end
end
if isempty(fmt)
    for i=1:nrcolumns;
        fmt{i}=[];
    end
end

action=varargin{2};

switch lower(action)
    case{'create'}
        fig=varargin{1};
        if isempty(parent)
            parent=fig;
        end
        tb=createTable(fig,tag,parent,position,nrcolumns,nrrows,columntypes,width,data,popuptext,pushtext,enab,callbacks,fmt,includebuttons,includenumbers);
        varargout{1}=tb;
    case{'getdata'}
        % get data
        tb=varargin{1};
        usd=get(tb,'UserData');
        data=usd.data;
        varargout{1}=data;
    case{'setdata'}
        % set data
        tb=varargin{1};
        data=varargin{3};
        changeTable(tb,data);
    case{'refresh'}
        % set data
        tb=varargin{1};
        refreshTable(tb,varargin);
end

%%
function tableHandle=createTable(fig,tag,parent,position,nrcolumns,nrrows,columntypes,width,data,popuptext,pushtext,enab,callbacks,fmt,includebuttons,includenumbers)

tableHandle=uipanel(fig,'Units','pixels','Parent',parent,'Tag',tag,'Position',[position(1) position(2) 10 10],'BorderType','none','BackgroundColor','none');

if isempty(width)
    for j=1:nrcolumns
        switch(columntypes{j}),
            case{'editreal','editstring','edittime','popupmenu'}
                width(j)=80;
            case{'checkbox'}
                width(j)=20;
        end
    end
end

posx0=1;
posy0=1;

if includenumbers
    posy=posy0+nrrows*20-20;
    for i=1:nrrows
        h=uicontrol(gcf,'Style','text','Parent',tableHandle,'String',num2str(i),'Position',[posx0-18 posy-3 15 20],'HorizontalAlignment','right');
        cl=get(fig,'Color');
        set(h,'BackgroundColor',cl);
        posy=posy-20;
        usd.numberHandles(i)=h;
        set(h,'Parent',tableHandle);
    end
end

posy=posy0+nrrows*20-20;
for i=1:nrrows
    posx=posx0;
    for j=1:nrcolumns
        switch(columntypes{j}),
            case{'editreal'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
                set(h,'Callback',@editReal_Callback,'Enable','on');
            case{'editstring'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
                set(h,'Callback',@editString_Callback,'Enable','on');
            case{'edittime'}
                h=uicontrol(gcf,'Style','edit','String','','Position',[posx posy width(j) 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1]);
                set(h,'Callback',@editTime_Callback,'Enable','on');
            case{'popupmenu'}
                for ii=1:size(popuptext,1)
                    str{ii}=popuptext{ii,j};
                end
                h=uicontrol(gcf,'Style','popupmenu','Position',[posx posy width(j) 20],'BackgroundColor',[1 1 1]);
                set(h,'Value',1);
                set(h,'String',str);
                set(h,'Callback',@popupMenu_Callback,'Enable','on');
            case{'pushbutton'}
                h=uicontrol(gcf,'Style','pushbutton','Position',[posx posy width(j) 20],'String',pushtext{j});
                set(h,'Callback',@pushButton_Callback,'Enable','on');
            case{'checkbox'}
                h=uicontrol(gcf,'Style','checkbox','String','','Position',[posx+3 posy width(j) 20]);
                set(h,'Callback',@checkBox_Callback,'Enable','on');
            case{'text'}
                h=uicontrol(gcf,'Style','text','String','','Position',[posx+3 posy-4 width(j) 20]);
        end
        
        set(h,'Parent',tableHandle);

        setappdata(h,'callback',callbacks{j});
        setappdata(h,'row',i);
        setappdata(h,'column',j);

        if enab(i,j)==0
            set(h,'Enable','off');
        end
        posx=posx+width(j);
        usd.handles(i,j)=h;
    end
    posy=posy-20;
end

h = uicontrol(fig,'Parent',tableHandle,'Style','slider','Position',[posx+3 posy0 20 nrrows*20]);
set(h,'Parent',tableHandle);
set(h,'Callback',{@verticalSlider_Callback});
usd.verticalSlider=h;
if includebuttons
    h = uicontrol(fig,'Style','pushbutton','String','Copy Row',  'Position',[posx+30 position(2)+nrrows*20-20 80 20]);
    set(h,'Callback',{@pushCopyRow_Callback},'Parent',tableHandle);
    h = uicontrol(fig,'Style','pushbutton','String','Delete Row','Position',[posx+30 position(2)+nrrows*20-45 80 20]);
    set(h,'Callback',{@pushDeleteRow_Callback},'Parent',tableHandle);
end
usd.data=data;
usd.nrRows=nrrows;
usd.nrColumns=nrcolumns;
usd.columnTypes=columntypes;
usd.activeRow=1;
usd.activeColumn=1;
usd.firstRow=1;
usd.firstColumn=1;
usd.format=fmt;
set(tableHandle,'UserData',usd);
refreshVerticalSlider(tableHandle);
refreshTable(tableHandle);

%%
function changeTable(tb,data)

usd=get(tb,'UserData');
usd.data=data;
if usd.activeRow>size(data,1)
    usd.activeRow=1;
end
set(tb,'UserData',usd);
refreshVerticalSlider(tb);
refreshTable(tb);

%%
function verticalSlider_Callback(hObject,eventdata)

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
if size(usd.data,1)<=usd.nrRows
    ip=0;
else
    ii=round(get(usd.verticalSlider,'Value'));
    imin=get(usd.verticalSlider,'Min');
    imax=get(usd.verticalSlider,'Max');
    ip=(imax-ii);
end
usd.firstRow=ip+1;
val=get(hObject,'Value');
set(hObject,'Value',round(val));
set(tb,'UserData',usd);
refreshTable(tb);

%%
function editTime_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
ip=usd.firstRow-1;
usd.data{i+ip,j}=D3DTimeString(get(hObject,'String'));
usd.activeRow=i;
usd.activeColumn=j;
set(tb,'UserData',usd);

if ~isempty(callback)
    feval(callback);
end

%%
function editReal_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
ip=usd.firstRow-1;
usd.data{i+ip,j}=str2double(get(hObject,'String'));
usd.activeRow=i;
usd.activeColumn=j;
set(tb,'UserData',usd);

if ~isempty(callback)
    fevalTable(callback);
end

%%
function editString_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
ip=usd.firstRow-1;
usd.data{i+ip,j}=get(hObject,'String');
set(tb,'UserData',usd);

if ~isempty(callback)
    feval(callback);
end

%%
function popupMenu_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
ip=usd.firstRow-1;
ii=get(hObject,'Value');
txt=get(hObject,'String');
usd.activeRow=i;
usd.activeColumn=j;
usd.data{i+ip,j}=txt{ii}; 
set(tb,'UserData',usd);

if ~isempty(callback)
    feval(callback);
end

%%
function checkBox_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

tb=get(hObject,'Parent');
usd=get(tb,'UserData');
ip=usd.firstRow-1;
ii=get(hObject,'Value');
usd.data{i+ip,j}=ii; 
usd.activeRow=i;
usd.activeColumn=j;
set(tb,'UserData',usd);

if ~isempty(callback)
    feval(callback);
end

%%
function pushButton_Callback(hObject,eventdata)

i=getappdata(hObject,'row');
j=getappdata(hObject,'column');
callback=getappdata(hObject,'callback');

if ~isempty(callback)
    feval(callback,i,j);
end

%%
function pushCopyRow_Callback(hObject,eventdata)
tb=get(hObject,'Parent');
usd=get(tb,'UserData');
data=usd.data;
nrcolumns=usd.nrColumns;
iac=usd.activeRow;
nr=size(usd.data,1);
ip=usd.firstRow-1;
iac=iac+ip;
for j=1:nrcolumns
    if iac<nr
        for i=nr+1:-1:iac+2
            data{i,j}=data{i-1,j};
        end
    end
    data{iac+1,j}=data{iac,j};
end
usd.data=data;
set(tb,'UserData',usd);
refreshVerticalSlider(tb);
refreshTable(tb);

%%
function pushDeleteRow_Callback(hObject,eventdata)
tb=get(hObject,'Parent');
usd=get(tb,'UserData');
data=usd.data;
nrcolumns=usd.nrColumns;
iac=usd.activeRow;
nr=size(usd.data,1);
ip=usd.firstRow-1;
iac=iac+ip;
if nr>2
    for j=1:nrcolumns
        if iac<nr
            for i=iac:nr-1
                data{i,j}=data{i+1,j};
            end
        end
        for i=1:nr-1
            data0{i,j}=data{i,j};
        end
    end
    usd.data=data0;
    set(tb,'UserData',usd);
    refreshVerticalSlider(tb);
    refreshTable(tb);
end

%%
function refreshTable(tb,varargin)

varg=[];
a=varargin;
if ~isempty(a)
    b=varargin{1};
    varg=b{1};
    varg=a{1};
end
enab=[];

for i=1:length(varg)
    if ischar(varg{i})
        switch(lower(varg{i})),
%             case{'position'}
%                 position=varargin{i+1};
%             case{'nrrows'}
%                 nrrows=varargin{i+1};
%             case{'columntypes'}
%                 columntypes=varargin{i+1};
%             case{'width'}
%                 width=varargin{i+1};
%             case{'data'}
%                 data=varargin{i+1};
%             case{'popuptext'}
%                 popuptext=varargin{i+1};
%             case{'pushtext'}
%                 pushtext=varargin{i+1};
            case{'enable'}
                enab=varg{i+1};
%             case{'format'}
%                 fmt=varargin{i+1};
%             case{'Callbacks'}
%                 Callbacks=varargin{i+1};
%             case{'includebuttons'}
%                 includebuttons=1;
%             case{'includenumbers'}
%                 includenumbers=1;
        end
    end
end            

usd=get(tb,'UserData');
data=usd.data;
nrrows=usd.nrRows;
nrcolumns=usd.nrColumns;

if isempty(enab)
    enab=zeros(nrrows,nrcolumns)+1;
end

vslider=usd.verticalSlider;
columntypes=usd.columnTypes;
handles=usd.handles;
fmt=usd.format;
nr=size(data,1);
if nr<=nrrows
    set(vslider,'Visible','off');
else
    set(vslider,'Visible','on');
end
ip=usd.firstRow-1;
if isfield(usd,'numberHandles')
    numberhandles=usd.numberHandles;
    for i=1:min(nr,nrrows)
        set(numberhandles(i),'String',num2str(i+ip));
        set(numberhandles(i),'Visible','on');
    end
    for i=nr+1:nrrows
        set(numberhandles(i),'Visible','off');
    end
end

for j=1:nrcolumns
    for i=1:min(nr,nrrows)
        if iscell(data)
            k=min(i+ip,size(data,1));
            switch(columntypes{j}),
                case{'editreal'}
                    if ~isempty(fmt{j})
                        set(handles(i,j),'String',num2str(data{k,j},fmt{j}),'Visible','on');
                    else
                        set(handles(i,j),'String',num2str(data{k,j}),'Visible','on');
                    end
                case{'editstring'}
                    set(handles(i,j),'String',data{k,j},'Visible','on');
                case{'edittime'}
                    set(handles(i,j),'String',D3DTimeString(data{k,j}),'Visible','on');
                case{'popupmenu'}
                    txt=get(handles(i,j),'String');
                    ii=strmatch(data{k,j},txt,'exact');
                    set(handles(i,j),'Value',ii,'Visible','on');
                case{'checkbox'}
                    set(handles(i,j),'Value',data{k,j},'Visible','on');
                case{'pushbutton'}
                    set(handles(i,j),'String',data{k,j},'Visible','on');
                case{'text'}
                    set(handles(i,j),'String',data{k,j},'Visible','on');
            end
        end
        if enab(i,j)
            set(handles(i,j),'Enable','on');
        else
            set(handles(i,j),'Enable','off');
        end
    end
    for i=nr+1:nrrows
        set(handles(i,j),'Visible','off');
    end
end

%%
function refreshVerticalSlider(tb)
usd=get(tb,'UserData');
data=usd.data;
nrrows=usd.nrRows;
vslider=usd.verticalSlider;
nr=size(data,1);
if nr<=nrrows
    set(vslider,'Min',0);
    set(vslider,'Max',max(nr,1));
    set(vslider,'SliderStep',[1 nrrows]);
    set(vslider,'Value',0);
    set(vslider,'Visible','off');
else
    set(vslider,'Visible','on');
    set(vslider,'Min',0);
    set(vslider,'Max',nr-nrrows);
    set(vslider,'Value',nr-nrrows);
    ii=nr-nrrows;
    set(vslider,'SliderStep',[1/ii nrrows/(nr-nrrows)]);
end

%%
function clickTextBox(imagefig, varargins,i,j)
hobj=get(gcf,'CurrentObject');
if strcmp(get(hobj,'Tag'),'UIControl') && strcmp(get(gcf,'SelectionType'),'normal')
    tb=get(hobj,'Parent');
    usd=get(tb,'UserData');
    uicontrol(hobj);
    set(hobj,'Enable','on');
    if isfield(usd,'ActiveUITool')
        pos=get(usd.activeUITool,'Position');
        str=get(usd.activeUITool,'String');
        horal=get(usd.activeUITool,'HorizontalAlignment');
        set(usd.activeUITool,'Enable','inactive');
        str=get(usd.activeUITool,'String');
%         delete(usd.ActiveUITool);
%         i0=usd.ActiveRow;
%         j0=usd.ActiveColumn;
%         usd.ActiveUITool=uicontrol(gcf,'Style','edit','String',str,'Position',pos,'HorizontalAlignment',horal,'BackgroundColor',[1 1 1]);
%         set(usd.ActiveUITool,'Tag','UIControl','Enable','inactive','UserData',tag);
%         usd.Handles(i0,j0)=usd.ActiveUITool;
%         switch(columntypes{j0}),
%             case{'editreal'}
%                 set(usd.ActiveUITool,'Callback',{@EditReal_Callback,i0,j0});
%             case{'editstring'}
%                 set(usd.ActiveUITool,'Callback',{@EditString_Callback,i0,j0});
%             case{'edittime'}
%                 set(usd.ActiveUITool,'Callback',{@EditTime_Callback,i0,j0});
%         end
%         set(usd.ActiveUITool,'ButtonDownFcn',{@ClickTextBox,i0,j0});
    end
    usd.activeUITool=hobj;
    usd.activeRow=i;
    usd.activeColumn=j;
    set(tb,'UserData',usd);
end

%%
function fevalTable(callback)
% This must be the WORST workaround ever
n=length(callback);
% Last input argument is onchange callback
if n>1
    occb=callback{n};
else
    occb=[];
end

switch n
    case 1,2
        feval(callback);
    case 3
        feval(callback{1},callback{2});
    case 4
        feval(callback{1},callback{2},callback{3});
    case 5
        feval(callback{1},callback{2},callback{3},callback{4});
    case 6
        feval(callback{1},callback{2},callback{3},callback{4},callback{5});
    case 7
        feval(callback{1},callback{2},callback{3},callback{4},callback{5},callback{6});
    case 8
        feval(callback{1},callback{2},callback{3},callback{4},callback{5},callback{6},callback{7});
    case 9
        feval(callback{1},callback{2},callback{3},callback{4},callback{5},callback{6},callback{7},callback{7});
end

if ~isempty(occb)
    feval(occb);
end
