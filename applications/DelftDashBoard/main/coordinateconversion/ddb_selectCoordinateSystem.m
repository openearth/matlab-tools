function [CS,ok]=ddb_selectCoordinateSystem(CoordinateSystems,varargin)

handles.ok=0;

if nargin>1
   cs0=varargin{1};
else
   cs0='Amersfoort / RD New';
end
handles.CS=cs0;

handles.Window=MakeNewWindow('Select Coordinate System',[400 480]);

handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 70 340 390],'BackgroundColor',[1 1 1]);

set(handles.SelectCS,'String',CoordinateSystems);
ii=strmatch(cs0,CoordinateSystems,'exact');
set(handles.SelectCS,'Value',ii);

handles.PushOK = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 320 30 50 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 260 30 50 20]);

set(handles.PushOK,     'CallBack',{@PushOK_CallBack});
set(handles.PushCancel, 'CallBack',{@PushCancel_CallBack});

pause(0.2);

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);

if handles.ok
    ok=1;
    CS=handles.CS;
else
    ok=0;
    CS=cs0;
end    
close(gcf);

function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
str=get(handles.SelectCS,'String');
ii=get(handles.SelectCS,'Value');
handles.CS=str{ii};
handles.ok=1;
guidata(gcf,handles);
uiresume;

function PushCancel_CallBack(hObject,eventdata)
uiresume;
