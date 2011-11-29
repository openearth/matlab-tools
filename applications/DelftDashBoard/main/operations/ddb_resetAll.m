function ddb_resetAll
%DDB_RESETALL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_resetAll
%
%   Input:

%
%
%
%
%   Example
%   ddb_resetAll
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
handles=getHandles;

% Delete new axes that is sometimes created for no apparent reason. Another
% fix for this should be found!!!
h=findobj(gcf,'Type','axes');
for i=1:length(h)
    if isempty(get(h(i),'Tag'));
        delete(h(i));
    end
end

if handles.debugMode
    
    h=findobj(gcf,'Tag','UIControl');
    if ~isempty(h)
        delete(h);
    end
    
    % Temporarily set map panel as child of current figure
    set(handles.GUIHandles.mapPanel,'Parent',gcf);
    
    iac=handles.Model(md).GUI.elements(1).activeTabNr;
    tbname=handles.Model(md).GUI.elements(1).tabs(iac).tabname;
    
    % Delete tab panels
    for i=1:length(handles.Model)
        try
            delete(handles.Model(i).GUI.elements(1).handle);
        end
    end
    
    % Read model xml files
    for i=1:length(handles.Model)
        handles=ddb_readModelXML(handles,i);
    end
    
    % Read toolbox xml files
    for i=1:length(handles.Toolbox)
        handles=ddb_readToolboxXML(handles,i);
    end
    
    for i=1:length(handles.Model)
        elements=handles.Model(i).GUI.elements;
        if ~isempty(elements)
            elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles);
            set(elements(1).handle,'Visible','off');
            handles.Model(i).GUI.elements=elements;
        end
    end
    
    handles=ddb_addToolboxElements(handles);
    
    setHandles(handles);
    
    ddb_resize;
    
    ddb_selectModel(handles.Model(md).name,tbname,'runcallback',0);
    
end

handles=getHandles;

for i=1:length(handles.Model)
    try
        feval(handles.Model(i).plotFcn,'delete');
    end
end

for i=1:length(handles.Toolbox)
    try
        feval(handles.Toolbox(i).plotFcn,'delete');
    end
end

ddb_initialize('all');

handles=getHandles;

% Make ModelMaker toolbox active
handles.activeToolbox.name='ModelMaker';
handles.activeToolbox.nr=1;

% Make sure that tb is updated
setHandles(handles);

% Check Model Maker in menu
c=handles.GUIHandles.Menu.Toolbox.ModelMaker;
p=get(c,'Parent');
ch=get(p,'Children');
set(ch,'Checked','off');
set(c,'Checked','on');

ddb_selectToolbox;

% % Add ModelMaker elements to model elements
% handles=ddb_addToolboxElements(handles);

% Update elements in model guis

handles=getHandles;

for i=1:length(handles.Model)
    elements=handles.Model(i).GUI.elements;
    if ~isempty(elements)
        setUIElements(elements);
    end
end

setHandles(handles);

% % Select toolbox tab
% tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);
%
% % Now select ModelMaker toolbox (Quick Mode)
% ddb_ModelMakerToolbox_quickMode;


