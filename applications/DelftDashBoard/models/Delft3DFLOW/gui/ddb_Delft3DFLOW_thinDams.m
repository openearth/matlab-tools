function ddb_Delft3DFLOW_thinDams(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
%    deleteUIControls;
    set(handles.GUIHandles.textAnn1,'String',{''});
    set(handles.GUIHandles.textAnn2,'String',{''});
    set(handles.GUIHandles.textAnn3,'String',{''});
    handles.Model(md).Input(ad).addThinDam=0;
    handles.Model(md).Input(ad).selectThinDam=0;
    handles.Model(md).Input(ad).changeThinDam=0;
    handles.Model(md).Input(ad).deleteThinDam=0;
%     ddb_refreshScreen2;
    handles=ddb_Delft3DFLOW_plotThinDams(handles,'plot');
else
    opt=varargin{1};
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            if handles.Model(md).Input(ad).addThinDam
                ddb_dragLine(@addThinDam,'method','alonggridline','x',handles.Model(md).Input(ad).GridX,'y',handles.Model(md).Input(ad).GridY);
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{'Drag line on map for new thin dam'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{''});
            end

        case{'delete'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            ddb_clickObject('tag','drypoint','callback',@deleteThinDamFromMap);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{'Select thin dam from map to delete'});
            if handles.Model(md).Input(ad).deleteThinDam
                handles=deleteThinDam(handles);
            end

        case{'select'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            ddb_clickObject('tag','drypoint','callback',@selectThinDamFromMap);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{'Select thin dam from map'});

        case{'change'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            if handles.Model(md).Input(ad).changeThinDam
                ddb_clickObject('tag','drypoint','callback',@changeThinDamFromMap);
                set(handles.GUIHandles.textAnn1,'String',{''});
                set(handles.GUIHandles.textAnn2,'String',{''});
                set(handles.GUIHandles.textAnn3,'String',{'Select thin dam to change from map'});
            end

        case{'edit'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeThinDam;
            m1str=num2str(handles.Model(md).Input(ad).ThinDams(n).M1);
            m2str=num2str(handles.Model(md).Input(ad).ThinDams(n).M2);
            n1str=num2str(handles.Model(md).Input(ad).ThinDams(n).N1);
            n2str=num2str(handles.Model(md).Input(ad).ThinDams(n).N2);
            handles.Model(md).Input(ad).thinDamNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            handles=ddb_Delft3DFLOW_plotThinDams(handles,'plot','active',1);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{''});

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            % Delete selected dry point next time delete is clicked
            handles.Model(md).Input(ad).deleteThinDam=1;
            ddb_Delft3DFLOW_plotThinDams(handles,'update','active',1);
            set(handles.GUIHandles.textAnn1,'String',{''});
            set(handles.GUIHandles.textAnn2,'String',{''});
            set(handles.GUIHandles.textAnn3,'String',{''});

    end
end

setHandles(handles);

refreshThinDams;

% %%
% function PushOpenThinDams_CallBack(hObject,eventdata)
% handles=getHandles;
% [filename, pathname, filterindex] = uigetfile('*.dry', 'Select Dry Points File');
% curdir=[lower(cd) '\'];
% if ~strcmpi(curdir,pathname)
%     filename=[pathname filename];
% end
% handles.Model(md).Input(ad).DryFile=filename;
% handles=ddb_readDryFile(handles);
% refreshThinDams(handles);
% set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
% handles.GUIData.DeleteSelectedThinDam=0;
% setHandles(handles);
% ddb_plotFlowAttributes(handles,'ThinDams','plot',ad,0,1);
% 
% %%
% function PushSaveThinDams_CallBack(hObject,eventdata)
% handles=getHandles;
% [filename, pathname, filterindex] = uiputfile('*.dry', 'Select Dry Points File',handles.Model(md).Input(ad).DryFile);
% curdir=[lower(cd) '\'];
% if ~strcmpi(curdir,pathname)
%     filename=[pathname filename];
% end
% handles.Model(md).Input(ad).DryFile=filename;
% ddb_saveDryFile(handles,ad);
% set(handles.GUIHandles.TextDryFile,'String',['File : ' filename]);
% handles.GUIData.DeleteSelectedThinDam=0;
% setHandles(handles);

%%
function addThinDam(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;
% Find grid indices of start and end point of line
[m1,n1]=FindGridCell(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[m2,n2]=FindGridCell(x2,y2,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
% Check if start and end are in one grid line
if m1>0 && (m1==m2 || n1==n2)
    if handles.Model(md).Input(ad).changeThinDam
        iac=handles.Model(md).Input(ad).activeThinDam;
    else
        % Add mode
        handles.Model(md).Input(ad).nrThinDams=handles.Model(md).Input(ad).nrThinDams+1;
        iac=handles.Model(md).Input(ad).nrThinDams;
    end
    handles.Model(md).Input(ad).ThinDams(iac).M1=m1;
    handles.Model(md).Input(ad).ThinDams(iac).N1=n1;
    handles.Model(md).Input(ad).ThinDams(iac).M2=m2;
    handles.Model(md).Input(ad).ThinDams(iac).N2=n2;
    handles.Model(md).Input(ad).ThinDams(iac).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).thinDamNames{iac}=handles.Model(md).Input(ad).ThinDams(iac).Name;
    handles.Model(md).Input(ad).activeThinDam=iac;
    setHandles(handles);
    handles=ddb_Delft3DFLOW_plotThinDams(handles,'plot');
    
    if handles.Model(md).Input(ad).changeThinDam
        ddb_clickObject('tag','drypoint','callback',@changeThinDamFromMap);
        set(handles.GUIHandles.textAnn1,'String',{''});
        set(handles.GUIHandles.textAnn2,'String',{''});
        set(handles.GUIHandles.textAnn3,'String',{'Select dry point'});
    else
        ddb_dragLine(@addThinDam,'free');
        set(handles.GUIHandles.textAnn1,'String',{''});
        set(handles.GUIHandles.textAnn2,'String',{''});
        set(handles.GUIHandles.textAnn3,'String',{'Click position of new dry point'});
    end
end
setHandles(handles);
refreshThinDams;

%%
function handles=deleteThinDam(handles)

nrdry=handles.Model(md).Input(ad).nrThinDams;

if nrdry>0
    iac=handles.Model(md).Input(ad).activeThinDam;    
    handles=ddb_Delft3DFLOW_plotThinDams(handles,'delete');
    if nrdry>1
        handles.Model(md).Input(ad).ThinDams=removeFromStruc(handles.Model(md).Input(ad).ThinDams,iac);
        handles.Model(md).Input(ad).thinDamNames=removeFromCellArray(handles.Model(md).Input(ad).thinDamNames,iac);
    else   
        handles.Model(md).Input(ad).thinDamNames={''};
        handles.Model(md).Input(ad).activeThinDam=1;
        handles.Model(md).Input(ad).ThinDams(1).M1=[];
        handles.Model(md).Input(ad).ThinDams(1).M2=[];
        handles.Model(md).Input(ad).ThinDams(1).N1=[];
        handles.Model(md).Input(ad).ThinDams(1).N2=[];
    end
    if iac==nrdry
        iac=nrdry-1;
    end
    handles.Model(md).Input(ad).nrThinDams=nrdry-1;
    handles.Model(md).Input(ad).activeThinDam=iac;
    handles=ddb_Delft3DFLOW_plotThinDams(handles,'plot');
    setHandles(handles);
    refreshThinDams;
end

%%
function deleteThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
handles=deleteThinDam(handles);
setHandles(handles);

%%
function selectThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
ddb_Delft3DFLOW_plotThinDams(handles,'update');
setHandles(handles);
refreshThinDams;

%%
function changeThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
ddb_Delft3DFLOW_plotThinDams(handles,'update');
setHandles(handles);
refreshThinDams;
ddb_dragLine(@addThinDam,'free');
set(handles.GUIHandles.textAnn1,'String',{''});
set(handles.GUIHandles.textAnn2,'String',{''});
set(handles.GUIHandles.textAnn3,'String',{'Click new position of thin dam'});

%%
function refreshThinDams
setUIElement('delft3dflow.domain.domainpanel.thindams.listthindams');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinm1');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinm2');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinn1');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinn2');
setUIElement('delft3dflow.domain.domainpanel.thindams.toggleaddthindam');
setUIElement('delft3dflow.domain.domainpanel.thindams.toggleselectthindam');
setUIElement('delft3dflow.domain.domainpanel.thindams.togglechangethindam');


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

