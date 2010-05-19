function ddb_editD3DFlowThinDams

ddb_refreshScreen('Domain','Thin Dams');
handles=getHandles;

uipanel('Title','','Units','pixels','Position',[220 30 170 90],'Tag','UIControl');
handles.GUIHandles.ListThinDams     = uicontrol(gcf,'Style','listbox','Position',[60 30 150 105],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListThinDams = uicontrol(gcf,'Style','text','String','Thin Dams', 'Position',[60 137 150 15],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.EditThdM1    = uicontrol(gcf,'Style','edit','Position',[250  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThdN1    = uicontrol(gcf,'Style','edit','Position',[330  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThdM2    = uicontrol(gcf,'Style','edit','Position',[250  60  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThdN2    = uicontrol(gcf,'Style','edit','Position',[330  60  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[225  86 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[305  86 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[225  56 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[305  56 20 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.ToggleU = uicontrol(gcf,'Style','radiobutton', 'String','U','Position',[310 35 30 20],'Tag','UIControl');
handles.GUIHandles.ToggleV = uicontrol(gcf,'Style','radiobutton', 'String','V','Position',[345 35 30 20],'Tag','UIControl');
handles.GUIHandles.TextDirection    = uicontrol(gcf,'Style','text','String','Direction','Position',[240 32 60 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushAddThinDam    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[410 105 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteThinDam = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[410  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeThinDam = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[410  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectThinDam = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[410  30 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenThinDams = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[500  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushSaveThinDams = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[500  55 70 20],'Tag','UIControl');
handles.GUIHandles.TextThdFile       = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).ThdFile],'Position',[500 27 300 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListThinDams,      'CallBack',{@ListThinDams_CallBack});
set(handles.GUIHandles.EditThdM1,         'CallBack',{@EditThdM1_CallBack});
set(handles.GUIHandles.EditThdN1,         'CallBack',{@EditThdN1_CallBack});
set(handles.GUIHandles.EditThdM2,         'CallBack',{@EditThdM2_CallBack});
set(handles.GUIHandles.EditThdN2,         'CallBack',{@EditThdN2_CallBack});
set(handles.GUIHandles.ToggleU,           'CallBack',{@ToggleU_CallBack});
set(handles.GUIHandles.ToggleV,           'CallBack',{@ToggleV_CallBack});
set(handles.GUIHandles.PushAddThinDam,    'CallBack',{@PushAddThinDam_CallBack});
set(handles.GUIHandles.PushDeleteThinDam, 'CallBack',{@PushDeleteThinDam_CallBack});
set(handles.GUIHandles.PushChangeThinDam, 'CallBack',{@PushChangeThinDam_CallBack});
set(handles.GUIHandles.PushSelectThinDam, 'CallBack',{@PushSelectThinDam_CallBack});
set(handles.GUIHandles.PushOpenThinDams,  'CallBack',{@PushOpenThinDams_CallBack});
set(handles.GUIHandles.PushSaveThinDams,  'CallBack',{@PushSaveThinDams_CallBack});

set(handles.GUIHandles.PushChangeThinDam,'Enable','off');

handles.GUIData.DeleteSelectedThinDam=0;

RefreshThinDams(handles);

if handles.Model(md).Input(ad).NrThinDams>0
    ddb_plotFlowAttributes(handles,'ThinDams','activate',ad,0,handles.GUIData.ActiveOpenBoundary);
end

SetUIBackgroundColors;

setHandles(handles);

%%
function ListThinDams_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveThinDam=get(hObject,'Value');
n=handles.GUIData.ActiveThinDam;
RefreshThinDams(handles);
handles.GUIData.DeleteSelectedThinDam=1;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','activate',ad,0,handles.GUIData.ActiveThinDam);

%%
function EditThdM1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
handles.Model(md).Input(ad).ThinDams(n).M1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).ThinDams(n).Name=['(' num2str(handles.Model(md).Input(ad).ThinDams(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).M2) ',' num2str(handles.Model(md).Input(ad).ThinDams(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrThinDams
    str{k}=handles.Model(md).Input(ad).ThinDams(k).Name;
end
set(handles.ListThinDams,'String',str);
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function EditThdM2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
handles.Model(md).Input(ad).ThinDams(n).M2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).ThinDams(n).Name=['(' num2str(handles.Model(md).Input(ad).ThinDams(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).M2) ',' num2str(handles.Model(md).Input(ad).ThinDams(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrThinDams
    str{k}=handles.Model(md).Input(ad).ThinDams(k).Name;
end
set(handles.ListThinDams,'String',str);
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function EditThdN1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
handles.Model(md).Input(ad).ThinDams(n).N1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).ThinDams(n).Name=['(' num2str(handles.Model(md).Input(ad).ThinDams(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).M2) ',' num2str(handles.Model(md).Input(ad).ThinDams(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrThinDams
    str{k}=handles.Model(md).Input(ad).ThinDams(k).Name;
end
set(handles.ListThinDams,'String',str);
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function EditThdN2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
handles.Model(md).Input(ad).ThinDams(n).N2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).ThinDams(n).Name=['(' num2str(handles.Model(md).Input(ad).ThinDams(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).ThinDams(n).M2) ',' num2str(handles.Model(md).Input(ad).ThinDams(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrThinDams
    str{k}=handles.Model(md).Input(ad).ThinDams(k).Name;
end
set(handles.ListThinDams,'String',str);
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function ToggleU_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleV,'Value',0);
    handles.Model(md).Input(ad).ThinDams(n).UV='U';
else
    set(handles.GUIHandles.ToggleV,'Value',1);
    handles.Model(md).Input(ad).ThinDams(n).UV='V';
end    
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function ToggleV_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListThinDams,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleU,'Value',0);
    handles.Model(md).Input(ad).ThinDams(n).UV='V';
else
    set(handles.GUIHandles.ToggleU,'Value',1);
    handles.Model(md).Input(ad).ThinDams(n).UV='U';
end    
handles.GUIData.DeleteSelectedThinDam=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,n,n);

%%
function PushAddThinDam_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@AddThinDam,'gridline'});

%%
function PushDeleteThinDam_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedThinDam==1 && handles.Model(md).Input(ad).NrThinDams>0
    handles=DeleteThinDam(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'ThinDam',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveThinDam=ii;
set(handles.GUIHandles.ListThinDams,'Value',ii);
handles=DeleteThinDam(handles);
setHandles(handles);

%%
function PushChangeThinDam_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='c';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectThinDam});

%%
function PushSelectThinDam_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='s';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectThinDam});

%%
function PushOpenThinDams_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.thd', 'Select Thin Dams File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).ThdFile=filename;
    handles.Model(md).Input(ad).ThinDams=[];
    handles=ddb_readThdFile(handles);
    handles.GUIData.ActiveThinDam=1;
    set(handles.GUIHandles.TextThdFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedThinDam=0;
    RefreshThinDams(handles);
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,0,1);
end

%%
function PushSaveThinDams_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.thd', 'Select Thin Dams File',handles.Model(md).Input(ad).ThdFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).ThdFile=filename;
    ddb_saveThdFile(handles,ad);
    set(handles.GUIHandles.TextThdFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedThinDam=0;
    setHandles(handles);
end

%%
function SelectThinDam(hObject,eventdata)
handles=getHandles;
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');
id=ad;
if posx>=xlim(1) && posx<=xlim(2) && posy>=ylim(1) && posy<=ylim(2)
    [m,n,uv]=FindGridLine(posx,posy,handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY);
    if m>0
        for i=1:handles.Model(md).Input(id).NrThinDams
            m1=handles.Model(md).Input(id).ThinDams(i).M1;
            n1=handles.Model(md).Input(id).ThinDams(i).N1;
            m2=handles.Model(md).Input(id).ThinDams(i).M2;
            n2=handles.Model(md).Input(id).ThinDams(i).N2;
            if ( m2==m1 && m==m1 && ((n<=n2 && n>=n1) || (n<=n1 && n>=n2)) ) || ...
                    ( n2==n1 && n==n1 && ((m<=m2 && m>=m1) || (m<=m1 && m>=m2)) )
                if uv==1 && strcmpi(handles.Model(md).Input(id).ThinDams(i).UV,'v') || ...
                        uv==0 && strcmpi(handles.Model(md).Input(id).ThinDams(i).UV,'u')
                    handles.GUIData.ActiveThinDam=i;
                    RefreshThinDams(handles);
                    handles.GUIData.DeleteSelectedThinDam=0;
                    setHandles(handles);
                    if handles.Mode=='c'
                        ddb_plotFlowAttributes(handles,'ThinDams','activate',ad,i,i);
                        set(gcf,'windowbuttondownfcn',{@DragLine,@AddThinDam});
                    elseif handles.Mode=='s'
                        ddb_plotFlowAttributes(handles,'ThinDams','activate',ad,i,i);
                    elseif handles.Mode=='d'
                        handles=DeleteThinDam(handles);
                    end
                    break
                end
            end
        end
    end
end
setHandles(handles);

%%
function AddThinDam(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;
if x1==x2 && y1==y2
    [m1,n1,uv]=FindGridLine(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
    m2=m1;
    n2=n1;
else
    [m1,n1]=FindCornerPoint(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
    [m2,n2]=FindCornerPoint(x2,y2,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
end
if m1>0 && (m1==m2 || n1==n2)
    if handles.Mode=='a'
        nrthd=handles.Model(md).Input(ad).NrThinDams+1;
        handles.Model(md).Input(ad).NrThinDams=nrthd;
    elseif handles.Mode=='c'
        nrthd=handles.GUIData.ActiveThinDam;
    end
    if x1==x2 && y1==y2
        if uv==1
            handles.Model(md).Input(ad).ThinDams(nrthd).UV='V';
        else
            handles.Model(md).Input(ad).ThinDams(nrthd).UV='U';
        end            
    else
        if m2~=m1
            handles.Model(md).Input(ad).ThinDams(nrthd).UV='V';
        else
            handles.Model(md).Input(ad).ThinDams(nrthd).UV='U';
        end
    end
    if m2>m1
        m1=m1+1;
    end
    if m2<m1
        m2=m2+1;
    end
    if n2>n1
        n1=n1+1;
    end
    if n1>n2
        n2=n2+1;
    end
    handles.Model(md).Input(ad).NrThinDams=nrthd;
    handles.Model(md).Input(ad).ThinDams(nrthd).M1=m1;
    handles.Model(md).Input(ad).ThinDams(nrthd).N1=n1;
    handles.Model(md).Input(ad).ThinDams(nrthd).M2=m2;
    handles.Model(md).Input(ad).ThinDams(nrthd).N2=n2;
    handles.Model(md).Input(ad).ThinDams(nrthd).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.GUIData.ActiveThinDam=nrthd;
    RefreshThinDams(handles);
    handles.GUIData.DeleteSelectedThinDam=0;
    setHandles(handles);
    if handles.Mode=='a'
        ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,nrthd,nrthd);
    elseif handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,nrthd,nrthd);
        set(gcf, 'windowbuttondownfcn',   {@SelectThinDam});
    end
end
setHandles(handles);

%%
function handles=DeleteThinDam(handles)

id=ad;
nrthd=handles.Model(md).Input(id).NrThinDams;

i=handles.GUIData.ActiveThinDam;

iacnew=handles.GUIData.ActiveThinDam;
if iacnew==nrthd
    iacnew=nrthd-1;
end
ddb_plotFlowAttributes(handles,'ThinDams','delete',id,handles.GUIData.ActiveThinDam,iacnew);

if nrthd>1
    for j=i:nrthd-1
        handles.Model(md).Input(id).ThinDams(j)=handles.Model(md).Input(id).ThinDams(j+1);
    end
    handles.Model(md).Input(id).ThinDams=handles.Model(md).Input(id).ThinDams(1:end-1);
else
    handles.Model(md).Input(id).ThinDams=[];
end
handles.Model(md).Input(id).NrThinDams=handles.Model(md).Input(id).NrThinDams-1;
if handles.Model(md).Input(id).NrThinDams>0
    if handles.GUIData.ActiveThinDam==handles.Model(md).Input(id).NrThinDams+1
        handles.GUIData.ActiveThinDam-1;
    end
end

RefreshThinDams(handles);

%%
function RefreshThinDams(handles)

id=ad;
nr=handles.Model(md).Input(id).NrThinDams;
n=handles.GUIData.ActiveThinDam;
if nr>0
    for k=1:nr
        str{k}=handles.Model(md).Input(id).ThinDams(k).Name;
    end
    set(handles.GUIHandles.ListThinDams,'Value',n);
    set(handles.GUIHandles.ListThinDams,'String',str);
    set(handles.GUIHandles.EditThdM1,'String',handles.Model(md).Input(id).ThinDams(n).M1);
    set(handles.GUIHandles.EditThdN1,'String',handles.Model(md).Input(id).ThinDams(n).N1);
    set(handles.GUIHandles.EditThdM2,'String',handles.Model(md).Input(id).ThinDams(n).M2);
    set(handles.GUIHandles.EditThdN2,'String',handles.Model(md).Input(id).ThinDams(n).N2);
    if strcmpi(handles.Model(md).Input(id).ThinDams(n).UV,'u')
        set(handles.GUIHandles.ToggleU,'Value',1);
        set(handles.GUIHandles.ToggleV,'Value',0);
    else
        set(handles.GUIHandles.ToggleU,'Value',0);
        set(handles.GUIHandles.ToggleV,'Value',1);
    end
    set(handles.GUIHandles.EditThdM1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditThdN1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditThdM2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditThdN2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.ToggleU,  'Enable','on');
    set(handles.GUIHandles.ToggleV,  'Enable','on');
    set(handles.GUIHandles.TextM1,   'Enable','on');
    set(handles.GUIHandles.TextN1,   'Enable','on');
    set(handles.GUIHandles.TextM2,   'Enable','on');
    set(handles.GUIHandles.TextN2,   'Enable','on');
    set(handles.GUIHandles.TextDirection,   'Enable','on');
else
    set(handles.GUIHandles.EditThdM1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditThdN1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditThdM2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditThdN2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.ToggleU,  'Enable','off');
    set(handles.GUIHandles.ToggleV,  'Enable','off');
    set(handles.GUIHandles.TextM1,   'Enable','off');
    set(handles.GUIHandles.TextN1,   'Enable','off');
    set(handles.GUIHandles.TextM2,   'Enable','off');
    set(handles.GUIHandles.TextN2,   'Enable','off');
    set(handles.GUIHandles.TextDirection,   'Enable','off');
    set(handles.GUIHandles.ListThinDams,'String','');
    set(handles.GUIHandles.ListThinDams,'Value',1);
    set(handles.GUIHandles.EditThdM1,'String',[]);
    set(handles.GUIHandles.EditThdN1,'String',[]);
    set(handles.GUIHandles.EditThdM2,'String',[]);
    set(handles.GUIHandles.EditThdN2,'String',[]);
    set(handles.GUIHandles.ToggleU,'Value',0);
    set(handles.GUIHandles.ToggleV,'Value',0);
end

