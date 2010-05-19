function EditSwanTimeFrame

ddb_refreshScreen('Time Frame');
handles=getHandles;

hp = uipanel('Title','Time Frame','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.TextWaterlevelCor      = uicontrol(gcf,'Style','text','String','Water level correction : ','Position',[40 140 140 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditWaterlevelCor      = uicontrol(gcf,'Style','edit', 'Position',[160 140 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextWaterlevelCorUnit  = uicontrol(gcf,'Style','text','String','[m]','Position',[220 140 30 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.EditWaterlevelCor,'Max',1);
set(handles.EditWaterlevelCor,'String',handles.SwanInput(handles.ActiveDomain).WaterlevelCor);
set(handles.EditWaterlevelCor,'CallBack',{@EditWaterlevelCor_CallBack}); 

hp = uipanel('Title','Time points for WAVE computation','Units','pixels','Position',[40 40 440 90],'Tag','UIControl');

handles.EditTimepoints  = uicontrol(gcf,'Style','edit','Position',[45 45 245 70],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.EditTimepoints,'Max',50);
set(handles.EditTimepoints,'String',handles.SwanInput(handles.ActiveDomain).Timepoints);
set(handles.EditTimepoints,'CallBack',{@EditTimepoints_CallBack});

handles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[300 90 70 20],'Tag','UIControl');
set(handles.PushAdd,'Enable','on');
set(handles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[300 60 70 20],'Tag','UIControl');
set(handles.PushDelete,'Enable','off');
set(handles.PushDelete,'CallBack',{@PushDelete_CallBack});

hp = uipanel('Title','Default hydrodynamic data for selected time period','Units','pixels','Position',[490 40 500 100],'Tag','UIControl');

handles.TextTime        = uicontrol(gcf,'Style','text','String','Time : ','Position',[500 105 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditTime        = uicontrol(gcf,'Style','edit', 'Position',[570 105 100 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextTimeUnit    = uicontrol(gcf,'Style','text','String','[dd mm yyyy hh mm ss]','Position',[680 105 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextWaterLevel       = uicontrol(gcf,'Style','text','String','Water level : ','Position',[500 85 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditWaterLevel       = uicontrol(gcf,'Style','edit', 'Position',[570 85 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextWaterLevelUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[620 85 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextXvelocity        = uicontrol(gcf,'Style','text','String','X-velocity : ','Position',[500 65 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXvelocity        = uicontrol(gcf,'Style','edit', 'Position',[570 65 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextXvelocityUnit    = uicontrol(gcf,'Style','text','String','[m/s]','Position',[620 65 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextYvelocity        = uicontrol(gcf,'Style','text','String','Y-velocity : ','Position',[500 45 60 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYvelocity        = uicontrol(gcf,'Style','edit', 'Position',[570 45 40 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYvelocityUnit    = uicontrol(gcf,'Style','text','String','[m/s]','Position',[620 45 150 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.EditTime,'Max',1);
set(handles.EditTime,'String',handles.SwanInput(handles.ActiveDomain).Time);
set(handles.EditTime,'CallBack',{@EditTime_CallBack});

set(handles.EditWaterLevel,'Max',1);
set(handles.EditWaterLevel,'String',handles.SwanInput(handles.ActiveDomain).WaterLevel);
set(handles.EditWaterLevel,'CallBack',{@EditWaterLevel_CallBack});

set(handles.EditXvelocity,'Max',1);
set(handles.EditXvelocity,'String',handles.SwanInput(handles.ActiveDomain).Xvelocity);
set(handles.EditXvelocity,'CallBack',{@EditXvelocity_CallBack});

set(handles.EditYvelocity,'Max',1);
set(handles.EditYvelocity,'String',handles.SwanInput(handles.ActiveDomain).Yvelocity);
set(handles.EditYvelocity,'CallBack',{@EditYvelocity_CallBack});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditWaterlevelCor_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).WaterlevelCor=get(hObject,'String');
setHandles(handles);

function EditTimepoints_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Timepoints=get(hObject,'String');
setHandles(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
handles=Add(handles);
set(handles.PushDelete,'Enable','on');
setHandles(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
handles=Delete(handles);
setHandles(handles);

function EditTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Time=get(hObject,'String');
setHandles(handles);

function EditWaterLevel_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).WaterLevel=get(hObject,'String');
setHandles(handles);

function EditXvelocity_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Xvelocity=get(hObject,'String');
setHandles(handles);

function EditYvelocity_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Yvelocity=get(hObject,'String');
setHandles(handles);
