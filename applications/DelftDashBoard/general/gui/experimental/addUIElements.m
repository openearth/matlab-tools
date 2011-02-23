function elements=addUIElements(figh,elements,varargin)

getFcn=[];
setFcn=[];
parent=figh;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'getfcn','getfunction'}
                getFcn=varargin{i+1};
            case{'setfcn','setfunction'}
                setFcn=varargin{i+1};
            case{'parent'}
                parent=varargin{i+1};
        end
    end
end

bgc=get(figh,'Color');

for i=1:length(elements)
        
    try
        
        elements(i).handle=[];
        elements(i).textHandle=[];
        position=elements(i).position;
        
        
        
        switch lower(elements(i).style)
            
            %% Standard elements
            
            case{'edit'}
                
                % Edit box
                elements(i).handle=uicontrol(figh,'Parent',parent,'Style','edit','String','','Position',position,'BackgroundColor',[1 1 1]);

                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

                if ~isempty(elements(i).type)
                    tp=elements(i).type;
                else
                    tp=elements(i).variable.type;
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
                
                set(elements(i).handle,'HorizontalAlignment',horal);
                if elements(i).nrLines>1
                    set(elements(i).handle,'Max',elements(i).nrLines);
                end
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                % Set text
                if ~isempty(elements(i).text)
                    if ~isfield(elements(i).text,'variable')
                        str=elements(i).text;
                    else
                        str=' ';
                    end
                    % Text
                    elements(i).textHandle=uicontrol(figh,'Parent',parent,'Style','text','String',str,'Position',position,'BackgroundColor',bgc);
                    setTextPosition(elements(i).textHandle,position,elements(i).textPosition);
                    
                    if ~isempty(elements(i).parent)
                        hh=findobj(gcf,'Tag',elements(i).parent);
                        set(elements(i).textHandle,'Parent',hh);
                    end

                end
                
                
            case{'panel'}
                elements(i).handle=uipanel('Title',elements(i).title,'Units','pixels','Position',position,'BackgroundColor',bgc);
