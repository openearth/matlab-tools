function ddb_editD3DFlowDischarges
%DDB_EDITD3DFLOWDISCHARGES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowDischarges
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowDischarges
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
ddb_refreshScreen('Discharges');

handles=getHandles;

uipanel('Title','Discharges','Units','pixels','Position',[50 20 900 160],'Tag','UIControl');

uipanel('Title','','Units','pixels','Position',[220 30 260 130],'Tag','UIControl');

handles.GUIHandles.EditSrcName  = uicontrol(gcf,'Style','edit','Position',[260 130 210 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSrcM     = uicontrol(gcf,'Style','edit','Position',[280 105  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSrcN     = uicontrol(gcf,'Style','edit','Position',[350 105  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSrcK     = uicontrol(gcf,'Style','edit','Position',[420 105  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextName     = uicontrol(gcf,'Style','text','String','Name',    'Position',[225 126 30 20],'HorizontalAlignment','right', 'Tag','UIControl');
handles.GUIHandles.TextM        = uicontrol(gcf,'Style','text','String','M',       'Position',[265 101 10 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextN        = uicontrol(gcf,'Style','text','String','N',       'Position',[335 101 10 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextK        = uicontrol(gcf,'Style','text','String','K',       'Position',[405 101 10 20],'HorizontalAlignment','right','Tag','UIControl');

str={'Normal','Momentum','Walking','In-Out'};
handles.GUIHandles.SelectType   = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[280 80 80 20],'Tag','UIControl');
handles.GUIHandles.TextType     = uicontrol(gcf,'Style','text','String','Type','Position',[225 76 30 20],'HorizontalAlignment','left', 'Tag','UIControl');

handles.GUIHandles.ToggleLinear = uicontrol(gcf,'Style','radiobutton','String','Linear','Position',[290 57 50 20],'Tag','UIControl');
handles.GUIHandles.ToggleBlock  = uicontrol(gcf,'Style','radiobutton','String','Block','Position', [350 57 50 20],'Tag','UIControl');
handles.GUIHandles.TextInterp   = uicontrol(gcf,'Style','text','String','Interpolation',       'Position',[225 53 60 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.EditSrcMOut     = uicontrol(gcf,'Style','edit','Position',[280 35  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSrcNOut     = uicontrol(gcf,'Style','edit','Position',[350 35  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSrcKOut     = uicontrol(gcf,'Style','edit','Position',[420 35  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMOut        = uicontrol(gcf,'Style','text','String','M',       'Position',[265 31 10 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextNOut        = uicontrol(gcf,'Style','text','String','N',       'Position',[335 31 10 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextKOut        = uicontrol(gcf,'Style','text','String','K',       'Position',[405 31 10 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.TextOutlet      = uicontrol(gcf,'Style','text','String','Outlet',       'Position',[225 31 30 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.ListDischarges     = uicontrol(gcf,'Style','listbox','Position',[60 30 150 130],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.PushAddDischarge    = uicontrol(gcf,'Style','pushbutton','String','Add','Position',   [490 140 70 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteDischarge = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[490 115 70 20],'Tag','UIControl');
handles.GUIHandles.PushChangeDischarge = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[490  90 70 20],'Tag','UIControl');
handles.GUIHandles.PushSelectDischarge = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[490  65 70 20],'Tag','UIControl');

handles.GUIHandles.PushOpenDischarges   = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[630 140 60 20],'Tag','UIControl');
handles.GUIHandles.PushSaveDischarges   = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[700 140 60 20],'Tag','UIControl');
handles.GUIHandles.TextSrcFile       = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).SrcFile],'Position',[770 137 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextLocations       = uicontrol(gcf,'Style','text','String','Locations','Position',[575 136 50 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushOpenData   = uicontrol(gcf,'Style','pushbutton','String','Open',   'Position',[630 115 60 20],'Tag','UIControl');
handles.GUIHandles.PushSaveData   = uicontrol(gcf,'Style','pushbutton','String','Save',   'Position',[700 115 60 20],'Tag','UIControl');
handles.GUIHandles.TextDisFile    = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).DisFile],'Position',[770 112 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextData       = uicontrol(gcf,'Style','text','String','Data','Position',[575 111 50 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushEditData      = uicontrol(gcf,'Style','pushbutton','String','Edit Data','Position',   [490 30 70 20],'Tag','UIControl');

set(handles.GUIHandles.ListDischarges,'CallBack',{@ListDischarges_CallBack});
set(handles.GUIHandles.ListDischarges,'BusyAction','Cancel');
set(handles.GUIHandles.PushAddDischarge,'CallBack',{@PushAddDischarge_CallBack});
set(handles.GUIHandles.PushDeleteDischarge,'CallBack',{@PushDeleteDischarge_CallBack});
set(handles.GUIHandles.PushChangeDischarge,'CallBack',{@PushChangeDischarge_CallBack});
set(handles.GUIHandles.PushSelectDischarge,'CallBack',{@PushSelectDischarge_CallBack});
set(handles.GUIHandles.PushOpenDischarges,'CallBack',{@PushOpenDischarges_CallBack});
set(handles.GUIHandles.PushSaveDischarges,'CallBack',{@PushSaveDischarges_CallBack});
set(handles.GUIHandles.PushOpenData,  'CallBack',{@PushOpenData_CallBack});
set(handles.GUIHandles.PushSaveData,  'CallBack',{@PushSaveData_CallBack});
set(handles.GUIHandles.PushEditData,     'CallBack',{@PushEditData_CallBack});
set(handles.GUIHandles.EditSrcM,     'CallBack',{@EditSrcM_CallBack});
set(handles.GUIHandles.EditSrcN,     'CallBack',{@EditSrcN_CallBack});
set(handles.GUIHandles.EditSrcK,     'CallBack',{@EditSrcK_CallBack});
set(handles.GUIHandles.EditSrcName,  'CallBack',{@EditSrcName_CallBack});
set(handles.GUIHandles.EditSrcMOut,  'CallBack',{@EditSrcMOut_CallBack});
set(handles.GUIHandles.EditSrcNOut,  'CallBack',{@EditSrcNOut_CallBack});
set(handles.GUIHandles.EditSrcKOut,  'CallBack',{@EditSrcKOut_CallBack});

set(handles.GUIHandles.ToggleLinear, 'CallBack',{@ToggleLinear_CallBack});
set(handles.GUIHandles.ToggleBlock,  'CallBack',{@ToggleBlock_CallBack});

set(handles.GUIHandles.SelectType,  'CallBack',{@SelectType_CallBack});

handles.GUIData.DeleteSelectedDischarge=0;

set(handles.GUIHandles.PushChangeDischarge,'Enable','off');

if handles.GUIData.ActiveDischarge>handles.Model(md).Input(ad).NrDischarges
    handles.GUIData.ActiveDischarge=handles.Model(md).Input(ad).NrDischarges;
end

setHandles(handles);

if handles.Model(md).Input(ad).NrDischarges>0
    ddb_plotFlowAttributes(handles,'Discharges','activate',ad,0,handles.GUIData.ActiveDischarge);
end

SetUIBackgroundColors;

RefreshDischarges(handles);

%%
function ListDischarges_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIData.ActiveDischarge=get(hObject,'Value');
RefreshDischarges(handles);
handles.GUIData.DeleteSelectedDischarge=1;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Discharges','activate',ad,0,handles.GUIData.ActiveDischarge);

%%
function EditSrcM_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).M=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedDischarge=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Discharges','plot',ad,n,n);

%%
function EditSrcN_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).N=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedDischarge=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Discharges','plot',ad,n,n);

%%
function EditSrcK_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).K=str2double(get(hObject,'String'));
handles.GUIData.DeleteSelectedDischarge=0;
setHandles(handles);

%%
function EditSrcName_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).Name=get(hObject,'String');
for k=1:handles.Model(md).Input(ad).NrDischarges
    str{k}=handles.Model(md).Input(ad).Discharges(k).Name;
end
set(handles.GUIHandles.ListDischarges,'String',str);
handles.GUIData.DeleteSelectedDischarge=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'Discharges','plot',ad,n,n);

%%
function EditSrcMOut_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).Mout=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditSrcNOut_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).Nout=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditSrcKOut_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).Kout=str2double(get(hObject,'String'));
setHandles(handles);

%%
function ToggleLinear_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(handles.GUIHandles.ListDischarges,'Value');
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleBlock,'Value',0);
    handles.Model(md).Input(ad).Discharges(ii).Interpolation='linear';
end
setHandles(handles);

%%
function ToggleBlock_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(handles.GUIHandles.ListDischarges,'Value');
k=get(hObject,'Value');
if k==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleLinear,'Value',0);
    handles.Model(md).Input(ad).Discharges(ii).Interpolation='block';
end
setHandles(handles);

%%
function SelectType_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
str=get(hObject,'String');
n=get(handles.GUIHandles.ListDischarges,'Value');
handles.Model(md).Input(ad).Discharges(n).Type=str{ii};
RefreshDischarges(handles);
setHandles(handles);

%%
function PushOpenDischarges_CallBack(hObject,eventdata)
handles=getHandles;
id=ad;
[filename, pathname, filterindex] = uigetfile('*.src', 'Select Sources File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(id).SrcFile=filename;
    handles.Model(md).Input(id).Discharges=[];
    handles=ddb_readSrcFile(handles,id);
    handles.GUIData.ActiveDischarge=1;
    handles.GUIData.DeleteSelectedDischarge=0;
    RefreshDischarges(handles);
    set(handles.GUIHandles.TextSrcFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedDischarge=0;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'Discharges','plot',id,0,1);
end

%%
function PushSaveDischarges_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.src', 'Select Sources File',handles.Model(md).Input(ad).SrcFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).SrcFile=filename;
    ddb_saveSrcFile(handles,ad);
    set(handles.GUIHandles.TextSrcFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedDischarge=0;
    setHandles(handles);
end

%%
function PushOpenData_CallBack(hObject,eventdata)
handles=getHandles;
id=ad;
[filename, pathname, filterindex] = uigetfile('*.dis', 'Select Discharge File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(id).DisFile=filename;
    handles=ddb_readDisFile(handles,id);
    RefreshDischarges(handles);
    set(handles.GUIHandles.TextDisFile,'String',['File : ' filename]);
    setHandles(handles);
end

%%
function PushSaveData_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.dis', 'Select Discharge File',handles.Model(md).Input(ad).DisFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).DisFile=filename;
    ddb_saveDisFile(handles,ad);
    set(handles.GUIHandles.TextDisFile,'String',['File : ' filename]);
    handles.GUIData.DeleteSelectedDischarge=0;
    setHandles(handles);
end

%%
function PushSelectDischarge_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedDischarge=0;
handles.Mode='s';
set(gcf, 'windowbuttondownfcn',   {@SelectDischarge});
setHandles(handles);

%%
function PushChangeDischarge_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedDischarge=0;
handles.Mode='c';
set(gcf, 'windowbuttondownfcn',   {@SelectDischarge});
setHandles(handles);

%%
function PushAddDischarge_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.GUIData.DeleteSelectedDischarge=0;
xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
setHandles(handles);
ClickPoint('cell','Grid',xg,yg,'Callback',@AddDischarge,'multiple');

%%
function PushDeleteDischarge_CallBack(hObject,eventdata)

ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.GUIData.DeleteSelectedDischarge==1 && handles.Model(md).Input(ad).NrDischarges>0
    handles=DeleteDischarge(handles);
    setHandles(handles);
end
xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
ddb_deleteDelft3DFLOWObject(ad,'Discharge',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveDischarge=ii;
set(handles.GUIHandles.ListDischarges,'Value',ii);
handles=DeleteDischarge(handles);
setHandles(handles);

%%
function PushEditData_CallBack(hObject,eventdata)

handles=getHandles;
ddb_editD3DDischargeData(handles.GUIData.ActiveDischarge);

%%
function AddDischarge(m,n)

handles=getHandles;
if ~isnan(m) && m>0 && n>0
    id=ad;
    nr=handles.Model(md).Input(id).NrDischarges+1;
    handles.Model(md).Input(id).NrDischarges=nr;
    handles=ddb_initializeDischarge(handles,id,nr);
    handles.Model(md).Input(id).Discharges(nr).M=m;
    handles.Model(md).Input(id).Discharges(nr).N=n;
    xz=0.25*(handles.Model(md).Input(id).GridX(m,n)+handles.Model(md).Input(id).GridX(m,n-1)+handles.Model(md).Input(id).GridX(m-1,n)+handles.Model(md).Input(id).GridX(m-1,n-1));
    yz=0.25*(handles.Model(md).Input(id).GridY(m,n)+handles.Model(md).Input(id).GridY(m,n-1)+handles.Model(md).Input(id).GridY(m-1,n)+handles.Model(md).Input(id).GridY(m-1,n-1));
    handles.Model(md).Input(id).Discharges(nr).x=xz;
    handles.Model(md).Input(id).Discharges(nr).y=yz;
    handles.Model(md).Input(id).Discharges(nr).Name=[num2str(m) ',' num2str(n)];
    handles.GUIData.ActiveDischarge=nr;
    setHandles(handles);
    ddb_plotFlowAttributes(handles,'Discharges','plot',ad,nr,nr);
end
RefreshDischarges(handles);
setHandles(handles);

%%
function SelectDischarge(hObject,eventdata)

handles=getHandles;
if strcmp(get(gco,'Tag'),'Discharge')
    id=ad;
    ud=get(gco,'UserData');
    handles.GUIData.ActiveDischarge=ud(2);
    RefreshDischarges(handles);
    setHandles(handles);
    if handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'Discharges','activate',ad,0,handles.GUIData.ActiveDischarge);
        xg=handles.Model(md).Input(ad).GridX;
        yg=handles.Model(md).Input(ad).GridY;
        set(gcf, 'windowbuttondownfcn',   {@ClickPoint,@AddDischarge,'cell',xg,yg});
    elseif handles.Mode=='s'
        ddb_plotFlowAttributes(handles,'Discharges','activate',ad,0,handles.GUIData.ActiveDischarge);
    elseif handles.Mode=='d'
        ddb_plotFlowAttributes(handles,'Discharges','plot',ad,0,handles.GUIData.ActiveDischarge);
    end
end
setHandles(handles);

%%
function handles=DeleteDischarge(handles)

id=ad;
nrobs=handles.Model(md).Input(id).NrDischarges;

iac0=handles.GUIData.ActiveDischarge;
iacnew=handles.GUIData.ActiveDischarge;
if iacnew==nrobs
    iacnew=nrobs-1;
end
ddb_plotFlowAttributes(handles,'Discharges','delete',id,handles.GUIData.ActiveDischarge,iacnew);

if nrobs>1
    for j=iac0:nrobs-1
        handles.Model(md).Input(id).Discharges(j).M=handles.Model(md).Input(id).Discharges(j+1).M;
        handles.Model(md).Input(id).Discharges(j).N=handles.Model(md).Input(id).Discharges(j+1).N;
        handles.Model(md).Input(id).Discharges(j).Name=handles.Model(md).Input(id).Discharges(j+1).Name;
    end
    handles.Model(md).Input(id).Discharges=handles.Model(md).Input(id).Discharges(1:end-1);
else
    handles.Model(md).Input(id).Discharges=[];
end
handles.Model(md).Input(id).NrDischarges=handles.Model(md).Input(id).NrDischarges-1;
if handles.Model(md).Input(id).NrDischarges>0
    if handles.GUIData.ActiveDischarge==handles.Model(md).Input(id).NrDischarges+1
        handles.GUIData.ActiveDischarge=handles.GUIData.ActiveDischarge-1;
    end
end
RefreshDischarges(handles);

%%
function RefreshDischarges(handles)

id=ad;
nr=handles.Model(md).Input(id).NrDischarges;
n=max(handles.GUIData.ActiveDischarge,1);

if nr>0
    set(handles.GUIHandles.ListDischarges,'Value',n);
    for k=1:nr
        str{k}=handles.Model(md).Input(id).Discharges(k).Name;
    end
    set(handles.GUIHandles.ListDischarges,'String',str);
    set(handles.GUIHandles.EditSrcName,'String',handles.Model(md).Input(id).Discharges(n).Name);
    set(handles.GUIHandles.EditSrcM,'String',handles.Model(md).Input(id).Discharges(n).M);
    set(handles.GUIHandles.EditSrcN,'String',handles.Model(md).Input(id).Discharges(n).N);
    set(handles.GUIHandles.EditSrcK,'String',handles.Model(md).Input(id).Discharges(n).K);
    set(handles.GUIHandles.EditSrcName,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditSrcM,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditSrcN,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditSrcK,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextName,'Enable','on');
    set(handles.GUIHandles.TextM,   'Enable','on');
    set(handles.GUIHandles.TextN,   'Enable','on');
    set(handles.GUIHandles.TextK,   'Enable','on');
    set(handles.GUIHandles.TextInterp, 'Enable','on');
    if strcmpi(handles.Model(md).Input(id).Discharges(n).Interpolation,'linear')
        set(handles.GUIHandles.ToggleLinear, 'Value',1);
        set(handles.GUIHandles.ToggleBlock,  'Value',0);
    else
        set(handles.GUIHandles.ToggleLinear, 'Value',0);
        set(handles.GUIHandles.ToggleBlock,  'Value',1);
    end
    set(handles.GUIHandles.ToggleLinear, 'Enable','on');
    set(handles.GUIHandles.ToggleBlock,  'Enable','on');
    set(handles.GUIHandles.TextType,   'Enable','on');
    set(handles.GUIHandles.SelectType,   'Enable','on');
    str=get(handles.GUIHandles.SelectType,'String');
    ii=strmatch(lower(handles.Model(md).Input(id).Discharges(n).Type),lower(str),'exact');
    set(handles.GUIHandles.SelectType,'Value',ii);
    set(handles.GUIHandles.PushSaveDischarges,   'Enable','on');
    set(handles.GUIHandles.PushOpenData,       'Enable','on');
    set(handles.GUIHandles.PushSaveData,       'Enable','on');
    if strcmpi(handles.Model(md).Input(id).Discharges(n).Type,'in-out')
        set(handles.GUIHandles.EditSrcMOut,'String',handles.Model(md).Input(id).Discharges(n).Mout);
        set(handles.GUIHandles.EditSrcNOut,'String',handles.Model(md).Input(id).Discharges(n).Nout);
        set(handles.GUIHandles.EditSrcKOut,'String',handles.Model(md).Input(id).Discharges(n).Kout);
        set(handles.GUIHandles.EditSrcMOut,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.EditSrcNOut,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.EditSrcKOut,'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.GUIHandles.TextMOut,   'Enable','on');
        set(handles.GUIHandles.TextNOut,   'Enable','on');
        set(handles.GUIHandles.TextKOut,   'Enable','on');
        set(handles.GUIHandles.TextOutlet,   'Enable','on');
    else
        set(handles.GUIHandles.EditSrcMOut,'String',[]);
        set(handles.GUIHandles.EditSrcNOut,'String',[]);
        set(handles.GUIHandles.EditSrcKOut,'String',[]);
        set(handles.GUIHandles.EditSrcMOut,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.EditSrcNOut,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.EditSrcKOut,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.TextMOut,   'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.TextNOut,   'Enable','off');
        set(handles.GUIHandles.TextKOut,   'Enable','off');
        set(handles.GUIHandles.TextOutlet, 'Enable','off');
    end
else
    set(handles.GUIHandles.EditSrcName,'String','');
    set(handles.GUIHandles.EditSrcName,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditSrcM,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditSrcN,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditSrcK,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextName,'Enable','off');
    set(handles.GUIHandles.TextM,   'Enable','off');
    set(handles.GUIHandles.TextN,   'Enable','off');
    set(handles.GUIHandles.TextK,   'Enable','off');
    set(handles.GUIHandles.TextOutlet,   'Enable','off');
    set(handles.GUIHandles.TextMOut,   'Enable','off');
    set(handles.GUIHandles.TextNOut,   'Enable','off');
    set(handles.GUIHandles.TextKOut,   'Enable','off');
    set(handles.GUIHandles.TextInterp, 'Enable','off');
    set(handles.GUIHandles.ToggleLinear, 'Enable','off');
    set(handles.GUIHandles.ToggleBlock,  'Enable','off');
    set(handles.GUIHandles.TextType,   'Enable','off');
    set(handles.GUIHandles.SelectType,   'Enable','off');
    set(handles.GUIHandles.ListDischarges,'String','');
    set(handles.GUIHandles.ListDischarges,'Value',1);
    set(handles.GUIHandles.EditSrcM,'String',[]);
    set(handles.GUIHandles.EditSrcN,'String',[]);
    set(handles.GUIHandles.EditSrcK,'String',[]);
    set(handles.GUIHandles.EditSrcMOut,'String',[],'BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditSrcNOut,'String',[],'BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.EditSrcKOut,'String',[],'BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.PushSaveDischarges, 'Enable','off');
    set(handles.GUIHandles.PushSaveData,       'Enable','off');
    set(handles.GUIHandles.PushOpenData,       'Enable','off');
end

