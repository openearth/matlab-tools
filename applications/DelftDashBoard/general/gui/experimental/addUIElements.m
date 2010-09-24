function elements=addUIElements(figh,elements,varargin)

subFields=[];
subIndices=[];
getFcn=[];
setFcn=[];
offset=[0 0];
parent=figh;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'subfields','subfield'}
                subFields=varargin{i+1};
            case{'subindices','subindex'}
                subIndices=varargin{i+1};
            case{'getfcn','getfunction'}
                getFcn=varargin{i+1};
            case{'setfcn','setfunction'}
                setFcn=varargin{i+1};
            case{'parent'}
                parent=varargin{i+1};
            case{'offset'}
                offset=varargin{i+1};
        end
    end
end

if isempty(subIndices)
    subIndices=zeros(length(subFields))+1;
end

bgc=get(figh,'Color');

for i=1:length(elements)
    
    elements(i).handle=[];
    elements(i).textHandle=[];
    
    position=elements(i).position;
    position(1)=position(1)-offset(1);
    position(2)=position(2)-offset(2);
    
    switch lower(elements(i).style)
        
        %% Standard elements
        
        case{'edit'}
            
            % Edit box
            elements(i).handle=uicontrol(figh,'Parent',parent,'Style','edit','String','','Position',position);
            
            switch elements(i).varType
                case{'char','string'}
                    horal='left';
                case{'int'}
                    horal='right';
                case{'real'}
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
                % Text
                elements(i).textHandle=uicontrol(figh,'Parent',parent,'Style','text','String',elements(i).text,'Position',position,'BackgroundColor',bgc);
                setTextPosition(elements(i).textHandle,position,elements(i).textPosition);
            end
            
        case{'panel'}
            elements(i).handle=uipanel('Title',elements(i).title,'Units','pixels','Position',position,'BackgroundColor',bgc);
            set(elements(i).handle,'Parent',parent);
            
        case{'checkbox'}
            
            % Check box
            pos=position;
            elements(i).handle=uicontrol(figh,'Style','check','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc);
            
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
            
        case{'pushbutton'}
            elements(i).handle=uicontrol(figh,'Style','pushbutton','String',elements(i).text,'Position',position);
            set(elements(i).handle,'Parent',parent);
            
        case{'listbox'}
            
        case{'text'}
            
            % Text
            pos=position;
            elements(i).handle=uicontrol(figh,'Style','text','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc);
            
            ext=get(elements(i).handle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(elements(i).handle,'Position',pos);
            
            if ~isempty(parent)
                set(elements(i).handle,'Parent',parent);
            end
            
        case{'vartext'}
            
            % Text
            pos=position;
            elements(i).handle=uicontrol(figh,'Units','pixels','Parent',parent,'Style','text','String',[elements(i).prefix elements(i).text],'Position',[pos 20 20],'BackgroundColor',bgc);
            
            ext=get(elements(i).handle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(elements(i).handle,'Position',pos);
            
            %% Custom elements
            
        case{'pushselectfile'}
            
            % Push select file
            elements(i).handle=uicontrol(figh,'Style','pushbutton','String',elements(i).text,'Position',position);
            
            if ~isempty(elements(i).toolTipString)
                set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
            end
            
            if ~isempty(parent)
                set(elements(i).handle,'Parent',parent);
            end
            
            % Text
            str='File : ';
            elements(i).textHandle=uicontrol(figh,'Style','text','String',str,'Position',position,'BackgroundColor',bgc);
            
            setTextPosition(elements(i).textHandle,position,'right');
            if ~isempty(parent)
                set(elements(i).textHandle,'Parent',parent);
            end
            
        case{'tabpanel'}
            
            tabname=elements(i).tag;
            for j=1:length(elements(i).tabs)
                strings{j}=elements(i).tabs(j).tabstring;
                tabnames{j}=elements(i).tabs(j).tabname;
                callbacks{j}=[];
                if ~isempty(elements(i).tabs(j).callback)
                    callbacks{j}=elements(i).tabs(j).callback;
                else
                    callbacks{j}=@deleteUIControls;
                end
            end
            [elements(i).handle tabhandles]=tabpanel('create','figure',figh,'tag',tabname,'position',position,'strings',strings,'callbacks',callbacks,'tabnames',tabnames,'Parent',parent,'activetabnr',1);
            for j=1:length(elements(i).tabs)
                elements(i).tabs(j).elements=addUIElements(figh,elements(i).tabs(j).elements,'subFields',subFields,'getFcn',getFcn,'setFcn',setFcn,'Parent',tabhandles(j));
                setUIElements(elements(i).tabs(j).elements,getFcn,subFields,subIndices);
                updateUIDependencies(elements(i).tabs(j).elements,0,getFcn,subFields,subIndices);
            end
            
    end
    
end


% Set callbacks
for i=1:length(elements)
    
    switch lower(elements(i).style)
        
        %% Standard elements
        
        case{'edit'}
            
            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',el.customCallback);
            else
                set(elements(i).handle,'Callback',{@edit_Callback,getFcn,setFcn,subFields,subIndices,elements,i});
            end
            
        case{'checkbox'}
            
            % Callback
            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',el.customCallback);
            else
                set(elements(i).handle,'Callback',{@checkbox_Callback,getFcn,setFcn,subFields,subIndices,elements,i});
            end
            
        case{'pushbutton'}
            
        case{'listbox'}
            
        case{'text'}
            
            
            %% Custom elements
            
        case{'pushselectfile'}
            
            % Callback
            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',elements(i).customCallback);
            else
                set(elements(i).handle,'Callback',{@pushSelectFile_Callback,getFcn,setFcn,subFields,subIndices,elements,i});
            end
            
    end
    
end



%%
function edit_Callback(hObject,eventdata,getFcn,setFcn,subFields,subIndices,elements,i)

s=feval(getFcn);

el=elements(i);

v=get(hObject,'String');
switch el.varType
    case{'string'}
    otherwise
        v=str2double(v);
end
s=setSubFieldValue(s,subFields,subIndices,el.varName,v);

feval(setFcn,s);

% Check for dependencies
if ~isempty(elements(i).dependees)
    updateUIDependencies(elements,i,getFcn,subFields,subIndices);
end

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback);
end

%%
function checkbox_Callback(hObject,eventdata,getFcn,setFcn,subFields,subIndices,elements,i)

s=feval(getFcn);

el=elements(i);

v=get(hObject,'Value');
s=setSubFieldValue(s,subFields,subIndices,el.varName,v);
feval(setFcn,s);

% Check for dependencies
if ~isempty(elements(i).dependees)
    updateUIDependencies(elements,i,getFcn,subFields,subIndices);
end

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(el.onChangeCallback);
end

%%
function pushSelectFile_Callback(hObject,eventdata,getFcn,setFcn,subFields,subIndices,elements,i)

s=feval(getFcn);

el=elements(i);

[filename, pathname, filterindex] = uigetfile(el.fileExtension,el.selectionText);

if pathname~=0
    
    curdir=[lower(pwd) filesep];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    v=filename;
    s=setSubFieldValue(s,subFields,subIndices,el.varName,v);
    set(el.textHandle,'enable','on','String',['File : ' v]);
    
    pos=get(el.textHandle,'Position');
    ext=get(el.textHandle,'Extent');
    pos(3)=ext(3);
    pos(4)=15;
    set(el.textHandle,'Position',pos);
    
    feval(setFcn,s);
    
    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(el.onChangeCallback);
    end
    
end

%%
function setTextPosition(tx,pos,textpos)

ext=get(tx,'Extent');
hgt=15;
switch lower(textpos)
    case{'left'}
        txtpos=[pos(1)-ext(3)-5 pos(2)+1 ext(3) hgt];
        horal='right';
    case{'right'}
        txtpos=[pos(1)+pos(3)+5 pos(2)+1 ext(3) hgt];
        horal='left';
    case{'above-left'}
        txtpos=[pos(1) pos(2)+pos(4)+1 ext(3) hgt];
        horal='left';
    case{'above-right'}
        txtpos=[pos(1)+pos(3)-ext(3) pos(2)+pos(4)+1 ext(3) hgt];
        horal='right';
    case{'above-center'}
        txtpos=[pos(1)+0.5*pos(3)-0.5*ext(3) pos(2)+pos(4)+1 ext(3) hgt];
        horal='center';
end
set(tx,'Position',txtpos,'HorizontalAlignment',horal);