%                elements(i).handle=uicontrol(figh,'Style','frame','String',elements(i).title,'Units','pixels','Position',position,'BackgroundColor',bgc);
                set(elements(i).handle,'Title',elements(i).text,'BorderType',elements(i).borderType);
                set(elements(i).handle,'Parent',parent);
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end
                
            case{'radiobutton'}
                
                % Check box
                pos=position;
                elements(i).handle=uicontrol(figh,'Style','radio','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc);
                
                ext=get(elements(i).handle,'Extent');
                pos(3)=ext(3)+15;
                pos(4)=20;
                set(elements(i).handle,'Position',pos);
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                if ~isempty(parent)
                    set(elements(i).handle,'Parent',parent);
                end
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end
                
            case{'checkbox'}
                
                % Check box
                pos=position;
                elements(i).handle=uicontrol(figh,'Style','check','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc);
                
                ext=get(elements(i).handle,'Extent');
                pos(3)=ext(3)+20;
                pos(4)=20;
                set(elements(i).handle,'Position',pos);
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                if ~isempty(parent)
                    set(elements(i).handle,'Parent',parent);
                end
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end
                
            case{'pushbutton'}
                elements(i).handle=uicontrol(figh,'Style','pushbutton','String',elements(i).text,'Position',position);
                set(elements(i).handle,'Parent',parent);
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

            case{'togglebutton'}
                elements(i).handle=uicontrol(figh,'Style','togglebutton','String',elements(i).text,'Position',position);
                set(elements(i).handle,'Parent',parent);
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

            case{'listbox'}

                % List box
                elements(i).handle=uicontrol(figh,'Parent',parent,'Style','listbox','String','','Position',position,'BackgroundColor',[1 1 1]);
                
                if ~isempty(elements(i).max)
                    set(elements(i).handle,'Max',elements(i).max);
                end
                
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                % Set text
                if ~isempty(elements(i).text)
                    % Text
                    elements(i).textHandle=uicontrol(figh,'Parent',parent,'Style','text','String',elements(i).text,'Position',position,'BackgroundColor',bgc);
                    setTextPosition(elements(i).textHandle,position,elements(i).textPosition);
                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).textHandle,'Parent',hh);
                end
                end

                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

            case{'popupmenu'}

                % Pop-up menu
                elements(i).handle=uicontrol(figh,'Parent',parent,'Style','popupmenu','String','','Position',position,'BackgroundColor',[1 1 1]);
                
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end

                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

                % Set text
                if ~isempty(elements(i).text)
                    % Text
                    elements(i).textHandle=uicontrol(figh,'Parent',parent,'Style','text','String',elements(i).text,'Position',position,'BackgroundColor',bgc);
                    setTextPosition(elements(i).textHandle,position,elements(i).textPosition);
                    if ~isempty(elements(i).parent)
                        hh=findobj(gcf,'Tag',elements(i).parent);
                        set(elements(i).textHandle,'Parent',hh);
                    end
                end

            case{'text'}
                
                % Text
                pos=position;

                if ~isfield(elements(i).text,'variable')
                    str=elements(i).text;
                else
                    str=' ';
                end
                        
                elements(i).handle=uicontrol(figh,'Style','text','String',str,'Position',[pos 20 20],'BackgroundColor',bgc);

                ext=get(elements(i).handle,'Extent');
                pos(3)=ext(3);
                pos(4)=15;
                
                if strcmpi(elements(i).horal,'right')
                    pos(1)=pos(1)-pos(3);
                end

                set(elements(i).handle,'Position',pos);
                
                if ~isempty(parent)
                    set(elements(i).handle,'Parent',parent);
                end

                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

                
                %% Custom elements
            case{'popupmenu'}    
                elements(i).handle=uicontrol(figh,'Style','popupmenu','String',elements(i).stringList,'Position',position);
                
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                if ~isempty(parent)
                    set(elements(i).handle,'Parent',parent);
                end
                
                if ~isempty(elements(i).text)
                    % Text
                    elements(i).textHandle=uicontrol(figh,'Parent',parent,'Style','text','String',elements(i).text,'Position',position,'BackgroundColor',bgc);
                    setTextPosition(elements(i).textHandle,position,elements(i).textPosition);
                end
            
            case{'pushselectfile','pushsavefile'}
                
                % Push select file
                elements(i).handle=uicontrol(figh,'Style','pushbutton','String',elements(i).text,'Position',position);
                
                if ~isempty(elements(i).toolTipString)
                    set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
                end
                
                if ~isempty(parent)
                    set(elements(i).handle,'Parent',parent);
                end

                if ~isempty(elements(i).parent)
                    hh=findobj(gcf,'Tag',elements(i).parent);
                    set(elements(i).handle,'Parent',hh);
                end

                if elements(i).showFileName
                    % Text
                    str='File : ';
                    elements(i).textHandle=uicontrol(figh,'Style','text','String',str,'Position',position,'BackgroundColor',bgc);
                    setTextPosition(elements(i).textHandle,position,'right');
                    if ~isempty(parent)
                        set(elements(i).textHandle,'Parent',parent);
                    end
                    
                    if ~isempty(elements(i).parent)
                        hh=findobj(gcf,'Tag',elements(i).parent);
                        set(elements(i).textHandle,'Parent',hh);
                    end

                end
                
                
            case{'tabpanel'}
                
                panelname=elements(i).tag;
                for j=1:length(elements(i).tabs)
                    strings{j}=elements(i).tabs(j).tabstring;
                    tabnames{j}=elements(i).tabs(j).tabname;
                    callbacks{j}=[];
                    if ~isempty(elements(i).tabs(j).callback)
                        callbacks{j}=elements(i).tabs(j).callback;
                        inputArguments{j}=[];
                    else
                        callbacks{j}=@defaultTabCallback;
                        inputArguments{j}={'tag',panelname,'tabnr',j};
                    end
                end
                
                if ~isfield(elements(i),'activeTabNr')
                    % Tab panel is drawn for the first time
                    elements(i).activeTabNr=1;
                end
                
                % Create tab panel
                [elements(i).handle tabhandles]=tabpanel('create','figure',figh,'tag',panelname,'position',position,'strings',strings, ...
                    'callbacks',callbacks,'tabnames',tabnames,'Parent',parent,'activetabnr',elements(i).activeTabNr, ...
                    'inputarguments',inputArguments);

                % Add UI elements to different tabs
                for j=1:length(elements(i).tabs)
                    elements(i).tabs(j).elements=addUIElements(figh,elements(i).tabs(j).elements,'getFcn',getFcn,'setFcn',setFcn, ...
                    'Parent',tabhandles(j));
                    set(tabhandles(j),'Tag',elements(i).tabs(j).tag);
                end
                
                for j=1:length(elements(i).tabs)
                    if elements(i).tabs(j).enable==0
                        disableTab(gcf,elements(i).tabs(j).tag);
                    end                    
                end
                
            case{'table'}
                
                tag=elements(i).tag;
                nrrows=elements(i).nrRows;
                inclb=elements(i).includeButtons;
                incln=elements(i).includeNumbers;
                
                cltp=[];
                width=[];
                enable=[];
                format=[];
                txt=[];
                callbacks=[];
                
                % Properties
                for j=1:length(elements(i).columns)
                    cltp{j}=elements(i).columns(j).style;
                    width(j)=elements(i).columns(j).width;
                    for k=1:nrrows
                        enable(k,j)=elements(i).columns(j).enable;
                    end
                    format{j}=elements(i).columns(j).format;
                    txt{j}=elements(i).columns(j).text;
                    callbacks{j}=[];
                end

                % Data?
                data=[];
                for j=1:length(elements(i).columns)
                    for k=1:elements(i).nrRows
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
                
                elements(i).handle=table(gcf,'create','tag',tag,'parent',parent,'data',data,'position',position,'nrrows',nrrows,'columntypes',cltp,'width',width,'callbacks',callbacks, ...
                    'includebuttons',inclb,'includenumbers',incln,'format',format,'enable',enable,'columntext',txt);

        end
    catch
        disp(['Something went wrong with generating element ' elements(i).tag]);
        a=lasterror;
        disp(a.message);
        for ia=1:length(a.stack)
            disp(a.stack(ia));
        end
    end
    
    %drawnow;
    
    set(elements(i).handle,'Tag',elements(i).tag);
    try
    setappdata(elements(i).handle,'getFcn',getFcn);
    catch
        shite=999
    end
    setappdata(elements(i).handle,'setFcn',setFcn);
    setappdata(elements(i).handle,'element',elements(i));
