function EditSwanObstacles

ddb_refreshScreen('Obstacles');
handles=getHandles;

hp = uipanel('Title','0bstacles','Units','pixels','Position',[20 20 490 160],'Tag','UIControl');

handles.EditObstacles  = uicontrol(gcf,'Style','edit','Position',[30 30 160 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditObstacles,'Max',50);
set(handles.EditObstacles,'String',handles.SwanInput(handles.ActiveDomain).Obstacles);

handles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[200 120 100 20],'Tag','UIControl');
set(handles.PushAdd,'Enable','on');

handles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[200 90 100 20],'Tag','UIControl');
set(handles.PushDelete,'Enable','on');

handles.PushImport   = uicontrol(gcf,'Style','pushbutton',  'String','Import from file','Position',[200 60 100 20],'Tag','UIControl');
set(handles.PushImport,'Enable','on');

handles.TextObstacletype  = uicontrol(gcf,'Style','text','String','Obstacle type : ','Position',[310 150 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.ToggleSheet       = uicontrol(gcf,'Style','radiobutton', 'String','Sheet','Position',[390 150 50 15],'Tag','UIControl');
handles.ToggleDam         = uicontrol(gcf,'Style','radiobutton', 'String','Dam','Position',[450 150 50 15],'Tag','UIControl');
set(handles.ToggleSheet,'Value',0);
set(handles.ToggleDam,'Value',0);
if handles.SwanInput(handles.ActiveDomain).Sheet
    set(handles.ToggleSheet,'Value',1);
elseif handles.SwanInput(handles.ActiveDomain).Dam
    set(handles.ToggleDam,'Value',1);
end

handles.TextReflections      = uicontrol(gcf,'Style','text','String','Reflections : ','Position',[310 130 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditReflections      = uicontrol(gcf,'Style','popupmenu','String',handles.SwanInput(handles.ActiveDomain).Reflections,'Position',[430 130 70 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditReflections,'Max',1);
set(handles.EditReflections,'String',handles.SwanInput(handles.ActiveDomain).Reflections);
handles.SwanInput(handles.ActiveDomain).Reflections

handles.TextRefcoef       = uicontrol(gcf,'Style','text','String','Reflection coefficient : ','Position',[310 105 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditRefcoef       = uicontrol(gcf,'Style','edit', 'Position',[430 105 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextRefcoefUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 105 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditRefcoef,'Max',1);
set(handles.EditRefcoef,'String',handles.SwanInput(handles.ActiveDomain).Refcoef);

handles.TextTransmcoef      = uicontrol(gcf,'Style','text','String','Transm. coefficient : ','Position',[310 85 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditTransmcoef      = uicontrol(gcf,'Style','edit', 'Position',[430 85 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextTransmcoefUnit  = uicontrol(gcf,'Style','text','String','[-]','Position',[485 85 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditTransmcoef,'Max',1);
set(handles.EditTransmcoef,'String',handles.SwanInput(handles.ActiveDomain).Transmcoef);

handles.TextHeight        = uicontrol(gcf,'Style','text','String','Height : ','Position',[310 65 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditHeight        = uicontrol(gcf,'Style','edit', 'Position',[430 65 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextHeightUnit    = uicontrol(gcf,'Style','text','String','[m]','Position',[485 65 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditHeight,'Max',1);
set(handles.EditHeight,'String',handles.SwanInput(handles.ActiveDomain).Height);

handles.TextAlpha       = uicontrol(gcf,'Style','text','String','Alpha : ','Position',[310 45 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditAlpha       = uicontrol(gcf,'Style','edit', 'Position',[430 45 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextAlphaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 45 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditAlpha,'Max',1);
set(handles.EditAlpha,'String',handles.SwanInput(handles.ActiveDomain).Alpha);

handles.TextBeta       = uicontrol(gcf,'Style','text','String','Beta : ','Position',[310 25 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditBeta       = uicontrol(gcf,'Style','edit', 'Position',[430 25 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextBetaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 25 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditBeta,'Max',1);
set(handles.EditBeta,'String',handles.SwanInput(handles.ActiveDomain).Beta);

hp = uipanel('Title','0bstacles segments','Units','pixels','Position',[520 20 490 160],'Tag','UIControl');

handles.EditSegments  = uicontrol(gcf,'Style','edit','Position',[530 30 160 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditSegments,'Max',50);
set(handles.EditSegments,'String',handles.SwanInput(handles.ActiveDomain).Segments);

handles.PushAddSeg      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[700 120 100 20],'Tag','UIControl');
set(handles.PushAddSeg,'Enable','on');

handles.PushDeleteSeg   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[700 90 100 20],'Tag','UIControl');
set(handles.PushDeleteSeg,'Enable','off');

handles.TextSegmentcoord  = uicontrol(gcf,'Style','text','String','Segment co-ordinates : ','Position',[810 150 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.TextXstart      = uicontrol(gcf,'Style','text','String','X-start : ','Position',[810 120 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXstart      = uicontrol(gcf,'Style','edit', 'Position',[860 120 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextXstartUnit  = uicontrol(gcf,'Style','text','String','[m]','Position',[915 120 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditXstart,'Max',1);
set(handles.EditXstart,'String',handles.SwanInput(handles.ActiveDomain).Xstart);

handles.TextYstart        = uicontrol(gcf,'Style','text','String','Y-start : ','Position',[810 100 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYstart        = uicontrol(gcf,'Style','edit', 'Position',[860 100 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYstartUnit    = uicontrol(gcf,'Style','text','String','[m]','Position',[915 100 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditYstart,'Max',1);
set(handles.EditYstart,'String',handles.SwanInput(handles.ActiveDomain).Ystart);

handles.TextXend       = uicontrol(gcf,'Style','text','String','X-end : ','Position',[810 70 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditXend       = uicontrol(gcf,'Style','edit', 'Position',[860 70 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextXendUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[915 70 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditXend,'Max',1);
set(handles.EditXend,'String',handles.SwanInput(handles.ActiveDomain).Xend);

handles.TextYend       = uicontrol(gcf,'Style','text','String','Y-end : ','Position',[810 50 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.EditYend       = uicontrol(gcf,'Style','edit', 'Position',[860 50 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextYendUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[915 50 20 15],'HorizontalAlignment','left','Tag','UIControl');
set(handles.EditYend,'Max',1);
set(handles.EditYend,'String',handles.SwanInput(handles.ActiveDomain).Yend);

set(handles.EditObstacles,   'CallBack',{@EditObstacles_CallBack});
set(handles.PushAdd,         'CallBack',{@PushAdd_CallBack});
set(handles.PushDelete,      'CallBack',{@PushDelete_CallBack});
set(handles.PushImport,      'CallBack',{@PushImport_CallBack});
set(handles.ToggleSheet,     'CallBack',{@ToggleSheet_CallBack});
set(handles.ToggleDam,       'CallBack',{@ToggleDam_CallBack});
set(handles.EditReflections, 'CallBack',{@EditReflections_CallBack});
set(handles.EditRefcoef,     'CallBack',{@EditRefcoef_CallBack});
set(handles.EditTransmcoef,  'CallBack',{@EditTransmcoef_CallBack});
set(handles.EditHeight,      'CallBack',{@EditHeight_CallBack});
set(handles.EditAlpha,       'CallBack',{@EditAlpha_CallBack});
set(handles.EditBeta,        'CallBack',{@EditBeta_CallBack});
set(handles.EditSegments,    'CallBack',{@EditSegments_CallBack});
set(handles.PushAddSeg,      'CallBack',{@PushAddSeg_CallBack});
set(handles.PushDeleteSeg,   'CallBack',{@PushDeleteSeg_CallBack});
set(handles.EditXstart,      'CallBack',{@EditXstart_CallBack});
set(handles.EditYstart,      'CallBack',{@EditYstart_CallBack});
set(handles.EditXend,        'CallBack',{@EditXend_CallBack});
set(handles.EditYend,        'CallBack',{@EditYend_CallBack});

setHandles(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditObstacles_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Obstacles=get(hObject,'String');
setHandles(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
handles=Add(handles);
setHandles(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
handles=Delete(handles);
setHandles(handles);

function PushImport_CallBack(hObject,eventdata)
handles=getHandles;
handles=Import(handles);
setHandles(handles);

function ToggleSheet_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Sheet=get(hObject,'Value');
if get(hObject,'Value')==1
    handles.ToggleSheet
    set(handles.ToggleSheet,'Value',1);
    set(handles.ToggleDam,'Value',0);
    handles.SwanInput(handles.ActiveDomain).Dam=0;
end
setHandles(handles);

function ToggleDam_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Dam=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.ToggleSheet,'Value',0);
    set(handles.ToggleDam,'Value',1);
    handles.SwanInput(handles.ActiveDomain).Sheet=0;
end
setHandles(handles);

function EditReflections_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Reflections=get(hObject,'String')
setHandles(handles);

function EditRefcoef_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Refcoef=get(hObject,'String');
setHandles(handles);

function EditTransmcoef_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Transmcoef=get(hObject,'String');
setHandles(handles);

function EditHeight_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Height=get(hObject,'String');
setHandles(handles);

function EditAlpha_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Alpha=get(hObject,'String');
setHandles(handles);

function EditBeta_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Beta=get(hObject,'String');
setHandles(handles);

function EditSegments_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Segments=get(hObject,'String');
setHandles(handles);

function PushAddSeg_CallBack(hObject,eventdata)
handles=getHandles;
handles=AddSeg(handles);
setHandles(handles);

function PushDeleteSeg_CallBack(hObject,eventdata)
handles=getHandles;
handles=DeleteSeg(handles);
setHandles(handles);

function EditXstart_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Xstart=get(hObject,'String');
setHandles(handles);

function EditYstart_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Ystart=get(hObject,'String');
setHandles(handles);

function EditXend_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Xend=get(hObject,'String');
setHandles(handles);

function EditYend_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Yend=get(hObject,'String');
setHandles(handles);

