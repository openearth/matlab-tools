function ddb_Delft3DFLOW_dryPoints(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
%    deleteUIControls;
    set(handles.GUIHandles.textAnn1,'String',{''});
    set(handles.GUIHandles.textAnn2,'String',{''});
    set(handles.GUIHandles.textAnn3,'String',{''});
    handles.Model(md).Input(ad).addDryPoint=0;
    handles.Model(md).Input(ad).selectDryPoint=0;
    handles.Model(md).Input(ad).changeDryPoint=0;
    handles.Model(md).Input(ad).deleteDryPoint=0;
%     ddb_refreshScreen2;
    handles=ddb_Delft3DFLOW_plotDryPoints(handles,'plot');
else
    opt=varargin{1};
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            if handles.Model(md).Input(ad).addDryPoint
                handles.editMode='add';
                ddb_dragLine(@addDryPoint,'free');
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{'Click point or drag line on map for new dry point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{''});
            end

        case{'delete'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            ddb_clickObject('tag','drypoint','callback',@deleteDryPointFromMap);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{'Select dry point from map to delete'});
            if handles.Model(md).Input(ad).deleteDryPoint
                handles=deleteDryPoint(handles);
            end

        case{'select'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            ddb_clickObject('tag','drypoint','callback',@selectDryPointFromMap);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{'Select dry point from map'});

        case{'change'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            if handles.Model(md).Input(ad).changeDryPoint
                ddb_clickObject('tag','drypoint','callback',@changeDryPointFromMap);
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{'Select dry point to change from map'});
            end

        case{'edit'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeDryPoint;
            m1str=num2str(handles.Model(md).Input(ad).DryPoints(n).M1);
            m2str=num2str(handles.Model(md).Input(ad).DryPoints(n).M2);
            n1str=num2str(handles.Model(md).Input(ad).DryPoints(n).N1);
            n2str=num2str(handles.Model(md).Input(ad).DryPoints(n).N2);
            handles.Model(md).Input(ad).dryPointNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            handles=ddb_Delft3DFLOW_plotDryPoints(handles,'plot','active',1);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{''});

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            % Delete selected dry point next time delete is clicked
            handles.Model(md).Input(ad).deleteDryPoint=1;
            ddb_Delft3DFLOW_plotDryPoints(handles,'update','active',1);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{''});

    end
end

setHandles(handles);

refreshDryPoints;

% %%
% function PushOpenDryPoints_CallBack(hObject,eventdata)
% handles=getHandles;
% [filename, pathname, filterindex] = uigetfile('*.dry', 'Select Dry Points File');
% curdir=[lower(cd) '\'];
% if ~strcmpi(curdir,pathname)
%     filename=[pathname filename];
% end
% handles.Model(md).Input(ad).DryFile=filename;
% handles=ddb_readDryFile(handles);
% refreshDryPoints(handles);
% set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
% handles.GUIData.DeleteSelectedDryPoint=0;
% setHandles(handles);
% ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,0,1);
% 
% %%
% function PushSaveDryPoints_CallBack(hObject,eventdata)
% handles=getHandles;
% [filename, pathname, filterindex] = uiputfile('*.dry', 'Select Dry Points File',handles.Model(md).Input(ad).DryFile);
% curdir=[lower(cd) '\'];
% if ~strcmpi(curdir,pathname)
%     filename=[pathname filename];
% end
% handles.Model(md).Input(ad).DryFile=filename;
% ddb_saveDryFile(handles,ad);
% set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
% handles.GUIData.DeleteSelectedDryPoint=0;
% setHandles(handles);

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
    if handles.Model(md).Input(ad).changeDryPoint
        iac=handles.Model(md).Input(ad).activeDryPoint;
    else
        % Add mode
        handles.Model(md).Input(ad).nrDryPoints=handles.Model(md).Input(ad).nrDryPoints+1;
        iac=handles.Model(md).Input(ad).nrDryPoints;
    end
    handles.Model(md).Input(ad).DryPoints(iac).M1=m1;
    handles.Model(md).Input(ad).DryPoints(iac).N1=n1;
    handles.Model(md).Input(ad).DryPoints(iac).M2=m2;
    handles.Model(md).Input(ad).DryPoints(iac).N2=n2;
    handles.Model(md).Input(ad).DryPoints(iac).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).dryPointNames{iac}=handles.Model(md).Input(ad).DryPoints(iac).Name;
    handles.Model(md).Input(ad).activeDryPoint=iac;
    setHandles(handles);
    handles=ddb_Delft3DFLOW_plotDryPoints(handles,'plot');
    
    if handles.Model(md).Input(ad).changeDryPoint
        ddb_clickObject('tag','drypoint','callback',@changeDryPointFromMap);
        set(handles.GUIHandles.textAnn1,'String',{''});
        set(handles.GUIHandles.textAnn2,'String',{''});
        set(handles.GUIHandles.textAnn3,'String',{'Select dry point'});
    else
        ddb_dragLine(@addDryPoint,'free');
        set(handles.GUIHandles.textAnn1,'String',{''});
        set(handles.GUIHandles.textAnn2,'String',{''});
        set(handles.GUIHandles.textAnn3,'String',{'Click position of new dry point'});
    end
end
setHandles(handles);
refreshDryPoints;

%%
function handles=deleteDryPoint(handles)

nrdry=handles.Model(md).Input(ad).nrDryPoints;

if nrdry>0
    iac=handles.Model(md).Input(ad).activeDryPoint;    
    handles=ddb_Delft3DFLOW_plotDryPoints(handles,'delete');
    if nrdry>1
        handles.Model(md).Input(ad).DryPoints=removeFromStruc(handles.Model(md).Input(ad).DryPoints,iac);
        handles.Model(md).Input(ad).dryPointNames=removeFromCellArray(handles.Model(md).Input(ad).dryPointNames,iac);
    else   
        handles.Model(md).Input(ad).dryPointNames={''};
        handles.Model(md).Input(ad).activeDryPoint=1;
        handles.Model(md).Input(ad).DryPoints(1).M1=[];
        handles.Model(md).Input(ad).DryPoints(1).M2=[];
        handles.Model(md).Input(ad).DryPoints(1).N1=[];
        handles.Model(md).Input(ad).DryPoints(1).N2=[];
    end
    if iac==nrdry
        iac=nrdry-1;
    end
    handles.Model(md).Input(ad).nrDryPoints=nrdry-1;
    handles.Model(md).Input(ad).activeDryPoint=iac;
    handles=ddb_Delft3DFLOW_plotDryPoints(handles,'plot');
    setHandles(handles);
    refreshDryPoints;
end

%%
function deleteDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
handles=deleteDryPoint(handles);
setHandles(handles);

%%
function selectDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
ddb_Delft3DFLOW_plotDryPoints(handles,'update');
setHandles(handles);
refreshDryPoints;

%%
function changeDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
ddb_Delft3DFLOW_plotDryPoints(handles,'update');
setHandles(handles);
refreshDryPoints;
ddb_dragLine(@addDryPoint,'free');
set(handles.GUIHandles.textAnn1,'String',{''});
set(handles.GUIHandles.textAnn2,'String',{''});
set(handles.GUIHandles.textAnn3,'String',{'Click new position of dry point'});

%%
function refreshDryPoints
setUIElement('delft3dflow.domain.domainpanel.drypoints.listdrypoints');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdrym1');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdrym2');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdryn1');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdryn2');
setUIElement('delft3dflow.domain.domainpanel.drypoints.toggleadddrypoint');
setUIElement('delft3dflow.domain.domainpanel.drypoints.toggleselectdrypoint');
setUIElement('delft3dflow.domain.domainpanel.drypoints.togglechangedrypoint');


%%
function str1=removeFromStruc(str0,iac)
k=0;
for i=1:length(str0)
    if i~=iac
        k=k+1;
        str1(k)=str0(i);
    end
end

%%
function str1=removeFromCellArray(str0,iac)
str{1}=[];
k=0;
for i=1:length(str0)
    if i~=iac
        k=k+1;
        str1{k}=str0{i};
    end
end

