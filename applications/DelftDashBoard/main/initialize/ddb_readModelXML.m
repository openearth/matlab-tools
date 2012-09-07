function handles = ddb_readModelXML(handles, j)
%DDB_READMODELXML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readModelXML(handles, j)
%
%   Input:
%   handles =
%   j       =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readModelXML
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

%%
fname=[handles.Model(j).name '.xml'];

xmldir= handles.Model(j).xmlDir;

if exist([xmldir fname],'file')
    
    handles.Model(j).useXML=1;
    
    xml=gui_readXMLfile(fname,xmldir,'variableprefix','Model(md).Input(ad)');
    
    handles.Model(j).longName=xml.longname;    
    handles.Model(j).supportsMultipleDomains=xml.multipledomains;    
    handles.Model(j).enable=xml.enable;
    handles.Model(j).element=xml.element;
    
end

handles.Model(j).GUI.element=xml.element;

%% Menu File
if isfield(xml.menu.menu,'menuopenfile')
    for i=1:length(xml.menu.menu.menuopenfile.menuopenfile.menuitem)
        handles.Model(j).GUI.menu.openFile(i).string=xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.string;
        handles.Model(j).GUI.menu.openFile(i).callback=str2func(xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.callback);
        handles.Model(j).GUI.menu.openFile(i).option=xml.menu.menu.menuopenfile.menuopenfile.menuitem(i).menuitem.option;
    end
else
    handles.Model(j).GUI.menu.openFile=[];
end

if isfield(xml.menu.menu,'menusavefile')
    for i=1:length(xml.menu.menu.menusavefile.menusavefile.menuitem)
        handles.Model(j).GUI.menu.saveFile(i).string=xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.string;
        handles.Model(j).GUI.menu.saveFile(i).callback=str2func(xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.callback);
        handles.Model(j).GUI.menu.saveFile(i).option=xml.menu.menu.menusavefile.menusavefile.menuitem(i).menuitem.option;
    end
else
    handles.Model(j).GUI.menu.saveFile=[];
end


