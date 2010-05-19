function ddb_editD3DFlowCrossSections

ddb_refreshScreen('Domain','Cross Sections');
handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

uipanel('Title','','Units','pixels','Position',[220 30 170 105],'Tag','UIControl');
handles.GUIHandles.ListCrossSections     = uicontrol(gcf,'Style','listbox','Position',[60 30 150 105],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListCrossSections = uicontrol(gcf,'Style','text','String','Cross Sections', 'Position',[60 137 150 15],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.EditCrsM1    = uicontrol(gcf,'Style','edit','Position',[250 105  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditCrsN1    = uicontrol(gcf,'Style','edit','Position',[330 105  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditCrsM2    = uicontrol(gcf,'Style','edit','Position',[250  75  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditCrsN2    = uicontrol(gcf,'Style','edit','Position',[330  75  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditName     = uicontrol(gcf,'Style','edit','Position',[265  45 115 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[225 101 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[305 101 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[225  71 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[305  71 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextName  = uicontrol(gcf,'Style','text','String','Name',    'Position',[230  41 30 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushAddCrossSection    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[410 105 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteCrossSection = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[410  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeCrossSection = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[410  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectCrossSection = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[410  30 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenCrossSections = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[500  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushSaveCrossSections = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[500  55 70 20],'Tag','UIControl');
handles.GUIHandles.TextCrsFile       = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).CrsFile],'Position',[500 27 300 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListCrossSections,      'CallBack',{@ListCrossSections_CallBack});
set(handles.GUIHandles.EditCrsM1,         'CallBack',{@EditCrsM1_CallBack});
set(handles.GUIHandles.EditCrsN1,         'CallBack',{@EditCrsN1_CallBack});
set(handles.GUIHandles.EditCrsM2,         'CallBack',{@EditCrsM2_CallBack});
set(handles.GUIHandles.EditCrsN2,         'CallBack',{@EditCrsN2_CallBack});
set(handles.GUIHandles.EditName,          'CallBack',{@EditName_CallBack});
set(handles.GUIHandles.PushAddCrossSection,    'CallBack',{@PushAddCrossSection_CallBack});
set(handles.GUIHandles.PushDeleteCrossSection, 'CallBack',{@PushDeleteCrossSection_CallBack});
set(handles.GUIHandles.PushChangeCrossSection, 'CallBack',{@PushChangeCrossSection_CallBack});
set(handles.GUIHandles.PushSelectCrossSection, 'CallBack',{@PushSelectCrossSection_CallBack});
set(handles.GUIHandles.PushOpenCrossSections,  'CallBack',{@PushOpenCrossSections_CallBack});
set(handles.GUIHandles.PushSaveCrossSections,  'CallBack',{@PushSaveCrossSections_CallBack});

set(handles.GUIHandles.PushChangeCrossSection,'Enable','off');

handles.GUIData.DeleteSelectedCrossSection=0;

RefreshCrossSections(handles);

if handles.Model(md).Input(ad).NrCrossSections>0
    ddb_plotFlowAttributes(handles,'CrossSections','activate',ad,0,handles.GUIData.ActiveOpenBoundary);
end

SetUIBackgroundColors;

setHandles(handles);

%%
function ListCrossSections_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveCrossSection=get(hObject,'Value');
RefreshCrossSections(handles);
handles.GUIData.DeleteSelectedCrossSection=1;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','activate',ad,0,handles.GUIData.ActiveCrossSection);

%%
function EditCrsM1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListCrossSections,'Value');
handles.Model(md).Input(ad).CrossSections(n).M1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).CrossSections(n).Name=['(' num2str(handles.Model(md).Input(ad).CrossSections(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).M2) ',' num2str(handles.Model(md).Input(ad).CrossSections(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrCrossSections
    str{k}=handles.Model(md).Input(ad).CrossSections(k).Name;
end
set(handles.GUIHandles.ListCrossSections,'String',str);
handles.GUIData.DeleteSelectedCrossSection=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,n,n);

%%
function EditCrsM2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListCrossSections,'Value');
handles.Model(md).Input(ad).CrossSections(n).M2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).CrossSections(n).Name=['(' num2str(handles.Model(md).Input(ad).CrossSections(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).M2) ',' num2str(handles.Model(md).Input(ad).CrossSections(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrCrossSections
    str{k}=handles.Model(md).Input(ad).CrossSections(k).Name;
end
set(handles.GUIHandles.ListCrossSections,'String',str);
handles.GUIData.DeleteSelectedCrossSection=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,n,n);

%%
function EditCrsN1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListCrossSections,'Value');
handles.Model(md).Input(ad).CrossSections(n).N1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).CrossSections(n).Name=['(' num2str(handles.Model(md).Input(ad).CrossSections(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).M2) ',' num2str(handles.Model(md).Input(ad).CrossSections(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrCrossSections
    str{k}=handles.Model(md).Input(ad).CrossSections(k).Name;
end
set(handles.GUIHandles.ListCrossSections,'String',str);
handles.GUIData.DeleteSelectedCrossSection=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,n,n);

%%
function EditCrsN2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListCrossSections,'Value');
handles.Model(md).Input(ad).CrossSections(n).N2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).CrossSections(n).Name=['(' num2str(handles.Model(md).Input(ad).CrossSections(n).M1) ',' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).N1) ')...(' ...
    num2str(handles.Model(md).Input(ad).CrossSections(n).M2) ',' num2str(handles.Model(md).Input(ad).CrossSections(n).N2) ')'];
for k=1:handles.Model(md).Input(ad).NrCrossSections
    str{k}=handles.Model(md).Input(ad).CrossSections(k).Name;
end
set(handles.GUIHandles.ListCrossSections,'String',str);
handles.GUIData.DeleteSelectedCrossSection=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,n,n);

%%
function EditName_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListCrossSections,'Value');
handles.Model(md).Input(ad).CrossSections(n).Name=get(hObject,'String');
RefreshCrossSections(handles);
handles.GUIData.DeleteSelectedCrossSection=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,n,n);

%%
function PushAddCrossSection_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@AddCrossSection,'gridline'});

%%
function PushDeleteCrossSection_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedCrossSection==1 && handles.Model(md).Input(ad).NrCrossSections>0
    handles=DeleteCrossSection(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'CrossSection',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveCrossSection=ii;
set(handles.GUIHandles.ListCrossSections,'Value',ii);
handles=DeleteCrossSection(handles);
setHandles(handles);

%%
function PushChangeCrossSection_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='c';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectCrossSection});

%%
function PushSelectCrossSection_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='s';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectCrossSection});

%%
function PushOpenCrossSections_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.crs', 'Select Thin Dams File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).CrsFile=filename;
    handles.Model(md).Input(ad).CrossSections=[];
    handles=ddb_readCrsFile(handles);
    handles.GUIData.ActiveCrossSection=1;
    set(handles.GUIHandles.TextCrsFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedCrossSection=0;
    RefreshCrossSections(handles);
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,0,1);
    ddb_setWindowButtonUpDownFcn;
end

%%
function PushSaveCrossSections_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.crs', 'Select Thin Dams File',handles.Model(md).Input(ad).CrsFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).CrsFile=filename;
    ddb_saveCrsFile(handles,ad);
    set(handles.GUIHandles.TextCrsFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedCrossSection=0;
    setHandles(handles);
end

%%
function SelectCrossSection(hObject,eventdata)

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
        for i=1:handles.Model(md).Input(id).NrCrossSections
            m1=handles.Model(md).Input(id).CrossSections(i).M1;
            n1=handles.Model(md).Input(id).CrossSections(i).N1;
            m2=handles.Model(md).Input(id).CrossSections(i).M2;
            n2=handles.Model(md).Input(id).CrossSections(i).N2;
            if ( m2==m1 && m==m1 && ((n<=n2 && n>=n1) || (n<=n1 && n>=n2)) ) || ...
                    ( n2==n1 && n==n1 && ((m<=m2 && m>=m1) || (m<=m1 && m>=m2)) )
                    handles.GUIData.ActiveCrossSection=i;
                    RefreshCrossSections(handles);
                    handles.GUIData.DeleteSelectedCrossSection=0;
                    setHandles(handles);
                    if handles.Mode=='c'
                        ddb_plotFlowAttributes(handles,'CrossSections','activate',ad,i,i);
                        set(gcf,'windowbuttondownfcn',{@DragLine,@AddCrossSection});
                    elseif handles.Mode=='s'
                        ddb_plotFlowAttributes(handles,'CrossSections','activate',ad,i,i);
                    elseif handles.Mode=='d'
                        handles=DeleteCrossSection(handles);
                    end
                    break
            end
        end
    end
end
setHandles(handles);

%%
function AddCrossSection(x,y)

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
        nrcrs=handles.Model(md).Input(ad).NrCrossSections+1;
        handles.Model(md).Input(ad).NrCrossSections=nrcrs;
    elseif handles.Mode=='c'
        nrcrs=handles.GUIData.ActiveCrossSection;
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
    handles.Model(md).Input(ad).NrCrossSections=nrcrs;
    handles.Model(md).Input(ad).CrossSections(nrcrs).M1=m1;
    handles.Model(md).Input(ad).CrossSections(nrcrs).N1=n1;
    handles.Model(md).Input(ad).CrossSections(nrcrs).M2=m2;
    handles.Model(md).Input(ad).CrossSections(nrcrs).N2=n2;
    handles.Model(md).Input(ad).CrossSections(nrcrs).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.GUIData.ActiveCrossSection=nrcrs;
    RefreshCrossSections(handles);
    handles.GUIData.DeleteSelectedCrossSection=0;
    setHandles(handles);
    if handles.Mode=='a'
        ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,nrcrs,nrcrs);
    elseif handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'CrossSections','plot',ad,nrcrs,nrcrs);
        set(gcf, 'windowbuttondownfcn',   {@SelectCrossSection});
    end
end
setHandles(handles);

%%
function handles=DeleteCrossSection(handles)

id=ad;
nrcrs=handles.Model(md).Input(id).NrCrossSections;
i=handles.GUIData.ActiveCrossSection;

iacnew=handles.GUIData.ActiveCrossSection;
if iacnew==nrcrs
    iacnew=nrcrs-1;
end
ddb_plotFlowAttributes(handles,'CrossSections','delete',id,handles.GUIData.ActiveCrossSection,iacnew);

if nrcrs>1
    for j=i:nrcrs-1
        handles.Model(md).Input(id).CrossSections(j)=handles.Model(md).Input(id).CrossSections(j+1);
    end
    handles.Model(md).Input(id).CrossSections=handles.Model(md).Input(id).CrossSections(1:end-1);
else
    handles.Model(md).Input(id).CrossSections=[];
end
handles.Model(md).Input(id).NrCrossSections=handles.Model(md).Input(id).NrCrossSections-1;
if handles.Model(md).Input(id).NrCrossSections>0
    if handles.GUIData.ActiveCrossSection==handles.Model(md).Input(id).NrCrossSections+1
        handles.GUIData.ActiveCrossSection=handles.GUIData.ActiveCrossSection-1;
    end
end
RefreshCrossSections(handles);

%%
function RefreshCrossSections(handles)

id=ad;
nr=handles.Model(md).Input(id).NrCrossSections;
n=handles.GUIData.ActiveCrossSection;
if nr>0
    for k=1:nr
        str{k}=handles.Model(md).Input(id).CrossSections(k).Name;
    end
    set(handles.GUIHandles.ListCrossSections,'String',str);
    set(handles.GUIHandles.ListCrossSections,'Value',n);
    set(handles.GUIHandles.EditName,'String',str{n});
    set(handles.GUIHandles.EditCrsM1,'String',handles.Model(md).Input(id).CrossSections(n).M1);
    set(handles.GUIHandles.EditCrsN1,'String',handles.Model(md).Input(id).CrossSections(n).N1);
    set(handles.GUIHandles.EditCrsM2,'String',handles.Model(md).Input(id).CrossSections(n).M2);
    set(handles.GUIHandles.EditCrsN2,'String',handles.Model(md).Input(id).CrossSections(n).N2);
    set(handles.GUIHandles.EditCrsM1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditCrsN1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditCrsM2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditCrsN2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextName, 'Enable','on');
    set(handles.GUIHandles.TextM1,   'Enable','on');
    set(handles.GUIHandles.TextN1,   'Enable','on');
    set(handles.GUIHandles.TextM2,   'Enable','on');
    set(handles.GUIHandles.TextN2,   'Enable','on');
else
    set(handles.GUIHandles.EditName, 'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditCrsM1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditCrsN1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditCrsM2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditCrsN2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextName, 'Enable','off');
    set(handles.GUIHandles.TextM1,   'Enable','off');
    set(handles.GUIHandles.TextN1,   'Enable','off');
    set(handles.GUIHandles.TextM2,   'Enable','off');
    set(handles.GUIHandles.TextN2,   'Enable','off');
    set(handles.GUIHandles.ListCrossSections,'String','');
    set(handles.GUIHandles.ListCrossSections,'Value',1);
    set(handles.GUIHandles.EditCrsM1,'String',[]);
    set(handles.GUIHandles.EditCrsN1,'String',[]);
    set(handles.GUIHandles.EditCrsM2,'String',[]);
    set(handles.GUIHandles.EditCrsN2,'String',[]);
end

