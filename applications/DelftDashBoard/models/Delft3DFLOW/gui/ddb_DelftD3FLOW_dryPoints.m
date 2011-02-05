function ddb_DelftD3FLOW_dryPoints(varargin)

handles=getHandles;

if isempty(varargin)
    % Dry points tab selected
    ddb_refreshScreen2;
    if handles.Model(md).Input(ad).nrDryPoints>0
        ddb_Delft3DFLOW_plotAttributes('DryPoints','activate',ad,0,handles.Model(md).Input(ad).activeDryPoint);
    end
else
    switch(lower(opt))

        case{'add'}
            ddb_zoomOff;
            handles=getHandles;
            handles.Mode='a';
            setHandles(handles);
            set(gcf, 'windowbuttondownfcn',{@DragLine,@addDryPoint,'free'});

        case{'plot'}
            n=handles.Model(md).Input(ad).activeDryPoint;
            ddb_Delft3DFLOW_plotAttributes(handles,'DryPoints','plot',ad,n,n);

        case{'delete'}
            ddb_zoomOff;
            handles=getHandles;
            handles.Mode='d';
            setHandles(handles);
            if handles.GUIData.DeleteSelectedDryPoint==1 && handles.Model(md).Input(ad).nrDryPoints>0
                handles=deleteDryPoint(handles);
                setHandles(handles);
            end
            ddb_deleteDelft3DFLOWObject(ad,'DryPoint',@DeleteObject);

        case{'edit'}
            n=handles.Model(md).Input(ad).activeDryPoint;
            handles.Model(md).Input(ad).dryPointNames{n}=['(' num2str(handles.Model(md).Input(ad).DryPoints(n).M1) ...
                ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N1) ')...('          ...
                num2str(handles.Model(md).Input(ad).DryPoints(n).M2) ',' num2str(handles.Model(md).Input(ad).DryPoints(n).N2) ')'];
            setHandles(handles);
            setUIElement('delft3dflow.domain.drypoints.listdrypoints');
            ddb_Delft3DFLOW_plotAttributes('DryPoints','plot',ad,n,n);

        case{'select'}
            ddb_zoomOff;
            handles.Mode='s';
            setHandles(handles);
            set(gcf, 'windowbuttondownfcn',   {@selectDryPoint});
            set(gcf, 'windowbuttonmotionfcn', []);

        case{'change'}
            pushChangeDryPoint;
    end
end

setHandles(handles);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveDryPoint=ii;
set(handles.GUIHandles.ListDryPoints,'Value',ii);
handles=deleteDryPoint(handles);
setHandles(handles);

%%
function pushChangeDryPoint
ddb_zoomOff;
handles=getHandles;
handles.Mode='c';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectDryPoint});

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
function selectDryPoint

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
% Find grid indices of start and end point of line
[m1,n1]=FindGridCell(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[m2,n2]=FindGridCell(x2,y2,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
% Check if start and end are in one grid line
if m1>0 && (m1==m2 || n1==n2)
    if handles.Mode=='a'
        % Add mode
        nrdry=handles.Model(md).Input(ad).nrDryPoints+1;
        handles.Model(md).Input(ad).nrDryPoints=nrdry;
    elseif handles.Mode=='c'
        % Change mode
        nrdry=handles.Model(md).Input(ad).activeDryPoint;
    end
    handles.Model(md).Input(ad).DryPoints(nrdry).M1=m1;
    handles.Model(md).Input(ad).DryPoints(nrdry).N1=n1;
    handles.Model(md).Input(ad).DryPoints(nrdry).M2=m2;
    handles.Model(md).Input(ad).DryPoints(nrdry).N2=n2;
    handles.Model(md).Input(ad).DryPoints(nrdry).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).dryPointNames{nrdry}=handles.Model(md).Input(ad).DryPoints(nrdry).Name;
    handles.Model(md).Input(ad).activeDryPoint=nrdry;
    handles.GUIData.DeleteSelectedDryPoint=0;
    setHandles(handles);
    ddb_Delft3DFLOW_plotAttributes('DryPoints','plot',ad,nrdry,nrdry);
    if handles.Mode=='c'
        set(gcf, 'windowbuttondownfcn',   {@selectDryPoint});
    end
end
setHandles(handles);

%%
function handles=deleteDryPoint(handles)

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
        handles.GUIData.ActiveDryPoint=handles.GUIData.ActiveDryPoint-1;
    end
end
RefreshDryPoints(handles);
