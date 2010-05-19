function ddb_editD3DFlowOutputStorage

ddb_refreshScreen('Output','Storage');
handles=getHandles;

hp                        = uipanel('Title','Map File','Units','pixels','Position',[60 30 180 120],'Tag','UIControl');
handles.GUIHandles.TextMapStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [ 65  96  50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextMapStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [ 65  66  50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextMapInterval      = uicontrol(gcf,'Style','text','String','Interval (min)',     'Position',    [ 80  36  75 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditMapStartTime     = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).MapStartTime),'Position',  [120 100 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditMapStopTime      = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).MapStopTime),'Position',   [120  70 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditMapInterval      = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).MapInterval),'Position',[160  40 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

hp                           = uipanel('Title','Communication File','Units','pixels','Position',[250 30 180 120],'Tag','UIControl');
handles.GUIHandles.TextComStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [255  96  50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextComStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [255  66  50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextComInterval      = uicontrol(gcf,'Style','text','String','Interval (min)',     'Position',    [270  36  75 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditComStartTime     = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).ComStartTime),'Position',  [310 100 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditComStopTime      = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).ComStopTime),'Position',   [310  70 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditComInterval      = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).ComInterval),'Position',[350  40 70 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextHisInterval  = uicontrol(gcf,'Style','text','String','History Interval (min)', 'Position',    [450  121 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditHisInterval  = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).HisInterval),'Position',  [555 125 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextRstInterval  = uicontrol(gcf,'Style','text','String','Restart Interval (min)', 'Position',    [450  96 100 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditRstInterval  = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).RstInterval),'Position',  [555 100 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.ToggleOnlineVisualisation  = uicontrol(gcf,'Style','checkbox','String','Online Visualisation','Position',  [450 70 150 20],'Tag','UIControl');
handles.GUIHandles.ToggleOnlineCoupling       = uicontrol(gcf,'Style','checkbox','String','Online Coupling',     'Position',  [450 50 150 20],'Tag','UIControl');

set(handles.GUIHandles.ToggleOnlineVisualisation,'Value',handles.Model(md).Input(ad).OnlineVisualisation);
set(handles.GUIHandles.ToggleOnlineCoupling,     'Value',handles.Model(md).Input(ad).OnlineCoupling);

handles.GUIHandles.ToggleFourierAnalysis  = uicontrol(gcf,'Style','checkbox',  'String','Fourier Analysis','Position',      [450 30 150 20],'Tag','UIControl');
handles.GUIHandles.SelectFourierAnalysisFile  = uicontrol(gcf,'Style','pushbutton','String','Select File','Position',  [555 30 70 20],'Tag','UIControl');
handles.GUIHandles.FourierAnalysisFile  = uicontrol(gcf,'Style','text','String','File : ','Position',  [635 26 300 20],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.ToggleFourierAnalysis,     'Value',handles.Model(md).Input(ad).FourierAnalysis);
if handles.Model(md).Input(ad).FourierAnalysis
    set(handles.GUIHandles.SelectFourierAnalysisFile,'Enable','on');
    set(handles.GUIHandles.FourierAnalysisFile,'String',['File : ' handles.Model(md).Input(ad).FouFile],'Enable','on');
else
    set(handles.GUIHandles.SelectFourierAnalysisFile,'Enable','off');
    set(handles.GUIHandles.FourierAnalysisFile,'String','File : ','Enable','off');
end

hp  = uipanel('Title','Time Frame','Units','pixels','Position',[685 70 250 80],'Tag','UIControl');
handles.GUIHandles.TextSimulationStartTime = uicontrol(gcf,'Style','text','String','Simulation Start Time : ',    'Position',[695 115 110 15],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextSimulationStopTime  = uicontrol(gcf,'Style','text','String','Simulation Stop Time : ',     'Position',[695  95 110 15],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextSimulationTimeStep  = uicontrol(gcf,'Style','text','String','Time Step (min) : ',          'Position',[695  75 110 15],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextSimulationStartTime = uicontrol(gcf,'Style','text','String',D3DTimeString(handles.Model(md).Input(ad).StartTime),'Position',[815 115 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextSimulationStopTime  = uicontrol(gcf,'Style','text','String',D3DTimeString(handles.Model(md).Input(ad).StopTime), 'Position',[815  95 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextSimulationTimeStep  = uicontrol(gcf,'Style','text','String',num2str(handles.Model(md).Input(ad).TimeStep),       'Position',[815  75 100 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditMapStartTime,    'CallBack',{@EditMapStartTime_CallBack});
set(handles.GUIHandles.EditMapStopTime,     'CallBack',{@EditMapStopTime_CallBack});
set(handles.GUIHandles.EditMapInterval,     'CallBack',{@EditMapInterval_CallBack});
set(handles.GUIHandles.EditComStartTime,    'CallBack',{@EditComStartTime_CallBack});
set(handles.GUIHandles.EditComStopTime,     'CallBack',{@EditComStopTime_CallBack});
set(handles.GUIHandles.EditComInterval,     'CallBack',{@EditComInterval_CallBack});
set(handles.GUIHandles.EditHisInterval,     'CallBack',{@EditHisInterval_CallBack});
set(handles.GUIHandles.EditRstInterval,     'CallBack',{@EditRstInterval_CallBack});
set(handles.GUIHandles.ToggleOnlineVisualisation,'CallBack',{@ToggleOnlineVisualisation_CallBack});
set(handles.GUIHandles.ToggleOnlineCoupling,     'CallBack',{@ToggleOnlineCoupling_CallBack});
set(handles.GUIHandles.ToggleFourierAnalysis,    'CallBack',{@ToggleFourierAnalysis_CallBack});
set(handles.GUIHandles.SelectFourierAnalysisFile,'CallBack',{@SelectFourierAnalysisFile_CallBack});

SetUIBackgroundColors;

setHandles(handles);

%%
function EditMapStartTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).MapStartTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditMapStopTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).MapStopTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditMapInterval_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).MapInterval=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditComStartTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).ComStartTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditComStopTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).ComStopTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditComInterval_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).ComInterval=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditHisInterval_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).HisInterval=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditRstInterval_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).RstInterval=str2num(get(hObject,'String'));
setHandles(handles);

%%
function ToggleOnlineVisualisation_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).OnlineVisualisation=get(hObject,'Value');
setHandles(handles);

%%
function ToggleOnlineCoupling_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).OnlineCoupling=get(hObject,'Value');
setHandles(handles);

%%
function ToggleFourierAnalysis_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.Model(md).Input(ad).FourierAnalysis=ii;
if handles.Model(md).Input(ad).FourierAnalysis
    set(handles.GUIHandles.SelectFourierAnalysisFile,'Enable','on');
    set(handles.GUIHandles.FourierAnalysisFile,'String',['File : ' handles.Model(md).Input(ad).FouFile],'Enable','on');
else
    set(handles.GUIHandles.SelectFourierAnalysisFile,'Enable','off');
    set(handles.GUIHandles.FourierAnalysisFile,'String','File : ','Enable','off');
end
setHandles(handles);

%%
function SelectFourierAnalysisFile_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.fou', 'Select Fourier File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmp(lower(curdir),lower(pathname))
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).FouFile=filename;
    set(handles.GUIHandles.FourierAnalysisFile,'String',['File : ' handles.Model(md).Input(ad).FouFile],'Enable','on');
    setHandles(handles);
end
