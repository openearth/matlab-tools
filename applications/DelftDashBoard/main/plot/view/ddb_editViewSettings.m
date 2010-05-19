function ddb_editViewSettings

h=getHandles;

f=MakeNewWindow('View Settings',[210 230],'modal',[h.SettingsDir '\icons\deltares.gif']);

% MakeNewWindow
% f=figure;
% clf;
% %pause(0.2);
% set(f,'Name','View Settings','Position',[300 200 210 230]);
% set(f,'NumberTitle','off','Units','pixels','WindowStyle','modal');
% PutInCentre(f);
% clf;
% pause(0.1);
% clf;

str={'Earth','Jet'};
ii=strmatch(h.ScreenParameters.ColorMap,str,'exact');
handles.SelectColorMap = uicontrol(gcf,'Style','popupmenu','Position',[30 165 80 20],'String',str,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextColorMap = uicontrol(gcf,'Style','text','String','Color Map','Position',[30 185  80 20],'Tag','UIControl');
set(handles.SelectColorMap,'Value',ii);

handles.EditCMin = uicontrol(gcf,'Style','edit','Position',[30 115  50 20],'HorizontalAlignment','right', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.EditCMax = uicontrol(gcf,'Style','edit','Position',[30 140  50 20],'HorizontalAlignment','right', 'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditCMin,'String',h.ScreenParameters.CMin);
set(handles.EditCMax,'String',h.ScreenParameters.CMax);
handles.TextCMin = uicontrol(gcf,'Style','text','String','CMin','Position',[85 111  50 20],'HorizontalAlignment','left','Tag','UIControl');
handles.TextCMax = uicontrol(gcf,'Style','text','String','CMax','Position',[85 136  50 20],'HorizontalAlignment','left','Tag','UIControl');

handles.ToggleAutomatic = uicontrol(gcf,'Style','checkbox','String','Automatic Color Limits','Position',[30 90  150 20],'Tag','UIControl');
set(handles.ToggleAutomatic,'Value',h.ScreenParameters.AutomaticColorLimits);

handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[110 30 60 30]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[40 30 60 30]);

if h.ScreenParameters.AutomaticColorLimits
    set(handles.EditCMin,'Enable','off');
    set(handles.EditCMax,'Enable','off');
    set(handles.TextCMin,'Enable','off');
    set(handles.TextCMax,'Enable','off');
end

set(handles.ToggleAutomatic,     'CallBack',{@ToggleAutomatic_CallBack});

set(handles.PushOK,              'CallBack',{@PushOK_CallBack});
set(handles.PushCancel,          'CallBack',{@PushCancel_CallBack});

guidata(f,handles);

uiwait;

%%
function ToggleAutomatic_CallBack(hObject,eventdata)
handles=guidata(gcf);
if get(hObject,'Value')
    set(handles.EditCMin,'Enable','off');
    set(handles.EditCMax,'Enable','off');
    set(handles.TextCMin,'Enable','off');
    set(handles.TextCMax,'Enable','off');
else
    set(handles.EditCMin,'Enable','on');
    set(handles.EditCMax,'Enable','on');
    set(handles.TextCMin,'Enable','on');
    set(handles.TextCMax,'Enable','on');
end

%%
function PushOK_CallBack(hObject,eventdata)

h=getHandles;

handles=guidata(gcf);
cmin=str2double(get(handles.EditCMin,'String'));
cmax=str2double(get(handles.EditCMax,'String'));
autocol=get(handles.ToggleAutomatic,'Value');
str=get(handles.SelectColorMap,'String');
ii=get(handles.SelectColorMap,'Value');
clmap=str{ii};

if cmin~=h.ScreenParameters.CMin || cmax~=h.ScreenParameters.CMax || autocol~=h.ScreenParameters.AutomaticColorLimits || ~strcmpi(h.ScreenParameters.ColorMap,clmap)
    plotnew=1;
else
    plotnew=0;
end

h.ScreenParameters.CMin=cmin;
h.ScreenParameters.CMax=cmax;
h.ScreenParameters.ColorMap=clmap;
h.ScreenParameters.AutomaticColorLimits=autocol;

setHandles(h);

closereq;
uiresume;

if plotnew
    ddb_plotBackgroundBathymetry(h);
end

%%
function PushCancel_CallBack(hObject,eventdata)
closereq;
uiresume;