end

setappdata(parent,'elements',elements);
setappdata(parent,'getFcn',getFcn);
setappdata(parent,'setFcn',setFcn);

setUIElements(elements);

updateUIDependencies(elements,getFcn);

% Set callbacks
for i=1:length(elements)

    try
        
        switch lower(elements(i).style)
            
            %% Standard elements
            
            case{'edit'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@edit_Callback,getFcn,setFcn,elements,i});
                end
                
            case{'checkbox'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@checkbox_Callback,getFcn,setFcn,elements,i});
                end
                
            case{'radiobutton'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@radiobutton_Callback,getFcn,setFcn,elements,i});
                end
                
            case{'pushbutton'}
                set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});

            case{'togglebutton'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@togglebutton_Callback,getFcn,setFcn,elements,i});
                end
                
            case{'table'}
                % Get handles from table
                usd=get(elements(i).handle,'UserData');
                tbh=usd.handles;
                for j=1:length(elements(i).columns)
                    for k=1:elements(i).nrRows
                        if ~isempty(elements(i).columns(j).callback)
                            callback=elements(i).column(j).callback;
                        else
                            callback={@table_Callback,getFcn,setFcn,elements,i,elements(i).onChangeCallback};
                        end
                        setappdata(tbh(k,j),'callback',callback);
                    end
                end
                
            case{'listbox'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@listbox_Callback,getFcn,setFcn,elements,i});
                end

            case{'popupmenu'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',{@custom_Callback,elements(i).customCallback,elements(i).option1,elements(i).option2});
                else
                    set(elements(i).handle,'Callback',{@popupmenu_Callback,getFcn,setFcn,elements,i});
                end

            case{'text'}
                
                
                %% Custom elements
                
            case{'pushselectfile'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',elements(i).customCallback);
                else
                    set(elements(i).handle,'Callback',{@pushSelectFile_Callback,getFcn,setFcn,elements,i});
                end

            case{'pushsavefile'}
                if ~isempty(elements(i).customCallback)
                    set(elements(i).handle,'Callback',elements(i).customCallback);
                else
                    set(elements(i).handle,'Callback',{@pushSaveFile_Callback,getFcn,setFcn,elements,i});
                end

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

s=feval(getFcn);

el=elements(i);

v=get(hObject,'String');

if ~isempty(el.type)
    tp=el.type;
else
    tp=el.variable.type;
end

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
s=setSubFieldValue(s,el.variable,v);

feval(setFcn,s);

% Update dependees
updateUIDependees(elements,i,getFcn)

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback,el.option1,el.option2);
end

%%
function checkbox_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

v=get(hObject,'Value');
s=setSubFieldValue(s,el.variable,v);
feval(setFcn,s);

% Update dependees
updateUIDependees(elements,i,getFcn)

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback,el.option1,el.option2);
end

%%
function radiobutton_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

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
                        
    s=setSubFieldValue(s,el.variable,v);
    feval(setFcn,s);
    
    % Update dependees
    updateUIDependees(elements,i,getFcn)
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback,el.option1,el.option2);
    end
    
end

%%
function togglebutton_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

ion=get(hObject,'Value');

s=setSubFieldValue(s,el.variable,ion);
feval(setFcn,s);

% Update dependees
updateUIDependees(elements,i,getFcn)
    
if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback,el.option1,el.option2);
end

%%
function listbox_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

