function elements=ddb_addUIElements(elements,subFields,subIndices,getFcn,setFcn)

s=feval(getFcn);

bgc=get(gcf,'Color');

nf=length(subFields);

for i=1:length(elements)
    
    elements(i).handle=[];
    elements(i).textHandle=[];

    subFields{nf+1}=elements(i).varName;
    subIndices{nf+1}=1;
    
    if ~isempty(elements(i).varName)
        val=getSubFieldValue(s,subFields,subIndices);
    end
    
    switch lower(elements(i).style)

        %% Standard elements

        case{'edit'}

            % Edit box
            elements(i).handle=uicontrol(gcf,'Style','edit','String','dummy','Position',elements(i).position,'Tag','UIControl');

            switch elements(i).varType
                case{'char','string'}
                    horal='left';
                    str=val;
                case{'int'}
                    horal='right';
                    str=num2str(val);
                case{'real'}
                    horal='right';
                    str=num2str(val);
            end
            set(elements(i).handle,'String',str);
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
                elements(i).textHandle=uicontrol(gcf,'Style','text','String',elements(i).text,'Position',elements(i).position,'BackgroundColor',bgc,'Tag','UIControl');
                setTextPosition(elements(i).textHandle,elements(i).position,elements(i).textPosition);
            end

            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',str2func(el.customCallback));
            else
                set(elements(i).handle,'Callback',{@edit_Callback,getFcn,setFcn,subFields,subIndices,elements,i});
            end
            
        case{'panel'}
            uipanel('Title',elements(i).title,'Units','pixels','Position',elements(i).position,'BackgroundColor',bgc,'Tag','UIControl');

        case{'checkbox'}
           
            % Check box
            pos=elements(i).position;
            elements(i).handle=uicontrol(gcf,'Style','check','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc,'Tag','UIControl');
            ext=get(elements(i).handle,'Extent');
            pos(3)=ext(3)+15;
            pos(4)=20;
            set(elements(i).handle,'Position',pos);
            set(elements(i).handle,'Value',val);
            if ~isempty(elements(i).toolTipString)
                set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
            end                           
            
            % Callback
            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',str2func(el.customCallback));
            else
                set(elements(i).handle,'Callback',{@checkbox_Callback,getFcn,setFcn,subFields,subIndices,elements,i});
            end

        case{'pushbutton'}

        case{'listbox'}

        case{'text'}
            
            % Text
            pos=elements(i).position;
            elements(i).handle=uicontrol(gcf,'Style','text','String',elements(i).text,'Position',[pos 20 20],'BackgroundColor',bgc,'Tag','UIControl');
            ext=get(elements(i).handle,'Extent');
            pos(3)=ext(3);
            pos(4)=15;
            set(elements(i).handle,'Position',pos);

        %% Custom elements

        case{'pushselectfile'}

            % Push select file
            elements(i).handle=uicontrol(gcf,'Style','pushbutton','String',elements(i).text,'Position',elements(i).position,'Tag','UIControl');
            if ~isempty(elements(i).toolTipString)
                set(elements(i).handle,'ToolTipString',elements(i).toolTipString);
            end
            
            % Text
            str=['File : ' val];
            elements(i).textHandle=uicontrol(gcf,'Style','text','String',str,'Position',elements(i).position,'BackgroundColor',bgc,'Tag','UIControl');
            setTextPosition(elements(i).textHandle,elements(i).position,'right');
            
            % Callback
            if ~isempty(elements(i).customCallback)
                set(elements(i).handle,'Callback',str2func(elements(i).customCallback));
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
s=setSubFieldValue(s,subFields,subIndices,v);

feval(setFcn,s);

% % Check for dependencies
% if ~isempty(element(ii).dependees)
%     % Other elements depend on this one
%     for j=1:length(element(ii).dependees)
%         refreshUIElements(s,element,i);
%     end
% end

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(str2func(el.onChangeCallback));
end

%%
function checkbox_Callback(hObject,eventdata,getFcn,setFcn,subFields,subIndices,elements,i)

s=feval(getFcn);

el=elements(i);

v=get(hObject,'Value');
s=setSubFieldValue(s,subFields,subIndices,v);
feval(setFcn,s);

% % Check for dependencies
% if ~isempty(element(ii).dependees)
%     % Other elements depend on this one
%     for j=1:length(element(ii).dependees)
%         refreshUIElements(s,element,i);
%     end
% end

if ~isempty(el.onChangeCallback)
    % Execute on-change callback
    feval(str2func(el.onChangeCallback));
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
    s=setSubFieldValue(s,subFields,subIndices,v);
    set(el.textHandle,'enable','on','String',['File : ' v]); 

    pos=get(el.textHandle,'Position');
    ext=get(el.textHandle,'Extent');
    pos(3)=ext(3);
    pos(4)=15;
    set(el.textHandle,'Position',pos);
    
    feval(setFcn,s);

    if ~isempty(el.onChangeCallback)
        % Execute on-change callback
        feval(str2func(el.onChangeCallback));
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

%%
function val=getSubFieldValue(s,sfields,sindices)

nf=length(sfields);
switch nf
    case 1
        val=s.(sfields{1});
    case 2
        val=s.(sfields{1})(sindices{1}).(sfields{2});
    case 3
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3});
    case 4
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4});
    case 5
        val=s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5});
end

%%
function s=setSubFieldValue(s,sfields,sindices,v)

nf=length(sfields);
switch nf
    case 1
        s.(sfields{1})=v;
    case 2
        s.(sfields{1})(sindices{1}).(sfields{2})=v;
    case 3
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})=v;
    case 4
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})=v;
    case 5
        s.(sfields{1})(sindices{1}).(sfields{2})(sindices{2}).(sfields{3})(sindices{3}).(sfields{4})(sindices{4}).(sfields{5})=v;
end
