function h=ddb_getInitialCycloneTrackParameters(h)

h.ok=0;

fig=MakeNewWindow('Track Parameters',[260 210],'modal');

h.TextStartDate = uicontrol(gcf,'Style','text','String','Time First Point','Position',[10 166 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextTimeStep  = uicontrol(gcf,'Style','text','String','Time Increment (h)',      'Position',[10 136 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextVMax      = uicontrol(gcf,'Style','text','String','Vmax (m/s)',    'Position',[10 106 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextPDrop     = uicontrol(gcf,'Style','text','String','Pdrop (Pa)',   'Position',[10  76 95 20],'HorizontalAlignment','right','Tag','UIControl');


h.EditStartDate = uicontrol(gcf,'Style','edit','String',datestr(h.t0,'yyyymmdd HHMMSS'),'Position',[110 170 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditTimeStep  = uicontrol(gcf,'Style','edit','String',num2str(h.dt),      'Position',[110 140 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditVMax      = uicontrol(gcf,'Style','edit','String',num2str(h.vmax),    'Position',[110 110 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditPDrop     = uicontrol(gcf,'Style','edit','String',num2str(h.pdrop),   'Position',[110  80 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

if ~h.hol==0
    set(h.EditVMax, 'String',num2str(h.para));
    set(h.EditPDrop,'String',num2str(h.parb));
    set(h.TextVMax,'String','Paramater A');
    set(h.TextPDrop,'String','Paramater B');
end

h.PushOK        = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[160 30 70 20],'Tag','UIControl');
h.PushCancel    = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[80 30 70 20],'Tag','UIControl');

set(h.PushOK,    'CallBack',{@PushOK_CallBack});
set(h.PushCancel,'CallBack',{@PushCancel_CallBack});

guidata(gcf,h);
uiwait;
h=guidata(gcf);
close(fig);

function PushOK_CallBack(hObject,eventdata)
h=guidata(gcf);
h.t0=datenum(get(h.EditStartDate,'String'),'yyyymmdd HHMMSS');
h.dt=str2double(get(h.EditTimeStep,'String'));
if h.hol
    h.vmax=str2double(get(h.EditVMax,'String'));
    h.pdrop=str2double(get(h.EditPDrop,'String'));
else
    h.para=str2double(get(h.EditVMax,'String'));
    h.parb=str2double(get(h.EditPDrop,'String'));
end

h.ok=1;
guidata(gcf,h);
uiresume;

function PushCancel_CallBack(hObject,eventdata)
uiresume;
