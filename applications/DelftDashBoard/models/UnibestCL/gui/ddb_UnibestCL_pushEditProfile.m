function ddb_UnibestCL_pushEditProfile(hObject,eventdata)

handles=getHandles;
% setUIElements(handles.Model(md).GUI.elements.tabs(3).elements.tabs(3).elements)

pr = handles.Model(md).Input.activePROfile;
if  pr>0
    PROdata = handles.Model(md).Input.PROdata(pr);
else
    fprintf('Error : No file selected.\n')
    return
end
pro = handles.Model(md).Input.PROdata;
nrpro = length(pro);
for ii=1:nrpro
    ProHandles.Input.x{ii} = {pro(ii).x};
    ProHandles.Input.z{ii} = {pro(ii).z};
end
ProHandles.Input.pr=pr;
ProHandles.Input.nrpro=nrpro;
ProHandles.Input.pro=pro;

ProHandles.GUI.figure = MakeNewWindow('Edit Profiles',[1000,500]);
pos = get(gcf,'Position');
hp = uipanel('Units','pixels','Position',[5 5 100 pos(4)-10],'Tag','UIControl');

pixelsxlabel=45;
pixelsylabel=35;

xrel1 = (105+pixelsxlabel)/pos(3);
xrel2 = (pos(3)-105-pixelsxlabel*1.5)/pos(3);
yrel1 = (pixelsylabel)/pos(4);
yrel2 = (pos(4)-pixelsylabel*1.5)/pos(4);

ProHandles.Axes.ha = axes('Position',[xrel1,yrel1,xrel2,yrel2],'FontSize',8);
%plot(ProHandles.Input.x{pr}{1},ProHandles.Input.z{pr}{1},'k.-');hold on;
setProHandles(ProHandles);
plotprofile;

