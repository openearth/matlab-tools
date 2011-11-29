function ddb_editD3DFlowOperations
%DDB_EDITD3DFLOWOPERATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowOperations
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowOperations
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

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

uipanel('Title','Discharges','Units','pixels','Position',[50 20 900 150],'Tag','UIControl');

handles.GUIHandles.PushOpenSrc = uicontrol(gcf,'Style','pushbutton','String','Open Source File','Position',[60 120 130 20],'Tag','UIControl');
handles.GUIHandles.TextSrcFile = uicontrol(gcf,'Style','text',      'String',['File : ' handles.Model(md).Input(ad).SrcFile],'Position',[200 117  200 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.PushSaveSrc = uicontrol(gcf,'Style','pushbutton','String','Save Source File','Position',[60  95 130 20],'Tag','UIControl');

set(handles.PushOpenSrc,   'Callback',{@PushOpenSrc_Callback});
set(handles.PushSaveSrc,   'Callback',{@PushSaveSrc_Callback});

if handles.Model(md).Input(ad).NrDischarges>0
    ddb_plotFlowAttributes(handles,'Discharge','activate',ad,handles.GUIData.ActiveDischarge);
end

%handles=Refresh(handles);

SetUIBackgroundColors;

setHandles(handles);

%%
function PushOpenSrc_Callback(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.Model(md).Input(ad).GrdFile)
    [filename, pathname, filterindex] = uigetfile('*.src', 'Select source file');
    if ~pathname==0
        handles.Model(md).Input(ad).SrcFile=filename;
        handles=ddb_readSrcFile(handles,ad);
        set(handles.TextSrcFile,'String',['File : ' handles.Model(md).Input(ad).SrcFile]);
        setHandles(handles);
        %        PlotFlowDischarges(handles,ad);
    end
else
    GiveWarning('Warning','First load a grid file');
end

%%
function PushSaveSrc_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.src', 'Select Source File',handles.Model(md).Input(ad).SrcFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).SrcFile=filename;
    ddb_saveSrcFile(handles,ad);
    set(handles.TextSrcFile,'String',['File : ' filename]);
    %    handles.GUIData.DeleteSelectedThinDam=0;
    setHandles(handles);
end

