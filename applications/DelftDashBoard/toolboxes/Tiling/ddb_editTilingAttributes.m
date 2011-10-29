function attr=ddb_editTilingAttributes(attr)

f=fieldnames(attr);

nat=length(f);

sz=[480 nat*20+140];

handles.SearchWindow    = MakeNewWindow('Edit Attributes',sz,'modal');
bgc = get(gcf,'Color');

for i=1:nat
    handles.txt(i)=uicontrol(gcf,'Style','text','String',f{i},'Position', [  10 351-i*25 135 20],'HorizontalAlignment','right','Tag','UIControl');
    handles.obj(i)=uicontrol(gcf,'Style','edit','String','','Position', [ 150 355-i*25 300 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.obj(i),'String',attr.(f{i}));
end

handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 315 20 70 20],'Tag','UIControl');
handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 390 20 70 20],'Tag','UIControl');

set(handles.PushCancel,     'CallBack',{@PushCancel_CallBack});
set(handles.PushOK,         'CallBack',{@PushOK_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);
 
uiwait;

handles=guidata(gcf);

if handles.ok
    for i=1:nat
        attr.(f{i})=get(handles.obj(i),'String');
    end
end

close(gcf);

%%
function EditString_CallBack(hObject,eventdata)

handles=guidata(gcf);
str=get(hObject,'String');

fnd=strfind(lower(handles.Strings),lower(str));
fnd = ~cellfun('isempty',fnd);
iind=find(fnd>0);

strs={''};
%handles.Code=[];
%handles.FoundCodes=[];
if ~isempty(iind)
    for i=1:length(iind)
        strs{i}=handles.Strings{iind(i)};
%        handles.FoundCodes(i)=handles.Codes(iind(i));
    end
    set(handles.ListCS,'String',strs);
    handles.foundStingNr=iind(1);
%    handles.Code=handles.Codes(iind(1));
end
guidata(gcf,handles);

%%
function ListCS_CallBack(hObject,eventdata)
handles=guidata(gcf);
strs=get(handles.ListCS,'String');
foundString=strs{get(hObject,'Value')};
handles.foundStringNr=strmatch(foundString,handles.Strings,'exact');
%handles.Code=handles.FoundCodes(get(hObject,'Value'));
guidata(gcf,handles);

%%
function PushCancel_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.ok=0;
guidata(gcf,handles);
uiresume;

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.ok=1;
guidata(gcf,handles);
uiresume;
