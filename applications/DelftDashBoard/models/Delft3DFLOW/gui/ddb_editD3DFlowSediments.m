function handles=ddb_editD3DFlowSediments(handles)

f=figure;
set(f,'Name','Processes :  Sediment','Position',[400 300 400 300]);
set(f,'NumberTitle','off','Units','pixels','WindowStyle','modal');
PutInCentre(f);

handles.GUIHandles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[310 30 60 30]);
handles.GUIHandles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[240 30 60 30]);

set(handles.GUIHandles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.GUIHandles.PushCancel,          'CallBack',{@PushCancel_CallBack});

SetUIBackgroundColors;

uiwait;


%%

function PushOK_CallBack(hObject,eventdata)
closereq;
uiresume;


%%

function PushCancel_CallBack(hObject,eventdata)
closereq;
uiresume;
