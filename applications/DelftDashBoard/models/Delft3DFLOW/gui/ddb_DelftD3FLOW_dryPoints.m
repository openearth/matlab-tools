function ddb_DelftD3FLOW_dryPoints(opt)

if isempty(opt)
    % Dry points tab selected
    ddb_refreshScreen2;
    if handles.Model(md).Input(ad).nrDryPoints>0
        ddb_Delft3DFLOW_plotAttributes('DryPoints','activate',ad,0,handles.Model(md).Input(ad).activeDryPoint);
    end
else
    switch(lower(opt))
        case{'add'}
            pushAddDryPoint;
        case{'plot'}
            ddb_Delft3DFLOW_plotAttributes(handles,'DryPoints','plot',ad,n,n);
        case{'delete'}
    end
end

%%
function ListDryPoints_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveDryPoint=get(hObject,'Value');
RefreshDryPoints(handles);
handles.GUIData.DeleteSelectedDryPoint=1;
setHandles(handles);
set(gcf, 'windowbuttondownfcn',[]);
set(gcf, 'windowbuttonmotionfcn',[]);
ddb_plotFlowAttributes(handles,'DryPoints','activate',ad,0,handles.GUIData.ActiveDryPoint);

%%
function EditDryM1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDryPoints,'Value');
handles.Model(md).Input(ad).DryPoints(n).M1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).DryPoints(n).Name=['(' num2str(handles.Model(md).Input(ad).DryPoints(n).M1) ...
    ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N1) ')...('          ...
    num2str(handles.Model(md).Input(ad).DryPoints(n).M2) ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N2) ')'];
set(handles.ListDryPoints,'String',handles.Model(md).Input(ad).DryPoints.Name);
guidata(hObject, handles);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);
set(gcf, 'windowbuttondownfcn',[]);
set(gcf, 'windowbuttonmotionfcn',[]);
ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,n,n);

%%
function EditDryM2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDryPoints,'Value');
handles.Model(md).Input(ad).DryPoints(n).M2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).DryPoints(n).Name=['(' num2str(handles.Model(md).Input(ad).DryPoints(n).M1) ...
    ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N1) ')...('          ...
    num2str(handles.Model(md).Input(ad).DryPoints(n).M2) ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N2) ')'];
set(handles.ListDryPoints,'String',handles.Model(md).Input(ad).DryPoints.Name);
guidata(hObject, handles);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);
set(gcf, 'windowbuttondownfcn',[]);
set(gcf, 'windowbuttonmotionfcn',[]);
ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,n,n);

%%
function EditDryN1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDryPoints,'Value');
handles.Model(md).Input(ad).DryPoints(n).N1=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).DryPoints(n).Name=['(' num2str(handles.Model(md).Input(ad).DryPoints(n).M1) ...
    ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N1) ')...('          ...
    num2str(handles.Model(md).Input(ad).DryPoints(n).M2) ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N2) ')'];
set(handles.ListDryPoints,'String',handles.Model(md).Input(ad).DryPoints.Name);
guidata(hObject, handles);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);
set(gcf, 'windowbuttondownfcn',[]);
set(gcf, 'windowbuttonmotionfcn',[]);
ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,n,n);

%%
function EditDryN2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDryPoints,'Value');
handles.Model(md).Input(ad).DryPoints(n).N2=str2double(get(hObject,'String'));
handles.Model(md).Input(ad).DryPoints(n).Name=['(' num2str(handles.Model(md).Input(ad).DryPoints(n).M1) ...
    ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N1) ')...('          ...
    num2str(handles.Model(md).Input(ad).DryPoints(n).M2) ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N2) ')'];
set(handles.ListDryPoints,'String',handles.Model(md).Input(ad).DryPoints.Name);
guidata(hObject, handles);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);
set(gcf, 'windowbuttondownfcn',[]);
set(gcf, 'windowbuttonmotionfcn',[]);
ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,n,n);

%%
function pushAddDryPoint
ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@addDryPoint,'free'});

%%
function PushDeleteDryPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedDryPoint==1 && handles.Model(md).Input(ad).NrDryPoints>0
    handles=DeleteDryPoint(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'DryPoint',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveDryPoint=ii;
set(handles.GUIHandles.ListDryPoints,'Value',ii);
handles=DeleteDryPoint(handles);
setHandles(handles);

%%
function PushChangeDryPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='c';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectDryPoint});

%%
function PushSelectDryPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='s';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectDryPoint});
%set(gcf, 'windowbuttonmotionfcn', {@movemouse});
set(gcf, 'windowbuttonmotionfcn', []);

%%
function PushOpenDryPoints_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.dry', 'Select Dry Points File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.Model(md).Input(ad).DryFile=filename;
handles=ddb_readDryFile(handles);
handles.GUIData.ActiveDryPoint=1;
RefreshDryPoints(handles);
set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,0,1);

%%
function PushSaveDryPoints_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.dry', 'Select Dry Points File',handles.Model(md).Input(ad).DryFile);
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.Model(md).Input(ad).DryFile=filename;
ddb_saveDryFile(handles,ad);
set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
handles.GUIData.DeleteSelectedDryPoint=0;
setHandles(handles);

%%
function SelectDryPoint(hObject,eventdata)

