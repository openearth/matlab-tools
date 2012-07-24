function elements=gui_addElements(figh,elements,varargin)

getFcn=[];
setFcn=[];
parenthandle=figh;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'getfcn','getfunction'}
                getFcn=varargin{i+1};
            case{'setfcn','setfunction'}
                setFcn=varargin{i+1};
            case{'parent'}
                parenthandle=varargin{i+1};
        end
    end
end

bgc=get(figh,'Color');

for i=1:length(elements)
        
    try
        
        elements(i).element.handle=[];
        elements(i).element.texthandle=[];
        pos=elements(i).element.position;
                       
        switch lower(elements(i).element.style)
            
            %% Standard elements
            
            case{'edit'}
                
                % Edit box

                elements(i).element.handle=uicontrol(figh,'Style','edit','String','','Position',pos,'BackgroundColor',[1 1 1]);

                if ~isempty(elements(i).element.type)
                    tp=elements(i).element.type;
                else
                    tp=elements(i).element.variable.type;
                end
                
                switch tp
                    case{'char','string'}
                        horal='left';
                    case{'int','integer'}
                        horal='right';
                    case{'real'}
                        horal='right';
                    case{'datetime','time','date'}
                        horal='right';
                end
                
                set(elements(i).element.handle,'HorizontalAlignment',horal);
                if elements(i).element.nrlines>1
                    set(elements(i).element.handle,'Max',elements(i).element.nrlines);
                end
                
                % Set text
                if ~isempty(elements(i).element.text)
                    if ~isfield(elements(i).element.text,'variable')
                        str=elements(i).element.text;
                    else
                        str=' ';
                    end
                    switch elements(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    % Text
                    elements(i).element.texthandle=uicontrol(figh,'Parent',parenthandle,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(elements(i).element.texthandle,pos,elements(i).element.textposition);
                end
                                
            case{'panel'}
                
                % Panel
                
                elements(i).element.handle=uipanel('Title',elements(i).element.title,'Units','pixels','Position',pos,'BackgroundColor',bgc);
                set(elements(i).element.handle,'Title',elements(i).element.text,'BorderType',elements(i).element.bordertype);
                
            case{'radiobutton'}
                
                % Radio button

                if ~isfield(elements(i).element.text,'variable')
                    str=elements(i).element.text;
                    elements(i).element.handle=uicontrol(figh,'Style','radio','String',str,'Position',[pos(1) pos(2) 20 20],'BackgroundColor',bgc);
                    % Length of string is known
                    ext=get(elements(i).element.handle,'Extent');
                    set(elements(i).element.handle,'Position',[pos(1) pos(2) ext(3)+20 20]);
                else
                    elements(i).element.handle=uicontrol(figh,'Style','radio','String',' ','Position',[pos(1) pos(2) pos(3) 20],'BackgroundColor',bgc);
                end
                
            case{'checkbox'}
                
                % Check box
                
                if ~isfield(elements(i).element.text,'variable')
                    str=elements(i).element.text;
                    elements(i).element.handle=uicontrol(figh,'Style','check','String',str,'Position',[pos(1) pos(2) 20 20],'BackgroundColor',bgc);
                    % Length of string is known
                    ext=get(elements(i).element.handle,'Extent');
                    set(elements(i).element.handle,'Position',[pos(1) pos(2) ext(3)+20 20]);
                else
                    elements(i).element.handle=uicontrol(figh,'Style','check','String',' ','Position',[pos(1) pos(2) pos(3) 20],'BackgroundColor',bgc);
                end
                
            case{'pushbutton'}
                
                % Push button
                
                elements(i).element.handle=uicontrol(figh,'Style','pushbutton','String',elements(i).element.text,'Position',pos);

            case{'pushok'}

                elements(i).element.handle=uicontrol(figh,'Style','pushbutton','String','OK','Position',pos);

            case{'pushcancel'}

                elements(i).element.handle=uicontrol(figh,'Style','pushbutton','String','Cancel','Position',pos);
                
            case{'togglebutton'}
                
                % Toggle button

                elements(i).element.handle=uicontrol(figh,'Style','togglebutton','String',elements(i).element.text,'Position',pos);
                
            case{'listbox'}

                % List box
                
                elements(i).element.handle=uicontrol(figh,'Style','listbox','String','','Position',pos,'BackgroundColor',[1 1 1]);
                
                if ~isempty(elements(i).element.max)
                    set(elements(i).element.handle,'Max',elements(i).element.max);
                end
                
                % Set text
                if ~isempty(elements(i).element.text)
                    % Text
                    elements(i).element.texthandle=uicontrol(figh,'Style','text','String',elements(i).element.text,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(elements(i).element.texthandle,pos,elements(i).element.textposition);
                end
                                
            case{'popupmenu'}

                % Pop-up menu
                
                elements(i).element.handle=uicontrol(figh,'Style','popupmenu','String',{'a','b'},'Position',pos,'BackgroundColor',[1 1 1]);
                
                % Set text
                if ~isempty(elements(i).element.text)

                    if ~isfield(elements(i).element.text,'variable')
                        str=elements(i).element.text;
                    else
                        str=' ';
                    end
                    switch elements(i).element.textposition
                        case{'left'}
                            str=[str ' '];
                    end
                    
                    % Text
                    elements(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(elements(i).element.texthandle,pos,elements(i).element.textposition);
                end
                
            case{'text'}
                
                % Text

                if ~isfield(elements(i).element.text,'variable')
                    str=elements(i).element.text;
                else
                    str=' ';
                end
                        
                elements(i).element.handle=uicontrol(figh,'Style','text','String',str,'Position',[pos(1) pos(2) 20 20],'BackgroundColor',bgc);

                ext=get(elements(i).element.handle,'Extent');
                ext(3)=ext(3)+2;
                
                ps1=pos(1);
                if strcmpi(elements(i).element.horal,'right')
                    ps1=pos(1)-ext(3);
                end
                
                set(elements(i).element.handle,'Position',[ps1 pos(2) ext(3) 15]);
%                setTextPosition(elements(i).element.texthandle,pos,elements(i).element.textposition);
                
            case{'pushselectfile','pushsavefile'}
                
                % Push select file
                
                elements(i).element.handle=uicontrol(figh,'Style','pushbutton','String',elements(i).element.text,'Position',pos);
                
                if elements(i).element.showfilename
                    % Text
                    str='File : ';
                    elements(i).element.texthandle=uicontrol(figh,'Style','text','String',str,'Position',pos,'BackgroundColor',bgc);
                    setTextPosition(elements(i).element.texthandle,pos,'right');
                end
                
            case{'tabpanel'}
                
                panelname=elements(i).element.tag;
                for j=1:length(elements(i).element.tabs)
                    strings{j}=elements(i).element.tabs(j).tab.tabstring;
                    tabnames{j}=elements(i).element.tabs(j).tab.tabstring;
                    callbacks{j}=[];
                    if ~isempty(elements(i).element.tabs(j).tab.callback)
                        callbacks{j}=elements(i).element.tabs(j).tab.callback;
                        inputArguments{j}=[];
                    else
                        % No callback given, use defaultTabCallback which
                        % tries to execute callback of active tab of
                        % tabpanel within current tab
                        callbacks{j}=@defaultTabCallback;
                        inputArguments{j}={'tag',panelname,'tabnr',j};
                    end
                end
                
                if ~isfield(elements(i).element,'activetabnr')
                    % Tab panel is drawn for the first time
                    elements(i).element.activetabnr=1;
                end
                
                % Create tab panel
                [elements(i).element.handle tabhandles]=tabpanel('create','figure',figh,'tag',panelname,'position',pos,'strings',strings, ...
                    'callbacks',callbacks,'tabnames',tabnames,'activetabnr',elements(i).element.activetabnr, ...
                    'inputarguments',inputArguments,'parent',parenthandle);

                % Add UI elements to different tabs
                for j=1:length(elements(i).element.tabs)
                    elements(i).element.tabs(j).tab.style='tab';
                    elements(i).element.tabs(j).tab.elements=gui_addElements(figh,elements(i).element.tabs(j).tab.elements,'getFcn',getFcn,'setFcn',setFcn, ...
                    'Parent',tabhandles(j));
                    set(tabhandles(j),'Tag',elements(i).element.tabs(j).tab.tag);
                    elements(i).element.tabs(j).tab.handle=tabhandles(j);
                end
                
                for j=1:length(elements(i).element.tabs)
                    if elements(i).element.tabs(j).tab.enable==0
                        tabpanel('disabletab','handle',elements(i).element.handle,'tabname',elements(i).element.tabs(j).tab.tabstring);
%                        disableTab(gcf,elements(i).element.tabs(j).tab.tag);
                    end                    
                end

            case{'table'}
                
                tag=elements(i).element.tag;
                nrrows=elements(i).element.nrrows;
                inclb=elements(i).element.includebuttons;
                incln=elements(i).element.includenumbers;
                
                cltp=[];
                width=[];
                enable=[];
                format=[];
                txt=[];
                callbacks=[];
                
                % Properties
                for j=1:length(elements(i).element.columns)
                    cltp{j}=elements(i).element.columns(j).column.style;
                    width(j)=elements(i).element.columns(j).column.width;
                    for k=1:nrrows
                        enable(k,j)=elements(i).element.columns(j).column.enable;
                    end
                    format{j}=elements(i).element.columns(j).column.format;
                    txt{j}=elements(i).element.columns(j).column.text;
                    callbacks{j}=[];
                    popuptext{j}={' '};
                end
                
                % Data?
                data=[];
                for j=1:length(elements(i).element.columns)
                    for k=1:elements(i).element.nrrows
                        switch lower(cltp{j})
                            case{'editreal'}
                                data{k,j}=0;
                            case{'editstring'}
                                data{k,j}=' ';
                            case{'popupmenu'}
                                data{k,j}=1;
                            case{'checkbox'}
                                data{k,j}=1;
                            case{'pushbutton'}
                                data{k,j}=[];
                            case{'text'}
                                data{k,j}=' ';                                
                                
                        end
                    end
                end
                elements(i).element.handle=table(gcf,'create','tag',tag,'data',data,'position',pos,'nrrows',nrrows,'columntypes',cltp,'width',width,'callbacks',callbacks, ...
                    'includebuttons',inclb,'includenumbers',incln,'format',format,'enable',enable,'columntext',txt,'popuptext',popuptext);
        end
    catch
        disp(['Something went wrong with generating element ' elements(i).element.tag]);
        a=lasterror;
        disp(a.message);
        for ia=1:length(a.stack)
            disp(a.stack(ia));
        end
    end

    %% Set some stuff needed for each type of element

    % Parent
    if ~isempty(elements(i).element.parent)
        % Use parent defined in xml file (needed for elements inside panels)
        ph=findobj(gcf,'Tag',elements(i).element.parent);
    else
        % Default parent
        ph=parenthandle;
    end
    if ~isempty(ph)
        set(elements(i).element.handle,'Parent',ph);
        elements(i).element.parenthandle=ph;
        if isfield(elements(i).element,'texthandle')
            set(elements(i).element.texthandle,'Parent',ph);
        end
    end
    
    % Tooltip string
    if ~isempty(elements(i).element.tooltipstring)
        set(elements(i).element.handle,'ToolTipString',elements(i).element.tooltipstring);
    end

    % Enable
    if elements(i).element.enable==0
        set(elements(i).element.handle,'Enable','off');
        if isfield(elements(i).element,'texthandle')
            set(elements(i).element.texthandle,'Enable','off');
        end
    end
    
    %drawnow;
    set(elements(i).element.handle,'Tag',elements(i).element.tag);

    setappdata(elements(i).element.handle,'getFcn',getFcn);
    setappdata(elements(i).element.handle,'setFcn',setFcn);
    setappdata(elements(i).element.handle,'element',elements(i).element);

end

setappdata(parenthandle,'elements',elements);
setappdata(parenthandle,'getFcn',getFcn);
setappdata(parenthandle,'setFcn',setFcn);

gui_setElements(elements);

%gui_updateDependencies(elements,getFcn);

% Now set callbacks for each element
for i=1:length(elements)

    try
        
        switch lower(elements(i).element.style)
            
            %% Standard elements
            
            case{'edit'}
                set(elements(i).element.handle,'Callback',{@edit_Callback,getFcn,setFcn,elements,i});
                
            case{'checkbox'}
                set(elements(i).element.handle,'Callback',{@checkbox_Callback,getFcn,setFcn,elements,i});
                
            case{'radiobutton'}
                set(elements(i).element.handle,'Callback',{@radiobutton_Callback,getFcn,setFcn,elements,i});
                
            case{'pushbutton'}
                set(elements(i).element.handle,'Callback',{@pushbutton_Callback,elements,i});

             case{'pushok'}
                set(elements(i).element.handle,'Callback',{@pushOK_Callback,elements,i});

            case{'pushcancel'}
                set(elements(i).element.handle,'Callback',{@pushCancel_Callback,elements,i});

            case{'togglebutton'}
                set(elements(i).element.handle,'Callback',{@togglebutton_Callback,getFcn,setFcn,elements,i});
                
            case{'table'}
                % Get handles from table
                usd=get(elements(i).element.handle,'UserData');
                usd.callback={@table_Callback,getFcn,setFcn,elements,i};
                set(elements(i).element.handle,'UserData',usd);
                tbh=usd.handles;
                for j=1:length(elements(i).element.columns)
                    for k=1:elements(i).element.nrrows
                        if ~isempty(elements(i).element.columns(j).column.callback)
                            callback=elements(i).element.column(j).column.callback;
                        else
                            callback={@table_Callback,getFcn,setFcn,elements,i,elements(i).element.callback,elements(i).element.option1,elements(i).element.option2};
                        end
                        setappdata(tbh(k,j),'callback',callback);
                    end
                end
                
            case{'listbox'}
                set(elements(i).element.handle,'Callback',{@listbox_Callback,getFcn,setFcn,elements,i});

            case{'popupmenu'}
                set(elements(i).element.handle,'Callback',{@popupmenu_Callback,getFcn,setFcn,elements,i});

            case{'pushselectfile'}
                set(elements(i).element.handle,'Callback',{@pushSelectFile_Callback,getFcn,setFcn,elements,i});

            case{'pushsavefile'}
                set(elements(i).element.handle,'Callback',{@pushSaveFile_Callback,getFcn,setFcn,elements,i});

        end
        
    catch
        disp(['Something went wrong with setting callbacks element ' num2str(i)]);
        a=lasterror;
        disp(a.message);
        for ia=1:length(a.stack)
            disp(a.stack(ia));
        end
    end
    
end

%%
function edit_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

v=get(hObject,'String');

tp=el.type;

for ii=1:10
    try
        switch tp
            case{'string'}
            case{'datetime'}
                v=datenum(v,'yyyy mm dd HH MM SS');
            case{'date'}
                v=datenum(v,'yyyy mm dd');
            case{'time'}
                v=datenum(v,'HH MM SS');
            otherwise
                v=str2double(v);
        end
        break;
    catch
        % Try again, not sure why this fails sometimes
        pause(0.1);
    end
end

gui_setValue(el,el.variable,v);

finishCallback(elements,i);

%%
function checkbox_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

v=get(hObject,'Value');

gui_setValue(el,el.variable,v); 

finishCallback(elements,i);

%%
function radiobutton_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

ion=get(hObject,'Value');

if ~ion
    % Button was turned
    set(hObject,'Value',1);
else
    
    v=el.value;
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end
    switch lower(tp)
        case{'real','integer'}
            v=str2double(v);
    end
                        
    gui_setValue(el,el.variable,v); 
    
    finishCallback(elements,i);
    
end

%%
function togglebutton_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

ion=get(hObject,'Value');

gui_setValue(el,el.variable,ion); 

finishCallback(elements,i);

%%
function listbox_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

str=get(hObject,'String');
% Check if listbox is not empty
if ~isempty(str{1})
    
    el=elements(i).element;
    
    if isfield(el,'variable')
        
        ii=get(hObject,'Value');
        
        if ~isempty(el.type)
            tp=lower(el.type);
        else
            tp=lower(el.variable.type);
        end
        
        switch tp
            case{'string'}                
                if isfield(el.list,'values')
                    % Values must be cell array of strings
                    if isfield(el.list.values,'variable')
                        values=gui_getValue(el,el.list.values.variable);
                    else
                        for jj=1:length(el.list.values)
                            values{jj}=el.list.values(jj).value;
                        end
                    end
                else
                    values=str;
                end
                if length(ii)>1
                    % multiple points selected
                    gui_setValue(el,el.variable,values{ii});
                    if ~isempty(el.multivariable)
                        for j=1:length(ii)
                            v{j}=values{ii};
                        end
                        gui_setValue(el,el.multivariable,v);
                    end
                else
                    gui_setValue(el,el.variable,values{ii});
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values{ii});
                    end
                end
            otherwise
                % Integer
                if isfield(el.list,'values')
                    % Values must be cell array of strings
                    if isfield(el.list.values,'variable')
                        values=gui_getValue(el,el.list.values.variable);
                    else
                        values=1:length(el.list.values);
                    end
                else
                    values=1:length(str);
                end
                if length(ii)>1
                    % multi
                    gui_setValue(el,el.variable,values(ii(1)));
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values(ii));
                    end
                else
                    gui_setValue(el,el.variable,values(ii));
                    if ~isempty(el.multivariable)
                        gui_setValue(el,el.multivariable,values(ii));
                    end
                end
        end
        
        finishCallback(elements,i);
    end
    
end

%%
function popupmenu_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

str=get(hObject,'String');
% Check if menu is not empty
if ~isempty(str{1})
       
    el=elements(i).element;
    
    ii=get(hObject,'Value');
    
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end

    switch tp
        case{'string'}
            if isfield(el.list,'values')
                % Values must be cell array of strings
                if isfield(el.list.values,'variable')
                    values=gui_getValue(el,el.list.values.variable);
                else
                    for jj=1:length(el.list.values)
                        values{jj}=el.list.values(jj).value;
                    end
                end
            else
                values=str;
            end
            gui_setValue(el,el.variable,values{ii});
        otherwise
            if isfield(el.list,'values')
                if isfield(el.list.values,'variable')
                    values=gui_getValue(el,el.list.values.variable);
                else
                    for jj=1:length(el.list.values)
                        values(jj)=str2double(el.list.values(jj).value);
                    end
                end
            else
                values=1:length(str);
            end
            gui_setValue(el,el.variable,values(ii));
    end
        
    finishCallback(elements,i);

end

%%
function pushSelectFile_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

if isfield(el.selectiontext,'variable')
    selectiontext=gui_getValue(el,el.selectiontext.variable);
else
    selectiontext=el.selectiontext;
end

if isfield(el.extension,'variable')
    extension=gui_getValue(el,el.extension.variable);
else
    extension=el.extension;
end

[filename, pathname, filterindex] = uigetfile(extension,selectiontext);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    gui_setValue(el,el.variable,v); 
    
    if el.showfilename
        set(el.texthandle,'enable','on','String',['File : ' v]);
        pos=get(el.texthandle,'Position');
        ext=get(el.texthandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.texthandle,'Position',pos);
    end
    
    elements(i).element.option2=filterindex;
    
    finishCallback(elements,i);

end

%%
function pushSaveFile_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

el=elements(i).element;

fnameori=gui_getValue(el,el.variable);

if isfield(el.selectiontext,'variable')
    selectiontext=gui_getValue(el,el.selectiontext.variable);
else
    selectiontext=el.selectiontext;
end

if isfield(el.extension,'variable')
    extension=gui_getValue(el,el.extension.variable);
else
    extension=el.extension;
end

[filename, pathname, filterindex] = uiputfile(extension,selectiontext,fnameori);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    gui_setValue(el,el.variable,v); 
    
    if el.showfilename
        set(el.texthandle,'enable','on','String',['File : ' v]);
        pos=get(el.texthandle,'Position');
        ext=get(el.texthandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.texthandle,'Position',pos);
    end
        
    elements(i).element.option2=filterindex;
    
    finishCallback(elements,i);

end

%%
function table_Callback(getFcn,setFcn,elements,i)

el=elements(i).element;

data=table(el.handle,'getdata');

% Now set the data
for j=1:length(el.columns)

    v=[];
    
    for k=1:size(data,1)
        switch lower(el.columns(j).column.style)
            case{'editreal'}
                v(k)=data{k,j};
            case{'edittime'}
                v(k)=data{k,j};
            case{'editstring'}
                v{k}=data{k,j};
            case{'popupmenu'}
                if isnumeric(data{k,j})
                    v(k)=data{k,j};
                else
                    v{k}=data{k,j};
                end
            case{'checkbox'}
                v(k)=data{k,j};
        end
    end
    
    gui_setValue(el,el.columns(j).column.variable,v);

end

finishCallback(elements,i);

%%
function pushbutton_Callback(hObject,eventdata,elements,i)

finishCallback(elements,i);

%%
function pushOK_Callback(hObject,eventdata,elements,i)

el=elements(i).element;
getFcn=getappdata(el.handle,'getFcn');
setFcn=getappdata(el.handle,'setFcn');
s=feval(getFcn);
s.ok=1;
feval(setFcn,s);
uiresume;

%%
function pushCancel_Callback(hObject,eventdata,elements,i)

el=elements(i).element;
getFcn=getappdata(el.handle,'getFcn');
setFcn=getappdata(el.handle,'setFcn');
s=feval(getFcn);
s.ok=0;
feval(setFcn,s);
uiresume;

%%
function finishCallback(elements,i)
% All elements are updated and the callback is executed

if ~isempty(elements(i).element.callback)
    % Execute callback
    feval(elements(i).element.callback,elements(i).element.option1,elements(i).element.option2);
end

gui_setElements(elements);
