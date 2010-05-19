function ddb_editD3DFlowDescription

ddb_refreshScreen('Description');
handles=getHandles;

handles.GUIHandles.TextDescription = uicontrol(gcf,'Style','text','string','Model Description (max. 10 lines)','Position',[60 158 300  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditDescription = uicontrol(gcf,'Style','edit','Position',[50  30 500 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditDescription,'Min',1);
set(handles.GUIHandles.EditDescription,'Max',10);
set(handles.GUIHandles.EditDescription,'String',handles.Model(md).Input(ad).Description);
set(handles.GUIHandles.EditDescription,'CallBack',{@EditDescription_CallBack});

SetUIBackgroundColors;

%%
function EditDescription_CallBack(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');

if size(str,1)>10
    handles.Model(md).Input(ad).Description=str(1:10,:);
else
    handles.Model(md).Input(ad).Description=str;
end    
setHandles(handles);