%% SELECTION
%listfield
ProHandles.Input.Smoothtype={'Thinning','Interpolation'};
ProHandles.GUI.TextGeneration   = uicontrol(gcf,'Style','text','String','Action :','Position',[10 pos(4)-25 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.Smoothtype       = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[10 pos(4)-45 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(ProHandles.GUI.Smoothtype,'Max',1);
set(ProHandles.GUI.Smoothtype,'String',ProHandles.Input.Smoothtype);
set(ProHandles.GUI.Smoothtype,'CallBack',{@Smoothtype_CallBack});

%% THINNING
% field thinning
ProHandles.Input.Thinfactor = 1;
ProHandles.GUI.TextThinning        = uicontrol(gcf,'Style','text','String','-----Thinning-----','Position',[10 pos(4)-75 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.TextThinfactor      = uicontrol(gcf,'Style','text','String','Thin factor :','Position',[10 pos(4)-90 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.EditThinfactor      = uicontrol(gcf,'Style','edit', 'Position',[10 pos(4)-110 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(ProHandles.GUI.EditThinfactor,'Max',1);
set(ProHandles.GUI.EditThinfactor,'String',ProHandles.Input.Thinfactor);
set(ProHandles.GUI.EditThinfactor,'CallBack',{@EditThinfactor_CallBack});

%% INTERPOLATION
% field interpolation
ProHandles.Input.Interpdx = 1;
ProHandles.GUI.TextInterp        = uicontrol(gcf,'Style','text','String','---Interpolation---','Position',[10 pos(4)-145 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.TextInterpdx      = uicontrol(gcf,'Style','text','String','Interp. dx :','Position',[10 pos(4)-160 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.EditInterpdx      = uicontrol(gcf,'Style','edit', 'Position',[10 pos(4)-180 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl','Enable','off');
set(ProHandles.GUI.EditInterpdx,'Max',1);
set(ProHandles.GUI.EditInterpdx,'String',ProHandles.Input.Interpdx);
set(ProHandles.GUI.EditInterpdx,'CallBack',{@EditInterpdx_CallBack});
% listfield interpolation
ProHandles.Input.Interptype={'linear','cubic','spline'};
ProHandles.GUI.TextGeneration2   = uicontrol(gcf,'Style','text','String','Interp. method :','Position',[10 pos(4)-200 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.Interptype        = uicontrol(gcf,'Style','popupmenu','String',' ','Position',[10 pos(4)-220 90 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl','Enable','off');
set(ProHandles.GUI.Interptype,'Max',1);
set(ProHandles.GUI.Interptype,'String',ProHandles.Input.Interptype);
set(ProHandles.GUI.Interptype,'CallBack',{@Interptype_CallBack});

%% ACTIONS
% push button
setProHandles(ProHandles);
ProHandles.GUI.Textaction        = uicontrol(gcf,'Style','text','String','------Actions------','Position',[10 pos(4)-255 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.Editprofile       = uicontrol(gcf,'Style','pushbutton','String','Perform action','Position',[10 pos(4)-280 90 20],'Tag','UIControl');
set(ProHandles.GUI.Editprofile,'CallBack',{@Editprofile_CallBack});
% push button
setProHandles(ProHandles);
ProHandles.GUI.Undo          = uicontrol(gcf,'Style','pushbutton',  'String','Undo 1 step','Position',[10 pos(4)-310 90 20],'Tag','UIControl');
set(ProHandles.GUI.Undo,'CallBack',{@Undo_CallBack});

%% QUIT
ProHandles.GUI.Textquit          = uicontrol(gcf,'Style','text','String','-------------------','Position',[10 pos(4)-355 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.Menuquit          = uicontrol(gcf,'Style','pushbutton','String','OK (quit+save)','Position',[10 pos(4)-380 90 20],'Tag','UIControl');
ProHandles.GUI.Menucancel        = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[10 pos(4)-410 90 20],'Tag','UIControl');
set(ProHandles.GUI.Menuquit,'CallBack',{@Menuquit_CallBack});
set(ProHandles.GUI.Menucancel,'CallBack',{@Menucancel_CallBack});

%% SCROLL BUTTONS
% push buttons
setProHandles(ProHandles);
ProHandles.GUI.Textscroll        = uicontrol(gcf,'Style','text','String','-------Scroll-------','Position',[10 pos(4)-455 90 15],'HorizontalAlignment','left','Tag','UIControl');
ProHandles.GUI.PrevPRO       = uicontrol(gcf,'Style','pushbutton','String','<Prev','Position',[10 pos(4)-480 40 20],'Tag','UIControl');
ProHandles.GUI.NextPRO       = uicontrol(gcf,'Style','pushbutton',  'String','Next>','Position',[60 pos(4)-480 40 20],'Tag','UIControl');
set(ProHandles.GUI.PrevPRO,'CallBack',{@PrevPRO_CallBack}); set(ProHandles.GUI.NextPRO,'CallBack',{@NextPRO_CallBack});

function plotprofile
ProHandles=getProHandles;pr=ProHandles.Input.pr;
axis(ProHandles.Axes.ha);
cla(ProHandles.Axes.ha);
legtxt={};
if length(ProHandles.Input.x{pr})>1
    x0 = ProHandles.Input.x{pr}{1};
    z0 = ProHandles.Input.z{pr}{1};
    plot(x0,z0,'Color',[0.5 0.5 0.5],'LineStyle',':');hold on;
    legtxt{1}='initial cross-shore profile';
end
if length(ProHandles.Input.x{pr})>2
    x1 = ProHandles.Input.x{pr}{length(ProHandles.Input.x{pr})-1};
    z1 = ProHandles.Input.z{pr}{length(ProHandles.Input.z{pr})-1};
    plot(x1,z1,'Color',[0 0 0.5],'LineStyle','--');hold on;
    legtxt{length(legtxt)+1}='previous iteration';
end
x2 = ProHandles.Input.x{pr}{length(ProHandles.Input.x{pr})};
z2 = ProHandles.Input.z{pr}{length(ProHandles.Input.z{pr})};
plot(x2,z2,'Color',[1 0 0],'LineStyle','-');hold on;plot(x2,z2,'Color',[1 0 0],'LineStyle','.');
if length(ProHandles.Input.x{pr})>1
    legtxt{length(legtxt)+1}='current profile';
else 
    legtxt={'initial cross-shore profile'};
end
legend(legtxt,'Location','NorthWest');
xlabel('Cross-shore position');
ylabel('Bed level [m w.r.t reference level]');
title([ProHandles.Input.pro(pr).Rayname,'.pro']);
setProHandles(ProHandles);

function EditThinfactor_CallBack(hObject,eventdata)
ProHandles=getProHandles;
ProHandles.Input.Thinfactor=get(hObject,'String');
setProHandles(ProHandles);

function EditInterpdx_CallBack(hObject,eventdata)
ProHandles=getProHandles;
ProHandles.Input.Interpdx=get(hObject,'String');
setProHandles(ProHandles);

function Smoothtype_CallBack(hObject,eventdata)
ProHandles=getProHandles;
Smoothtypeval=get(hObject,'value');
set(ProHandles.GUI.Smoothtype,'Value',Smoothtypeval);
if Smoothtypeval==1
    set(ProHandles.GUI.Interptype,'Enable','off');
    set(ProHandles.GUI.EditInterpdx,'Enable','off');
    set(ProHandles.GUI.EditThinfactor,'Enable','on');
elseif Smoothtypeval==2
    set(ProHandles.GUI.EditThinfactor,'Enable','off');
    set(ProHandles.GUI.Interptype,'Enable','on');
    set(ProHandles.GUI.EditInterpdx,'Enable','on');
end
setProHandles(ProHandles);

function Interptype_CallBack(hObject,eventdata)
ProHandles=getProHandles;
Interptypeval=get(hObject,'value');
set(ProHandles.GUI.Interptype,'Value',Interptypeval);
setProHandles(ProHandles);

function Undo_CallBack(hObject,eventdata)
ProHandles=getProHandles;pr=ProHandles.Input.pr;
nrsteps = length(ProHandles.Input.x{pr});
if nrsteps>=2
    ProHandles.Input.x{pr} = ProHandles.Input.x{pr}(1:nrsteps-1);
    ProHandles.Input.z{pr} = ProHandles.Input.z{pr}(1:nrsteps-1);
    setProHandles(ProHandles);
    plotprofile;
end

function Editprofile_CallBack(hObject,eventdata)
ProHandles=getProHandles;pr=ProHandles.Input.pr;
Smoothtype = get(ProHandles.GUI.Smoothtype,'Value');
Thinfactor = ProHandles.Input.Thinfactor;
Interptype = get(ProHandles.GUI.Interptype,'Value');
Interpdx   = ProHandles.Input.Interpdx;

x0 = ProHandles.Input.x{pr}{1};
z0 = ProHandles.Input.z{pr}{1};
x1 = ProHandles.Input.x{pr}{length(ProHandles.Input.x{pr})};
z1 = ProHandles.Input.z{pr}{length(ProHandles.Input.z{pr})};
x2 = x1;
z2 = z1;
if Smoothtype==1
    if ~isnumeric(Thinfactor)
        Thinfactor = str2num(ProHandles.Input.Thinfactor);
        if isempty(Thinfactor)
            fprintf('Warning : Thinfactor is not a number!')
            Thinfactor = 1;
        end
    end
    x2=unique([x1(1);x1(1:Thinfactor:end);x1(end)]);
    z2=unique([z1(1);z1(1:Thinfactor:end);z1(end)]); 
elseif Smoothtype==2
    if ~isnumeric(Interpdx)
        Interpdx = str2num(ProHandles.Input.Interpdx);
        if isempty(Interpdx)
            fprintf('Warning : Interpdx is not a number!')
            Interpdx = 1;
        end
    end
    x2=unique([min(x1(1),x1(end)),min(x1(1),x1(end)):Interpdx:max(x1(1),x1(end)),max(x1(1),x1(end))])';
    if length(x2)==1;x2=[x1(1);x1(end)];end
    z2=interp1(x1,z1,x2,ProHandles.Input.Interptype{Interptype});
end
ProHandles.Input.x{pr}{length(ProHandles.Input.x{pr})+1}=x2;
ProHandles.Input.z{pr}{length(ProHandles.Input.z{pr})+1}=z2;
setProHandles(ProHandles);
plotprofile;

function Menuquit_CallBack(hObject,eventdata)
ProHandles=getProHandles;pr=ProHandles.Input.pr;
%% save data
handles = getHandles;
pr =handles.Model(md).Input.activePROfile; 
handles.Model(md).Input.PROdata(pr).x = ProHandles.Input.x{pr}{length(ProHandles.Input.x{pr})};
handles.Model(md).Input.PROdata(pr).h = ProHandles.Input.z{pr}{length(ProHandles.Input.z{pr})}*(-1)+handles.Model(md).Input.PROdata(pr).waterlevel;%Convert bed level to water depth
x1          = handles.Model(md).Input.PROdata(pr).x;
h1          = handles.Model(md).Input.PROdata(pr).h;
Xid1        = handles.Model(md).Input.PROdata(pr).X1;
Yid1        = handles.Model(md).Input.PROdata(pr).Y1;
Xid2        = handles.Model(md).Input.PROdata(pr).X2;
Yid2        = handles.Model(md).Input.PROdata(pr).Y2;
h_dynbound  = handles.Model(md).Input.PROdata(pr).zdynbound*(-1)+handles.Model(md).Input.PROdata(pr).waterlevel;%Convert bed level to water depth;
water_level = handles.Model(md).Input.PROdata(pr).waterlevel;
filename    = handles.Model(md).Input.PROdata(pr).filename;
[err_message] = ddb_writePRO(x1,h1,h_dynbound,Xid1,Yid1,Xid2,Yid2,filename,water_level);
if ~isempty(err_message)
    fprintf(fid2,'%s\n',err_message);
end
setHandles(handles);

rmfield(ProHandles.GUI,'figure');
close(ProHandles.GUI.figure);
setProHandles(ProHandles);

function PrevPRO_CallBack(hObject,eventdata)
ProHandles = getProHandles;
pr=ProHandles.Input.pr;
nrpro=ProHandles.Input.nrpro; 
if  nrpro>1 && pr>1
    pr = pr-1;
    ProHandles.Input.pr=pr;
    setProHandles(ProHandles);
    plotprofile;
end

function NextPRO_CallBack(hObject,eventdata)
ProHandles = getProHandles;
pr=ProHandles.Input.pr;
nrpro=ProHandles.Input.nrpro; 
if  nrpro>1 && pr<nrpro
    pr = pr+1;
    ProHandles.Input.pr=pr;
    setProHandles(ProHandles);
    plotprofile;
end

function Menucancel_CallBack(hObject,eventdata)
ProHandles=getProHandles;
rmfield(ProHandles.GUI,'figure');
close(ProHandles.GUI.figure);
setProHandles(ProHandles);

function h=getProHandles
global ProProHandles
h=ProProHandles;

function setProHandles(h)
global ProProHandles
ProProHandles=h;