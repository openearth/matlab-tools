function ddb_selectToolbox
%DDB_SELECTTOOLBOX  This function is called to change the toolbox in Delft
%Dashboard
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_selectToolbox

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

handles=getHandles;

%% Delete existing toolbox elements
parent=handles.Model(md).GUI.element(1).element.tab(1).tab.handle;
ch=get(parent,'Children');
if ~isempty(ch)
    delete(ch);
end

%% And now add the new elements
toolboxelements=handles.Toolbox(tb).GUI.element;

% Check if toolbox has tabs
% If so, find tabs that are model specific
if length(toolboxelements)==1
    if strcmpi(toolboxelements(1).element.style,'tabpanel')
        toolboxelements0=toolboxelements;
        toolboxelements0.element.tab=[];
        ntabs=0;
        for itab=1:length(toolboxelements(1).element.tab)
            iadd=0;
            if isempty(toolboxelements(1).element.tab(itab).tab.formodel)
                % Tab added to all models
                iadd=1;
            else
                if isstruct(toolboxelements(1).element.tab(itab).tab.formodel)
                    % Multiple models get this tab
                    for im=1:length(toolboxelements(1).element.tab(itab).tab.formodel)
                        if strcmpi(toolboxelements(1).element.tab(itab).tab.formodel(im).formodel,handles.Model(md).name)
                            iadd=1;
                        end
                    end
                else
                    % Only one model gets this tab
                    if strcmpi(toolboxelements(1).element.tab(itab).tab.formodel,handles.Model(md).name)
                        iadd=1;
                    end
                end
            end
            if iadd
                % Tab specific to active model                
                ntabs=ntabs+1;
                toolboxelements0(1).element.tab(ntabs).tab=toolboxelements(1).element.tab(itab).tab;
            end           
        end
        toolboxelements=toolboxelements0;
    end
end

% Add elements to GUI
handles.Model(md).GUI.element(1).element.tab(1).tab.element=gui_addElements(gcf,toolboxelements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
setHandles(handles);

drawnow;

% Find handle of tab panel and get tab info
el=getappdata(handles.Model(md).GUI.element(1).element.handle,'element');
el.tab(1).tab.element=handles.Model(md).GUI.element(1).element.tab(1).tab.element;

% Set callback to tab
el.tab(1).tab.callback=handles.Toolbox(tb).callFcn;
setappdata(handles.Model(md).GUI.element(1).element.handle,'element',el);

% And finally select the toolbox tab
tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox');