str=get(hObject,'String');
% Check if listbox is not empty
if ~isempty(str{1})
    
    s=feval(getFcn);
    
    el=elements(i);
    
    ii=get(hObject,'Value');
    
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end

    switch tp
        case{'string'}
            if isfield(el.list.value)
                str=el.list.value;
            end
            if length(ii)>1
                % multi
                s=setSubFieldValue(s,el.variable,str{ii(1)});
                if ~isempty(el.multivariable)
                    for j=1:length(ii)
                        v{j}=str{ii(j)};
                    end
                    s=setSubFieldValue(s,el.multivariable,v);
                end
            else
                s=setSubFieldValue(s,el.variable,str{ii});
                if ~isempty(el.multivariable)
                    s=setSubFieldValue(s,el.multivariable,str{ii});
                end
            end
        otherwise
            if length(ii)>1
                % multi
                s=setSubFieldValue(s,el.variable,ii(1));
                if ~isempty(el.multivariable)
                    s=setSubFieldValue(s,el.multivariable,ii);
                end
            else
                s=setSubFieldValue(s,el.variable,ii);
                if ~isempty(el.multivariable)
                    s=setSubFieldValue(s,el.multivariable,ii);
                end
            end
    end
    
    feval(setFcn,s);
    
    % Update dependees
    updateUIDependees(elements,i,getFcn)
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback,el.option1,el.option2);
    end
end

%%
function popupmenu_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

str=get(hObject,'String');
% Check if menu is not empty
if ~isempty(str{1})
    
    s=feval(getFcn);
    
    el=elements(i);
    
    ii=get(hObject,'Value');
    
    if ~isempty(el.type)
        tp=lower(el.type);
    else
        tp=lower(el.variable.type);
    end

    switch tp
        case{'string'}
            if isfield(el.list,'value')
                if isfield(el.list.value,'variable')
                    values=getSubFieldValue(s,el.list.value.variable);
                else
                    values=el.list.value;
                end
                v=values{ii};
            else
                v=str{ii};
            end
        otherwise
            if isfield(el.list,'value')
                if isfield(el.list.value,'variable')
                    values=getSubFieldValue(s,el.list.value.variable);
                else
                    values=el.list.value;
                end
                for jj=1:length(values)
                    vnum(jj)=str2double(values{jj});
                end
                v=vnum(ii);
            else
                v=ii;
            end
    end
    s=setSubFieldValue(s,el.variable,v);
    
    feval(setFcn,s);
    
    % Update dependees
    updateUIDependees(elements,i,getFcn)
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback,el.option1,el.option2);
    end
end

%%
function pushSelectFile_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

[filename, pathname, filterindex] = uigetfile(el.fileExtension,el.selectionText);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    s=setSubFieldValue(s,el.variable,v);
    
    if el.showFileName
        set(el.textHandle,'enable','on','String',['File : ' v]);
        pos=get(el.textHandle,'Position');
        ext=get(el.textHandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.textHandle,'Position',pos);
    end
        
    feval(setFcn,s);
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback,el.option1,el.option2);
    end
    
    % Update dependees
    updateUIDependees(elements,i,getFcn)

end

%%
function pushSaveFile_Callback(hObject,eventdata,getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

[filename, pathname, filterindex] = uiputfile(el.fileExtension,el.selectionText);

if pathname~=0
    
    curdir=[pwd filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    s=setSubFieldValue(s,el.variable,v);
    
    if el.showFileName
        set(el.textHandle,'enable','on','String',['File : ' v]);
        pos=get(el.textHandle,'Position');
        ext=get(el.textHandle,'Extent');
        pos(3)=ext(3);
        pos(4)=15;
        set(el.textHandle,'Position',pos);
    end
    
    feval(setFcn,s);
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback,el.option1,el.option2);
    end
    
    % Update dependees
    updateUIDependees(elements,i,getFcn)

end

%%
function table_Callback(getFcn,setFcn,elements,i)

s=feval(getFcn);

el=elements(i);

data=table(el.handle,'getdata');

% Now set the data
for j=1:length(el.columns)
    v=[];
    for k=1:size(data,1)
        switch lower(el.columns(j).style)
            case{'editreal'}
                v(k)=data{k,j};
            case{'editstring'}
                v{k}=data{k,j};
            case{'popupmenu'}
                v{k}=data{k,j};
            case{'checkbox'}
                v(k)=data{k,j};
        end
    end
    s=setSubFieldValue(s,el.columns(j).variable,v);
end

feval(setFcn,s);

% Update dependees
updateUIDependees(elements,i,getFcn)

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback,el.option1,el.option2);
end

%%
function custom_Callback(hObject,eventdata,callback,option1,option2)
feval(callback,option1,option2);

