function handles = ddb_addToolboxElements(handles)
%DDB_ADDTOOLBOXELEMENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_addToolboxElements(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_addToolboxElements
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Adds GUI elements to toolbox tab

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

% % Find parent (the toolbox tab of the active model), and delete all
% % children
% parent=findobj(gcf,'Tag',[lower(handles.Model(md).name) '.toolbox']);
% ch=get(parent,'Children');
% delete(ch);
% %drawnow;
%
% h=findobj(gcf,'Tag','UIControl');
% if ~isempty(h)
%     delete(h);
% %    drawnow;
% end
%
% if handles.Toolbox(tb).useXML
%
%     % And now add the elements
%     elements=handles.Toolbox(tb).GUI.elements;
%     if ~isempty(elements)
%         elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
% %        drawnow;
%         handles.Toolbox(tb).GUI.elements=elements;
%     end
%
% end

