function crossshoreprofileedit(X,Y)
if ~exist('md','var')
    global md
    md=1;
end
% X=[0:100];
% Y=4-(X).^0.5;
handles.ActiveModel.Nr=4;
handles.Model(md).Input.x{1}=X;
handles.Model(md).Input.y{1}=Y;

handles.GUIHandles.Profigure = figure('Position',[100,300,1000,500]);
pos = get(gcf,'Position');
hp = uipanel('Units','pixels','Position',[5 5 100 pos(4)-10],'Tag','UIControl');

pixelsxlabel=45;
pixelsylabel=35;

xrel1 = (105+pixelsxlabel)/pos(3);
xrel2 = (pos(3)-105-pixelsxlabel*1.5)/pos(3);
yrel1 = (pixelsylabel)/pos(4);
yrel2 = (pos(4)-pixelsylabel*1.5)/pos(4);
handles.Axes.ha = axes('Position',[xrel1,yrel1,xrel2,yrel2],'FontSize',8);
%plot(handles.Model(md).Input.x{1},handles.Model(md).Input.y{1},'k.-');hold on;
setHandles(handles);
plotprofile;


%% SELECTION
%listfield
handles.Model(md).Input.Smoothtype={'Thinning','Interpolation'};
handles.GUIHandles.TextGeneration   = uicontrol(gcf,'Style','text','String','Action :','Position',[10 pos(4)-25 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Smoothtype       = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[10 pos(4)-45 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.Smoothtype,'Max',1);
set(handles.GUIHandles.Smoothtype,'String',handles.Model(md).Input.Smoothtype);
set(handles.GUIHandles.Smoothtype,'CallBack',{@Smoothtype_CallBack});

%% THINNING
% field thinning
handles.Model(md).Input.Thinfactor = 1;
handles.GUIHandles.TextThinning        = uicontrol(gcf,'Style','text','String','-----Thinning-----','Position',[10 pos(4)-75 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextThinfactor      = uicontrol(gcf,'Style','text','String','Thin factor :','Position',[10 pos(4)-90 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditThinfactor      = uicontrol(gcf,'Style','edit', 'Position',[10 pos(4)-110 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditThinfactor,'Max',1);
set(handles.GUIHandles.EditThinfactor,'String',handles.Model(md).Input.Thinfactor);
set(handles.GUIHandles.EditThinfactor,'CallBack',{@EditThinfactor_CallBack});

%% INTERPOLATION
% field interpolation
handles.Model(md).Input.Interpdx = 1;
handles.GUIHandles.TextInterp        = uicontrol(gcf,'Style','text','String','---Interpolation---','Position',[10 pos(4)-145 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextInterpdx      = uicontrol(gcf,'Style','text','String','Interp. dx :','Position',[10 pos(4)-160 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditInterpdx      = uicontrol(gcf,'Style','edit', 'Position',[10 pos(4)-180 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl','Enable','off');
set(handles.GUIHandles.EditInterpdx,'Max',1);
set(handles.GUIHandles.EditInterpdx,'String',handles.Model(md).Input.Interpdx);
set(handles.GUIHandles.EditInterpdx,'CallBack',{@EditInterpdx_CallBack});
% listfield interpolation
handles.Model(md).Input.Interptype={'linear','cubic','spline'};
handles.GUIHandles.TextGeneration2   = uicontrol(gcf,'Style','text','String','Interp. method :','Position',[10 pos(4)-200 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Interptype        = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[10 pos(4)-220 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl','Enable','off');
set(handles.GUIHandles.Interptype,'Max',1);
set(handles.GUIHandles.Interptype,'String',handles.Model(md).Input.Interptype);
set(handles.GUIHandles.Interptype,'CallBack',{@Interptype_CallBack});

%% ACTIONS
% push button
setHandles(handles);
handles.GUIHandles.Textaction        = uicontrol(gcf,'Style','text','String','------Actions------','Position',[10 pos(4)-255 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Editprofile       = uicontrol(gcf,'Style','pushbutton','String','Perform action','Position',[10 pos(4)-280 90 20],'Tag','UIControl');
set(handles.GUIHandles.Editprofile,'CallBack',{@Editprofile_CallBack});
% push button
setHandles(handles);
handles.GUIHandles.Undo          = uicontrol(gcf,'Style','pushbutton',  'String','Undo 1 step','Position',[10 pos(4)-310 90 20],'Tag','UIControl');
set(handles.GUIHandles.Undo,'CallBack',{@Undo_CallBack});

%% QUIT
handles.GUIHandles.Textquit          = uicontrol(gcf,'Style','text','String','-------------------','Position',[10 pos(4)-355 90 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.Menuquit          = uicontrol(gcf,'Style','pushbutton','String','OK (quit+save)','Position',[10 pos(4)-380 90 20],'Tag','UIControl');
handles.GUIHandles.Menucancel        = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[10 pos(4)-410 90 20],'Tag','UIControl');
set(handles.GUIHandles.Menuquit,'CallBack',{@Menuquit_CallBack});
set(handles.GUIHandles.Menucancel,'CallBack',{@Menucancel_CallBack});

function plotprofile
handles=getHandles;
axis(handles.Axes.ha);
cla(handles.Axes.ha);
legtxt={};
if length(handles.Model(md).Input.x)>1
    x0 = handles.Model(md).Input.x{1};
    y0 = handles.Model(md).Input.y{1};
    plot(x0,y0,'Color',[0.5 0.5 0.5],'LineStyle',':');hold on;
    legtxt{1}='initial cross-shore profile';
end
if length(handles.Model(md).Input.x)>2
    x1 = handles.Model(md).Input.x{length(handles.Model(md).Input.x)-1};
    y1 = handles.Model(md).Input.y{length(handles.Model(md).Input.y)-1};
    plot(x1,y1,'Color',[0 0 0.5],'LineStyle','--');hold on;
    legtxt{length(legtxt)+1}='previous iteration';
end
x2 = handles.Model(md).Input.x{length(handles.Model(md).Input.x)};
y2 = handles.Model(md).Input.y{length(handles.Model(md).Input.y)};
plot(x2,y2,'Color',[1 0 0],'LineStyle','-');hold on;plot(x2,y2,'Color',[1 0 0],'LineStyle','.');
if length(handles.Model(md).Input.x)>1
    legtxt{length(legtxt)+1}='current profile';
else 
    legtxt={'initial cross-shore profile'};
end
legend(legtxt);
xlabel('Cross-shore position');
ylabel('Bed level [m w.r.t reference level]');
setHandles(handles);

function EditThinfactor_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Thinfactor=get(hObject,'String');
setHandles(handles);

function EditInterpdx_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Interpdx=get(hObject,'String');
setHandles(handles);

function Smoothtype_CallBack(hObject,eventdata)
handles=getHandles;
Smoothtypeval=get(hObject,'value');
set(handles.GUIHandles.Smoothtype,'Value',Smoothtypeval);
if Smoothtypeval==1
    set(handles.GUIHandles.Interptype,'Enable','off');
    set(handles.GUIHandles.EditInterpdx,'Enable','off');
    set(handles.GUIHandles.EditThinfactor,'Enable','on');
elseif Smoothtypeval==2
    set(handles.GUIHandles.EditThinfactor,'Enable','off');
    set(handles.GUIHandles.Interptype,'Enable','on');
    set(handles.GUIHandles.EditInterpdx,'Enable','on');
end
setHandles(handles);

function Interptype_CallBack(hObject,eventdata)
handles=getHandles;
Interptypeval=get(hObject,'value');
set(handles.GUIHandles.Interptype,'Value',Interptypeval);
setHandles(handles);

function Undo_CallBack(hObject,eventdata)
handles=getHandles;
nrsteps = length(handles.Model(md).Input.x);
if nrsteps>=2
    handles.Model(md).Input.x = handles.Model(md).Input.x(1:nrsteps-1);
    handles.Model(md).Input.y = handles.Model(md).Input.y(1:nrsteps-1);
    setHandles(handles);
    plotprofile;
end


function Editprofile_CallBack(hObject,eventdata)
handles=getHandles;
Smoothtype = get(handles.GUIHandles.Smoothtype,'Value');
Thinfactor = handles.Model(md).Input.Thinfactor;
Interptype = get(handles.GUIHandles.Interptype,'Value');
Interpdx   = handles.Model(md).Input.Interpdx;

x0 = handles.Model(md).Input.x{1};
y0 = handles.Model(md).Input.y{1};
x1 = handles.Model(md).Input.x{length(handles.Model(md).Input.x)};
y1 = handles.Model(md).Input.y{length(handles.Model(md).Input.y)};
x2 = x1;
y2 = y1;
if Smoothtype==1
    if ~isnumeric(Thinfactor)
        Thinfactor = str2num(handles.Model(md).Input.Thinfactor);
        if isempty(Thinfactor)
            fprintf('Warning : Thinfactor is not a number!')
            Thinfactor = 1;
        end
    end
    x2=x1(1:Thinfactor:end);
    y2=y1(1:Thinfactor:end);
elseif Smoothtype==2
    if ~isnumeric(Interpdx)
        Interpdx = str2num(handles.Model(md).Input.Interpdx);
        if isempty(Interpdx)
            fprintf('Warning : Interpdx is not a number!')
            Interpdx = 1;
        end
    end
    x2=[x1(1):Interpdx:x1(end)];
    if length(x2)==1;x2=[x1(1),x1(end)];end
    y2=interp1(x1,y1,x2,handles.Model(md).Input.Interptype{Interptype});
end
handles.Model(md).Input.x{length(handles.Model(md).Input.x)+1}=x2;
handles.Model(md).Input.y{length(handles.Model(md).Input.y)+1}=y2;
setHandles(handles);
plotprofile;

function Menuquit_CallBack(hObject,eventdata)
handles=getHandles;
%% save data
rmfield(handles.GUIHandles,'Profigure');
close(handles.GUIHandles.Profigure);
setHandles(handles);


function Menucancel_CallBack(hObject,eventdata)
handles=getHandles;
rmfield(handles.GUIHandles,'Profigure');
close(handles.GUIHandles.Profigure);
setHandles(handles);