handles=getHandles;
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(gca,'xlim');
ylim=get(gca,'ylim');
id=ad;
if posx>=xlim(1) && posx<=xlim(2) && posy>=ylim(1) && posy<=ylim(2)
    [m,n]=FindGridCell(posx,posy,handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY);
    nrdry=handles.Model(md).Input(id).NrDryPoints;
    if m>0
        for i=1:nrdry
            m1=handles.Model(md).Input(id).DryPoints(i).M1;
            n1=handles.Model(md).Input(id).DryPoints(i).N1;
            m2=handles.Model(md).Input(id).DryPoints(i).M2;
            n2=handles.Model(md).Input(id).DryPoints(i).N2;
            if ( m2==m1 && m==m1 && ((n<=n2 && n>=n1) || (n<=n1 && n>=n2)) ) || ...
                    ( n2==n1 && n==n1 && ((m<=m2 && m>=m1) || (m<=m1 && m>=m2)) )
                handles.GUIData.ActiveDryPoint=i;
                RefreshDryPoints(handles);
                handles.GUIData.DeleteSelectedDryPoint=0;
                setHandles(handles);
                if handles.Mode=='c'
                    ddb_plotFlowAttributes(handles,'DryPoints','activate',ad,i,i);
                    set(gcf, 'windowbuttondownfcn',   {@starttrack});
                elseif handles.Mode=='s'
                    ddb_plotFlowAttributes(handles,'DryPoints','activate',ad,i,i);
                elseif handles.Mode=='d'
                    handles=DeleteDryPoint(handles);
                    setHandles(handles);
                end
                break
            end
        end
    end
end

%%
function addDryPoint(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;
[m1,n1]=FindGridCell(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[m2,n2]=FindGridCell(x2,y2,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
if m1>0 && (m1==m2 || n1==n2)
    if handles.Mode=='a'
        nrdry=handles.Model(md).Input(ad).NrDryPoints+1;
        handles.Model(md).Input(ad).NrDryPoints=nrdry;
    elseif handles.Mode=='c'
        nrdry=handles.GUIData.ActiveDryPoint;
    end
    handles.Model(md).Input(ad).DryPoints(nrdry).M1=m1;
    handles.Model(md).Input(ad).DryPoints(nrdry).N1=n1;
    handles.Model(md).Input(ad).DryPoints(nrdry).M2=m2;
    handles.Model(md).Input(ad).DryPoints(nrdry).N2=n2;
    handles.Model(md).Input(ad).DryPoints(nrdry).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.GUIData.ActiveDryPoint=nrdry;
    RefreshDryPoints(handles);
    handles.GUIData.DeleteSelectedDryPoint=0;
    setHandles(handles);
    if handles.Mode=='a'
        ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,nrdry,nrdry);
    elseif handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,nrdry,nrdry);
        set(gcf, 'windowbuttondownfcn',   {@SelectDryPoint});
    end
end
setHandles(handles);

%%
function handles=DeleteDryPoint(handles)

id=ad;
nrdry=handles.Model(md).Input(id).NrDryPoints;
iac0=handles.GUIData.ActiveDryPoint;
i=handles.GUIData.ActiveDryPoint;

iacnew=handles.GUIData.ActiveDryPoint;
if iacnew==nrdry
    iacnew=nrdry-1;
end
ddb_plotFlowAttributes(handles,'DryPoints','delete',id,handles.GUIData.ActiveDryPoint,iacnew);

handles.GUIData.ActiveDryPoint=iac0;
if nrdry>1
    for j=i:nrdry-1
        handles.Model(md).Input(id).DryPoints(j)=handles.Model(md).Input(id).DryPoints(j+1);
    end
    handles.Model(md).Input(id).DryPoints=handles.Model(md).Input(id).DryPoints(1:end-1);
else
    handles.Model(md).Input(id).DryPoints=[];
end
handles.Model(md).Input(id).NrDryPoints=handles.Model(md).Input(id).NrDryPoints-1;
if handles.Model(md).Input(id).NrDryPoints>0
    if handles.GUIData.ActiveDryPoint==handles.Model(md).Input(id).NrDryPoints+1
        handles.GUIData.ActiveDryPoint-1;
    end
end
RefreshDryPoints(handles);

%%
function RefreshDryPoints(handles)

id=ad;
nr=handles.Model(md).Input(id).NrDryPoints;
n=handles.GUIData.ActiveDryPoint;
if nr>0
    for k=1:nr
        str{k}=handles.Model(md).Input(id).DryPoints(k).Name;
    end
    set(handles.GUIHandles.ListDryPoints,'Value',n);
    set(handles.GUIHandles.ListDryPoints,'String',str);
    set(handles.GUIHandles.EditDryM1,'String',handles.Model(md).Input(id).DryPoints(n).M1);
    set(handles.GUIHandles.EditDryN1,'String',handles.Model(md).Input(id).DryPoints(n).N1);
    set(handles.GUIHandles.EditDryM2,'String',handles.Model(md).Input(id).DryPoints(n).M2);
    set(handles.GUIHandles.EditDryN2,'String',handles.Model(md).Input(id).DryPoints(n).N2);
    set(handles.GUIHandles.EditDryM1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDryN1,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDryM2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDryN2,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextM1,   'Enable','on');
    set(handles.GUIHandles.TextN1,   'Enable','on');
    set(handles.GUIHandles.TextM2,   'Enable','on');
    set(handles.GUIHandles.TextN2,   'Enable','on');
else
    set(handles.GUIHandles.EditDryM1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditDryN1,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditDryM2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditDryN2,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextM1,   'Enable','off');
    set(handles.GUIHandles.TextN1,   'Enable','off');
    set(handles.GUIHandles.TextM2,   'Enable','off');
    set(handles.GUIHandles.TextN2,   'Enable','off');
    set(handles.GUIHandles.ListDryPoints,'String','');
    set(handles.GUIHandles.ListDryPoints,'Value',1);
    set(handles.GUIHandles.EditDryM1,'String',[]);
    set(handles.GUIHandles.EditDryN1,'String',[]);
    set(handles.GUIHandles.EditDryM2,'String',[]);
    set(handles.GUIHandles.EditDryN2,'String',[]);
end


