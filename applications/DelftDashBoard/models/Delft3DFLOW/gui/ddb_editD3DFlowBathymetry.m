function ddb_editD3DFlowBathymetry
%DDB_EDITD3DFLOWBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowBathymetry
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowBathymetry
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
ddb_refreshScreen('Domain','Bathymetry');
handles=getHandles;

handles.GUIHandles.ToggleFile    = uicontrol(gcf,'Style','radiobutton', 'String','File',                    'Position',[70 120 100 20],'Tag','UIControl');
handles.GUIHandles.ToggleUniform = uicontrol(gcf,'Style','radiobutton', 'String','Uniform',                 'Position',[70  90 100 20],'Tag','UIControl');
handles.GUIHandles.PushOpenDepth = uicontrol(gcf,'Style','pushbutton','String','Open Depth File',            'Position',[150 120 130 20],'Tag','UIControl');
handles.GUIHandles.TextDepthFile = uicontrol(gcf,'Style','text',      'String',['File : ' handles.Model(md).Input(ad).DepFile],'Position',[290 117  200 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditUniformDepth = uicontrol(gcf,'Style','edit',      'String',num2str(handles.Model(md).Input(ad).UniformDepth),'Position',[150  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextUniformDepth = uicontrol(gcf,'Style','text',      'String','m below reference level','Position',[205  86  200 20],'HorizontalAlignment','left','Tag','UIControl');

if ~isempty(handles.Model(md).Input(ad).DepFile)
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    set(handles.GUIHandles.ToggleFile,'Value',1);
else
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleFile,'Value',0);
end

set(handles.GUIHandles.ToggleFile,      'CallBack',{@ToggleFile_CallBack});
set(handles.GUIHandles.PushOpenDepth,   'CallBack',{@PushOpenDepth_CallBack});
set(handles.GUIHandles.ToggleUniform,   'CallBack',{@ToggleUniform_CallBack});
set(handles.GUIHandles.EditUniformDepth,'CallBack',{@EditUniformDepth_CallBack});

handles=Refresh(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function ToggleFile_CallBack(hObject,eventdata)
handles=getHandles;
set(handles.GUIHandles.ToggleUniform,'Value',0);
set(handles.GUIHandles.ToggleFile,'Value',1);
handles=Refresh(handles);
setHandles(handles);

%%
function PushOpenDepth_CallBack(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.Model(md).Input(ad).GrdFile)
    [filename, pathname, filterindex] = uigetfile('*.dep', 'Select depth file');
    if ~pathname==0
        handles.Model(md).Input(ad).DepFile=[pathname filename];
        dp=ddb_wldep('read',handles.Model(md).Input(ad).DepFile,[handles.Model(md).Input(ad).MMax,handles.Model(md).Input(ad).NMax]);
        %        dp=max(dp,-10);
        handles.Model(md).Input(ad).Depth=-dp(1:end-1,1:end-1);
        %        handles.Model(md).Input(ad).Depth=handles.Model(md).Input(ad).Depth';
        handles.Model(md).Input(ad).Depth(handles.Model(md).Input(ad).Depth==999.999)=NaN;
        handles.Model(md).Input(ad).DepthZ=GetDepthZ(handles.Model(md).Input(ad).Depth,handles.Model(md).Input(ad).DpsOpt);
        set(handles.GUIHandles.TextDepthFile,'String',['File : ' handles.Model(md).Input(ad).DepFile]);
        setHandles(handles);
        ddb_plotFlowBathymetry(handles,'plot',ad);
    end
else
    GiveWarning('Warning','First load a grid file');
end

%%
function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
set(handles.GUIHandles.ToggleUniform,'Value',1);
set(handles.GUIHandles.ToggleFile,'Value',0);
handles=Refresh(handles);
setHandles(handles);

%%
function handles=Refresh(handles)

if get(handles.GUIHandles.ToggleUniform,'Value')==1
    set(handles.GUIHandles.PushOpenDepth,'Enable','off');
    set(handles.GUIHandles.TextDepthFile,'Enable','off');
    set(handles.GUIHandles.EditUniformDepth,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextUniformDepth,'Enable','on');
else
    set(handles.GUIHandles.PushOpenDepth,'Enable','on');
    set(handles.GUIHandles.TextDepthFile,'Enable','on');
    set(handles.GUIHandles.EditUniformDepth,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextUniformDepth,'Enable','off');
end

