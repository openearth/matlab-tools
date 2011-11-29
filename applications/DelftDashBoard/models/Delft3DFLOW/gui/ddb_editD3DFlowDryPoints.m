function ddb_editD3DFlowDryPoints
%DDB_EDITD3DFLOWDRYPOINTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowDryPoints
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowDryPoints
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ddb_refreshScreen('Domain','Dry Points');
handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

ndry=handles.Model(md).Input(ad).NrDryPoints;

hp = uipanel('Title','','Units','pixels','Position',[220 30 170 70],'Tag','UIControl');
handles.GUIHandles.ListDryPoints     = uicontrol(gcf,'Style','listbox','Position',[60 30 150 105],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListDryPoints = uicontrol(gcf,'Style','text','String','Dry Points', 'Position',[60 137 150 15],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.EditDryM1    = uicontrol(gcf,'Style','edit','Position',[250  70  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDryN1    = uicontrol(gcf,'Style','edit','Position',[330  70  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDryM2    = uicontrol(gcf,'Style','edit','Position',[250  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDryN2    = uicontrol(gcf,'Style','edit','Position',[330  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[225  66 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[305  66 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[225  36 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[305  36 20 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushAddDryPoint    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[410 105 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteDryPoint = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[410  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeDryPoint = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[410  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectDryPoint = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[410  30 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenDryPoints = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[500  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushSaveDryPoints = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[500  55 70 20],'Tag','UIControl');
handles.GUIHandles.TextDryFile       = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).DryFile],           'Position',[500 27 300 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListDryPoints,      'CallBack',{@ListDryPoints_CallBack});
set(handles.GUIHandles.EditDryM1,          'CallBack',{@EditDryM1_CallBack});
set(handles.GUIHandles.EditDryN1,          'CallBack',{@EditDryN1_CallBack});
set(handles.GUIHandles.EditDryM2,          'CallBack',{@EditDryM2_CallBack});
set(handles.GUIHandles.EditDryN2,          'CallBack',{@EditDryN2_CallBack});
set(handles.GUIHandles.PushAddDryPoint,    'CallBack',{@PushAddDryPoint_CallBack});
set(handles.GUIHandles.PushDeleteDryPoint, 'CallBack',{@PushDeleteDryPoint_CallBack});
set(handles.GUIHandles.PushChangeDryPoint, 'CallBack',{@PushChangeDryPoint_CallBack});
set(handles.GUIHandles.PushSelectDryPoint, 'CallBack',{@PushSelectDryPoint_CallBack});
set(handles.GUIHandles.PushOpenDryPoints,  'CallBack',{@PushOpenDryPoints_CallBack});
set(handles.GUIHandles.PushSaveDryPoints,  'CallBack',{@PushSaveDryPoints_CallBack});

setHandles(handles);

if handles.Model(md).Input(ad).NrDryPoints>0
    ddb_plotFlowAttributes(handles,'DryPoints','activate',ad,0,handles.GUIData.ActiveDryPoint);
end

set(handles.GUIHandles.PushChangeDryPoint, 'Enable','off');

RefreshDryPoints(handles);

handles.GUIData.DeleteSelectedDryPoint=0;

SetUIBackgroundColors;

setHandles(handles);

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
function PushAddDryPoint_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@AddDryPoint,'free'});

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
function AddDryPoint(x,y)

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



