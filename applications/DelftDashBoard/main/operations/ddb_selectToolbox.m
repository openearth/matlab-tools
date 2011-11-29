function ddb_selectToolbox
%DDB_SELECTTOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_selectToolbox
%
%   Input:

%
%
%
%
%   Example
%   ddb_selectToolbox
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

%% This function is called to change the toolbox

handles=getHandles;

% Delete existing toolbox elements
parent=handles.Model(md).GUI.elements.tabs(1).handle;
ch=get(parent,'Children');
if ~isempty(ch)
    delete(ch);
end

% And now add the new elements
toolboxElements=handles.Toolbox(tb).GUI.elements;
handles.Model(md).GUI.elements.tabs(1).elements=toolboxElements;
handles.Model(md).GUI.elements.tabs(1).elements=addUIElements(gcf,toolboxElements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
setHandles(handles);

% Find handle of tab panel and get tab info
el=getappdata(handles.Model(md).GUI.elements.handle,'element');
el.tabs(1).elements=handles.Model(md).GUI.elements.tabs(1).elements;
setappdata(handles.Model(md).GUI.elements.handle,'element',el);

% Select toolbox tab.
tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);

% Check to see if there is a tab panel under this tab
elements=handles.Model(md).GUI.elements.tabs(1).elements;
itab=0;
for k=1:length(elements)
    if strcmpi(elements(k).style,'tabpanel')
        itab=1;
    end
end

% Set callback for the next time the toolbox tab is clicked
panel=get(handles.Model(md).GUI.elements.handle,'UserData');
callbacks=panel.callbacks;
inputArguments=panel.inputArguments;
if itab
    % Default callback
    callbacks{1}=@defaultTabCallback;
    inputArguments{1}={'tag',lower(handles.Model(md).name),'tabnr',1};
else
    callbacks{1}=handles.Toolbox(tb).callFcn;
    inputArguments{1}=[];
end
panel.callbacks=callbacks;
panel.inputArguments=inputArguments;
set(handles.Model(md).GUI.elements.handle,'UserData',panel);

% And now execute the callback
if isempty(inputArguments{1})
    feval(callbacks{1});
else
    feval(callbacks{1},inputArguments{1});
end

