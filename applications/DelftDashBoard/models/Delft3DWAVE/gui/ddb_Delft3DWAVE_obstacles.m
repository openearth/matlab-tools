function ddb_Delft3DWAVE_obstacles(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.timeframe');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end

%{
ddb_refreshScreen('Obstacles');
handles=getHandles;

if isempty(handles.Model(md).Input.Obstacles)
    id = 1;
else
    id = handles.Model(md).Input.ObstaclesIval;
end

hp = uipanel('Title','0bstacles','Units','pixels','Position',[20 20 490 160],'Tag','UIControl');

handles.GUIHandles.EditObstacles  = uicontrol(gcf,'Style','listbox','Position',[30 30 160 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditObstacles,'Max',50);
if isempty(handles.Model(md).Input.Obstacles)
    set(handles.GUIHandles.EditObstacles,'String','');
else
    set(handles.GUIHandles.EditObstacles,'String',[handles.Model(md).Input.Obstacles{:}]');
end

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[200 120 100 20],'Tag','UIControl');

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[200 90 100 20],'Tag','UIControl');

handles.GUIHandles.PushImport   = uicontrol(gcf,'Style','pushbutton',  'String','Import from file','Position',[200 60 100 20],'Tag','UIControl');

handles.GUIHandles.TextObstacletype  = uicontrol(gcf,'Style','text','String','Obstacle type : ','Position',[310 150 75 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.ToggleSheet       = uicontrol(gcf,'Style','radiobutton', 'String','Sheet','Position',[390 150 50 15],'Tag','UIControl');
handles.GUIHandles.ToggleDam         = uicontrol(gcf,'Style','radiobutton', 'String','Dam','Position',[450 150 50 15],'Tag','UIControl');

handles.GUIHandles.TextReflections      = uicontrol(gcf,'Style','text','String','Reflections : ','Position',[310 130 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditReflections      = uicontrol(gcf,'Style','popupmenu','String',handles.Model(md).Input.Reflections,'Position',[430 130 70 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextRefcoef       = uicontrol(gcf,'Style','text','String','Reflection coefficient : ','Position',[310 105 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditRefcoef       = uicontrol(gcf,'Style','edit', 'Position',[430 105 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextRefcoefUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 105 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextTransmcoef      = uicontrol(gcf,'Style','text','String','Transm. coefficient : ','Position',[310 85 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditTransmcoef      = uicontrol(gcf,'Style','edit', 'Position',[430 85 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextTransmcoefUnit  = uicontrol(gcf,'Style','text','String','[-]','Position',[485 85 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextHeight        = uicontrol(gcf,'Style','text','String','Height : ','Position',[310 65 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditHeight        = uicontrol(gcf,'Style','edit', 'Position',[430 65 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextHeightUnit    = uicontrol(gcf,'Style','text','String','[m]','Position',[485 65 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextAlpha       = uicontrol(gcf,'Style','text','String','Alpha : ','Position',[310 45 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditAlpha       = uicontrol(gcf,'Style','edit', 'Position',[430 45 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextAlphaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 45 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextBeta       = uicontrol(gcf,'Style','text','String','Beta : ','Position',[310 25 110 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditBeta       = uicontrol(gcf,'Style','edit', 'Position',[430 25 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextBetaUnit   = uicontrol(gcf,'Style','text','String','[-]','Position',[485 25 20 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditObstacles,   'CallBack',{@EditObstacles_CallBack});
set(handles.GUIHandles.PushAdd,         'CallBack',{@PushAdd_CallBack});
set(handles.GUIHandles.PushDelete,      'CallBack',{@PushDelete_CallBack});
set(handles.GUIHandles.PushImport,      'CallBack',{@PushImport_CallBack});
set(handles.GUIHandles.ToggleSheet,     'CallBack',{@ToggleSheet_CallBack});
set(handles.GUIHandles.ToggleDam,       'CallBack',{@ToggleDam_CallBack});
set(handles.GUIHandles.EditReflections, 'CallBack',{@EditReflections_CallBack});
set(handles.GUIHandles.EditRefcoef,     'CallBack',{@EditRefcoef_CallBack});
set(handles.GUIHandles.EditTransmcoef,  'CallBack',{@EditTransmcoef_CallBack});
set(handles.GUIHandles.EditHeight,      'CallBack',{@EditHeight_CallBack});
set(handles.GUIHandles.EditAlpha,       'CallBack',{@EditAlpha_CallBack});
set(handles.GUIHandles.EditBeta,        'CallBack',{@EditBeta_CallBack});

setHandles(handles);

hp = uipanel('Title','0bstacles segments','Units','pixels','Position',[520 20 490 160],'Tag','UIControl');

handles.GUIHandles.EditSegments  = uicontrol(gcf,'Style','listbox','Position',[530 30 160 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditSegments,'Max',50);
set(handles.GUIHandles.EditSegments,'enable','off');
set(handles.GUIHandles.EditSegments,'String',handles.Model(md).Input.ObstaclesNb(id).Segments);

handles.GUIHandles.PushAddSeg      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[700 120 100 20],'Tag','UIControl');

handles.GUIHandles.PushDeleteSeg   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[700 90 100 20],'Tag','UIControl');

handles.GUIHandles.TextSegmentcoord  = uicontrol(gcf,'Style','text','String','Segment co-ordinates : ','Position',[810 150 150 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextXstart      = uicontrol(gcf,'Style','text','String','X-start : ','Position',[810 120 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXstart      = uicontrol(gcf,'Style','edit', 'Position',[860 120 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextXstartUnit  = uicontrol(gcf,'Style','text','String','[m]','Position',[915 120 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextYstart        = uicontrol(gcf,'Style','text','String','Y-start : ','Position',[810 100 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYstart        = uicontrol(gcf,'Style','edit', 'Position',[860 100 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYstartUnit    = uicontrol(gcf,'Style','text','String','[m]','Position',[915 100 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextXend       = uicontrol(gcf,'Style','text','String','X-end : ','Position',[810 70 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditXend       = uicontrol(gcf,'Style','edit', 'Position',[860 70 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextXendUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[915 70 20 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextYend       = uicontrol(gcf,'Style','text','String','Y-end : ','Position',[810 50 40 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditYend       = uicontrol(gcf,'Style','edit', 'Position',[860 50 50 15],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextYendUnit   = uicontrol(gcf,'Style','text','String','[m]','Position',[915 50 20 15],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditSegments,    'CallBack',{@EditSegments_CallBack});
set(handles.GUIHandles.PushAddSeg,      'CallBack',{@PushAddSeg_CallBack});
set(handles.GUIHandles.PushDeleteSeg,   'CallBack',{@PushDeleteSeg_CallBack});
set(handles.GUIHandles.EditXstart,      'CallBack',{@EditXstart_CallBack});
set(handles.GUIHandles.EditYstart,      'CallBack',{@EditYstart_CallBack});
set(handles.GUIHandles.EditXend,        'CallBack',{@EditXend_CallBack});
set(handles.GUIHandles.EditYend,        'CallBack',{@EditYend_CallBack});

setHandles(handles);

Refresh(handles);

%%

function EditObstacles_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ObstaclesIval=get(hObject,'Value');
setHandles(handles);
Refresh(handles);

function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
if isempty(handles.Model(md).Input.Obstacles)
    handles.Model(md).Input.ObstaclesIval = 1;
else
    handles.Model(md).Input.ObstaclesIval=size(handles.Model(md).Input.Obstacles,2)+1;
end
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Obstacles{id}=cellstr(['Obstacle ' num2str(id)]);
handles.Model(md).Input.ObstaclesNb(id).Segments{1}=cellstr('Segment 1');
handles.Model(md).Input.ObstaclesNb(id).SegmentsIval=1;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.Reflectionsval(id)=1;
handles.Model(md).Input.Sheet(id)=1;
handles.Model(md).Input.Dam(id)=0;
handles.Model(md).Input.Refcoef(id)=0;
handles.Model(md).Input.Transmcoef(id)=1;
handles.Model(md).Input.Height(id)=0;
handles.Model(md).Input.Alpha(id)=2.6;
handles.Model(md).Input.Beta(id)=0.15;
handles.Model(md).Input.ObstaclesNb(id).Xstart(is)=0;
handles.Model(md).Input.ObstaclesNb(id).Ystart(is)=0;
handles.Model(md).Input.ObstaclesNb(id).Xend(is)=0;
handles.Model(md).Input.ObstaclesNb(id).Yend(is)=0;
setHandles(handles);
Refresh(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
id = find([1:size(handles.Model(md).Input.Obstacles,2)]~=handles.Model(md).Input.ObstaclesIval);
if size(id,2)> 0
    handles.Model(md).Input.Obstacles=handles.Model(md).Input.Obstacles(1:end-1);
    handles.Model(md).Input.Sheet=handles.Model(md).Input.Sheet(id);
    handles.Model(md).Input.Dam=handles.Model(md).Input.Dam(id);
    handles.Model(md).Input.Reflectionsval=handles.Model(md).Input.Reflectionsval(id);
    handles.Model(md).Input.Refcoef=handles.Model(md).Input.Refcoef(id);
    handles.Model(md).Input.Transmcoef=handles.Model(md).Input.Transmcoef(id);
    handles.Model(md).Input.Height=handles.Model(md).Input.Height(id);
    handles.Model(md).Input.Alpha=handles.Model(md).Input.Alpha(id);
    handles.Model(md).Input.Beta=handles.Model(md).Input.Beta(id);
    handles.Model(md).Input.ObstaclesNb=handles.Model(md).Input.ObstaclesNb(id);
    handles.Model(md).Input.ObstaclesIval=1;
else
    handles.Model(md).Input.Obstacles='';
    handles.Model(md).Input.ObstaclesIval='';
    handles.Model(md).Input.Sheet=1;
    handles.Model(md).Input.Dam=0;
    handles.Model(md).Input.Reflectionsval=1;
    handles.Model(md).Input.Refcoef=0;
    handles.Model(md).Input.Transmcoef=1
    handles.Model(md).Input.Height=0;
    handles.Model(md).Input.Alpha=2.6;
    handles.Model(md).Input.Beta=0.15;
    handles.Model(md).Input.ObstaclesNb(1).Segments='';
    handles.Model(md).Input.ObstaclesNb(1).Xstart='';
    handles.Model(md).Input.ObstaclesNb(1).Ystart='';
    handles.Model(md).Input.ObstaclesNb(1).Xend='';
    handles.Model(md).Input.ObstaclesNb(1).Yend='';
end
setHandles(handles);
Refresh(handles);

function PushImport_CallBack(hObject,eventdata)
handles=getHandles;
if isempty(handles.Model(md).Input.Obstacles)
    handles.Model(md).Input.ObstaclesIval = 1;
else
    handles.Model(md).Input.ObstaclesIval=size(handles.Model(md).Input.Obstacles,2)+1;
end
id=handles.Model(md).Input.ObstaclesIval;
[filename, pathname, filterindex] = uigetfile('*.pol', 'Select POL File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
end
fid=fopen(filename,'r');
tline = fgetl(fid);
while (tline ~= -1)
    tline = fgetl(fid);
    [token, remain] = strtok(tline, ' ');
    AA = str2num(token); BB = str2num(remain);
    handles.Model(md).Input.Obstacles{id}=cellstr(['Obstacle ' num2str(id)]);
    handles.Model(md).Input.ObstaclesNb(id).SegmentsIval=1;
    for kk = 1:AA-1
         tline = fgetl(fid);
         [token, remain] = strtok(tline, ' ');
        handles.Model(md).Input.ObstaclesNb(id).Segments{kk}=cellstr(['Segment ' num2str(kk)]);
        handles.Model(md).Input.ObstaclesNb(id).Xstart(kk)=str2num(token);
        handles.Model(md).Input.ObstaclesNb(id).Ystart(kk)=str2num(remain);
    end
    handles.Model(md).Input.ObstaclesNb(id).Xend(1:AA-2)=handles.Model(md).Input.ObstaclesNb(id).Xstart(2:AA-1);
    handles.Model(md).Input.ObstaclesNb(id).Yend(1:AA-2)=handles.Model(md).Input.ObstaclesNb(id).Ystart(2:AA-1);
    tline = fgetl(fid);
    [token, remain] = strtok(tline, ' ');
    handles.Model(md).Input.ObstaclesNb(id).Xend(AA-1)=str2num(token);
    handles.Model(md).Input.ObstaclesNb(id).Yend(AA-1)=str2num(remain);
    id = id+1;
    tline = fgetl(fid);
end
setHandles(handles);
Refresh(handles);

function ToggleSheet_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Sheet(id)=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleSheet,'Value',1);
    set(handles.GUIHandles.ToggleDam,'Value',0);
    handles.Model(md).Input.Dam(id)=0;
end
setHandles(handles);
Refresh(handles);

function ToggleDam_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Dam(id)=get(hObject,'value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleSheet,'Value',0);
    set(handles.GUIHandles.ToggleDam,'Value',1);
    handles.Model(md).Input.Sheet(id)=0;
end
setHandles(handles);
Refresh(handles);

function EditReflections_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Reflectionsval(id)=get(hObject,'value');
setHandles(handles);
Refresh(handles);

function EditRefcoef_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Refcoef(id)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditTransmcoef_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Transmcoef(id)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditHeight_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Height(id)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditAlpha_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Alpha(id)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditBeta_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.Beta(id)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditSegments_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.ObstaclesNb(id).SegmentsIval=get(hObject,'Value');
setHandles(handles);
Refresh(handles);

function PushAddSeg_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
handles.Model(md).Input.ObstaclesNb(id).SegmentsIval=handles.Model(md).Input.ObstaclesNb(id).SegmentsIval+1;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.ObstaclesNb(id).Segments{is}=cellstr(['Segment ' num2str(is)]);
handles.Model(md).Input.ObstaclesNb(id).Xstart(is)=handles.Model(md).Input.ObstaclesNb(id).Xend(is-1);
handles.Model(md).Input.ObstaclesNb(id).Ystart(is)=handles.Model(md).Input.ObstaclesNb(id).Yend(is-1);
handles.Model(md).Input.ObstaclesNb(id).Xend(is)=0;
handles.Model(md).Input.ObstaclesNb(id).Yend(is)=0;
setHandles(handles);
Refresh(handles);

function PushDeleteSeg_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ObstaclesIval;
is = find([1:size(handles.Model(md).Input.ObstaclesNb(id).Segments,2)]~=handles.Model(md).Input.ObstaclesNb(id).SegmentsIval);
if size(is,2)> 0
    handles.Model(md).Input.ObstaclesNb(id).Segments=handles.Model(md).Input.ObstaclesNb(id).Segments(1:end-1);
    handles.Model(md).Input.ObstaclesNb(id).Xstart=handles.Model(md).Input.ObstaclesNb(id).Xstart(is);
    handles.Model(md).Input.ObstaclesNb(id).Ystart=handles.Model(md).Input.ObstaclesNb(id).Ystart(is);
    handles.Model(md).Input.ObstaclesNb(id).Xend=handles.Model(md).Input.ObstaclesNb(id).Xend(is);
    handles.Model(md).Input.ObstaclesNb(id).Yend=handles.Model(md).Input.ObstaclesNb(id).Yend(is);     
    handles.Model(md).Input.ObstaclesNb(id).SegmentsIval=1;
else
    handles.Model(md).Input.ObstaclesNb(id).Segments='Segment 1';
    handles.Model(md).Input.ObstaclesNb(id).Xstart=0;
    handles.Model(md).Input.ObstaclesNb(id).Ystart=0;
    handles.Model(md).Input.ObstaclesNb(id).Xend=0;
    handles.Model(md).Input.ObstaclesNb(id).Yend=0; 
end
setHandles(handles);
Refresh(handles);

function EditXstart_CallBack(hObject,eventdata)
handles=getHandles;
id = handles.Model(md).Input.ObstaclesIval;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.ObstaclesNb(id).Xstart(is)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditYstart_CallBack(hObject,eventdata)
handles=getHandles;
id = handles.Model(md).Input.ObstaclesIval;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.ObstaclesNb(id).Ystart(is)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditXend_CallBack(hObject,eventdata)
handles=getHandles;
id = handles.Model(md).Input.ObstaclesIval;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.ObstaclesNb(id).Xend(is)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

function EditYend_CallBack(hObject,eventdata)
handles=getHandles;
id = handles.Model(md).Input.ObstaclesIval;
is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
handles.Model(md).Input.ObstaclesNb(id).Yend(is)=str2double(get(hObject,'string'));
setHandles(handles);
Refresh(handles);

%%
function Refresh(handles)
handles=getHandles;
if ~isempty(handles.Model(md).Input.ObstaclesIval)
    id = handles.Model(md).Input.ObstaclesIval;
    set(handles.GUIHandles.EditObstacles,'String',[handles.Model(md).Input.Obstacles{:}]');
    set(handles.GUIHandles.EditObstacles,'Value',handles.Model(md).Input.ObstaclesIval);
    set(handles.GUIHandles.EditReflections,'String',handles.Model(md).Input.Reflections);
    set(handles.GUIHandles.EditReflections,'Value',handles.Model(md).Input.Reflectionsval(id));
    set(handles.GUIHandles.EditRefcoef,'String',handles.Model(md).Input.Refcoef(id));
    set(handles.GUIHandles.EditTransmcoef,'String',handles.Model(md).Input.Transmcoef(id));
    set(handles.GUIHandles.EditHeight,'String',handles.Model(md).Input.Height(id));
    set(handles.GUIHandles.EditAlpha,'String',handles.Model(md).Input.Alpha(id));
    set(handles.GUIHandles.EditBeta,'String',handles.Model(md).Input.Beta(id));    
    is = handles.Model(md).Input.ObstaclesNb(id).SegmentsIval;
    set(handles.GUIHandles.EditSegments,'String',[handles.Model(md).Input.ObstaclesNb(id).Segments{:}]');
    set(handles.GUIHandles.EditSegments,'Value',handles.Model(md).Input.ObstaclesNb(id).SegmentsIval);
    set(handles.GUIHandles.EditXstart,'String',handles.Model(md).Input.ObstaclesNb(id).Xstart(is));    
    set(handles.GUIHandles.EditYstart,'String',handles.Model(md).Input.ObstaclesNb(id).Ystart(is));
    set(handles.GUIHandles.EditXend,'String',handles.Model(md).Input.ObstaclesNb(id).Xend(is));
    set(handles.GUIHandles.EditYend,'String',handles.Model(md).Input.ObstaclesNb(id).Yend(is));
    set(handles.GUIHandles.PushAdd,'Enable','on');
    set(handles.GUIHandles.PushDelete,'Enable','on');
    set(handles.GUIHandles.PushImport,'Enable','on');
    set(handles.GUIHandles.TextObstacletype,'Enable','on');
    set(handles.GUIHandles.ToggleSheet,'Enable','on');
    set(handles.GUIHandles.ToggleDam,'Enable','on');
    set(handles.GUIHandles.TextReflections,'Enable','on');
    set(handles.GUIHandles.EditReflections,'Enable','on');    
    set(handles.GUIHandles.EditSegments,'enable','on');
    set(handles.GUIHandles.PushAddSeg,'Enable','on');
    set(handles.GUIHandles.PushDeleteSeg,'Enable','on');
    set(handles.GUIHandles.TextSegmentcoord,'enable','on');
    set(handles.GUIHandles.TextXstart,'enable','on');
    set(handles.GUIHandles.EditXstart,'enable','on');
    set(handles.GUIHandles.TextXstartUnit,'enable','on');
    set(handles.GUIHandles.TextYstart,'enable','on');
    set(handles.GUIHandles.EditYstart,'enable','on');
    set(handles.GUIHandles.TextYstartUnit,'enable','on');
    set(handles.GUIHandles.TextXend,'enable','on');
    set(handles.GUIHandles.EditXend,'enable','on');
    set(handles.GUIHandles.TextXendUnit,'enable','on');
    set(handles.GUIHandles.TextYend,'enable','on');
    set(handles.GUIHandles.EditYend,'enable','on');
    set(handles.GUIHandles.TextYendUnit,'enable','on');
    set(handles.GUIHandles.ToggleSheet,'Value',0);
    set(handles.GUIHandles.TextRefcoef,'Enable','off');
    set(handles.GUIHandles.EditRefcoef,'Enable','off');
    set(handles.GUIHandles.TextRefcoefUnit,'Enable','off');
    set(handles.GUIHandles.TextTransmcoef,'Enable','off');
    set(handles.GUIHandles.EditTransmcoef,'Enable','off');
    set(handles.GUIHandles.TextTransmcoefUnit,'Enable','off');
    set(handles.GUIHandles.ToggleDam,'Value',0);
    set(handles.GUIHandles.TextHeight,'Enable','off');
    set(handles.GUIHandles.EditHeight,'Enable','off');
    set(handles.GUIHandles.TextHeightUnit,'Enable','off');
    set(handles.GUIHandles.TextAlpha,'enable','off');
    set(handles.GUIHandles.EditAlpha,'enable','off');
    set(handles.GUIHandles.TextAlphaUnit,'enable','off');
    set(handles.GUIHandles.TextBeta,'enable','off');
    set(handles.GUIHandles.EditBeta,'enable','off');
    set(handles.GUIHandles.TextBetaUnit,'enable','off');    
    if handles.Model(md).Input.Sheet(id) == 1
        set(handles.GUIHandles.ToggleSheet,'Value',1);
        set(handles.GUIHandles.ToggleDam,'Value',0);
        if handles.Model(md).Input.Reflectionsval(id) == 1
            set(handles.GUIHandles.TextTransmcoef,'Enable','on');
            set(handles.GUIHandles.EditTransmcoef,'Enable','on');
            set(handles.GUIHandles.TextTransmcoefUnit,'Enable','on');            
        else
            set(handles.GUIHandles.TextRefcoef,'Enable','on');
            set(handles.GUIHandles.EditRefcoef,'Enable','on');
            set(handles.GUIHandles.TextRefcoefUnit,'Enable','on');
            set(handles.GUIHandles.TextTransmcoef,'Enable','on');
            set(handles.GUIHandles.EditTransmcoef,'Enable','on');
            set(handles.GUIHandles.TextTransmcoefUnit,'Enable','on');
        end
    else
        set(handles.GUIHandles.ToggleSheet,'Value',0);
        set(handles.GUIHandles.ToggleDam,'Value',1);
        set(handles.GUIHandles.TextHeight,'Enable','on');
        set(handles.GUIHandles.EditHeight,'Enable','on');
        set(handles.GUIHandles.TextHeightUnit,'Enable','on');
        set(handles.GUIHandles.TextAlpha,'enable','on');
        set(handles.GUIHandles.EditAlpha,'enable','on');
        set(handles.GUIHandles.TextAlphaUnit,'enable','on');
        set(handles.GUIHandles.TextBeta,'enable','on');
        set(handles.GUIHandles.EditBeta,'enable','on');
        set(handles.GUIHandles.TextBetaUnit,'enable','on');        
        if handles.Model(md).Input.Reflectionsval(id) > 1
            set(handles.GUIHandles.TextRefcoef,'Enable','on');
            set(handles.GUIHandles.EditRefcoef,'Enable','on');
            set(handles.GUIHandles.TextRefcoefUnit,'Enable','on');
        end
    end
else
    set(handles.GUIHandles.EditObstacles,'String','');    
    set(handles.GUIHandles.EditReflections,'String',handles.Model(md).Input.Reflections);
    set(handles.GUIHandles.EditRefcoef,'String',handles.Model(md).Input.Refcoef);
    set(handles.GUIHandles.EditTransmcoef,'String',handles.Model(md).Input.Transmcoef);    
    set(handles.GUIHandles.EditHeight,'String',handles.Model(md).Input.Height);    
    set(handles.GUIHandles.EditAlpha,'String',handles.Model(md).Input.Alpha);    
    set(handles.GUIHandles.EditBeta,'String',handles.Model(md).Input.Beta);    
    set(handles.GUIHandles.EditSegments,'String',handles.Model(md).Input.ObstaclesNb(1).Segments);    
    set(handles.GUIHandles.EditXstart,'String',handles.Model(md).Input.ObstaclesNb(1).Xstart);    
    set(handles.GUIHandles.EditYstart,'String',handles.Model(md).Input.ObstaclesNb(1).Ystart);    
    set(handles.GUIHandles.EditXend,'String',handles.Model(md).Input.ObstaclesNb(1).Xend);    
    set(handles.GUIHandles.EditYend,'String',handles.Model(md).Input.ObstaclesNb(1).Yend);
    set(handles.GUIHandles.EditRefcoef,'String','');
    set(handles.GUIHandles.EditTransmcoef,'String','');    
    set(handles.GUIHandles.EditHeight,'String','');    
    set(handles.GUIHandles.EditAlpha,'String','');    
    set(handles.GUIHandles.EditBeta,'String','');    
    set(handles.GUIHandles.EditSegments,'String','');    
    set(handles.GUIHandles.EditXstart,'String','');    
    set(handles.GUIHandles.EditYstart,'String','');    
    set(handles.GUIHandles.EditXend,'String','');    
    set(handles.GUIHandles.EditYend,'String','');        
    set(handles.GUIHandles.PushAdd,'Enable','on');
    set(handles.GUIHandles.PushDelete,'Enable','off');
    set(handles.GUIHandles.PushImport,'Enable','on');
    set(handles.GUIHandles.TextObstacletype,'Enable','off');
    set(handles.GUIHandles.ToggleSheet,'Value',0);
    set(handles.GUIHandles.ToggleDam,'Value',0);
    set(handles.GUIHandles.ToggleSheet,'Enable','off');
    set(handles.GUIHandles.ToggleDam,'Enable','off');
    set(handles.GUIHandles.ToggleSheet,'Value',0);
    set(handles.GUIHandles.ToggleSheet,'Enable','off');
    set(handles.GUIHandles.ToggleDam,'Value',0);
    set(handles.GUIHandles.ToggleDam,'Enable','off');
    set(handles.GUIHandles.TextReflections,'Enable','off');
    set(handles.GUIHandles.EditReflections,'Max',1);
    set(handles.GUIHandles.EditReflections,'Enable','off');
    set(handles.GUIHandles.TextRefcoef,'Enable','off');
    set(handles.GUIHandles.EditRefcoef,'Max',1);
    set(handles.GUIHandles.EditRefcoef,'Enable','off');
    set(handles.GUIHandles.TextRefcoefUnit,'Enable','off');
    set(handles.GUIHandles.TextTransmcoef,'Enable','off');
    set(handles.GUIHandles.EditTransmcoef,'Max',1);
    set(handles.GUIHandles.EditTransmcoef,'Enable','off');
    set(handles.GUIHandles.TextTransmcoefUnit,'Enable','off');
    set(handles.GUIHandles.TextHeight,'Enable','off');
    set(handles.GUIHandles.EditHeight,'Max',1);
    set(handles.GUIHandles.EditHeight,'Enable','off');
    set(handles.GUIHandles.TextHeightUnit,'Enable','off');
    set(handles.GUIHandles.TextAlpha,'enable','off');
    set(handles.GUIHandles.EditAlpha,'Max',1);
    set(handles.GUIHandles.EditAlpha,'enable','off');
    set(handles.GUIHandles.TextAlphaUnit,'enable','off');
    set(handles.GUIHandles.TextBeta,'enable','off');
    set(handles.GUIHandles.EditBeta,'Max',1);
    set(handles.GUIHandles.EditBeta,'enable','off');
    set(handles.GUIHandles.TextBetaUnit,'enable','off');
    set(handles.GUIHandles.EditSegments,'Max',50);
    set(handles.GUIHandles.EditSegments,'enable','off');
    set(handles.GUIHandles.PushAddSeg,'Enable','off');
    set(handles.GUIHandles.PushDeleteSeg,'Enable','off');
    set(handles.GUIHandles.TextSegmentcoord,'enable','off');
    set(handles.GUIHandles.TextXstart,'enable','off');
    set(handles.GUIHandles.EditXstart,'Max',1);
    set(handles.GUIHandles.EditXstart,'enable','off');
    set(handles.GUIHandles.TextXstartUnit,'enable','off');
    set(handles.GUIHandles.TextYstart,'enable','off');
    set(handles.GUIHandles.EditYstart,'Max',1);
    set(handles.GUIHandles.EditYstart,'enable','off');
    set(handles.GUIHandles.TextYstartUnit,'enable','off');
    set(handles.GUIHandles.TextXend,'enable','off');
    set(handles.GUIHandles.EditXend,'Max',1);
    set(handles.GUIHandles.EditXend,'enable','off');
    set(handles.GUIHandles.TextXendUnit,'enable','off');
    set(handles.GUIHandles.TextYend,'enable','off');
    set(handles.GUIHandles.EditYend,'Max',1);
    set(handles.GUIHandles.EditYend,'enable','off');
    set(handles.GUIHandles.TextYendUnit,'enable','off');
end
setHandles(handles);
%}





