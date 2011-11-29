function ddb_editD3DFlowDrogues
%DDB_EDITD3DFLOWDROGUES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowDrogues
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowDrogues
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
ddb_refreshScreen('Monitoring','Stations');
handles=getHandles;

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

uipanel('Title','','Units','pixels','Position',[220 30 180 110],'Tag','UIControl');

handles.GUIHandles.EditDroName      = uicontrol(gcf,'Style','edit','Position',[260 110 130 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDroM         = uicontrol(gcf,'Style','edit','Position',[260  85  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDroN         = uicontrol(gcf,'Style','edit','Position',[340  85  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditRelease      = uicontrol(gcf,'Style','edit','Position',[280  60 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditRecovery     = uicontrol(gcf,'Style','edit','Position',[280  35 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextName     = uicontrol(gcf,'Style','text','String','Name',    'Position',[225 106 30 20],'HorizontalAlignment','right', 'Tag','UIControl');
handles.GUIHandles.TextM        = uicontrol(gcf,'Style','text','String','M',       'Position',[235  81 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN        = uicontrol(gcf,'Style','text','String','N',       'Position',[315  81 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextRelease  = uicontrol(gcf,'Style','text','String','Release', 'Position',[225  56 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextRecovery = uicontrol(gcf,'Style','text','String','Recovery','Position',[225  31 50 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.ListDrogues = uicontrol(gcf,'Style','listbox','Position',[60 30 150 110],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListDrogues = uicontrol(gcf,'Style','text','String','Drogues', 'Position',[60 143 150 12],'HorizontalAlignment','center','Tag','UIControl');

handles.GUIHandles.PushAddDrogue    = uicontrol(gcf,'Style','pushbutton','String','Add','Position',   [410 105 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteDrogue = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[410  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeDrogue = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[410  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectDrogue = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[410  30 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenDrogues   = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[500  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushSaveDrogues   = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[500  55 70 20],'Tag','UIControl');
handles.GUIHandles.PushImportDrogues = uicontrol(gcf,'Style','pushbutton','String','Import', 'Position',[580  80 70 20],'Tag','UIControl');
handles.GUIHandles.PushExportDrogues = uicontrol(gcf,'Style','pushbutton','String','Export', 'Position',[580  55 70 20],'Tag','UIControl');
handles.GUIHandles.TextDroFile                 = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).DroFile],'Position',[500 27 300 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListDrogues,'CallBack',{@ListDrogues_CallBack},'BusyAction','Cancel');
set(handles.GUIHandles.PushAddDrogue,'CallBack',{@PushAddDrogue_CallBack});
set(handles.GUIHandles.PushDeleteDrogue,'CallBack',{@PushDeleteDrogue_CallBack});
set(handles.GUIHandles.PushChangeDrogue,'CallBack',{@PushChangeDrogue_CallBack});
set(handles.GUIHandles.PushSelectDrogue,'CallBack',{@PushSelectDrogue_CallBack});
set(handles.GUIHandles.PushOpenDrogues,'CallBack',{@PushOpenDrogues_CallBack});
set(handles.GUIHandles.PushSaveDrogues,'CallBack',{@PushSaveDrogues_CallBack});
set(handles.GUIHandles.EditDroM,  'CallBack',{@EditDroM_CallBack});
set(handles.GUIHandles.EditDroN,  'CallBack',{@EditDroN_CallBack});
set(handles.GUIHandles.EditDroName,  'CallBack',{@EditDroName_CallBack});
set(handles.GUIHandles.EditRelease,  'CallBack',{@EditRelease_CallBack});
set(handles.GUIHandles.EditRecovery,  'CallBack',{@EditRecovery_CallBack});

handles.DeleteSelectedDrogue=0;

set(handles.GUIHandles.PushChangeDrogue,'Enable','off');
set(handles.GUIHandles.PushImportDrogues,'Enable','off');
set(handles.GUIHandles.PushExportDrogues,'Enable','off');

if handles.GUIData.ActiveDrogue>handles.Model(md).Input(ad).NrDrogues
    handles.GUIData.ActiveDrogue=handles.Model(md).Input(ad).NrDrogues;
end

setHandles(handles);

if handles.Model(md).Input(ad).NrDrogues>0
    ddb_plotFlowAttributes(handles,'Drogues','activate',ad,0,handles.GUIData.ActiveDrogue);
end

SetUIBackgroundColors;

RefreshDrogues(handles);

%%
function ListDrogues_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveDrogue=get(hObject,'Value');
RefreshDrogues(handles);
handles.GUIData.DeleteSelectedDrogue=1;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Drogues','activate',ad,0,handles.GUIData.ActiveDrogue);

%%
function EditDroM_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDrogues,'Value');
handles.Model(md).Input(ad).Drogues(n).M=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedDrogue=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Drogues','plot',ad,n,n);

%%
function EditDroN_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDrogues,'Value');
handles.Model(md).Input(ad).Drogues(n).N=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedDrogue=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Drogues','plot',ad,n,n);

%%
function EditDroName_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDrogues,'Value');
handles.Model(md).Input(ad).Drogues(n).Name=get(hObject,'String');
for k=1:handles.Model(md).Input(ad).NrDrogues
    str{k}=handles.Model(md).Input(ad).Drogues(k).Name;
end
set(handles.ListDrogues,'String',str);
handles.GUIData.DeleteSelectedDrogue=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Drogues','plot',ad,n,n);

%%
function EditRelease_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDrogues,'Value');
handles.Model(md).Input(ad).Drogues(n).ReleaseTime=datenum(get(hObject,'String'),'yyyy mm dd HH MM SS');
handles.GUIData.DeleteSelectedDrogue=0;
setHandles(handles);

%%
function EditRecovery_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDrogues,'Value');
handles.Model(md).Input(ad).Drogues(n).RecoveryTime=datenum(get(hObject,'String'),'yyyy mm dd HH MM SS');
handles.GUIData.DeleteSelectedDrogue=0;
setHandles(handles);

%%
function PushOpenDrogues_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.par', 'Select Drogues File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).DroFile=filename;
    handles.Model(md).Input(ad).Drogues=[];
    handles=ddb_readDroFile(handles);
    handles.GUIData.ActiveDrogue=1;
    handles.GUIData.DeleteSelectedDrogue=0;
    RefreshDrogues(handles);
    set(handles.TextDroFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedDrogue=0;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'Drogues','plot',ad,0,1);
end

%%
function PushSaveDrogues_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.par', 'Select Droervation Points File',handles.Model(md).Input(ad).DroFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).DroFile=filename;
    ddb_saveDroFile(handles,ad);
    set(handles.GUIHandles.TextDroFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedDrogue=0;
    setHandles(handles);
end

%%
function PushSelectDrogue_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedDrogue=0;
handles.Mode='s';
set(gcf, 'windowbuttondownfcn',   {@SelectDrogue});
setHandles(handles);

%%
function PushChangeDrogue_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedDrogue=0;
handles.Mode='c';
set(gcf, 'windowbuttondownfcn',   {@SelectDrogue});
setHandles(handles);

%%
function PushAddDrogue_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
% h=findobj('Tag','MainWindow');
% handles=guidata(h);
handles.GUIData.DeleteSelectedDrogue=0;
xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
setHandles(handles);
% guidata(h,handles);
ClickPoint('cell','Grid',xg,yg,'Callback',@AddDrogue,'multiple');

%%
function PushDeleteDrogue_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedDrogue==1 && handles.Model(md).Input(ad).NrDrogues>0
    handles=DeleteDrogue(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'Drogue',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveDrogue=ii;
set(handles.GUIHandles.ListDrogues,'Value',ii);
handles=DeleteDrogue(handles);
setHandles(handles);

%%
function AddDrogue(m,n)

handles=getHandles;
if ~isnan(m)
    id=ad;
    nr=handles.Model(md).Input(id).NrDrogues+1;
    handles.Model(md).Input(id).NrDrogues=nr;
    handles.Model(md).Input(id).Drogues(nr).M=m-0.5;
    handles.Model(md).Input(id).Drogues(nr).N=n-0.5;
    handles.Model(md).Input(id).Drogues(nr).ReleaseTime=handles.Model(md).Input(id).StartTime;
    handles.Model(md).Input(id).Drogues(nr).RecoveryTime=handles.Model(md).Input(id).StopTime;
    xz=0.25*(handles.Model(md).Input(id).GridX(m,n)+handles.Model(md).Input(id).GridX(m,n-1)+handles.Model(md).Input(id).GridX(m-1,n)+handles.Model(md).Input(id).GridX(m-1,n-1));
    yz=0.25*(handles.Model(md).Input(id).GridY(m,n)+handles.Model(md).Input(id).GridY(m,n-1)+handles.Model(md).Input(id).GridY(m-1,n)+handles.Model(md).Input(id).GridY(m-1,n-1));
    handles.Model(md).Input(id).Drogues(nr).x=xz;
    handles.Model(md).Input(id).Drogues(nr).y=yz;
    handles.Model(md).Input(id).Drogues(nr).Name=[num2str(m-0.5) ',' num2str(n-0.5)];
    handles.GUIData.ActiveDrogue=nr;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'Drogues','plot',ad,nr,nr);
end
RefreshDrogues(handles);
setHandles(handles);

%%
function SelectDrogue(hObject,eventdata)

handles=getHandles;
if strcmp(get(gco,'Tag'),'Drogue')
    id=ad;
    ud=get(gco,'UserData');
    handles.GUIData.ActiveDrogue=ud(2);
    RefreshDrogues(handles);
    setHandles(handles);
    if handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'Drogues','activate',ad,0,handles.GUIData.ActiveDrogue);
        xg=handles.Model(md).Input(ad).GridX;
        yg=handles.Model(md).Input(ad).GridY;
        set(gcf, 'windowbuttondownfcn',   {@ClickPoint,@AddDrogue,'cell',xg,yg});
    elseif handles.Mode=='s'
        ddb_plotFlowAttributes(handles,'Drogues','activate',ad,0,handles.GUIData.ActiveDrogue);
    elseif handles.Mode=='d'
        ddb_plotFlowAttributes(handles,'Drogues','plot',ad,0,handles.GUIData.ActiveDrogue);
    end
end
setHandles(handles);

%%
function handles=DeleteDrogue(handles)

id=ad;
nrdro=handles.Model(md).Input(id).NrDrogues;

iac0=handles.GUIData.ActiveDrogue;
iacnew=handles.GUIData.ActiveDrogue;
if iacnew==nrdro
    iacnew=nrdro-1;
end
ddb_plotFlowAttributes(handles,'Drogues','delete',id,handles.GUIData.ActiveDrogue,iacnew);

if nrdro>1
    for j=iac0:nrdro-1
        handles.Model(md).Input(id).Drogues(j).M=handles.Model(md).Input(id).Drogues(j+1).M;
        handles.Model(md).Input(id).Drogues(j).N=handles.Model(md).Input(id).Drogues(j+1).N;
        handles.Model(md).Input(id).Drogues(j).x=handles.Model(md).Input(id).Drogues(j+1).x;
        handles.Model(md).Input(id).Drogues(j).y=handles.Model(md).Input(id).Drogues(j+1).y;
        handles.Model(md).Input(id).Drogues(j).Name=handles.Model(md).Input(id).Drogues(j+1).Name;
    end
    handles.Model(md).Input(id).Drogues=handles.Model(md).Input(id).Drogues(1:end-1);
else
    handles.Model(md).Input(id).Drogues=[];
end
handles.Model(md).Input(id).NrDrogues=handles.Model(md).Input(id).NrDrogues-1;
if handles.Model(md).Input(id).NrDrogues>0
    if handles.GUIData.ActiveDrogue==handles.Model(md).Input(id).NrDrogues+1
        handles.GUIData.ActiveDrogue=handles.GUIData.ActiveDrogue-1;
    end
end
RefreshDrogues(handles);

%%
function RefreshDrogues(handles)

id=ad;
nr=handles.Model(md).Input(id).NrDrogues;
n=max(handles.GUIData.ActiveDrogue,1);

if nr>0
    set(handles.GUIHandles.ListDrogues,'Value',n);
    for k=1:nr
        str{k}=handles.Model(md).Input(id).Drogues(k).Name;
    end
    set(handles.GUIHandles.ListDrogues,'String',str);
    set(handles.GUIHandles.EditDroName,'String',handles.Model(md).Input(id).Drogues(n).Name);
    set(handles.GUIHandles.EditDroM,'String',handles.Model(md).Input(id).Drogues(n).M);
    set(handles.GUIHandles.EditDroN,'String',handles.Model(md).Input(id).Drogues(n).N);
    set(handles.GUIHandles.EditRelease, 'String',D3DTimeString(handles.Model(md).Input(id).Drogues(n).ReleaseTime));
    set(handles.GUIHandles.EditRecovery,'String',D3DTimeString(handles.Model(md).Input(id).Drogues(n).RecoveryTime));
    set(handles.GUIHandles.EditDroName,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDroM,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditDroN,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditRelease, 'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditRecovery,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextName,'Enable','on');
    set(handles.GUIHandles.TextM,   'Enable','on');
    set(handles.GUIHandles.TextN,   'Enable','on');
    set(handles.GUIHandles.TextRelease, 'Enable','on');
    set(handles.GUIHandles.TextRecovery,'Enable','on');
    set(handles.GUIHandles.PushSaveDrogues,   'Enable','on');
else
    set(handles.GUIHandles.EditDroName,'String','');
    set(handles.GUIHandles.EditDroName,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditDroM,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditDroN,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditRelease, 'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditRecovery,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextName,'Enable','off');
    set(handles.GUIHandles.TextM,   'Enable','off');
    set(handles.GUIHandles.TextN,   'Enable','off');
    set(handles.GUIHandles.TextRelease, 'Enable','off');
    set(handles.GUIHandles.TextRecovery,'Enable','off');
    set(handles.GUIHandles.ListDrogues,'String','');
    set(handles.GUIHandles.ListDrogues,'Value',1);
    set(handles.GUIHandles.EditDroM,'String',[]);
    set(handles.GUIHandles.EditDroN,'String',[]);
    set(handles.GUIHandles.PushSaveDrogues,   'Enable','off');
end

